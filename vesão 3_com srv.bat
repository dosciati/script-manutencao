@echo off
title MENU DO SUPORTE TECNICO

:: Menu Principal
:menu
cls
echo ========= MENU DO SUPORTE TECNICO =========
echo 0 - Sair
echo 1 - Rede
echo 2 - Impressoras
echo 3 - Manutencao
echo 4 - Avancado
echo 5 - Servidores
echo ===========================================
set /p opcao=Escolha uma opcao: 
if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto rede
if "%opcao%"=="2" goto impressoras
if "%opcao%"=="3" goto manutencao
if "%opcao%"=="4" goto avancado
if "%opcao%"=="5" goto servidores
echo Opcao invalida.& pause & goto menu

:: Rede
:rede
cls
echo ==== MENU REDE ====
echo 0 - Voltar
echo 1 - ipconfig /all
echo 2 - ipconfig /flushdns
echo 3 - ping
echo 4 - netsh winsock reset
echo 5 - route print
set /p redeop=Opção: 
if "%redeop%"=="0" goto menu
if "%redeop%"=="1" (ipconfig /all & pause & goto rede)
if "%redeop%"=="2" (ipconfig /flushdns & pause & goto rede)
if "%redeop%"=="3" (set /p host=Host/IP: & ping %host% & pause & goto rede)
if "%redeop%"=="4" (netsh winsock reset & netsh int ip reset & echo Reinicie o PC & pause & goto rede)
if "%redeop%"=="5" (route print & pause & goto rede)
echo Opcao invalida.& pause & goto rede

:: Impressoras
:impressoras
cls
echo === MENU IMPRESSORAS ===
echo 0 - Voltar
echo 1 - Listar
echo 2 - Fila
echo 3 - Cancelar Jobs
echo 4 - Definir Padrao
echo 5 - Corrigir 0x11b
echo 6 - Corrigir 0x0bcb
echo 7 - Corrigir 0x709
echo 8 - Restart Spooler
echo 9 - Exportar Drivers
echo 10 - Importar Drivers
echo 11 - Test Page
echo 12 - Porta TCP/IP
echo 13 - Permissoes Pasta
echo 14 - Limpar Drivers
set /p impop=Opção: 
if "%impop%"=="0" goto menu
if "%impop%"=="1" (wmic printer get name,default & pause & goto impressoras)
if "%impop%"=="2" (set /p prn=Impressora: & rundll32 printui.dll,PrintUIEntry /o /n "%prn%" & pause & goto impressoras)
if "%impop%"=="3" (set /p prn=Impressora: & powershell "Get-PrintJob -PrinterName '%prn%' | Remove-PrintJob" & pause & goto impressoras)
if "%impop%"=="4" (set /p def=Padrao: & rundll32 printui.dll,PrintUIEntry /y /n "%def%" & pause & goto impressoras)
if "%impop%"=="5" (reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f & pause & goto impressoras)
if "%impop%"=="6" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f & pause & goto impressoras)
if "%impop%"=="7" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f & pause & goto impressoras)
if "%impop%"=="8" (net stop spooler & timeout /t 3 & net start spooler & pause & goto impressoras)
if "%impop%"=="9" (dism /online /export-driver /destination:"%userprofile%\PrinterDrivers" & pause & goto impressoras)
if "%impop%"=="10" (dism /online /add-driver /driver:"%userprofile%\PrinterDrivers\*.inf" & pause & goto impressoras)
if "%impop%"=="11" (set /p prn=Impressora: & rundll32 printui.dll,PrintUIEntry /k /n "%prn%" & pause & goto impressoras)
if "%impop%"=="12" (wmic port where "Name like 'IP_%'" get Name,Protocol,HostAddress & pause & goto impressoras)
if "%impop%"=="13" (cacls "%SystemRoot%\System32\spool\PRINTERS" /E /G Users:F & pause & goto impressoras)
if "%impop%"=="14" (for /f "tokens=2 delims=:" %%D in ('pnputil /enum-drivers ^| findstr /i printer') do pnputil /delete-driver %%D /uninstall /force & pause & goto impressoras)
echo Opcao invalida.& pause & goto impressoras

