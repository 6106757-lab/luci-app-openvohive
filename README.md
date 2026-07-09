# luci-app-openvohive

Open-VoHive 的 OpenWrt / ImmortalWrt LuCI 管理插件。

## 功能

- 在 `服务 -> Open-VoHive` 管理核心安装、更新
- 自动检测设备架构（amd64/arm64/armv7），从 GitHub Release 下载对应核心
- 启动、停止、重启 Open-VoHive 服务
- 查看运行状态：版本、端口、内存、磁盘
- 查看和下载运行日志
- 基础 UCI 配置管理

## 安装
默认用户名 admin
默认密码 V0h!ve@2025rt 或者 admin123
### 方式一：手动安装（推荐）

```sh
# 安装依赖
opkg update && opkg install curl ca-bundle jsonfilter

# 复制文件
cp -r luci-app-openvohive/root/* /

# 重载 rpcd
/etc/init.d/rpcd restart

# 清除 LuCI 缓存
rm -rf /tmp/luci-*
```

### 方式二：SDK 编译 IPK

```sh
cp -r luci-app-openvohive /path/to/sdk/package/
cd /path/to/sdk
make package/luci-app-openvohive/compile V=s
```

## 目录结构

```
luci-app-openvohive/
└── root/
    ├── etc/
    │   ├── config/openvohive          # UCI 配置文件
    │   └── init.d/openvohive          # procd 服务脚本
    └── usr/
        ├── share/
        │   ├── luci/menu.d/           # LuCI 菜单定义
        │   ├── rpcd/acl.d/            # rpcd 权限
        │   └── openvohive/            # 管理脚本
        │       ├── status.sh          # 状态查询
        │       ├── service.sh         # 服务启停
        │       ├── logs.sh            # 日志读取
        │       ├── clear_logs.sh      # 日志清理
        │       ├── releases.sh        # GitHub Release 查询
        │       ├── install_core.sh    # 核心安装
        │       ├── task_start.sh      # 后台任务启动
        │       ├── task_worker.sh     # 后台任务执行
        │       ├── task_status.sh     # 任务状态查询
        │       └── task_cancel.sh     # 任务取消
        └── www/luci-static/resources/view/openvohive/
            └── index.js               # LuCI JS 视图

## 默认路径

```
/opt/openvohive/openvohive              # 二进制
/opt/openvohive/bin/version             # 版本文件
/opt/openvohive/bin/arch                # 架构文件
/opt/openvohive/config/config.yaml      # 配置文件
/opt/openvohive/data/                   # 数据目录
/opt/openvohive/logs/                   # 日志目录
/etc/config/openvohive                  # UCI 配置
```
