@echo off
cd /d %~dp0
if exist DNF.exe (goto next) else (goto baddir)
:next
if exist FakeService (goto prev) else (goto fakenotfound)
:prev
echo 正在提权...
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

@echo off
color 3E
echo %username% 已获取超级管理员权限
echo.
title DNF全家桶处理专用工具箱v7.0patch4 (2024.9.12最后更新)
echo.【功能说明】
echo.禁用DNF外置TP与P2P流氓插件，节省系统资源和带宽占用，提高运行速度
echo.禁用DNF直播框＆小鸟＆我要变强＆同城交友等无用插件，不影响战斗力系统
echo.
echo.【特别提醒】
echo.1. 使用前请【确保】已经关闭DNF和WeGame；
echo.2. 清理垃圾功能已经为DNF做了针对性优化，您可以经常使用以获得最佳体验；
echo 3. 更新游戏时：需要先恢复全家桶待更新完再禁用，否则会显示文件被占用；
echo.4. 最新更新内容已整合至**清理插件**，若您第一次使用，请先执行【4.清理插件】，再执行【1.禁用全家桶】
echo.
taskkill /im CrossProxy.exe /T /F
taskkill /im TPHelper.exe /T /F
taskkill /im GameLoader.exe /T /F
taskkill /im DNF.exe /T /F
taskkill /im tgp_gamead.exe /T /F
taskkill /im TQMCenter.exe /T /F
echo.
:on
cd /d %~dp0
choice /c 123456 /m "请输入编号：(1)禁用全家桶；(2)恢复全家桶；(3)清理DNF垃圾；(4)清理捆绑插件；(5)修复黑屏连接服务器；(6)退出；"
if %errorlevel%==6 goto end
if %errorlevel%==5 goto fix
if %errorlevel%==4 goto plugin
if %errorlevel%==3 goto dnf
if %errorlevel%==2 goto restore
if %errorlevel%==1 goto disable

:disable
echo 禁用全家桶
rd /s /q components
icacls Install.dll /deny Everyone:(S,X)
icacls TP3Helper.exe /deny Everyone:(S,X)
::icacls TCLS/plugins/TPLocalDataDir/TPData /deny Everyone:(S,X)
icacls TCLS/TenProtect/TP/TPHelper/TPHelper.exe /deny Everyone:(S,X)
icacls TCLS/TenProtect/TP/TPHelper/TPWeb.exe /deny Everyone:(S,X)
icacls start/TenProtect/TenSafe.exe /deny Everyone:(S,X)
icacls start/Cross/Core/Stable/CrossProxy.exe /deny Everyone:(S,X)
::icacls TCLS/TPSvc.exe /deny Everyone:(S,X)
icacls TCLS/TenProtect/TenSafe.exe /deny Everyone:(S,X)
icacls TCLS/TenProtect/TenSafe_1.exe /deny Everyone:(S,X)
icacls TCLS/AdvertDialog.exe /deny Everyone:(S,X)
icacls TCLS/AdvertTips.exe /deny Everyone:(S,X)
icacls TCLS/BackgroundDownloader.exe /deny Everyone:(S,X)
icacls start\Cross\Apps\DNFAD\DNFADApp.dll /deny Everyone:(S,X)
icacls start\Cross\Apps\DNFAD\GameDataPlatformClient.dll /deny Everyone:(S,X)
icacls start\Cross\Apps\DNFAD\res.vfs /deny Everyone:(S,X)
icacls start\Cross\Apps\DNFTips /deny Everyone:(OI)(CI)(S,X) /setintegritylevel Level:H

rd /s/q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
cd /d %PROGRAMFILES(x86)%\Tencent
rd /s/q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
goto on

:restore
echo 恢复全家桶
icacls TP3Helper.exe /reset /c /l /q 
icacls Install.dll /reset /c /l /q 
icacls TCLS/TenProtect/TP/TPHelper/TPHelper.exe /reset /c /l /q 
icacls TCLS/TenProtect/TP/TPHelper/TPWeb.exe /reset /c /l /q 
icacls start/TenProtect/TenSafe.exe /reset /c /l /q 
icacls TCLS/AdvertDialog.exe /reset /c /l /q 
icacls TCLS/AdvertTips.exe /reset /c /l /q 
icacls TCLS/BackgroundDownloader.exe /reset /c /l /q 
::icacls TCLS/TPSvc.exe /reset /c /l /q 
icacls TCLS/TenProtect/TenSafe.exe /reset /c /l /q 
icacls TCLS/TenProtect/TenSafe_1.exe /reset /c /l /q 
icacls start\Cross\Apps\DNFAD\DNFADApp.dll /reset /c /l /q 
icacls start\Cross\Apps\DNFAD\GameDataPlatformClient.dll /reset /c /l /q 
icacls start\Cross\Apps\DNFAD\res.vfs /reset /c /l /q 
icacls start\Cross\Apps\DNFTips /reset /t /c /l /q 
icacls TGuard /reset /t /c /l /q & del /f /s /q TGuard & md TGuard
cd /d %PROGRAMFILES(x86)%\Tencent
icacls TGuard /reset /t /c /l /q & del /f /s /q TGuard & md TGuard
goto on

