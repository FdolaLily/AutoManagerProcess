@echo off
cd /d %~dp0
if exist DNF.exe (goto next) else (goto baddir)
:next
if exist FakeService (goto prev) else (goto fakenotfound)
:prev
echo ������Ȩ...
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

@echo off
color 3E
echo %username% �ѻ�ȡ��������ԱȨ��
echo.
title DNFȫ��Ͱ����ר�ù�����v7.0patch4 (2024.9.12������)
echo.������˵����
echo.����DNF����TP��P2P��å�������ʡϵͳ��Դ�ʹ���ռ�ã���������ٶ�
echo.����DNFֱ����С����Ҫ��ǿ��ͬ�ǽ��ѵ����ò������Ӱ��ս����ϵͳ
echo.
echo.���ر����ѡ�
echo.1. ʹ��ǰ�롾ȷ�����Ѿ��ر�DNF��WeGame��
echo.2. �������������Ѿ�ΪDNF����������Ż��������Ծ���ʹ���Ի��������飻
echo 3. ������Ϸʱ����Ҫ�Ȼָ�ȫ��Ͱ���������ٽ��ã��������ʾ�ļ���ռ�ã�
echo.4. ���¸���������������**������**��������һ��ʹ�ã�����ִ�С�4.������������ִ�С�1.����ȫ��Ͱ��
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
choice /c 123456 /m "�������ţ�(1)����ȫ��Ͱ��(2)�ָ�ȫ��Ͱ��(3)����DNF������(4)������������(5)�޸��������ӷ�������(6)�˳���"
if %errorlevel%==6 goto end
if %errorlevel%==5 goto fix
if %errorlevel%==4 goto plugin
if %errorlevel%==3 goto dnf
if %errorlevel%==2 goto restore
if %errorlevel%==1 goto disable

:disable
echo ����ȫ��Ͱ
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
echo �ָ�ȫ��Ͱ
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
echo ��������DNF�����ļ����� 
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
echo ����׼������������..
echo ��ɱ�������������������ִ�С�
echo.
choice /t 1 /d y /n >nul
taskkill /im Tencentdl.exe /T /F
taskkill /im TenioDL.exe /T /F
taskkill /im TXPlatform.exe /T /F
taskkill /im TesService.exe /T /F
net stop TesService
sc delete TesService
echo ����д��TesService.exe...
del /f /s /q TesService.exe
copy /y FakeService TesService.exe
del /f /s /q TCLS\Tenio\TenioDL\Tencentdl.exe & type nul>TCLS\Tenio\TenioDL\Tencentdl.exe
del /f /s /q TCLS\Tenio\TenioDL\TenioDL.exe & type nul>TCLS\Tenio\TenioDL\TenioDL.exe
cd /d %userprofile%\AppData\Roaming\Tencent\���³�����ʿ
for /f "delims=" %%i in ('dir Tencentdl.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
for /f "delims=" %%i in ('dir TenioDL.exe /b /s') do del "%%i" & md "%%i" & icacls "%%i" /deny Everyone:(S,X)
cd /d %userprofile%\AppData\Roaming\Tencent\Ӣ������
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
del /f /s /q ��Ϸ����cross\teniodl\TenioDL.exe & md ��Ϸ����cross\teniodl\TenioDL.exe & icacls ��Ϸ����cross\teniodl\TenioDL.exe /deny Everyone:(S,X)
del /f /s /q ��Ϸ����cross\teniodl\TenioDL_core.dll & md ��Ϸ����cross\teniodl\TenioDL_core.dll & icacls ��Ϸ����cross\teniodl\TenioDL_core.dll /deny Everyone:(S,X)
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
echo ׼���Ƴ�TGuard...
taskkill /im TGuard.exe /T /F
taskkill /im TGuardSvc.exe /T /F
taskkill /im TP3Helper.exe /T /F
taskkill /im Update.exe /T /F
echo ����ͣ��TGuardSvc����...
net stop TGuardSvc
sc delete TGuardSvc
sc create TGuardSvc binpath= "C:\TXSB.exe" displayname= "TGuardSvc"
sc delete TGuardSvc
echo ����ɾ�������ļ�..
cd /d %~dp0
rd /s /q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
cd /d %PROGRAMFILES(x86)%\Tencent
rd /s /q TGuard & type nul>TGuard & icacls TGuard /deny Everyone:(S,X)
echo �����ɹ���ɡ�
echo.
echo.
echo.       ����˵����
echo.   �����������������������ʾ�Ĵ�����Ϣ��
echo.   �ڱ����߷�����һ�θ���ǰ������������������Ҫ��ִ��һ�μ���
echo.   ���ʹ��ɾ��������޷�������Ϸ���볢�Իָ�ȫ��Ͱ��
echo.
echo.
cd /d %~dp0
goto on

:repairupdate
::�������ݽ��޾ɰ湤������ɵ��޷�����ʹ��
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
echo �����ɹ����
goto on

:baddir
echo.
echo ���棺�뽫�����������DNF��Ŀ¼�������У����򽫳��ֲ���Ԥ�ϵĺ����
echo.
echo ����������Ϸ��װĿ¼Ϊ��D��\���³�����ʿ�����򽫸ù�������ڡ�D��\���³�����ʿ��Ŀ¼�º���ִ�С���
echo.
pause
echo �˳��ű�
exit

:fakenotfound
echo.
echo ���棺��������ѹ�õ��� FakeService �ļ�һ����������ϷĿ¼�������޷�����TesService.exe ��
echo.
echo ����������Ϸ��װĿ¼Ϊ��D��\���³�����ʿ�����򽫽�ѹ�õ��� FakeService �ļ�ͬ������һ����ڡ�D��\���³�����ʿ��Ŀ¼����
echo.
pause
echo �˳��ű�
exit

:end
echo �˳��ű�
exit