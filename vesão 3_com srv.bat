@echo off

title MENU DO SUPORTE TECNICO

:: ====================================================================
:: Script: Suporte Tecnico Completo
:: Autor: Andre Forlin Dosciati
:: Data: 08/08/2025
:: Versao: 1.0
:: ====================================================================

:: Inicia no menu principal
goto menu

:: Rotina de cabeçalho persistente
:header
 echo.
 echo =======================================================
 echo Suporte Tecnico Completo ^|Autor: Andre Forlin Dosciati
 echo Data: 08/08/2025       ^|Versao: 1.0
 echo =======================================================
 echo.
 goto :eof

:: Menu Principal
:menu
 cls
 call :header
 echo ========== MENU DO SUPORTE TECNICO ==========
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

:: Menu Rede
:rede
 cls
 call :header
 echo ==== MENU REDE ====
 echo 0 - Voltar
 echo 1 - ipconfig /all
 echo 2 - ipconfig /flushdns
 echo 3 - ping
 echo 4 - netsh winsock reset
 echo 5 - route print
 echo ===========================================
 set /p redeop=Escolha uma opcao: 
 if "%redeop%"=="0" goto menu
 if "%redeop%"=="1" (ipconfig /all & pause & goto rede)
 if "%redeop%"=="2" (ipconfig /flushdns & pause & goto rede)
 if "%redeop%"=="3" (set /p host=Host/IP: & ping %host% & pause & goto rede)
 if "%redeop%"=="4" (netsh winsock reset & netsh int ip reset & echo Reinicie o PC & pause & goto rede)
 if "%redeop%"=="5" (route print & pause & goto rede)
 echo Opcao invalida.& pause & goto rede

:: Menu Impressoras
:impressoras
 cls
 call :header
 echo ==== MENU IMPRESSORAS ====
 echo 0 - Voltar
 echo 1 - Listar Impressoras Instaladas
 echo 2 - Exibir Fila de Impressao
 echo 3 - Cancelar Todos os Jobs
 echo 4 - Definir Impressora Padrao
 echo 5 - Corrigir Erro 0x0000011b
 echo 6 - Corrigir Erro 0x00000bcb
 echo 7 - Corrigir Erro 0x00000709
 echo 8 - Reiniciar Spooler
 echo 9 - Exportar Drivers de Impressora
 echo 10 - Importar Drivers de Impressora
 echo 11 - Imprimir Pagina de Teste
 echo 12 - Ver Detalhes de Porta TCP/IP
 echo 13 - Ajustar Permissoes da Pasta Spool
 echo 14 - Limpar Drivers Obsoletos
 echo ===========================================
 set /p impop=Escolha uma opcao: 
 if "%impop%"=="0" goto menu
 if "%impop%"=="1" (wmic printer get name,default & pause & goto impressoras)
 if "%impop%"=="2" (set /p prn=Nome da Impressora: & rundll32 printui.dll,PrintUIEntry /o /n "%prn%" & pause & goto impressoras)
 if "%impop%"=="3" (set /p prn=Nome da Impressora: & powershell -Command "Get-PrintJob -PrinterName '%prn%' | Remove-PrintJob" & pause & goto impressoras)
 if "%impop%"=="4" (set /p def=Nome da Impressora Padrao: & rundll32 printui.dll,PrintUIEntry /y /n "%def%" & pause & goto impressoras)
 if "%impop%"=="5" (reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f & pause & goto impressoras)
 if "%impop%"=="6" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f & pause & goto impressoras)
 if "%impop%"=="7" (reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f & pause & goto impressoras)
 if "%impop%"=="8" (net stop spooler & timeout /t 3 >nul & net start spooler & pause & goto impressoras)
 if "%impop%"=="9" (dism /online /export-driver /destination:"%userprofile%\PrinterDrivers" & echo Drivers exportados & pause & goto impressoras)
 if "%impop%"=="10" (dism /online /add-driver /driver:"%userprofile%\PrinterDrivers\*.inf" & echo Drivers importados & pause & goto impressoras)
 if "%impop%"=="11" (set /p prn=Nome da Impressora: & rundll32 printui.dll,PrintUIEntry /k /n "%prn%" & pause & goto impressoras)
 if "%impop%"=="12" (wmic port where "Name like 'IP_%'" get Name,Protocol,HostAddress & pause & goto impressoras)
 if "%impop%"=="13" (cacls "%SystemRoot%\System32\spool\PRINTERS" /E /G Users:F & echo Permissoes ajustadas & pause & goto impressoras)
 if "%impop%"=="14" (for /f "tokens=2 delims=:" %%D in ('pnputil /enum-drivers ^| findstr /i printer') do pnputil /delete-driver %%D /uninstall /force & echo Drivers obsoletos removidos & pause & goto impressoras)
 echo Opcao invalida.& pause & goto impressoras