:: Manutencao
:manutencao
cls
echo ==== MANUTENCAO ====
echo 0 - Voltar
echo 1 - CHKDSK
echo 2 - SFC
echo 3 - DISM
echo 4 - Limpar Temp+Cache Navegadores
echo 5 - Relatorio Disco
echo 6 - CPU/Memory perf
echo 7 - Energia/Bateria
echo 8 - Logs Eventos
echo 9 - Netstat/Traceroute
echo 10 - Rede Avancada
echo 11 - Reset Policies
set /p manop=Opção:
if "%manop%"=="0" goto menu
if "%manop%"=="1" (chkdsk C: /f /r & pause & goto manutencao)
if "%manop%"=="2" (sfc /scannow & pause & goto manutencao)
if "%manop%"=="3" (dism /online /cleanup-image /restorehealth & pause & goto manutencao)
if "%manop%"=="4" (del /f /s /q "%temp%\*.*" & del /f /s /q "%windir%\Temp\*.*" & rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" & rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" & for /d %%G in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do rd /s /q "%%G\cache2" & pause & goto manutencao)
if "%manop%"=="5" (wmic logicaldisk get caption,FreeSpace,Size & pause & goto manutencao)
if "%manop%"=="6" (typeperf "\Processor(_Total)\% Processor Time" "\Memory\Available MBytes" -si 5 -sc 5 & pause & goto manutencao)
if "%manop%"=="7" (powercfg /energy /output "%userprofile%\energy-report.html" & powercfg /batteryreport /output "%userprofile%\battery-report.html" & pause & goto manutencao)
if "%manop%"=="8" (for %%l in (Application System Security) do wevtutil epl %%l "%userprofile%\%%l.evtx" & for %%l in (Application System Security) do wevtutil cl %%l & pause & goto manutencao)
if "%manop%"=="9" (netstat -ano & set /p h=Host/IP: & tracert %h% & pause & goto manutencao)
if "%manop%"=="10" (netsh interface show interface & net stop dhcp & net start dhcp & net stop dnscache & net start dnscache & pause & goto manutencao)
if "%manop%"=="11" (secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb /verbose & pause & goto manutencao)
echo Opcao invalida.& pause & goto manutencao

:: Avancado
:avancado
cls
echo ==== MENU AVANCADO ====
echo 0 - Voltar
echo 1 - Memoria Diagnostico
echo 2 - Restore System
echo 3 - Backup Drivers
echo 4 - Windows Update Log
echo 5 - System Info
echo 6 - ipconfig /flushdns
echo 7 - Firewall Manager
echo 8 - Event Viewer
echo 9 - Disk Speed Test
echo 10 - Create Restore Point
echo 11 - Custom Command
echo 12 - winget List
echo 13 - Add Network Printer
echo 14 - Security Policy
echo 15 - Local Rights
echo 16 - Defrag Disk
echo 17 - Defender Status
echo 18 - Defender Quick Scan
echo 19 - WSReset Store Cache
echo 20 - Registry Backup
echo 21 - GPO Manager
set /p advop=Opção:
if "%advop%"=="0" goto menu
if "%advop%"=="7" goto firewallMenu
if "%advop%"=="21" goto gpoMenu
:: demais opções seguem o mesmo padrão
echo Opcao invalida.& pause & goto avancado

