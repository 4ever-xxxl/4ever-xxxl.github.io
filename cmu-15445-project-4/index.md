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

### Update && Delete Executor

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


// UNFINISHED

---


## Task #4 - Primary Key Index

## Bonus Task 1: Abort

## Bonus Task #2 - Serializable Verification

## Leaderboard

## Conclusion