:dnf
echo 正在清理DNF垃圾文件…… 
rd /s /q "%~dp0\tgppatches"
del /f /s /q "%~dp0\*_tmp.dat"
del /f /s /q "%~dp0\debug.log"
del /f /s /q "%~dp0\gameloader.log"
del /f /s /q "%~dp0\LagLog.txt"
del /f /s /q "%~dp0\BugTrace.log"
del /f /s /q "%~dp0\awesomium.log"
del /f /s /q "%~dp0\CrashDNF2.cra"
del /f /s /q "%~dp0\TCLS\tlog\*.log"
del /f /s /q "%~dp0\Thread*.*"
del /f /s /q "%~dp0\start\Cross\Logs\*.*"
del /f /s /q "%~dp0\Logs\*.*"
del /f /s /q "%~dp0\EXPlugins\*.*"
del /f /s /q "%~dp0\tgppatches\*.*"
del /f /s /q "%~dp0\start\Cross\FileCache\*.*"
::del /f /s /q "%~dp0\TCLS\plugins\TPLocalDataDir\TPData"
copy %userprofile%\AppData\LocalLow\DNF\DNF.cfg C:\
del /f /s /q "%userprofile%\AppData\LocalLow\DNF\*.*"
copy C:\DNF.cfg %userprofile%\AppData\LocalLow\DNF\
del C:\DNF.cfg
del /f /s /q "%userprofile%\AppData\Roaming\Tencent\Logs\dnf.tlg"
cd /d %userprofile%\AppData\Roaming\Tencent
del /f /s /q QQCall*.exe
del /f /s /q WeGame\update_*.7z
goto on