:: Menu Manutencao
:manutencao
 cls
 call :header
 echo ==== MENU MANUTENCAO ====
 echo 0 - Voltar
 echo 1 - CHKDSK
 echo 2 - SFC
 echo 3 - DISM RestoreHealth
 echo 4 - Limpar Temp e Cache Navegadores
 echo 5 - Relatorio de Disco
 echo 6 - Uso de CPU/Memoria
 echo 7 - Relatorio de Energia e Bateria
 echo 8 - Exportar e Limpar Logs de Eventos
 echo 9 - Netstat e Traceroute
 echo 10 - Interfaces + Reiniciar Servicos Rede
 echo 11 - Reset Politicas de Seguranca
 echo ===========================================
 set /p manop=Escolha uma opcao: 
 if "%manop%"=="0" goto menu
 if "%manop%"=="1" (chkdsk C: /f /r & pause & goto manutencao)
 if "%manop%"=="2" (sfc /scannow & pause & goto manutencao)
 if "%manop%"=="3" (dism /online /cleanup-image /restorehealth & pause & goto manutencao)
 if "%manop%"=="4" (del /f /s /q "%temp%\*.*" & del /f /s /q "%windir%\Temp\*.*" & rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" & rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" & for /d %%G in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do rd /s /q "%%G\cache2" & echo Limpeza completa & pause & goto manutencao)
 if "%manop%"=="5" (wmic logicaldisk get caption,FreeSpace,Size & pause & goto manutencao)
 if "%manop%"=="6" (typeperf "\Processor(_Total)\% Processor Time" "\Memory\Available MBytes" -si 5 -sc 5 & pause & goto manutencao)
 if "%manop%"=="7" (powercfg /energy /output "%userprofile%\energy-report.html" & powercfg /batteryreport /output "%userprofile%\battery-report.html" & echo Relatorios gerados & pause & goto manutencao)
 if "%manop%"=="8" (for %%l in (Application System Security) do wevtutil epl %%l "%userprofile%\%%l.evtx" & for %%l in (Application System Security) do wevtutil cl %%l & echo Logs exportados e limpos & pause & goto manutencao)
 if "%manop%"=="9" (netstat -ano & set /p h=Host/IP: & tracert %h% & pause & goto manutencao)
 if "%manop%"=="10" (netsh interface show interface & net stop dhcp & net start dhcp & net stop dnscache & net start dnscache & pause & goto manutencao)
 if "%manop%"=="11" (secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb /verbose & echo Politicas resetadas & pause & goto manutencao)
 echo Opcao invalida.& pause & goto manutencao

:: Menu Avancado
:avancado
 cls
 call :header
 echo ==== MENU AVANCADO ====
 echo 0 - Voltar
 echo 1 - Diagnostico de Memoria
 echo 2 - Restaurar Sistema
 echo 3 - Backup de Drivers
 echo 4 - Windows Update Log
 echo 5 - Informacoes do Sistema
 echo 6 - Flush DNS
 echo 7 - Firewall Manager
 echo 8 - Event Viewer
 echo 9 - Teste de Velocidade de Disco
 echo 10 - Criar Ponto de Restauracao
 echo 11 - Comando Personalizado
 echo 12 - Gerenciar Apps (winget)
 echo 13 - Instalar Impressora em Rede
 echo 14 - Politicas de Seguranca Local
 echo 15 - Atribuicao de Direitos de Usuario
 echo 16 - Desfragmentar Disco
 echo 17 - Status Windows Defender
 echo 18 - Scan Defender
 echo 19 - Limpar Cache Microsoft Store
 echo 20 - Backup do Registro
 echo 21 - GPO Manager
 echo ===========================================
 set /p advop=Escolha uma opcao: 
 if "%advop%"=="0" goto menu
 if "%advop%"=="7" goto firewallMenu
 if "%advop%"=="21" goto gpoMenu
 echo Opcao invalida.& pause & goto avancado

