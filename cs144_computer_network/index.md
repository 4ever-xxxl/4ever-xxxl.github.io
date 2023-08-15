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

waiting.
