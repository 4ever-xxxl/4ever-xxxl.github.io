# CMU 15445 Project4


<!--more-->


终于写完了, 截至 2024/03/10 完成了四个项目的基础 100 分, 以及前三个项目的 Leaderboard. 

最近一直在忙着大三下的课程学习以及保研的准备 (给个学上吧, 求求了我什么都能做的), 博客搁置了蛮久. 纯 🕊 了 咕咕咕, 所以博客内容可能相对之前几期较简略, 请读者见谅喵.

## Foreword

照例先放 Leader-Board, 截止 2024/03/10 排名第 8:

{{< figure src="./img/leaderboard.png" caption="`figure-1` LeaderBoard">}}

个人感觉 LeaderBoard 还什么优化都没做, 希望有空了再请教一下大佬们.

这一个 Project 前后时间跨度非常大, 刚开始写是在 03/01, 写完过了两周开始 bonus task. 拿到 120% 后过了三周才抽出时间来写这篇博客. 

这一章开始进入事务的领域, 开始真正接触到并发 (~~重构~~) 的魅力

## Task #1 - Timestamps

每个事务开始时会有一个读时间戳, 读时间戳是最近提交事务的时间戳. 水印 `watermark` 是最低的读时间戳.

这里实现很简单, 只是需要注意以下 `watermark` 的更新写法, 我个人这里使用了以下两个数据结构用来辅助:

```cpp
  std::list<timestamp_t> read_list_;
  std::unordered_map<timestamp_t, std::list<timestamp_t>::iterator> read_list_iter_;
```

## Task #2 - Storage Format and Sequential Scan

### Tuple Reconstruction

维护一个 `vector<Value>`, 遍历 `undo_logs` 逐步更新即可, 注意一下判空, 空数据以及 `schema` 的构造, 可能需要用到 `Schema::CopySchema`, `ValueFactory::GetNullValueByType` 等函数. 

### Sequential Scan / Tuple Retrieval

这里需要重构 `SeqScan` 的遍历方式, 对于每一个 `tuple`:
1. 如果该元组的 `ts_` 小于等于事务的读取时间戳, 或者等于事务的事务时间戳 ( 即已被当前事务修改过, 堆上是最新的版本 ), 则直接读取堆上的元组数据.
2. 否则需要遍历 `undo_logs`, 从最新的版本遍历到小于等于读取时间戳, 才算能够恢复出该元组. 然后使用之前的方法恢复, 再进行后续处理.

## Task #3 - MVCC Executors

### Insert Executor

这里码量很小, 按照要求即可, 更新元组时间戳, 加入到 `write_set` 中.

### Commit

提交事务时, 需要先获取新的 `commit_ts_`, 遍历 `write_set`, 将元组的时间戳更新为事务的提交时间戳, 最后提交.

### Update & Delete Executor

首先是 `Write-Writes Conflict`, 如果元组的时间戳大于事务读取时间戳且不等于事务时间戳, 则说明已被其他事务修改过. 这里发生了一个写写冲突, 需要将事务标记为 `Tainted`, 然后抛出一个异常.

若未发生写写冲突, 进入更新逻辑, 这俩处理类似, 都是更新数据 + 更新 `undo_log`, 为了便于后面的 `GC`, 我们这里需要将是否已被当前事务修改过分别处理.
根据元组的时间戳和当前事务时间戳判断是否已被修改过:
1. 若是, 则需要新建一个合并 `undolog` 的函数来合并已修改的操作, 并使用新的 `undo_log` 更新 `version_link`.
2. 若否, 则直接新建一个 `undo_log` 并更新 `version_link`.

其中, 合并 `undo_log` 时需要注意老的修改日志具有更高的优先级.

### Garbage Collection

这里可能的做法和写法还是有挺多的, 仅介绍个人做法.

遍历每一个元组的 `version_link`, 维护一个 `std::unordered_map<txn_id_t, uint32_t> garbage_cnt` 来记录每个事务可撤销的 `undo_log` 数量. 需要特殊处理仅有一个版本且小于水印的情况.

然后遍历 `txn_map_`, 如果事务已提交或已中止, 判断事务的 `undo_log` 数量是否和可以撤销的数量相等, 若相等则可以回收该事务的 `undo_log`.

## Task #4 - Primary Key Index

### Index Scan

与 `SeqScan` 类似.

### Insert, Delete & Update

由于我 `git` 是按 `task` 提交的, 所以这里的重构我直接按照加入更新主键后的逻辑来说了.

**Insert** 如果存在 `primary_index`, 先对表进行 `ScanKey`:
- 如果不存在主键或查找后不存在元组则直接进行之前的插入逻辑;
- 否则需要检查是否仅有一个且被标记删除, 若是则使用更新逻辑, 否则抛出异常.

**Delete** 逻辑较为简单, 直接标记删除即可.

**Update** 首先在 `Init` 阶段做检查, 是否对主键作了更新, 若是则需要将更新逻辑拆分为删除 + 插入.

### Concurrent

这一部分使用 `in_progress_` 来获取对元组的锁, 具体逻辑如下:

1. 检查写写冲突, 若发生则抛出异常.
2. 原子自旋, 不断读取 `old_version_link` 直到 `in_progress_` 为 `false`.
3. 带检查修改, 若成功则成功获取锁, 否则转 1.
4. 再次检查写写冲突, 执行后续操作, 最后释放锁.

## Bonus Task 1: Abort

又双叒叕要重构, 有点难绷的.

使用的第二种实现方法. 对于已经设置 `tainted` 的事务, 需要在 `Abort` 时将其 `write_set` 中的元组恢复, 依然是使用 `undolog` 的逻辑. 同时将之前的修改获取 `in_progress_` 锁的逻辑换成获取表的锁 (显然这样锁的粒度变大了, 效率降低了不少). 

需要注意的是之前获取锁的逻辑可能会有 `txn_map_mutex_` 和 表锁的冲突, 可能需要调整加锁顺序.

## Bonus Task #2 - Serializable Verification

在 `seqscan` 和 `indexscan` 中 统计 `ScanPredicate` 获取事务读取的元组.

在事务提交时进行序列化检查:
1. 遍历 `txn_map_`, 找到所有在 `txn` 之后开始但是先提交的事务
2. 获取它们的修改元组集合, 恢复出元组, 然后开始检查是否和当前事务读取的元组有交集, 若有则返回 `false` 转中止事务逻辑.

## Leaderboard

抽空看了一下论文但是没有啥明确的思路, 加上最近比较忙就搁置了, 以后有时间再看看吧.

## Conclusion

这一章的 `MVCC` 还是让我学到了很多的, 尤其是并发的处理和 `Debug`, 真的很难调试, 容易让人红温. 整个 `Bustub` 到这里也就结束了, 算是激发了我对 `Database` 的浓厚兴趣, 也不知研究生阶段会不会继续深入这个领域. ~~没书读了, 给个学上吧.~~

最后, 感谢 `CMU 15445` 的老师和助教们的辛勤付出.