:: Firewall Menu
:firewallMenu
cls
echo ==== FIREWALL MANAGER ====
echo 0 - Voltar
echo 1 - Enable All Profiles
echo 2 - Disable All Profiles
echo 3 - List Rules
echo 4 - Add Inbound Rule
echo 5 - Add Outbound Rule
echo 6 - Remove Rule
set /p fwop=Opção:
if "%fwop%"=="0" goto avancado
if "%fwop%"=="1" (netsh advfirewall set allprofiles state on & pause & goto firewallMenu)
if "%fwop%"=="2" (netsh advfirewall set allprofiles state off & pause & goto firewallMenu)
if "%fwop%"=="3" (netsh advfirewall firewall show rule name=all & pause & goto firewallMenu)
if "%fwop%"=="4" (set /p rn=Rule Name:& set /p proto=Protocol:& set /p lp=Local Port: & netsh advfirewall firewall add rule name="%rn%" dir=in action=allow protocol=%proto% localport=%lp% & pause & goto firewallMenu)
if "%fwop%"=="5" (set /p rn=Rule Name:& set /p proto=Protocol:& set /p lp=Local Port: & netsh advfirewall firewall add rule name="%rn%" dir=out action=allow protocol=%proto% localport=%lp% & pause & goto firewallMenu)
if "%fwop%"=="6" (set /p rn=Rule Name: & netsh advfirewall firewall delete rule name="%rn%" & pause & goto firewallMenu)
echo Opcao invalida.& pause & goto firewallMenu

:: GPO Menu
:gpoMenu
cls
echo ==== GPO MANAGER ====
echo 0 - Voltar
echo 1 - Get-GPO All
echo 2 - New-GPO
echo 3 - Remove-GPO
echo 4 - Backup-GPO
echo 5 - Restore-GPO
echo 6 - Set-GPLink
echo 7 - Remove-GPLink
set /p gpop=Opção:
if "%gpop%"=="0" goto avancado
if "%gpop%"=="1" (powershell "Get-GPO -All" & pause & goto gpoMenu)
if "%gpop%"=="2" (set /p nm=Name: & powershell "New-GPO -Name '%nm%'" & pause & goto gpoMenu)
if "%gpop%"=="3" (set /p gd=GUID: & powershell "Remove-GPO -Guid '%gd%' -Confirm:$false" & pause & goto gpoMenu)
if "%gpop%"=="4" (set /p gd=GUID: & set /p pt=Path: & powershell "Backup-GPO -Guid '%gd%' -Path '%pt%'" & pause & goto gpoMenu)
if "%gpop%"=="5" (set /p pt=Path: & powershell "Restore-GPO -Path '%pt%' -CreateIfNeeded" & pause & goto gpoMenu)
if "%gpop%"=="6" (set /p nm=Name:& set /p ou=OU DN: & powershell "Set-GPLink -Name '%nm%' -Target '%ou%' -Enforced Yes" & pause & goto gpoMenu)
if "%gpop%"=="7" (set /p nm=Name:& set /p ou=OU DN: & powershell "Remove-GPLink -Name '%nm%' -Target '%ou%'" & pause & goto gpoMenu)
echo Opcao invalida.& pause & goto gpoMenu

