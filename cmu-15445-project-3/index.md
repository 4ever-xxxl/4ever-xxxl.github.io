# CMU 15445 Project 3


<!--more-->

## Foreword

~~过完年摆着摆着就开学了, 再不努力加进度就寄了.~~

照例先放 Leader-Board, 截止 2024/02/28 排名第 2: (其中 Q1 和 Q3 都是单榜第一)

{{< figure src="./img/leaderboard.png" caption="`figure-1` LeaderBoard">}}

在这一章我们从存储器和索引继续往上走, 进入了 SQL 的执行和优化环节. 建议反复看下面这张图理解整个流程:

{{< figure src="./img/project-structure.svg" caption="`figure-2` ProjectStructure">}}

这一章来说实现并不复杂 (好像也没有哪一关比较复杂的, 也许是已经被删掉的 B+ Tree), 主要的难点在于与前面两章完全解耦. 需要从头阅读源码, 理清 `Executor` `ExecutorContext` `PlanNode` 之间的关系, 以及如何与之前的实现联立的. 做这个项目时最好能自己画一下结构图便于理解.

## Task #1 - Access Method Executors

### SeqScan
通过 `TableInfo` 拿到 `table_iter_` 来遍历表中的元组. 需要处理 `is_deleted_` 和 `filer` 两个条件.

### Insert, Delete ＆ Update
这三个的处理逻辑类似, 都是通过 `PlanNode` 得到要操作的和新的 `tuple`, 然后调用 `table_` 中的函数来更新, 同时记得更新 `Index`.

### IndexScan
需要进行一次强制转换
```cpp
dynamic_cast<HashTableIndexForTwoIntegerColumn *>(index_info_->index_.get())
```
然后调用函数遍历即可.

### SeqScan -> IndexScan

当 `SeqScan` 的 `Filter` 条件是形如 `#1 = const_value` 并且有包含 `#1` 列的索引时, 可以将其优化为 `IndexScan`.
{{< figure src="./img/seq2index.png" caption="`figure-3` Seq -> Index">}}

## Task #2 - Aggregation & Join Executors

### Aggregation

对 `GroupBys` 和 `Aggregates` 分别进行处理得到 key 和 value, 然后添加进 `HashTable` 中. 添加时需要根据 `AggregationType` 对表中的值进行更新. 如果没有进行分组, 那么添加完之后要再加入一个 `InitialAggregateValue` 来统计整个表的值.

### NestedLoopJoin

采用遍历的方法得到两个表的连接. 首先保存左表的所有元组, 然后遍历左表中的元组, 执行 `EvaluateJoin` 匹配右表中的元组, 如果匹配成功则输出新的元组, 如果没有且 `JoinType` 是 `LEFT` 则输出 将左表中的元组和通过 `GetNullValueByType` 得到的元组进行连接输出.

## Task #3 - HashJoin Executor and Optimization

### HashJoin

仿照 `NestedLoopJoin` 的实现, 构造自己的 `HashTable`. 需要实现的有 `HashJoinKey` 的类定义, 比较函数和 `Hash` 模板, 以及 `HashJoinValue` 的类定义.

其中 `HashJoinKey` 保存的是元组中用于连接的列的值, `HashJoinValue` 保存的是元组的所有值.
```cpp
std::unordered_map<HashJoinKey, std::vector<HashJoinValue>> ht_;
```

在这里为了便于处理两种连接类型, 我选择将所有的右表的元组都存入 `HashTable` 中, 然后遍历左表的元组, 通过 `HashTable` 得到右表中的元组, 然后进行连接. 具体处理类似于 `NestedLoopJoin`.

### NLJ -> HashJoin

如果 `NestedLoopJoin` 的所有 `JoinPredicate` 都是 `#1 = #2` 的形式, 那么可以优化为 `HashJoin`.

{{< figure src="./img/nlj2hashjoin.png" caption="`figure-4` NLJ -> HashJoin">}}

具体处理时, 我们需要递归地遍历 `JoinPredicate` 的左右子树. 这里为了便于实现只处理了 `LogicExpression` 为 `AND` 的情况, 这种情况下递归调用左右子树. 如果 `expr` 是 ` ComparisonExpression` 并且是 `#1 = #2` 的形式, 那么就可以将两边的列分发保存. 这里需要注意 `#1` 和 `#2` 的顺序.

## Task #4: Sort + Limit Executors + Window Functions + Top-N Optimization

### Sort ＆ Limit
最简单的一集.

### Top-N
堆排序取前 N 项即可, 既可以用优先队列, 也可以使用 `std::push_heap` 等来实现.

### Sort ＆ Limit -> Top-N
{{< figure src="./img/sortlimit2topn.png" caption="`figure-5` Sort ＆ Limit -> TopN">}}

