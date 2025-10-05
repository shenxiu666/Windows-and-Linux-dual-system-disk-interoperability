#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 权限运行该脚本。"
    exit 1
fi

# 1. 自动识别 NTFS 分区并挂载
echo "正在识别 NTFS 分区..."
NTFS_PARTITION=$(lsblk -o NAME,FSTYPE | grep ntfs | awk '{print $1}' | head -n 1)

if [ -z "$NTFS_PARTITION" ]; then
    echo "未找到 NTFS 分区。"
    exit 1
fi

# 2. 创建挂载点
MOUNT_POINT="/mnt/Data"
if [ ! -d "$MOUNT_POINT" ]; then
    echo "正在创建挂载点: $MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"
fi

# 3. 挂载 NTFS 分区
echo "正在挂载 NTFS 分区..."
mount -t ntfs-3g /dev/"$NTFS_PARTITION" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "分区已成功挂载至 $MOUNT_POINT"
else
    echo "挂载失败，请检查系统日志。"
    exit 1
fi

# 4. 获取分区 UUID
UUID=$(blkid /dev/"$NTFS_PARTITION" -o value -s UUID)

if [ -z "$UUID" ]; then
    echo "无法获取 UUID。"
    exit 1
fi

# 5. 更新 /etc/fstab 实现开机自动挂载
echo "正在更新 /etc/fstab 文件以实现开机自动挂载..."

FSTAB_ENTRY="UUID=$UUID $MOUNT_POINT ntfs-3g defaults,windows_names,locale=zh_CN.utf8,uid=1000,gid=1000,umask=0022 0 0"

# 备份原始 /etc/fstab 文件
cp /etc/fstab /etc/fstab.bak

# 添加新的挂载配置
echo "$FSTAB_ENTRY" >> /etc/fstab

if [ $? -eq 0 ]; then
    echo "成功更新 /etc/fstab 文件。"
else
    echo "更新 /etc/fstab 失败。"
    exit 1
fi

# 6. 提示禁用 Windows 快速启动
echo "请手动禁用 Windows 快速启动功能，以确保 Linux 能正常挂载 NTFS 分区。"
echo "操作路径: 控制面板 -> 电源选项 -> 选择电源按钮的功能 -> 更改当前不可用的设置 -> 取消勾选 '启用快速启动'"

# 7. 测试挂载是否成功
mount -a

if [ $? -eq 0 ]; then
    echo "系统重启后，NTFS 分区将自动挂载。"
else
    echo "测试挂载失败，请检查系统设置。"
    exit 1
fi

echo "脚本执行完毕！"