:: Servidores
:servidores
cls
echo ==== MENU SERVIDORES ====
echo 0 - Voltar
echo 1 - Get-Service
echo 2 - Start-Service
echo 3 - Stop-Service
echo 4 - Get-LocalUser
echo 5 - Get-LocalGroup
echo 6 - New-LocalUser
echo 7 - Remove-LocalUser
echo 8 - New-LocalGroup
echo 9 - Remove-LocalGroup
echo 10 - Add-LocalGroupMember
echo 11 - Remove-LocalGroupMember
echo 12 - Install-WindowsFeature
echo 13 - Uninstall-WindowsFeature
echo 14 - Get-WindowsFeature
echo 15 - Get-ADUser
echo 16 - Get-ADComputer
echo 17 - Dcdiag
echo 18 - Disk Report
echo 19 - Enable-PSRemoting
echo 20 - sconfig
echo 21 - Restart
echo 22 - Disk Management
echo 23 - Install Feature
echo ==================================
set /p servop=Opção:
if "%servop%"=="0" goto menu
if "%servop%"=="1" (powershell "Get-Service" & pause & goto servidores)
if "%servop%"=="2" (set /p srv=Name: & powershell "Start-Service -Name '%srv%'" & pause & goto servidores)
if "%servop%"=="3" (set /p srv=Name: & powershell "Stop-Service -Name '%srv%'" & pause & goto servidores)
if "%servop%"=="4" (powershell "Get-LocalUser" & pause & goto servidores)
if "%servop%"=="5" (powershell "Get-LocalGroup" & pause & goto servidores)
if "%servop%"=="6" (set /p u=Name: & set /p p=Password: & powershell "New-LocalUser -Name '%u%' -Password (ConvertTo-SecureString '%p%' -AsPlainText -Force)" & pause & goto servidores)
if "%servop%"=="7" (set /p u=Name: & powershell "Remove-LocalUser -Name '%u%'" & pause & goto servidores)
if "%servop%"=="8" (set /p g=Name: & powershell "New-LocalGroup -Name '%g%'" & pause & goto servidores)
if "%servop%"=="9" (set /p g=Name: & powershell "Remove-LocalGroup -Name '%g%'" & pause & goto servidores)
if "%servop%"=="10" (set /p u=User: & set /p g=Group: & powershell "Add-LocalGroupMember -Group '%g%' -Member '%u%'" & pause & goto servidores)
if "%servop%"=="11" (set /p u=User: & set /p g=Group: & powershell "Remove-LocalGroupMember -Group '%g%' -Member '%u%'" & pause & goto servidores)
if "%servop%"=="12" (set /p f=Feature: & powershell "Install-WindowsFeature -Name '%f%'" & pause & goto servidores)
if "%servop%"=="13" (set /p f=Feature: & powershell "Uninstall-WindowsFeature -Name '%f%'" & pause & goto servidores)
if "%servop%"=="14" (powershell "Get-WindowsFeature" & pause & goto servidores)
if "%servop%"=="15" (set /p u=User: & powershell "Get-ADUser -Identity '%u%'" & pause & goto servidores)
if "%servop%"=="16" (set /p c=Computer: & powershell "Get-ADComputer -Identity '%c%'" & pause & goto servidores)
if "%servop%"=="17" (dcdiag & pause & goto servidores)
if "%servop%"=="18" (wmic logicaldisk get caption,FreeSpace,Size & pause & goto servidores)
if "%servop%"=="19" (powershell "Enable-PSRemoting -Force" & pause & goto servidores)
if "%servop%"=="20" (sconfig & pause & goto servidores)
if "%servop%"=="21" (shutdown /r /t 0)
if "%servop%"=="22" goto discoserver
if "%servop%"=="23" (set /p f=Feature: & powershell "Install-WindowsFeature -Name '%f%'" & pause & goto servidores)
echo Opcao invalida.& pause & goto servidores

:: Disk Management for Servers
:discoserver
cls
echo ==== GERENCIAMENTO DE DISCOS ====
echo 0 - Voltar
echo 1 - list disk
echo 2 - list volume
echo 3 - create partition primary
echo 4 - assign letter
echo 5 - extend volume
set /p diskop=Opção:
if "%diskop%"=="0" goto servidores
if "%diskop%"=="1" (echo list disk|diskpart & pause & goto discoserver)
if "%diskop%"=="2" (echo list volume|diskpart & pause & goto discoserver)
if "%diskop%"=="3" (set /p d=Disk#: & (
  echo select disk %d%>dp.txt
  echo create partition primary>>dp.txt
  )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
if "%diskop%"=="4" (set /p v=Volume#: & set /p l=Letra: & (
  echo select volume %v%>dp.txt
  echo assign letter=%l%>>dp.txt
  )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
if "%diskop%"=="5" (set /p v=Volume#: & (
  echo select volume %v%>dp.txt
  echo extend>>dp.txt
  )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
echo Opcao invalida.& pause & goto discoserver

:: Sair
:sair
echo Ate mais!
exit /b 0
