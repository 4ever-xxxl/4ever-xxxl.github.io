# RankVote_重要节点组挖掘


<!--more-->
<!-- # RankVote_重要节点组挖掘 -->



这是我本学期数据结构课的项目作业（最简单的一次作业，其他的写的太烂了，没脸放）。

首先就把我交上去的实验报告贴上来吧，懒得再写一次了。

-------------------------------------------------------------手动分割线--------------------------------------------------------------

## 1.实验内容简介

分别根据以度为标准和以 Vote Rank 算法为标准选出两组重要节点组，然后用 SIR 模型评测传染规模来比较两种挖掘方案。

## 2.算法说明

### 2.1. 根据度挖掘

直观的看，贪心地选出前 num 个初始传输结点。

### 2.2. Vote Rank挖掘

通过投票选举的策略，在选出某一个结点之后，降低周围结点的投票能力，在一定程度上避免选出的初始节点出现扎堆的情况。从而尽可能地分散初始节点，使得传播的尽可能地广。

### 2.3. SIR传染模型

用于测试上面两种方案的传播能力。设立感染，未感染，痊愈三种类别。通过初始结点开始进行传播，直到所有结点感染或者清零结束，通过比较感染过的节点数量比对两种初始结点选取方案的传播能力。

## 3.算法分析与设计

### 3.1. 根据度挖掘

贪心的选择前 num 大的度的结点即可，这里不必进行排序算法，而是利用 nth_element 函数采用了类似于快速排序单次移位 partation 的思想。

```c++
nth_element(a.begin(), a.begin() + num, a.end(), cmp);
```

其中时间复杂度为 O(N)

### 3.2. Vote Rank挖掘

原始思想的过程如下：

```markdown
1.初始化每个结点的分数为0，投票能力为1
2.遍历图，每个结点的分数为直接相连结点的投票能力之和
3.找出分数最高的结点 P，将 P 加入初始结点选集中
4.修改 P 的分数和投票能力为0，削弱 P 直接相连的结点，幅度为度的期望的倒数
5.重复 2-4 步，直至选出 num 个结点
```

而后考虑到每一次对选出结点和相邻结点投票能力的改变，只会影响 P 的二环和三环结点，并不会影响整个图的分数。所以只需要对二环投票能力和分数，三环的分数进行相应的修改即可。同时初始分数可以直接简化为改点邻接表的大小，而不必重复计算。

算法过程优化如下：

```markdown
1.初始化每个结点的分数为该节点的度，投票能力为1
2.找出分数最高的结点 P，将 P 加入初始结点选集中
3.修改 P 的分数和投票能力为0
4.削弱 P 直接相连的结点，削弱与该结点直接相连的点的分数，幅度为度的期望的倒数
5.重复 2-4 步，直至选出 num 个结点
```

从效果来看，Vote Rank 算法避免了大量度值比较大的结点扎堆的情况，而是尽量地使选取的结点尽可能分布地广，从而使得传播范围扩大。

然后若所有结点的投票能力都下降为 0 会导致选不出分数最大的结点，因此当每次选出的最大分数结点的分数为 0 时，随机选择一个未加入过的结点作为初始结点。

### 3.3. SIR 传播模型

通过设置结点为 S, I ,R 三种类别，其中 S 表示已传染的结点，在每一轮传染中，都有 beta 的概率传染和它直接相连的 I 类型结点，然后该 S 结点变为 R 类型的已痊愈结点。

算法过程如下：

```c++
1.将初始传播结点入队列
2.取队首结点弹出并设为 R 类型结点
3.遍历与它直接相连的 I 类型结点，每一个以 beta 的概率被传染为 S
4.第三步中被传染的结点加入队列中
5.重复 2-4 步直至队列为空，统计所有被传染过的结点的数量，即规模
```

该算法较为简化的模拟了结点的传播过程，可以作为两种挖掘方式的一种评测手段。

其中，直观上来看，Vote Rank 算法是对度算法的优化版本，选出的结点分布更为广泛，理应对传播规模有一定显式程度的提升。

## 4.测试分析与结果

测试用例为

|      | USAir.txt | router.txt | sex.txt | network.txt |
| ---- | --------- | ---------- | ------- | ----------- |
| 点数 | 332       | 5022       | 16730   | 36692       |
| 边数 | 2126      | 6258       | 50632   | 367662      |

