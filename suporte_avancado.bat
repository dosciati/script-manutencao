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
echo 3 - Sistema
echo 4 - Suporte Profissional
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto rede
if "%opcao%"=="2" goto impressoras
if "%opcao%"=="3" goto sistema
if "%opcao%"=="4" goto profissional

echo Opcao invalida.
pause
goto menu

::–––––––––––––––––––––––––––––––––––––––––––––
:: MENU REDE
:rede
cls
echo ================== REDE ==================
echo 0 - Voltar para o menu inicial
echo 1 - Verificar informacoes completas da rede
echo 2 - Flush DNS
echo 3 - Ping Servidor
echo 4 - Resetar configuracoes de rede (Winsock)
echo 5 - Rotas de rede
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto ipall
if "%opcao%"=="2" goto flushdns
if "%opcao%"=="3" goto pingserv
if "%opcao%"=="4" goto winsock
if "%opcao%"=="5" goto rotas

echo Opcao invalida.
pause
goto rede

:ipall
ipconfig /all
pause
goto menu

:flushdns
ipconfig /flushdns
pause
goto menu

:pingserv
set /p ipNome=Digite o nome ou IP do Servidor:
ping %ipNome%
pause
goto menu

:winsock
netsh winsock reset
netsh int ip reset
echo É necessário reiniciar o computador.
pause
goto menu

:rotas
route print
pause
goto menu

::–––––––––––––––––––––––––––––––––––––––––––––
:: MENU IMPRESSORAS
:impressoras
cls
echo =============== IMPRESSORAS ===============
echo 0 - Voltar para o menu inicial
echo 1 - Fix erro 0x0000011b
echo 2 - Fix erro 0x00000bcb
echo 3 - Fix erro 0x00000709
echo 4 - Reiniciar spooler de impressao
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto erro11b
if "%opcao%"=="2" goto erro0bcb
if "%opcao%"=="3" goto erro709
if "%opcao%"=="4" goto spooler

echo Opcao invalida.
pause
goto impressoras

:erro11b
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo Erro 0x0000011b corrigido.
pause
goto menu

:erro0bcb
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
echo Erro 0x00000bcb corrigido.
pause
goto menu

:erro709
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
echo Erro 0x00000709 corrigido.
pause
goto menu

:spooler
net stop spooler
timeout /t 3 >nul
net start spooler
echo Spooler reiniciado com sucesso.
pause
goto menu

::–––––––––––––––––––––––––––––––––––––––––––––
:: MENU SISTEMA
:sistema
cls
echo ================= SISTEMA =================
echo 0 - Voltar para o menu inicial
echo 1 - Reiniciar Computador
echo 2 - Lentidao
echo 3 - Atualizar Group Policy
echo 4 - Processos com maior uso de CPU
echo 5 - Liberar acesso a compartilhamentos
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto reiniciar
if "%opcao%"=="2" goto lentidao
if "%opcao%"=="3" goto updateGp
if "%opcao%"=="4" goto cpu
if "%opcao%"=="5" goto compartilhamento

echo Opcao invalida.
pause
goto sistema

:reiniciar
shutdown /r /t 0
goto fim

:lentidao
cls
echo Etapa 1: Abrindo pastas temporarias...
start "" "%temp%"
start "" "%SystemRoot%\SoftwareDistribution\Download"
start "" "%LocalAppData%\Microsoft\Windows\Explorer"
start "" "C:\Windows\Prefetch"

echo.
echo Etapa 2: Executando SFC...
sfc /scannow

echo.
echo Etapa 3: Limpando arquivos temporarios...
del /f /s /q "%temp%\*.*"
del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*.*"
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\*.*"
del /f /s /q "C:\Windows\Prefetch\*.*"
pause
goto menu

:updateGp
gpupdate /force
pause
goto menu

:cpu
wmic path Win32_PerfFormattedData_PerfProc_Process get Name,PercentProcessorTime ^| sort
pause
goto menu

:compartilhamento
powershell -Command "Set-SmbClientConfiguration -RequireSecuritySignature $false -Confirm:$false"
powershell -Command "Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Confirm:$false"
echo Acesso a compartilhamentos liberado.
pause
goto menu

::–––––––––––––––––––––––––––––––––––––––––––––
:: MENU SUPORTE PROFISSIONAL
:profissional
cls
echo ==== Suporte Profissional - by Cauã Philip Silva ====
echo  1  - Verificar e Reparar Disco (CHKDSK)
echo  2  - Reparar Arquivos do Sistema (SFC)
echo  3  - Limpar Arquivos Temporarios
echo  4  - Verificar Erros de Memoria (Diagnostico)
echo  5  - Restaurar Sistema
echo  6  - Testar Conectividade de Rede
echo  7  - Gerenciar Processos
echo  8  - Backup de Drivers
echo  9  - Verificar Atualizacoes do Windows
echo 10  - Informacoes do Sistema
echo 11  - Limpar Cache DNS
echo 12  - Reiniciar Servicos de Rede
echo 13  - Desfragmentar Disco
echo 14  - Gerenciar Usuarios Locais
echo 15  - Verificar Integridade com DISM
echo 16  - Ativar/Desativar Firewall
echo 17  - Ver Logs de Eventos
echo 18  - Testar Velocidade do Disco
echo 19  - Criar Ponto de Restauracao
echo 20  - Executar Comando Personalizado
echo 21  - Gerenciar Aplicativos (winget)
echo 22  - Instalar Impressora pela Rede
echo 23  - Abrir Politica de Seguranca Local
echo 24  - Permitir/Negar Logon Local
echo 25  - Voltar ao menu principal
echo 26  - Manutencao Avancada
echo =====================================================
set /p op2=Escolha uma opcao (1-26): 