### Window Functions
最难绷的一集, 感觉基础任务的所有难度都在这个点的繁琐上了. 

- 首先根据是否有 `order_by` 来进行排序.
- 然后根据 `partition_by` 来分组. 这里扫一遍产生每个组的全局数据, 如果是 Rank 似乎需要单独写处理的逻辑.
- 再扫一遍根据 `window_type` 来进行处理.
- 收集所有的 `Value` 矩阵, 生成 `Tuple` 输出.

真的很繁琐, 不是很喜欢这个任务, 感觉各个部分的细节都很奇怪.

到这里就完成了所有的任务, 接下来就是优化了.

---

## Leaderboard Optimization

### Q1 WindowFunc -> TopNPerGroup
```sql
SELECT x, y FROM (
  SELECT x, y, rank() OVER (partition by x order by y) as rank
  FROM t1
) WHERE rank <= 3;
```

主要优化部分如下:
{{< figure src="./img/q1.png" caption="`figure-6` WindowFunc -> TopNPerGroup">}}

优化在于 `WindowFunc` 中的 `Rank` 函数在后续结点被清除, 那么只需要进行排序分组操作, 然后取前 N 项即可. 也就是针对这一小种情况, 将其优化为 `TopNPerGroup`.

说实话我依然不是很喜欢这个和 `WindowFunc` 相关的任务, 感觉优化太刻意了, 自己写出来的优化几乎没有什么通用性.

TopNPerGroup 的实现则是维护一个 `HashTable`, `key` 是 `partition_by` 的值, `value` 是一个保存元组所有值的 `vector` 的堆, 从而可以得到每个组的前 N 项.

### Q2 ReorderJoin & PredicatePushDown

```sql
SELECT * FROM t4, t5, t6
  WHERE (t4.x = t5.x) AND (t5.y = t6.y) AND (t4.y >= 1000000)
    AND (t4.y < 1500000) AND (t6.x >= 100000) AND (t6.x < 150000);
```
{{< figure src="./img/q2.png" caption="`figure-7` ReorderJoin & PredicatePushDown">}}

首先是 `ReorderJoin`. 递归的计算 `NLJ` 两侧表的总大小:
 - Scan 结点通过 `EstimatedCardinality` 估算表的大小.
 - NLJ 结点则计算两者之和
 - Values, Limit, TopN 结点的大小为限制大小
 - 其余结点的大小为子结点的大小

然后根据大小进行排序, 从而得到最优的连接顺序. 记得递归分发 `JoinPredicate` 中的条件.

---

然后是 `PredicatePushDown`. 将 `Filter` 条件尽量下推到靠近源点, 从而减少中间计算量. 这里主要处理 `NLJ` 的情况.

- 递归处理 `NLJ` 的 `predicate_` 树, 要求必须是 `AND` 结构. 对于形如 `#1.x = #2.x` 的条件保留, 其余条件下推到左右子树. 通过 `And` 逻辑拼接.
- 得到新的 `predicate_` 之后, 将各自的 `Filter` 条件与子结点合并. 如果子结点是 `NLJ` 则需要使用 `RewriteExpressionForJoin` 来重写条件; 否则新建一个 `Filter` 结点.

### Q3 ConstantFolding & ColumnPruning
```sql
SELECT v, d1, d2 FROM (
  SELECT v,
         MAX(v1) AS d1, MIN(v1), MAX(v2), MIN(v2),
         MAX(v1) + MIN(v1), MAX(v2) + MIN(v2),
         MAX(v1) + MAX(v1) + MAX(v2) AS d2
    FROM t7 LEFT JOIN (SELECT v4 FROM t8 WHERE 1 == 2) ON v < v4
    GROUP BY v
)
```
{{< figure src="./img/q3.png" caption="`figure-8` ConstantFolding & ColumnPruning">}}

首先是 `ConstantFolding`. 递归处理 `Expression` 树, 将所有的常量表达式计算出来, 然后替换原来的表达式. 如果得到最后的值是常量
 - 若为真, 则用子结点替换;
 - 若为假, 则替换为空的 `Value` 结点.

此时还可以对 `Join` 优化, 如果右表是空的, 则直接返回左表.

然后是 `ColumnPruning`. 对于 `Projection` 结点, 分别处理子结点为 `Projection` 和 `Aggregation` 的情况.

- 对于 `Projection` 结点, 用父节点对子结点修剪, 然后用子结点替换父节点.
- 对于 `Aggregation` 结点, 用 `Projection` 中出现的列检查 `Aggregation` 中是否出现, 若没有则删除. 同时检查是否存在冗余, 若存在则删除.

(以上的删除均指重写相关部分得到新结点再替换, 而不是直接操作原结点.)

## Conclusion

收获很大喵~, 最大的收获应该是初步了解了优化过程, 同时锻炼了自己阅读源码的能力.
