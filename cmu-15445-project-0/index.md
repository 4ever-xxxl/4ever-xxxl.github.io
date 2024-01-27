# CMU 15445 Project 0


<!--more-->

## 前言

寒假无所事事决定刷一下 CMU 15445 的 Project, 顺便学习一下 C++. 结果我 Project 0 就写得汗流浃背的, 直接打破了我对 C++ 的幻想. 顺便批评一下 UESTC 的 C++ 教学, 2 个学分只教了个面向对象, modern Cpp 的内容一点没有. 第一次写的时候, 智能指针看得我头大.

> 噫！『 上课耽误学习 』 诚不欺我。

基于课程要求, 本文并不包含代码实现, 也不会公开仓库. 不过欢迎读者找我交流.
{{< link "mailto:lx10ng@qq.com" "lx10ng@qq.com" >}}

## 环境配置

直接跟着 `README.md` 的步骤来就行了, 网上类似的教程也挺多, 不多说了.

我的环境是 VSCode 远程连接 `Ubuntu 22.04`, `Clang++-18`, `clangd`. 官方推荐是 `Clang++14`, 亲测除了会在 cmake 时有一句 warning 之外并无影响, 所以也就懒得改了.

## Task #1 - Copy-On-Write Trie

实现一个写时复制的前缀树 (COW Trie), 用于存储键值对和版本管理. 包括实现三个函数 `Get`, `Put` 和 `Remove`.

### Get

沿着深度向下寻找便是, 找不到或者根结点为空就返回 `nullptr`. 找到结点之后来到了 C++ 喜闻乐见的类型转换, 我们需要对这个基类的智能指针强制转换.
```cpp
auto ret = dynamic_cast<const TrieNodeWithValue<T> *>(terminal_node.get());
```
然后进行对 `ret` 进行空判断来推出 `terminal_node` 是父类还是子类, 如果是父类那么是错误查询返回空指针.

{{< admonition title="坑点">}}
对根结点为空的判断错误在这个 Get 的测试中是看不出来的, 要在后面 Put 的调试中才能发现.
{{< /admonition >}}

### Put

整个 Project 0 中最难的一部分, 难点在于对 **Copy-On-Write** 的理解, 以及对智能指针和 `std::move` 的利用.

整个流程大致如下:
1. 沿着路径向下寻找, 一边寻找一边复制路径结点直到到底或者 key 末尾时转 2 或 3;
2. 如果找完路径有剩, 说明剩下的结点都需要自己新建;
3. 如果找到已有的路径, 那么对 terminal_node 进行类型检验, 分别进行 clone&polish / new 的操作;
4. 最后返回 new_root 的 trie tree.

{{< admonition title="坑点">}}
初始时需要检验 `root_` 是否为空进行不同的初始化操作.

`T value` 的使用需要 `std::make_shared<T>(std::move(value))` 但是只能使用一次, 所以需要新建一个局部变量 `new_value` 之后使用这个传入参数, 不然过不了 clang-tidy 的检查.
{{< /admonition >}}
### Remove

写完 Put 之后这个的实现就相对简单了, 对于能找到的路径的 `terminal_node` 修改为 `TrieNode`, 然后自底向上检查. 同时满足没有孩子和不是带值结点就删除, 否则停止. 最后对根结点做一次检验, 如果是空结点那么返回空树.

{{< admonition title="坑点">}}
同样需要特殊处理 `root_`, 有为空和直接删除带值根结点两种情况.

函数已经指定了返回类型, 所以返回空树时应当写 `return {};` 而不是 `return Trie();`. 这个也是 clang-tidy 要求.
{{< /admonition >}}

## Task #2 - Concurrent Key-Value Store

对 Task1 中的实现进行并行化, 使得可以同时有多个读者和一个写者同时访问Trie.

学过操作系统的互斥和同步之后这个就很简单了, 注意临界区加锁就行, 不再赘述.

## Task #3 - Debugging

这个 Task 主要是要求对 gdb 的掌握, 打断点查看内存信息, 因为涉及到动态指针, 所以只靠默认 Debugger 是无法满足要求的.

我一开始找到内存后直接强制转换指针访问, 但是死活访问不上
```shell
(gdb) p *(TrieNodeWithValue<uint32_t>*)0x608000001130
No symbol "TrieNodeWithValue<uint32_t>" in current context.
```
无奈之下为了做出这个 Task, 我在前面的 40 行设置条件断点 `key.compare("969")==0` 可以绕过后面的智能指针得到答案.( ~~不提倡~~ )

但是这终究不是正解, 后面我在求助 ssg 和 crescentia 之后在 gdb 命令行中又重试了一遍, 发现
```shell
(gdb) p *(TrieNode*)0x608000001130
$1 = {_vptr.TrieNode = 0x5555557ce700 <vtable for bustub::TrieNodeWithValue<unsigned int>+16>, children_ = std::map with 0 elements, is_value_node_ = true}
```
原因竟是 `uint32_t` 会被宏替换为 `unsigned int`, 所以 gdb 中自然没有 `TrieNodeWithValue<uint32_t>` 这个类型. **可恶, 好坑!**

## Task #4 - SQL String Functions

这个 Task 就是对 SQL 字符串的文本处理了, 实现设计到 `std::transform` 的使用和函数的注册.

## 项目提交的坑点

1. 记得先运行 `gradescope_sign.py` 添加签名.
2. 注意代码格式问题, 我一开始不注重 `clang-tidy` 导致后面改了半天.

## 总结

通过这次一天多的 Project 0, 使我第一次面对 modern cpp 的高级特性. 这就是 c++! 太难蚌了.