具体内容见 [## 6.附录与源代码](##6.附录与源代码) ，以及附录文件
测试时，选择不同的感染率 beta 和不同的初始传播结点数 num，然后运行 500 次取平均值，计算 Vote Rank的提升幅度



首先是在选取初始传播结点数不同情况下，提升幅度的数据表

其中 beta 设置为 5*averageK/averageK2：五倍度的期望除以度的平方的期望

| 数据文件名  |  0.01  |  0.1   |  0.2   |  0.3   |  0.5  |  0.7  |
| ----------- | :----: | :----: | :----: | :----: | :---: | :---: |
| USAir.txt   | -0.01% | 5.24%  | 11.95% | 15.39% | 7.73% | 2.71% |
| router.txt  | 1.70%  | 7.20%  | 6.18%  | 4.29%  | 1.27% | 0.35% |
| sex.txt     | 3.54%  | 12.51% | 14.19% | 13.10% | 5.32% | 2.64% |
| network.txt | 4.79%  | 16.22% | 12.89% | 9.95%  | 3.40% | 1.61% |



然后在确定初始传播结点数为总结点数的 0.2 情况下，改变 beta 前面的系数的数据表

| 数据文件名  |  0.1  |  1.2   |  2.0   |  3.0   |  5.0   |  10.0  |
| :---------: | :---: | :----: | :----: | :----: | :----: | :----: |
|  USAir.txt  | 1.62% | 12.57% | 15.60% | 14.78% | 12.72% | 5.84%  |
| router.txt  | 0.58% | 4.36%  | 5.60%  | 6.31%  | 6.27%  | 2.97%  |
|   sex.txt   | 0.72% | 6.64%  | 9.37%  | 11.82% | 14.01% | 13.67% |
| network.txt | 0.40% | 4.38%  | 6.74%  | 9.21%  | 12.89% | 17.08% |



由于相对图结构的感染率水平受稀疏稠密图影响较大，以下为 0.2 选取率下不同绝对感染率的数据表

| 数据文件名  | 0.001 | 0.01  |   0.1   |  0.3   |  0.5  |  0.8  |
| :---------: | :---: | :---: | :-----: | :----: | :---: | :---: |
|  USAir.txt  | 0.80% | 6.02% | 13.01%  | 4.24%  | 2.05% | 0.48% |
| router.txt  | 0.07% | 0.73% |  4.68%  | 6.49%  | 5.32% | 2.23% |
|   sex.txt   | 0.39% | 3.35% | 14.57%  | 10.80% | 6.11% | 2.46% |
| network.txt | 1.10% | 8.78% | 15.638% | 6.90%  | 4.84% | 4.06% |

## 5.分析与研讨

从测试结果中我们可以发现，当初始传播节点数目增加时，传播规模的提升度先上升再下降。当感染率增加时，提升度同样先上升再下降。

这是显而易见的，当传播结点较少时，两种方案都是优先选取结点较为大的点集，并没有多少差别。当初始传播节点数量增加时，初始结点差别变大，传播规模提升度增加。但是当初始传播结点数目增加到一定规模后，又几乎选出了大部分结点，两种方案差别变小，传播规模提升度下降。

而感染率同理，感染率较低，例如为 0.001 时，几乎传播不开，提升幅度很小。感染率很大接近于 1 时，几乎传遍了整个网络，提升幅度依然很小。只有当感染率位于适当大小时，提升度才有一个显然的水平。

同时，图的结构对测试结果影响很大，依赖于点与点之间的度的差别，由于测试数据中 router.txt 较为稀疏，各点的度差别较小，导致提升率相比其他测试数据偏小。


## 6.改进方向

1.本实验中已经对 Vote Rank 算法进行了一定的优化，单次选点之后只更新一环和二环的结点，从而避免了重复遍历整个图。

2.在本次实验中，使用了 vector 进行存储，导致图的遍历的时，顺序是固定的。后续提升可以使用 undered_map 进行存储，消除数据集初始编号的影响。

3.在对单独数据找到最适合的初始传播点集和感染率可以采用模拟退火算法找到近似最优解。


## 7.附录与源代码

以下为附件目录，具体文件内容见附件

```shell
$ tree -L 2
.
|-- Makefile
|-- data
|   |-- USAir.txt
|   |-- network.txt
|   |-- result.out
|   |-- router.txt
|   `-- sex.txt
|-- output
|   `-- main.exe
`-- src
    |-- main.cpp
    `-- main.o

3 directories, 9 files
```

-------------------------------------------------------------手动分割线--------------------------------------------------------------

贴一下源码吧还是 ~~原谅我不加注释~~

```c++
#include <algorithm>
#include <ctime>
#include <iostream>
#include <numeric>
#include <queue>
#include <random>
#include <vector>
typedef long long ll;
using namespace std;
vector<int> Du, Vote;
vector<vector<int> > G;

void SelectByDu(int num);
void SelectByVote(int num);
bool cmp(int x, int y);
double Rand();
int TestSIR(vector<int> InitNode);

double f;
int n, m, u, v;
int num;              /* 选出的初始传播结点数目 */
double pjlunci = 500; /* 求平均值的轮数 */
vector<int> cntDu, cntVote;
double meanDu, meanVote, varianceDu, varianceVote;
double averageK, averageK2;
double SIRbeta, SIRalpha;

struct votenode {
  double score = 0, value = 1;
};

int main(int argc, char *argv[]) {
  srand(time(NULL));
  num = atoi(argv[2]);
  // SIRalpha = atof(argv[3]);
  SIRbeta = atof(argv[3]);
  freopen(argv[1], "r", stdin);
  freopen("data\\result.out", "w", stdout);
  cin >> n >> m;
  cout << "[+] vertices : " << n << " edges : " << m << endl;
  cout << "[+] the num of selected is " << num << endl;

  G.resize(n);
  for (int i = 0; i < m; i++) {
    cin >> u >> v;
    G[u].push_back(v), G[v].push_back(u);
  }
  averageK = 2.0 * m / n;
  f = 1.0 / averageK;

  SelectByDu(num);
  SelectByVote(num);

  for (auto &i : G) averageK2 += pow(i.size(), 2) / (double)n;

  // SIRbeta = SIRalpha * (averageK / averageK2);

  cout << "averageK = " << averageK << " averageK2 =" << averageK2 << "\n"
       << endl;
  cout << "SIRbeta = " << SIRbeta << "\n" << endl;

  for (int i = 0; i < pjlunci; i++) {
    cntDu.push_back(TestSIR(Du)), cntVote.push_back(TestSIR(Vote));
  }
  meanDu = accumulate(cntDu.begin(), cntDu.end(), 0.0) / pjlunci;
  meanVote = accumulate(cntVote.begin(), cntVote.end(), 0.0) / pjlunci;

  for (int i = 0; i < pjlunci; i++) {
    varianceDu += pow(cntDu[i] - meanDu, 2) / n;
    varianceVote += pow(cntVote[i] - meanVote, 2) / n;
  }

  cout << "[+] the mean of Du: " << meanDu
       << "    the variance of Du: " << varianceDu << endl;
  cout << "[+] the mean of Vote: " << meanVote
       << "    the variance of Vote: " << varianceVote << endl;
  cout << "rate : " << (meanVote - meanDu) / meanDu * 100 << " %" << endl;
  return 0;
}

bool cmp(int x, int y) { return G[x].size() > G[y].size(); }
double Rand() { return (double)rand() / RAND_MAX; }

// 以度为顺序选出前 num 大的节点
void SelectByDu(int num) {
  clock_t start, finish;
  start = clock();
  vector<int> a(n);
  for (int i = 0; i < n; i++) a[i] = i;
  nth_element(a.begin(), a.begin() + num, a.end(), cmp);
  cout << "[+] Select by degree of vertex" << endl;
  for (int i = 0; i < num; i++) Du.push_back(a[i]);
  sort(Du.begin(), Du.end(), cmp);
  // for (int i = 0; i < num; i++) {
  //   cout << Du[i] << " ";
  // }

  finish = clock();
  cout << endl
       << "[-] the time cost is:" << double(finish - start) / CLOCKS_PER_SEC
       << endl
       << endl;
}

void SelectByVote(int num) {
  clock_t start, finish;
  start = clock();
  vector<votenode> S(n);
  vector<int> vis(n);
  for (int i = 0; i < n; i++) {
    S[i].score = G[i].size(), S[i].value = (double)1;
  }
  while (num--) {
    double maxScore = -1;
    int p = -1;
    for (int i = 0; i < n; i++) {
      if (S[i].score > maxScore) {
        maxScore = S[i].score;
        p = i;
      }
    }

    if (maxScore == 0) {
      for (int i = 0; i < n; i++) {
        if (!vis[i]) {
          p = i;
          break;
        }
      }
    }
    vis[p] = 1;
    for (int i = 0; i < (int)G[p].size(); i++) {
      u = G[p][i];
      S[u].score -= S[p].value;
      double deltaval = S[u].value - max(S[u].value - f, (double)0);
      S[u].value = max(S[u].value - f, (double)0);
      for (int j = 0; j < (int)G[u].size(); j++) {
        v = G[u][j];
        S[v].score = max(S[v].score - deltaval, (double)0);
      }
    }
    S[p].score = S[p].value = 0;
    Vote.push_back(p);
  }

  cout << "[+] Select by vote of vertex" << endl;
  // for (int i = 0; i < (int)Vote.size(); i++) {
  //   cout << Vote[i] << " ";
  // }
  finish = clock();
  cout << endl
       << "[-] the time cost is:" << double(finish - start) / CLOCKS_PER_SEC
       << endl
       << endl;
}

int TestSIR(vector<int> InitNode) {
  vector<int> T(n, 0);
  queue<int> infected;
  for (auto &i : InitNode) {
    T[i] = 1;
    infected.push(i);
  }
  int infectedNum = InitNode.size(), infectCount = 0;
  while (!infected.empty()) {
    u = infected.front();
    infected.pop();
    T[u] = -1;
    for (int j = 0; j < (int)G[u].size(); j++) {
      v = G[u][j];
      if (T[v] == 0 && Rand() <= SIRbeta) {
        T[v] = 1;
        infected.push(v);
        infectedNum++;
      }
    }
    infectCount++;
  }
  return infectCount;
}
```

以及项目文件：[RankVote_重要节点组挖掘.zip](./RankVote_重要节点组挖掘.zip)

