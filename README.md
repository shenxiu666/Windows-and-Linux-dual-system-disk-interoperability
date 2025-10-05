# Windows-and-Linux-dual-system-disk-interoperability
通过在Linux中挂载NTFS分区实现
# 双系统共享分区配置

在安装双系统之前或在现有系统下，按以下步骤设置文件共享分区：

## 1. 分区规划
在安装双系统之前或在现有系统下通过分区工具调整，留出一块未分配的硬盘空间用于文件共享。

- 在 **Windows** 系统中，右键点击“此电脑”选择“管理”，进入“磁盘管理”，右键点击未分配空间进行分区操作。

## 2. 格式化为 NTFS
将留出的分区格式化为 NTFS 文件系统。

- 在 **Windows** 中，分区过程中可直接选择 NTFS 格式。
- 在 **Linux** 中，使用“磁盘”实用工具，选择要分区的磁盘，点击“+”号创建新分区，设置分区大小并选择“NTFS”作为文件系统。

## 3. 在 Linux 中挂载 NTFS 分区
Linux 系统通常会自动识别 NTFS 分区，若需手动挂载，可执行以下操作：

1. 创建挂载点：

    ```bash
    sudo mkdir /mnt/Data
    ```

2. 使用命令挂载 NTFS 分区：

    ```bash
    sudo mount -t ntfs-3g /dev/sdXY /mnt/Data
    ```

   其中 `/dev/sdXY` 为 NTFS 分区的设备名，可通过 `sudo blkid` 或 `sudo fdisk -l` 命令查看。

## 4. 设置自动挂载
为实现开机自动挂载，需编辑 `/etc/fstab` 文件。

1. 备份原始文件：

    ```bash
    sudo cp /etc/fstab /etc/fstab.bak
    ```

2. 使用文本编辑器打开 `/etc/fstab` 文件：

    ```bash
    sudo nano /etc/fstab
    ```

3. 在文件末尾添加一行配置：

    ```
    UUID=你的NTFS分区UUID /mnt/Data ntfs-3g defaults,windows_names,locale=zh_CN.utf8,uid=1000,gid=1000,umask=0022 0 0
    ```

   - `UUID` 可通过 `sudo blkid` 获取。
   - `/mnt/Data` 为挂载点。
   - `uid=1000,gid=1000` 用于设置用户权限。
   - `umask=0022` 设置新建文件的默认权限。

4. 保存并关闭文件后，执行以下命令测试挂载是否成功：

    ```bash
    sudo mount -a
    ```

## 5. 关闭 Windows 快速启动功能
在 Windows 的电源选项中，禁用“快速启动”功能，避免 Linux 挂载 NTFS 分区时出现只读或无法挂载的问题。

### 操作步骤：
1. 进入“控制面板 -> 电源选项 -> 选择电源按钮的功能 -> 更改当前不可用的设置”。
2. 取消勾选“启用快速启动”。
