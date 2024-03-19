# CMU 15445 Project 2


<!--more-->

## Foreword

这两天从~~清水河~~\)臭水河的 526 回到了连个服务器都得试 N 次的老家, 感觉进度又慢了不少. 先放 LeaderBoard 结果吧, 截止 2024/02/05 排名第 3:

{{< figure src="./img/leaderboard.png" caption="`figure-1` LeaderBoard">}}

## Task #1 - Read/Write Page Guards

实现对 page 的 RAII 保护, 实现还是蛮简单的. 主要是有几个坑点:

- 因为要同时保留手动传入和手动释放的接口, 所以锁的获取和保留并不是在构造和析构时完成的. 而是传入指针前获取, 析构时调用 Drop 释放.

- 注意对指针相同和为空的特殊判断.

## Task #2 - Extendible Hash Table Pages

这几个按照注释翻译即可, 只讲下遇到的坑点了.

### header

header 表用于对 hash 的 MSB 进行索引, 定位到对应的 directory. 其采用静态的结构是便于对并发的控制.

首先解决一个函数签名的格式问题:

```diff
-   auto GetDirectoryPageId(uint32_t directory_idx) const -> uint32_t;
+   auto GetDirectoryPageId(uint32_t directory_idx) const -> page_id_t;
```

以及获取 MSB 时如果 max_depth_ 为 0, uint32_t >> 32 是 ub 行为 (在 clang 中会返回自身而非 0). 所以还需要进行一次特判.
```cpp
hash >> (HTABLE_HEADER_PAGE_METADATA_SIZE * 8 - max_depth_);
```

### directory

directory 中 global_depth_, local_depth_ 的设计是整个 extendiblehash 的精髓. 通过这两个变量的设计, 可以实现动态的扩容和收缩.

global_depth_ 变化时记得对 bucket 进行复制或初始化操作.

### bucket

bucket 只作为存储和查找的容器, 实现比较简单. 只需要注意每个元素是唯一的, 插入前需要进行检查.

## Task #3 - Extendible Hashing Implementation

GetValue 和 不特殊处理的 Insert, Remove 都是直接调用对应的 page 的函数即可. 下面主要讲一下特殊处理的步骤.

### Insert

当 Insert 时如果只因为 bucket 满了而需要分裂时, 需要进行以下步骤:

1. 如果 local_depth_ < global_depth_, 若否转 7.
2. 初始化分裂出的 bucket
3. local_depth_ + 1
4. 重新分配 directory, 将 msb 取反对应的 bucket_idx 指向新的 bucket.
5. 对原来 bucket 中的所有 key 用新的 local_depth_ 重新分配到两个 bucket 中.
6. 尝试插入 key. 成功则返回, 否则转 1.
7. 如果 global_depth_ < max_depth_, 则进行全局分裂. 成功转 1; 否则返回失败.

### Remove

当 remove 后如果 bucket 为空而可能需要合并时, 需要进行以下步骤:

1. 首先检查 global_depth_ 是否为 0, 即不存在 merge_bucket. 将该 bucket 设置为 INVALID_PAGE_ID 后删除即可返回.
2. 开始循环, 如果 bucket 和 merge_buckt 页面不同且 local_depth 相同, 则进行合并操作.
3. 遍历 directory, 将指向 bucket 的指针指向 merge_bucket, 减少 local_depth_.
4. 删除 bucket.
5. 检查是否可以收缩 global_depth_

    a) 是: 收缩. 遍历 directory, 检查是否仍然有为空的 bucket, 有则以其为收缩点转 2.

    b) 否: 检查 merge_bucket 是否为空, 是则转2.

如果还是失败的话可以用 `LOG_DEBUG` 来输出一些信息, 方便调试. 同时可以试试下面的测试用例:

```cpp
TEST(ExtendibleHTableTest, DebugTest) {
  auto disk_mgr = std::make_unique<DiskManagerUnlimitedMemory>();
  auto bpm = std::make_unique<BufferPoolManager>(3, disk_mgr.get());
  DiskExtendibleHashTable<int, int, IntComparator> ht("debug_test", bpm.get(), IntComparator(), HashFunction<int>(), 9,
                                                      9, 255);
  for (int i = 1; i <= 5; i++) {
    ht.Insert(i, i);
  }
  std::vector<int> remove_order{1, 1, 5, 5, 3, 4};
  for (auto i : remove_order) {
    ht.Remove(i);
  }
  ht.VerifyIntegrity();
}
```

---
这里简短地说一下并发的实现吧, 由于已经使用了 page_guard, 所以只需要保证 insert 和 remove 两个事务操作不对同一块操作打断就行. 目前看下来效果来看, 直接一把大锁反而是效果最好的, 如果细化 directory 的锁, 会提升 write 性能, 但是频繁地锁操作反而导致 read 性能大幅下降. 所以最终还是选择了大锁.

事务区别 `Transaction *transaction` 并没有用上, 以后有空再补上这一块吧.

## Conclusion

后面看了之前 2023-Spring 的实验, 从 B+ 树到 Extendible Hashing 的难度确实下降了不少.

这次 lab 最大的收获就是调试技术的提升, 尤其是对于不太方便内存挨个查看的过程. 然后便是对 `LOG_DEBUG` 的应用, 可以方便地帮我复现短过程的 gradescope 测试失败样例.