if "%op2%"=="1"  goto chkdsk
if "%op2%"=="2"  goto sfc2
if "%op2%"=="3"  goto cleantemp
if "%op2%"=="4"  goto memdiag
if "%op2%"=="5"  goto restoresys
if "%op2%"=="6"  start cmd /k "ping 8.8.8.8 & pause" & goto profissional
if "%op2%"=="7"  goto listproc
if "%op2%"=="8"  goto backdrivers
if "%op2%"=="9"  goto winupd
if "%op2%"=="10" goto sysinfo
if "%op2%"=="11" goto flushdns2
if "%op2%"=="12" goto netrestart
if "%op2%"=="13" goto defrag
if "%op2%"=="14" goto userslocal
if "%op2%"=="15" goto dism
if "%op2%"=="16" goto firewall
if "%op2%"=="17" goto eventlog
if "%op2%"=="18" goto diskspd
if "%op2%"=="19" goto restorept
if "%op2%"=="20" goto customcmd
if "%op2%"=="21" goto winget
if "%op2%"=="22" goto netprinter
if "%op2%"=="23" goto seclocal
if "%op2%"=="24" goto logon
if "%op2%"=="25" goto menu
if "%op2%"=="26" goto manutencao

echo Opcao invalida.
pause
goto profissional

:chkdsk
chkdsk C: /f /r
pause
goto profissional

:sfc2
sfc /scannow
pause
goto profissional

:cleantemp
echo Limpando arquivos temporarios...
del /f /s /q "%temp%\*.*"
del /f /s /q "%windir%\Temp\*.*"
pause
goto profissional

:memdiag
echo Iniciando Diagnostico de Memoria...
mdsched.exe
pause
goto profissional

:restoresys
echo Abrindo Restauracao do Sistema...
rstrui.exe
pause
goto profissional

:listproc
tasklist
pause
goto profissional

:backdrivers
echo Exportando lista de drivers instalados...
dism /online /export-driver /destination:"%userprofile%\Desktop\DriverBackup"
pause
goto profissional

:winupd
echo Verificando atualizacoes...
powershell -Command "Get-WindowsUpdateLog"
pause
goto profissional

:sysinfo
systeminfo
pause
goto profissional

:flushdns2
ipconfig /flushdns
pause
goto profissional

:netrestart
net stop dhcp & net start dhcp
net stop dnscache & net start dnscache
echo Servicos de rede reiniciados.
pause
goto profissional

:defrag
defrag C: /U /V
pause
goto profissional

:userslocal
net user
pause
goto profissional

:dism
dism /online /cleanup-image /restorehealth
pause
goto profissional

:firewall
echo Escolha: [1] Ativar  [2] Desativar
set /p f=
if "%f%"=="1" netsh advfirewall set allprofiles state on
if "%f%"=="2" netsh advfirewall set allprofiles state off
pause
goto profissional

:eventlog
eventvwr
goto profissional

:diskspd
winsat disk -seq
pause
goto profissional

:restorept
wmic /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Ponto Criado",100,7
pause
goto profissional

:customcmd
set /p cmdExec=Digite o comando:
%cmdExec%
pause
goto profissional

:winget
echo Listando apps via winget...
winget list
pause
goto profissional

:netprinter
set /p printer=\\Servidor\Printer:
rundll32 printui.dll,PrintUIEntry /in /n "%printer%"
pause
goto profissional

:seclocal
start secpol.msc
pause
goto profissional

:logon
start secpol.msc
echo Configure Logon Rights em Políticas Locais > Atribuição de Direitos de Usuário
pause
goto profissional

::–––––––––––––––––––––––––––––––––––––––––––––
:: MENU MANUTENÇÃO AVANÇADA
:manutencao
cls
echo ===== Manutencao Avancada =====
echo  1  - Relatorio de Espaco em Disco
echo  2  - Uso de CPU e Memoria (typeperf)
echo  3  - Relatorio de Energia (powercfg)
echo  4  - Relatorio de Bateria (powercfg)
echo  5  - Portas Abertas (netstat)
echo  6  - Traceroute
echo  7  - Interfaces de Rede
echo  8  - Habilitar/Desabilitar Interface
echo  9  - Status Windows Defender
echo 10  - Scan Rapido com Defender
echo 11  - Limpar Cache Microsoft Store
echo 12  - Cleanup do Windows Update
echo 13  - Backup do Registro
echo 14  - Reset de Politicas de Seguranca
echo 15  - Exportar Logs de Eventos
echo 16  - Limpar Logs de Eventos
echo 17  - Gerenciar Servicos (sc)
echo 18  - Gerenciar Tarefas Agendadas
echo 19  - Limpar Cache Navegadores
echo 20  - Voltar ao Suporte Profissional
echo ================================
set /p m=Escolha uma opcao (1-20): 

if "%m%

