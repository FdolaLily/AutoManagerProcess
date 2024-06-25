第一次使用，需要用管理员启动命令行，执行以下两个命令，需要自行改exe路径 以放在D:\test为例

sc create "AutoKillACE" binpath="D:\test\AutoManagerProcess.exe" start=auto

sc start "AutoKillACE"



后续如果有更新发现无法替换exe，需要先停止服务才能替换exe，用管理员启动命令行执行以下命令即可

sc stop "AutoKillACE"

替换后，执行以下命令打开

sc start "AutoKillACE"



如果需要删除该程序，同样用管理员运行命令行，然后执行以下两个命令

sc stop "AutoKillACE"

sc delete "AutoKillACE"

最后删除文件即可



进阶说明：这个服务可以在dnf启动时附带启动其他程序（如网易云/外置连发）
会自动判断是否已经启动 不用担心启动多个

找到同目录下的appsettings.json文件，修改AutoStart字段，注意只修改[]里的内容，不要动[]

以同时启动网易云和连发为例子

我们假设网易云路径是 C:\网易云\cloudmusic.exe

连发路径是 D:\连发\DNFAutoFire.exe

我们只需要把 AutoStart 那行改成

"AutoStart" : [ "C:\\网易云\\cloudmusic.exe", "D:\\连发\\DNFAutoFire.exe" ]

注意两个路径之间用逗号分割 如果只有一个程序 则后面不需要逗号

还有就是将原本路径中的\改成\\
