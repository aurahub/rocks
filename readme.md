# 关于运行脚本（sbin）

## 环境依赖

- Windows/Linux/macOS

## 安装Docker

- Windows和macOS去官网下载对应版本，官方下载[(点击跳转)](https://www.docker.com/products/docker-desktop)DockerDesktop
- Centos/RedHat: yum install -y docker
- Ubuntu/Debian: apt-get install -y docker

## 运行

- 编译: compile.bat/compile.sh
- 运行sshd环境(ssh登录，可以自定义操作)：start_sshd.bat/start_sshd.sh
- 运行server前台环境：start.bat | start.sh
- 运行server后台环境：start_daemon.bat | stat_daemon.sh
- 停止server/sshd环境：stop.bat | stop.sh