:: Firewall Menu
:firewallMenu
 cls
 call :header
 echo ==== FIREWALL MANAGER ====
 echo 0 - Voltar
 echo 1 - Ativar Todos Profiles
 echo 2 - Desativar Todos Profiles
 echo 3 - Listar Regras
 echo 4 - Add Regra Inbound
 echo 5 - Add Regra Outbound
 echo 6 - Remover Regra
 echo ===========================================
 set /p fwop=opcao: 
 if "%fwop%"=="0" goto avancado
 if "%fwop%"=="1" (netsh advfirewall set allprofiles state on & pause & goto firewallMenu)
 if "%fwop%"=="2" (netsh advfirewall set allprofiles state off & pause & goto firewallMenu)
 if "%fwop%"=="3" (netsh advfirewall firewall show rule name=all & pause & goto firewallMenu)
 if "%fwop%"=="4" (set /p rn=Nome Regra: & set /p proto=Protocolo: & set /p lp=Porta: & netsh advfirewall firewall add rule name="%rn%" dir=in action=allow protocol=%proto% localport=%lp% & pause & goto firewallMenu)
 if "%fwop%"=="5" (set /p rn=Nome Regra: & set /p proto=Protocolo: & set /p lp=Porta: & netsh advfirewall firewall add rule name="%rn%" dir=out action=allow protocol=%proto% localport=%lp% & pause & goto firewallMenu)
 if "%fwop%"=="6" (set /p rn=Nome Regra: & netsh advfirewall firewall delete rule name="%rn%" & pause & goto firewallMenu)
 echo Opcao invalida.& pause & goto firewallMenu

:: GPO Manager
:gpoMenu
 cls
 call :header
 echo ==== GPO MANAGER ====
 echo 0 - Voltar
 echo 1 - Listar GPOs
 echo 2 - Criar GPO
 echo 3 - Remover GPO
 echo 4 - Backup GPO
 echo 5 - Restaurar GPO
 echo 6 - Linkar GPO
 echo 7 - Unlink GPO
 echo ===========================================
 set /p gpop=Escolha uma opcao: 
 if "%gpop%"=="0" goto avancado
 if "%gpop%"=="1" (powershell -Command "Get-GPO -All" & pause & goto gpoMenu)
 if "%gpop%"=="2" (set /p nm=Nome: & powershell -Command "New-GPO -Name '%nm%'" & pause & goto gpoMenu)
 if "%gpop%"=="3" (set /p gd=GUID: & powershell -Command "Remove-GPO -Guid '%gd%' -Confirm:$false" & pause & goto gpoMenu)
 if "%gpop%"=="4" (set /p gd=GUID: & set /p pt=Path: & powershell -Command "Backup-GPO -Guid '%gd%' -Path '%pt%'" & pause & goto gpoMenu)
 if "%gpop%"=="5" (set /p pt=Path: & powershell -Command "Restore-GPO -Path '%pt%' -CreateIfNeeded" & pause & goto gpoMenu)
 if "%gpop%"=="6" (set /p nm=Nome: & set /p ou=OU DN: & powershell -Command "Set-GPLink -Name '%nm%' -Target '%ou%' -Enforced Yes" & pause & goto gpoMenu)
 if "%gpop%"=="7" (set /p nm=Nome: & set /p ou=OU DN: & powershell -Command "Remove-GPLink -Name '%nm%' -Target '%ou%'" & pause & goto gpoMenu)
 echo Opcao invalida.& pause & goto gpoMenu

