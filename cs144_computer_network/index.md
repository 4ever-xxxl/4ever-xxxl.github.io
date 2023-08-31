# CS144_Lab 笔记 (updating)

很早就听闻 CS144 Lab 的大名, 但是由于各种原因一直没有上手实践. 直到最近才开始着手实践, 本文将记录我在实践过程中的一些笔记.
<!--more-->

由于本次实验和博客是并行进行的, 所以已经编辑公开的部分也可能会出现部分差错以及可能导致的多次修改. 

我的仓库在 [4ever-xxxl/CS144-Computer-Network](https://github.com/4ever-xxxl/CS144-Computer-Network) .

## 环境搭建

本次环境基于官方镜像 VirtualBox 搭建, 镜像文件以及搭建教程可以在 [这里](https://stanford.edu/class/cs144/vm_howto/vm-howto-image.html) 找到. VirtualBox 启动后照常配置, 使用 Vscode 远程连接到虚拟机, Vscode 中配置插件 `C/C++` `GitLens`, 之后的实验都在 Vscode 中进行. 

运行 [setup_dev_env.sh](https://web.stanford.edu/class/cs144/vm_howto/setup_dev_env.sh) 配置实验所需环境. 之后 git clone 仓库, 我使用的仓库是 [PKUFlyingPig/CS144-Computer-Network](https://github.com/PKUFlyingPig/CS144-Computer-Network) , 再按照 README.md 配置即可.

这里有个坑就是由于缺失了 \<array\> \<stdexcept\> 两个文件头导致执行 `make` 时会报错, 需要在对应文件手动补上. \(我也不是很理解为什么三年前的高星仓库 clone 下来不能直接用. 
![error](./img/error.png)


## Lab_0

### Writing webget

编写 get_URL 函数简略实现应用层 HTTP 请求响应的功能, 即使用 socket 向指定 IP 和 Path 发送 GET 请求并获取响应.
```Cpp
void get_URL(const string &host, const string &path) {
    TCPSocket sock{};
    sock.connect(Address(host,"http"));
    sock.write("GET "+path+" HTTP/1.1\r\n");
    sock.write("Host: "+host+"\r\n");
    sock.write("Connection: close\r\n\r\n");
    while (!sock.eof()) {
        cout<<sock.read();
    }
    sock.close();
}
```

这里同样有个坑就是如果主机开了代理并且开了 TUN 模式, 那么 `sock.shutdown(SHUT_WR);` 会导致异常退出. 具体原因还不是很清楚.

### An in-memory reliable byte stream

编写一个循环字节流类, 需要向 `_buffeer` 中写入和读取数据, 其中读取部分分成了两步, 先复制再弹出. 代码如下 

byte\_stream.hh
```Cpp
#include <deque>
class ByteStream {
  private:
    size_t _capacity = 0;
    size_t _read_count = 0;
    size_t _write_count = 0;
    std::deque<char> _buffer = {};
    bool _eof = false;
    bool _error = false;
    // ...
}
```

byte\_stream.cc
```Cpp
ByteStream::ByteStream(const size_t capacity) : _capacity(capacity) {}

size_t ByteStream::write(const string &data) {
    size_t len = std::min(data.length(), remaining_capacity());
    for (size_t i = 0; i < len; i++) {
        _buffer.emplace_back(data[i]);
    }
    _write_count += len;
    return len;
}

string ByteStream::peek_output(const size_t len) const {
    size_t peekLen = std::min(len, buffer_size());
    return string().assign(_buffer.begin(), _buffer.begin() + peekLen);
}

void ByteStream::pop_output(const size_t len) {
    size_t popLen = std::min(len, buffer_size());
    for (size_t i = 0; i < popLen; i++) {
        _buffer.pop_front();
    }
    _read_count += popLen;
}

std::string ByteStream::read(const size_t len) {
    std::string readStream = ByteStream::peek_output(len);
    ByteStream::pop_output(len);
    return readStream;
}

void ByteStream::end_input() { _eof = true; }

bool ByteStream::input_ended() const { return _eof; }

size_t ByteStream::buffer_size() const { return _buffer.size(); }

bool ByteStream::buffer_empty() const { return _buffer.size() == 0; }

bool ByteStream::eof() const { return buffer_empty() && input_ended(); }

size_t ByteStream::bytes_written() const { return _write_count; }

size_t ByteStream::bytes_read() const { return _read_count; }

size_t ByteStream::remaining_capacity() const { return _capacity - buffer_size(); }
```


## Lab_1

### stream_reassembler

编写一个流重组器, 用于将乱序的数据流重组成有序的数据流. 

这个 lab 的难点在于乱序数据流的合并以及数据流结尾的边界问题. 

对于乱序数据流, 我采用 deque 来进行存储, 用 `_buffer` 存储数据, `_bitmap` 存储数据是否已经被写入. 当数据流到来时, 先根据前后边界进行裁剪. 前边界为第一个未按序的字节序号, 后边界由缓冲区大小限制. 然后顺序扫一遍, 将数据写入 `_buffer` 未存储的位置, 即 `_bitmap` 为 `false` 的位置, 并将其置真. 最后顺序检查 `_bitmap` , 将已经按序的头部数据弹出并写入 `_output` 中. 

这里的实现并没有采用 set 等树型数据结构, 而是在双端队列中顺序存储. 虽然实现简单, 但是时间复杂度是 $O(n)$ 的, 理论上部分环节是可以达到 $O(\log n)$ 的, 留个坑等后面再改进吧. 

然后是数据流结尾的边界问题, 只有当数据流结尾到来并且都能被写入时, 才能记录下 `_eof` 信号, 否则会导致数据流结尾的数据丢失. 这时结尾前可能仍然是乱序状态, 因此需要等待所有乱序数据排列完并写入后才能将 `_output` 关闭. 

`check_lab1` 的运行时间在 0.75~0.85s 左右. 

stream\_reassembler.hh
```Cpp
class StreamReassembler {
  private:
    // Your code here -- add private members as necessary.
    std::deque<char> _buffer = {};
    std::deque<bool> _bitmap = {};
    size_t _first_unassembled_idx = 0;
    size_t _unassembled_bytes_num = 0;
    bool _eof = false;
    ByteStream _output;  //!< The reassembled in-order byte stream
    size_t _capacity;    //!< The maximum number of bytes
// ...
}
```

stream\_reassembler.cc
```Cpp
StreamReassembler::StreamReassembler(const size_t capacity)
    : _buffer(capacity, '\0'), _bitmap(capacity, false), _output(capacity), _capacity(capacity) {}

void StreamReassembler::push_substring(const string &data, const size_t index, const bool eof) {
    if (eof && _first_unassembled_idx + _capacity - _output.buffer_size() >= index + data.length()) {
        _eof = true;
    }
    size_t front_boundary = std::max(index, _first_unassembled_idx);
    size_t back_boundary = std::min(index + data.length(), _first_unassembled_idx + _capacity - _output.buffer_size());
    for (size_t i = front_boundary; i < back_boundary; i++) {
        if (_bitmap[i - _first_unassembled_idx]) {
            continue;
        }
        _buffer[i - _first_unassembled_idx] = data[i - index];
        _bitmap[i - _first_unassembled_idx] = true;
        _unassembled_bytes_num++;
    }
    std::string _str = "";
    while (_bitmap.front()) {
        _str += _buffer.front();
        _buffer.pop_front();
        _bitmap.pop_front();
        _buffer.push_back('\0');
        _bitmap.push_back(false);
    }
    _output.write(_str);
    _first_unassembled_idx += _str.length();
    _unassembled_bytes_num -= _str.length();
    if (_eof && empty()) {
        _output.end_input();
    }
}

size_t StreamReassembler::unassembled_bytes() const { return _unassembled_bytes_num; }

bool StreamReassembler::empty() const { return unassembled_bytes() == 0; }

size_t StreamReassembler::ack_idx() const { return _first_unassembled_idx; }

bool StreamReassembler::input_ended() const { return _eof && empty(); }
```


## Lab_2

### wrapping\_integers

编写一个包装整数类, 用于实现序列号的加减法. 实现 `WrappingInt32` 和 `uint64_t` 两个类之间的转换函数. 

这里的实现很简单, 对于绝对序列号转化成序列号, 只需要加上基准偏移量 `isn` 即可, 同时由于序列号自动取模了, 因此不需要其他操作. 

对于序列号转化成绝对序列号, 想要找到离 `checkpoint` 最近的绝对序列号. 首先注意到有以下式子成立:
$$
\begin{aligned}
\text{checkpoint} &= \text{n} - \text{isn} + k * 2^{32} + \text{remainder}\\
\end{aligned}
$$

其中 `k` 为任意整数, `remainder` 为余数. 通过比较 `2 * remainder` 和 `1 << 32` 的大小, 就可以决定应该靠近哪一边. 计算绝对序列号时应该取 `k` 还是 `k+1`. 

但是这里有个坑, 就是当 `checkpoint < remainder` 时, 会导致算出的值小于 0, 但是我们绝对序列号的类型是 `uint64_t`, 因此会导致溢出. 所以这种情况应该单独处理. 

wrapping\_integers.cc
```Cpp
WrappingInt32 wrap(uint64_t n, WrappingInt32 isn) { return isn + uint32_t(n); }

uint64_t unwrap(WrappingInt32 n, WrappingInt32 isn, uint64_t checkpoint) {
    uint64_t res = uint64_t(n - isn);
    uint64_t RING = 1ul << 32;
    if (res >= checkpoint) {
        uint64_t k = (res - checkpoint) / RING;
        uint64_t Mod = (res - checkpoint) % RING;
        if (2ul * Mod > RING && checkpoint >= Mod) {
            res -= (k + 1ul) * RING;
        } else {
            res -= k * RING;
        }
    } else {
        uint64_t k = (checkpoint - res) / RING;
        uint64_t Mod = (checkpoint - res) % RING;
        if (2ul * Mod > RING) {
            res += (k + 1ul) * RING;
        } else {
            res += k * RING;
        }
    }
    return res;
}
```

### tcp_receiver


***
> Wait for next lab...
