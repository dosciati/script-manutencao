@echo off
title MENU DO SUPORTE TECNICO

:: ====================================================================
:: Script: Suporte Tecnico Completo
:: Autor: André Forlin Dosciati
:: Data: 08/08/2025
:: Versao: 1.0
:: ====================================================================

:: Menu Principal
:menu
cls
echo ========= MENU DO SUPORTE TECNICO =========
echo 0 - Sair
echo 1 - Rede
echo 2 - Impressoras
echo 3 - Manutencao
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto rede
if "%opcao%"=="2" goto impressoras
if "%opcao%"=="3" goto manutencao

echo Opcao invalida.
pause
goto menu

:rede
cls
echo ===== MENU REDE =====
echo 0 - Voltar
echo 1 - Informacoes Rede (ipconfig /all)
echo 2 - Flush DNS
echo 3 - Ping
echo 4 - Reset Winsock/IP
echo 5 - Rotas de Rede
echo =====================
set /p redeop=Opção: 
if "%redeop%"=="0" goto menu
if "%redeop%"=="1" (ipconfig /all & pause & goto rede)
if "%redeop%"=="2" (ipconfig /flushdns & pause & goto rede)
if "%redeop%"=="3" (set /p host=Host/IP: & ping %host% & pause & goto rede)
if "%redeop%"=="4" (netsh winsock reset & netsh int ip reset & echo Reinicie o PC & pause & goto rede)
if "%redeop%"=="5" (route print & pause & goto rede)
echo Opcao invalida.& pause & goto rede

:impressoras
cls
echo === MENU IMPRESSORAS ===
echo 0 - Voltar
echo 1 - Corrigir 0x0000011b
echo 2 - Corrigir 0x00000bcb
echo 3 - Corrigir 0x00000709
echo 4 - Reiniciar Spooler
echo ========================
set /p impop=Opção: 
if "%impop%"=="0" goto menu
if "%impop%"=="1" (reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f & echo Feito & pause & goto impressoras)
if "%impop%"=="2" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f & echo Feito & pause & goto impressoras)
if "%impop%"=="3" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f & echo Feito & pause & goto impressoras)
if "%impop%"=="4" (net stop spooler & timeout /t 3 >nul & net start spooler & echo Feito & pause & goto impressoras)
echo Opcao invalida.& pause & goto impressoras

:manutencao
cls
echo ==== MANUTENCAO ==== 
echo 0 - Voltar
echo 1 - CHKDSK
echo 2 - SFC
echo 3 - DISM Restore
echo 4 - Limpar Temp e Cache Navegadores
echo 5 - Relatorio de Disco
echo 6 - Uso de CPU/Memoria
echo 7 - Relatorio de Energia e Bateria
echo 8 - Exportar e Limpar Logs de Eventos
echo 9 - Netstat e Traceroute
echo 10 - Interfaces de Rede + Reiniciar Servicos Rede
echo 11 - Reset Politicas de Seguranca
echo =======================
set /p manop=Opção: 
if "%manop%"=="0" goto menu
if "%manop%"=="1" (chkdsk C: /f /r & pause & goto manutencao)
if "%manop%"=="2" (sfc /scannow & pause & goto manutencao)
if "%manop%"=="3" (dism /online /cleanup-image /restorehealth & pause & goto manutencao)
if "%manop%"=="4" (echo Limpando temporarios... & del /f /s /q "%temp%\*.*" & del /f /s /q "%windir%\Temp\*.*" & \
  rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" & \
  rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" & \
  for /d %%G in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do rd /s /q "%%G\cache2" & \
  echo Pronto & pause & goto manutencao)
if "%manop%"=="5" (wmic logicaldisk get caption,FreeSpace,Size & pause & goto manutencao)
if "%manop%"=="6" (typeperf "\Processor(_Total)\% Processor Time" "\Memory\Available MBytes" -si 5 -sc 5 & pause & goto manutencao)
if "%manop%"=="7" (powercfg /energy /output "%userprofile%\energy-report.html" & powercfg /batteryreport /output "%userprofile%\battery-report.html" & echo Relatorios em Desktop & pause & goto manutencao)
if "%manop%"=="8" (for %%l in (Application System Security) do wevtutil epl %%l "%userprofile%\%%l.evtx" & for %%l in (Application System Security) do wevtutil cl %%l & echo Logs exportados e limpos & pause & goto manutencao)
if "%manop%"=="9" (netstat -ano & set /p h=Host/IP para tracert: & tracert %h% & pause & goto manutencao)
if "%manop%"=="10" (netsh interface show interface & echo Reiniciando DHCP e DNS & net stop dhcp & net start dhcp & net stop dnscache & net start dnscache & pause & goto manutencao)
if "%manop%"=="11" (secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb /verbose & echo Pronto & pause & goto manutencao)
echo Opcao invalida.& pause & goto manutencao

:sair
echo Ate mais!
exit /b 0