:: Menu Servidores
:servidores
 cls
 call :header
 echo ==== MENU SERVIDORES ====
 echo 0 - Voltar
 echo 1 - Listar Servicos (Get-Service)
 echo 2 - Iniciar Servico
 echo 3 - Parar Servico
 echo 4 - Listar Usuarios Locais
 echo 5 - Listar Grupos Locais
 echo 6 - Adicionar Usuario Local
 echo 7 - Remover Usuario Local
 echo 8 - Adicionar Grupo Local
 echo 9 - Remover Grupo Local
 echo 10 - Adicionar Usuario a Grupo
 echo 11 - Remover Usuario de Grupo
 echo 12 - Listar Roles/Features
 echo 13 - Instalar Feature
 echo 14 - Remover Feature
 echo 15 - Get-ADUser
 echo 16 - Get-ADComputer
 echo 17 - Diagnostico AD
 echo 18 - Relatorio de Disco
 echo 19 - Habilitar PSRemoting
 echo 20 - Windows Update (sconfig)
 echo 21 - Reiniciar Servidor
 echo 22 - Gerenciar Discos
 echo ===========================================
 set /p servop=Escolha uma opcao: 
 if "%servop%"=="0" goto menu
 if "%servop%"=="1" (powershell -Command "Get-Service" & pause & goto servidores)
 if "%servop%"=="2" (set /p srv=Servico: & powershell -Command "Start-Service -Name '%srv%'" & pause & goto servidores)
 if "%servop%"=="3" (set /p srv=Servico: & powershell -Command "Stop-Service -Name '%srv%'" & pause & goto servidores)
 if "%servop%"=="4" (powershell -Command "Get-LocalUser" & pause & goto servidores)
 if "%servop%"=="5" (powershell -Command "Get-LocalGroup" & pause & goto servidores)
 if "%servop%"=="6" (set /p u=Usuario: & set /p p=Senha: & powershell -Command "New-LocalUser -Name '%u%' -Password (ConvertTo-SecureString '%p%' -AsPlainText -Force)" & pause & goto servidores)
 if "%servop%"=="7" (set /p u=Usuario: & powershell -Command "Remove-LocalUser -Name '%u%'" & pause & goto servidores)
 if "%servop%"=="8" (set /p g=Grupo: & powershell -Command "New-LocalGroup -Name '%g%'" & pause & goto servidores)
 if "%servop%"=="9" (set /p g=Grupo: & powershell -Command "Remove-LocalGroup -Name '%g%'" & pause & goto servidores)
 if "%servop%"=="10" (set /p u=Usuario: & set /p g=Grupo: & powershell -Command "Add-LocalGroupMember -Group '%g%' -Member '%u%'" & pause & goto servidores)
 if "%servop%"=="11" (set /p u=Usuario: & set /p g=Grupo: & powershell -Command "Remove-LocalGroupMember -Group '%g%' -Member '%u%'" & pause & goto servidores)
 if "%servop%"=="12" (powershell -Command "Get-WindowsFeature" & pause & goto servidores)
 if "%servop%"=="13" (set /p f=Feature: & powershell -Command "Install-WindowsFeature -Name '%f%'" & pause & goto servidores)
 if "%servop%"=="14" (set /p f=Feature: & powershell -Command "Uninstall-WindowsFeature -Name '%f%'" & pause & goto servidores)
 if "%servop%"=="15" (set /p u=Usuario: & powershell -Command "Get-ADUser -Identity '%u%'" & pause & goto servidores)
 if "%servop%"=="16" (set /p c=Computer: & powershell -Command "Get-ADComputer -Identity '%c%'" & pause & goto servidores)
 if "%servop%"=="17" (dcdiag & pause & goto servidores)
 if "%servop%"=="18" (wmic logicaldisk get caption,FreeSpace,Size & pause & goto servidores)
 if "%servop%"=="19" (powershell -Command "Enable-PSRemoting -Force" & pause & goto servidores)
 if "%servop%"=="20" (sconfig & pause & goto servidores)
 if "%servop%"=="21" (shutdown /r /t 0)
 if "%servop%"=="22" goto discoserver
 echo Opcao invalida.& pause & goto servidores

:: Gerenciamento de Discos no Servidor
:discoserver
 cls
 call :header
 echo ==== GERENCIAMENTO DE DISCOS ====
 echo 0 - Voltar
 echo 1 - Listar Discos
 echo 2 - Listar Volumes
 echo 3 - Criar Particao Primaria
 echo 4 - Atribuir Letra de Unidade
 echo 5 - Estender Volume
 echo ===========================================
 set /p diskop=Escolha uma opcao: 
 if "%diskop%"=="0" goto servidores
 if "%diskop%"=="1" (echo list disk|diskpart & pause & goto discoserver)
 if "%diskop%"=="2" (echo list volume|diskpart & pause & goto discoserver)
 if "%diskop%"=="3" (set /p d=Disco: & (
    echo select disk %d%>dp.txt
    echo create partition primary>>dp.txt
 )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
 if "%diskop%"=="4" (set /p v=Volume: & set /p l=Letra: & (
    echo select volume %v%>dp.txt
    echo assign letter=%l%>>dp.txt
 )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
 if "%diskop%"=="5" (set /p v=Volume: & (
    echo select volume %v%>dp.txt
    echo extend>>dp.txt
 )&diskpart /s dp.txt&del dp.txt&pause&goto discoserver)
 echo Opcao invalida.& pause & goto discoserver

:: Sair
:sair
 echo Ate mais!
 exit /b 0