:plugin
cls
echo 正在准备处理捆绑插件..
echo 若杀毒软件拦截请点击【允许执行】
echo.
choice /t 1 /d y /n >nul
taskkill /im Tencentdl.exe /T /F
taskkill /im TenioDL.exe /T /F
taskkill /im TXPlatform.exe /T /F
taskkill /im TesService.exe /T /F
net stop TesService
sc delete TesService
echo 正在写入TesService.exe...
del /f /s /q TesService.exe
copy /y FakeService TesService.exe
del /f /s /q TCLS\Tenio\TenioDL\Tencentdl.exe & type nul>TCLS\Tenio\TenioDL\Tencentdl.exe
del /f /s /q TCLS\Tenio\TenioDL\TenioDL.exe & type nul>TCLS\Tenio\TenioDL\TenioDL.exe
cd /d %userprofile%\AppData\Roaming\Tencent\地下城与勇士
for /f "delims=" %%i in ('dir Tencentdl.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
for /f "delims=" %%i in ('dir TenioDL.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
cd /d %userprofile%\AppData\Roaming\Tencent\英雄联盟
for /f "delims=" %%i in ('dir Tencentdl.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
for /f "delims=" %%i in ('dir TenioDL.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
cd /d %COMMONPROGRAMFILES(x86)%\Tencent\QQDownload
for /f "delims=" %%i in ('dir Tencentdl.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
for /f "delims=" %%i in ('dir bugreport_xf.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
cd /d %COMMONPROGRAMFILES(x86)%\Tencent
del /f /s /q TesService\TesService.exe & md TesService\TesService.exe & icacls TesService\TesService.exe /deny Everyone:(S,X)
rd /s /q TXPTOP & type nul>TXPTOP & icacls TXPTOP /deny Everyone:(S,X)
rd /s /q TXFTN & type nul>TXFTN & icacls TXFTN /deny Everyone:(S,X)
cd /d C:\Windows\SysWOW64
del /f /s /q TesService.exe & md TesService.exe & icacls TesService.exe /deny Everyone:(S,X)
cd /d %userprofile%\AppData\Roaming\Tencent
del /f /s /q QQCall*.exe
del /f /s /q 游戏人生cross\teniodl\TenioDL.exe & md 游戏人生cross\teniodl\TenioDL.exe & icacls 游戏人生cross\teniodl\TenioDL.exe /deny Everyone:(S,X)
del /f /s /q 游戏人生cross\teniodl\TenioDL_core.dll & md 游戏人生cross\teniodl\TenioDL_core.dll & icacls 游戏人生cross\teniodl\TenioDL_core.dll /deny Everyone:(S,X)
del /f /s /q Common\gjdatareport.dll & md Common\gjdatareport.dll & icacls Common\gjdatareport.dll /deny Everyone:(S,X)
del /f /s /q pallas\teniodl\TenioDL.exe & md pallas\teniodl\TenioDL.exe & icacls pallas\teniodl\TenioDL.exe /deny Everyone:(S,X)
del /f /s /q pallas\teniodl\TenioDL_core.dll & md pallas\teniodl\TenioDL_core.dll & icacls pallas\teniodl\TenioDL_core.dll /deny Everyone:(S,X)
rd /s /q AndroidAssist & type nul>AndroidAssist & icacls AndroidAssist /deny Everyone:(S,X)
rd /s /q AndroidServer & type nul>AndroidServer & icacls AndroidServer /deny Everyone:(S,X)
rd /s /q DeskUpdate & type nul>DeskUpdate & icacls DeskUpdate /deny Everyone:(S,X)
rd /s /q QQDoctor & type nul>QQDoctor & icacls QQDoctor /deny Everyone:(S,X)
rd /s /q QQDownload & type nul>QQDownload & icacls QQDownload /deny Everyone:(S,X)
rd /s /q QQMiniDL & type nul>QQMiniDL & icacls QQMiniDL /deny Everyone:(S,X)
rd /s /q MiniQBrowser & type nul>MiniQBrowser & icacls MiniQBrowser /deny Everyone:(S,X)
rd /s /q QQPCMgr & type nul>QQPCMgr & icacls QQPCMgr /deny Everyone:(S,X)
rd /s /q QQPhoneAssistant & type nul>QQPhoneAssistant & icacls QQPhoneAssistant /deny Everyone:(S,X)
rd /s /q QQPhoneManager & type nul>QQPhoneManager & icacls QQPhoneManager /deny Everyone:(S,X)
rd /s /q TAS & type nul>TAS & icacls TAS /deny Everyone:(S,X)
rd /s /q TCLSCore & type nul>TCLSCore & icacls TCLSCore /deny Everyone:(S,X)
rd /s /q Tencentdl & type nul>Tencentdl & icacls Tencentdl /deny Everyone:(S,X)
rd /s /q TenioDL & type nul>TenioDL & icacls TenioDL /deny Everyone:(S,X)
rd /s /q WebGamePlugin & type nul>WebGamePlugin & icacls WebGamePlugin /deny Everyone:(S,X)
cls
echo 准备移除TGuard...
taskkill /im TGuard.exe /T /F
taskkill /im TGuardSvc.exe /T /F
taskkill /im TP3Helper.exe /T /F
taskkill /im Update.exe /T /F
echo 正在停用TGuardSvc服务...
net stop TGuardSvc
sc delete TGuardSvc
sc create TGuardSvc binpath= "C:\TXSB.exe" displayname= "TGuardSvc"
sc delete TGuardSvc
echo 正在删除本地文件..
cd /d %~dp0
rd /s /q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
cd /d %PROGRAMFILES(x86)%\Tencent
rd /s /q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
echo 操作成功完成。
echo.
echo.
echo.       附加说明：
echo.   你无需理会清理插件过程中提示的错误信息。
echo.   在本工具发布下一次更新前，本项清理插件【仅需要】执行一次即可
echo.   如果使用删除插件后无法更新游戏，请尝试恢复全家桶。
echo.
echo.
cd /d %~dp0
goto on

:repairupdate
::以下内容仅限旧版工具箱造成的无法更新使用
set path1=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TGuardSvc
set path2=HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TGuardSvc
del /f /s /q %tmp%\patch2recv.ini
echo "%path1%" [1 7 17] >>%tmp%\patch2recv.ini
echo "%path2%" [1 7 17] >>%tmp%\patch2recv.ini
regini %tmp%\patch2recv.ini
reg delete %path1% /va /f
reg delete %path2% /va /f
goto on

:fix
del /f /s /q "%userprofile%\AppData\LocalLow\DNF\*.*"
echo 操作成功完成
goto on

:baddir
echo.
echo 警告：请将本工具箱放在DNF根目录下再运行，否则将出现不可预料的后果！
echo.
echo （例：若游戏安装目录为【D：\地下城与勇士】，则将该工具箱放在【D：\地下城与勇士】目录下后再执行。）
echo.
pause
echo 退出脚本
exit

:fakenotfound
echo.
echo 警告：请您将解压得到的 FakeService 文件一并拷贝到游戏目录，否则将无法处理TesService.exe ！
echo.
echo （例：若游戏安装目录为【D：\地下城与勇士】，则将解压得到的 FakeService 文件同工具箱一起放在【D：\地下城与勇士】目录。）
echo.
pause
echo 退出脚本
exit

:end
echo 退出脚本
exit