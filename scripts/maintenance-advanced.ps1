#requires -RunAsAdministrator

# --- Forçar UTF-8 (corrige acentuação em consoles antigos) ---
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
} catch {}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$OutputEncoding = [System.Text.Encoding]::UTF8
# -------------------------------------------------------------

<#
    MENU DO SUPORTE TECNICO (PowerShell)
    Autor: André Forlin Dosciati
#>

# ========================= Utilitários =========================
function Pause { Read-Host "Pressione ENTER para continuar" | Out-Null }
function Confirm($msg) {
    $r = Read-Host "$msg [S/N]"
    return ($r -match '^[sSyY]')
}

# Evitar saída verbosa excessiva
$ErrorActionPreference = 'Continue'

# ========================= Cabeçalho =========================
function Show-Header {
    Clear-Host
    Write-Host "==============================================="
    Write-Host "           MENU DO SUPORTE TECNICO             "
    Write-Host "     Autor: André Forlin Dosciati (PowerShell) "
    Write-Host "==============================================="
}

# ========================= Menu Principal =========================
function Show-MainMenu {
    Show-Header
    Write-Host "0 - Sair"
    Write-Host "1 - Rede"
    Write-Host "2 - Impressoras"
    Write-Host "3 - Sistema"
    Write-Host "4 - Suporte Profissional"
    Write-Host "==============================================="
    $op = Read-Host "Escolha uma opção"
    switch ($op) {
        '0' { return }
        '1' { Show-NetworkMenu }
        '2' { Show-PrinterMenu }
        '3' { Show-SystemMenu }
        '4' { Show-ProMenu }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-MainMenu
}

# ========================= REDE =========================
function Show-NetworkMenu {
    Show-Header
    Write-Host "==================== REDE ====================="
    Write-Host "0 - Voltar"
    Write-Host "1 - Informações completas de rede (ipconfig /all)"
    Write-Host "2 - Flush DNS"
    Write-Host "3 - Ping um servidor"
    Write-Host "4 - Reset Winsock / TCP-IP"
    Write-Host "5 - Tabela de rotas (route print)"
    Write-Host "==============================================="
    $op = Read-Host "Escolha uma opção"
    switch ($op) {
        '0' { return }
        '1' { ipconfig /all | Out-Host; Pause }
        '2' { ipconfig /flushdns | Out-Host; Pause }
        '3' {
            $t = Read-Host "Nome ou IP do destino"
            if ($t) { Test-Connection -ComputerName $t -Count 4 | Out-Host }
            Pause
        }
        '4' {
            netsh winsock reset | Out-Host
            netsh int ip reset | Out-Host
            Write-Host "Reinicie o computador para aplicar."
            Pause
        }
        '5' { route print | Out-Host; Pause }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-NetworkMenu
}

# ========================= IMPRESSORAS =========================
function Fix-Print-0x0000011b {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f | Out-Host
    Write-Host "Erro 0x0000011b: valor definido para 0 (requer reinicialização do serviço Spooler)."
}

function Fix-Print-0x00000bcb {
    # Caminho conhecido para a correção do 0x00000bcb (PointAndPrint)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f | Out-Host
    Write-Host "Erro 0x00000bcb: restrição de instalação de driver desabilitada (temporariamente)."
}

function Fix-Print-0x00000709 {
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f | Out-Host
    Write-Host "Erro 0x00000709: uso de NamedPipe habilitado."
}

function Restart-Spooler {
    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Service -Name Spooler
    Write-Host "Spooler reiniciado com sucesso."
}

function Show-PrinterMenu {
    Show-Header
    Write-Host "================ IMPRESSORAS ================="
    Write-Host "0 - Voltar"
    Write-Host "1 - Corrigir 0x0000011b"
    Write-Host "2 - Corrigir 0x00000bcb"
    Write-Host "3 - Corrigir 0x00000709"
    Write-Host "4 - Reiniciar Spooler"
    Write-Host "==============================================="
    $op = Read-Host "Escolha uma opção"
    switch ($op) {
        '0' { return }
        '1' { Fix-Print-0x0000011b; Pause }
        '2' { Fix-Print-0x00000bcb; Pause }
        '3' { Fix-Print-0x00000709; Pause }
        '4' { Restart-Spooler; Pause }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-PrinterMenu
}

# ========================= SISTEMA =========================
function Show-SystemMenu {
    Show-Header
    Write-Host "================== SISTEMA ===================="
    Write-Host "0 - Voltar"
    Write-Host "1 - Reiniciar Computador"
    Write-Host "2 - Limpeza de Lentidão (Temp + SFC)"
    Write-Host "3 - Atualizar Group Policy (gpupdate /force)"
    Write-Host "4 - Processos com maior uso de CPU"
    Write-Host "5 - Liberar acesso a compartilhamentos (SMB guest/assinatura)"
    Write-Host "==============================================="
    $op = Read-Host "Escolha uma opção"
    switch ($op) {
        '0' { return }
        '1' { Restart-Computer -Force }
        '2' { Invoke-SlowFix }
        '3' { gpupdate /force | Out-Host; Pause }
        '4' { Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 Name,CPU,Id | Format-Table -AutoSize | Out-Host; Pause }
        '5' {
            Set-SmbClientConfiguration -RequireSecuritySignature $false -Force | Out-Null
            Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force | Out-Null
            Write-Host "Acesso a compartilhamentos liberado (guest logon e sem assinatura)."
            Pause
        }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-SystemMenu
}

function Invoke-SlowFix {
    Write-Host "Abrindo pastas temporárias..."
    Start-Process explorer "$env:TEMP"
    Start-Process explorer "$env:SystemRoot\SoftwareDistribution\Download"
    Start-Process explorer "$env:LocalAppData\Microsoft\Windows\Explorer"
    if (Test-Path "C:\Windows\Prefetch") { Start-Process explorer "C:\Windows\Prefetch" }

    Write-Host "`nExecutando SFC..."
    sfc /scannow | Out-Host

    Write-Host "`nLimpando arquivos temporários..."
    $paths = @("$env:TEMP\*.*",
               "$env:SystemRoot\SoftwareDistribution\Download\*.*",
               "$env:LocalAppData\Microsoft\Windows\Explorer\*.*",
               "C:\Windows\Prefetch\*.*")
    foreach ($p in $paths) { Remove-Item $p -Force -Recurse -ErrorAction SilentlyContinue }
    Write-Host "Limpeza concluída."
    Pause
}

# ========================= SUPORTE PROFISSIONAL =========================
function Show-ProMenu {
    Show-Header
    Write-Host "==== SUPORTE PROFISSIONAL ===="
    Write-Host " 0  - Voltar"
    Write-Host " 1  - Verificar/Reparar Disco (CHKDSK)"
    Write-Host " 2  - Reparar Arquivos do Sistema (SFC)"
    Write-Host " 3  - Limpar Arquivos Temporários"
    Write-Host " 4  - Diagnóstico de Memória"
    Write-Host " 5  - Restaurar Sistema"
    Write-Host " 6  - Testar Conectividade (ping 8.8.8.8)"
    Write-Host " 7  - Listar Processos"
    Write-Host " 8  - Backup de Drivers (DISM export-driver)"
    Write-Host " 9  - Verificar Log de Update (Get-WindowsUpdateLog)"
    Write-Host "10  - Informações do Sistema"
    Write-Host "11  - Limpar Cache DNS"
    Write-Host "12  - Reiniciar Serviços de Rede"
    Write-Host "13  - Desfragmentar Disco"
    Write-Host "14  - Usuários Locais (lista/criação rápida)"
    Write-Host "15  - DISM RestoreHealth"
    Write-Host "16  - Firewall: Ativar/Desativar"
    Write-Host "17  - Visualizar Logs de Eventos"
    Write-Host "18  - Testar Velocidade do Disco (winsat)"
    Write-Host "19  - Criar Ponto de Restauração"
    Write-Host "20  - Executar Comando Personalizado"
    Write-Host "21  - Gerenciar Aplicativos (winget)"
    Write-Host "22  - Instalar Impressora pela Rede"
    Write-Host "23  - Abrir Política de Segurança Local"
    Write-Host "24  - Permitir/Negar Logon Local (secpol)"
    Write-Host "25  - Voltar ao menu principal"
    Write-Host "26  - Manutenção Avançada"
    Write-Host "================================"
    $op = Read-Host "Escolha uma opção (1-26)"
    switch ($op) {
        '0'  { return }
        '1'  { chkdsk C: /f /r | Out-Host; Pause }
        '2'  { sfc /scannow | Out-Host; Pause }
        '3'  { Invoke-CleanTemp }
        '4'  { Start-Process mdsched.exe; Pause }
        '5'  { Start-Process rstrui.exe; Pause }
        '6'  { Start-Process cmd -ArgumentList '/k ping 8.8.8.8 & pause' }
        '7'  { Get-Process | Sort-Object CPU -Descending | Select-Object -First 30 Name,Id,CPU,WS | Format-Table -AutoSize | Out-Host; Pause }
        '8'  { $dest="$env:USERPROFILE\Desktop\DriverBackup"; New-Item -ItemType Directory -Force -Path $dest | Out-Null; dism /online /export-driver /destination:"$dest" | Out-Host; Pause }
        '9'  { powershell -Command "Get-WindowsUpdateLog" | Out-Host; Pause }
        '10' { systeminfo | Out-Host; Pause }
        '11' { ipconfig /flushdns | Out-Host; Pause }
        '12' { Restart-NetworkServices }
        '13' { defrag C: /U /V | Out-Host; Pause }
        '14' { Show-UsersLocal }
        '15' { DISM /Online /Cleanup-Image /RestoreHealth | Out-Host; Pause }
        '16' { Show-FirewallMenu }
        '17' { eventvwr.msc; Pause }
        '18' { winsat disk | Out-Host; Pause }
        '19' { Checkpoint-Computer -Description "ManualRestorePoint" -RestorePointType "MODIFY_SETTINGS"; Write-Host "Ponto de restauração criado (se habilitado)."; Pause }
        '20' { $cmd = Read-Host "Digite o comando para executar"; if ($cmd) { Invoke-Expression $cmd | Out-Host }; Pause }
        '21' { winget list | Out-Host; Pause }
        '22' { Install-NetworkPrinter }
        '23' { Start-Process secpol.msc }
        '24' { Write-Host "Utilize secpol.msc -> Políticas Locais -> Atribuição de direitos de usuário -> Permitir/Negar logon local."; Pause }
        '25' { return }
        '26' { Show-Maintenance }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-ProMenu
}

function Invoke-CleanTemp {
    $paths = @("$env:TEMP\*.*",
               "$env:SystemRoot\SoftwareDistribution\Download\*.*",
               "$env:LocalAppData\Microsoft\Windows\Explorer\*.*",
               "C:\Windows\Prefetch\*.*")
    foreach ($p in $paths) { Remove-Item $p -Force -Recurse -ErrorAction SilentlyContinue }
    Write-Host "Arquivos temporários limpos."
    Pause
}

function Restart-NetworkServices {
    $svcs = 'Dnscache','Dhcp','NlaSvc'
    foreach ($s in $svcs) { Get-Service $s -ErrorAction SilentlyContinue | Restart-Service -Force -ErrorAction SilentlyContinue }
    Write-Host "Serviços de rede reiniciados (se existentes)."
    Pause
}

function Show-UsersLocal {
    Write-Host "Usuários locais:"; Get-LocalUser | Select-Object Name,Enabled,LastLogon | Format-Table -AutoSize | Out-Host
    if (Confirm "Deseja criar rapidamente um usuário local?") {
        $u = Read-Host "Nome do usuário"
        $p = Read-Host "Senha" -AsSecureString
        try { New-LocalUser -Name $u -Password $p -FullName $u -PasswordNeverExpires:$true; Add-LocalGroupMember -Group 'Users' -Member $u; Write-Host "Usuário $u criado." }
        catch { Write-Host "Falha ao criar usuário: $($_.Exception.Message)" }
    }
    Pause
}

function Show-FirewallMenu {
    Write-Host "Firewall:"
    Write-Host "1 - Ativar todos perfis"
    Write-Host "2 - Desativar todos perfis"
    $f = Read-Host "Escolha"
    if ($f -eq '1') { netsh advfirewall set allprofiles state on | Out-Host }
    elseif ($f -eq '2') { netsh advfirewall set allprofiles state off | Out-Host }
    else { Write-Host "Opção inválida." }
    Pause
}

function Install-NetworkPrinter {
    $path = Read-Host "Caminho da impressora (ex.: \\servidor\\fila)"
    if ($path) {
        try {
            Add-Printer -ConnectionName $path
            Write-Host "Impressora $path instalada."
        } catch {
            Write-Host "Falha ao instalar: $($_.Exception.Message)"
        }
    }
    Pause
}

# ========================= Manutenção Avançada (submenu) =========================
function Show-Maintenance {
    Show-Header
    Write-Host "========= MANUTENÇÃO AVANÇADA ========="
    Write-Host " 1  - DISM StartComponentCleanup"
    Write-Host " 2  - DISM AnalyzeComponentStore"
    Write-Host " 3  - Reset WU (wuauserv, bits, catroot2, SoftwareDistribution)"
    Write-Host " 4  - Reparar WMI (winmgmt)"
    Write-Host " 5  - Limpar Prefetch/Temp/MS Store cache"
    Write-Host " 6  - Traceroute (tracert 8.8.8.8)"
    Write-Host " 7  - Interfaces de Rede (ipconfig /all)"
    Write-Host " 8  - Habilitar/Desabilitar Interface"
    Write-Host " 9  - Status Windows Defender"
    Write-Host "10  - Scan rápido Windows Defender"
    Write-Host "11  - Limpar Cache Microsoft Store"
    Write-Host "12  - Cleanup Windows Update"
    Write-Host "13  - Backup do Registro (HKLM + HKCU)"
    Write-Host "14  - Reset Políticas de Segurança (secedit)"
    Write-Host "15  - Exportar Logs de Eventos (Application/System)"
    Write-Host "16  - Limpar Logs de Eventos (Application/System)"
    Write-Host "17  - Gerenciar Serviços (abrir services.msc)"
    Write-Host "18  - Tarefas Agendadas (abrir taskschd.msc)"
    Write-Host "19  - Limpar cache navegadores (Edge/Chrome/Firefox perfis padrão)"
    Write-Host "20  - Voltar"
    $m = Read-Host "Escolha (1-20)"
    switch ($m) {
        '1'  { DISM /Online /Cleanup-Image /StartComponentCleanup | Out-Host; Pause }
        '2'  { DISM /Online /Cleanup-Image /AnalyzeComponentStore | Out-Host; Pause }
        '3'  { Reset-WU }
        '4'  { winmgmt /verifyrepository | Out-Host; winmgmt /salvagerepository | Out-Host; Pause }
        '5'  { Invoke-CleanTemp; Clear-MSStoreCache }
        '6'  { tracert 8.8.8.8 | Out-Host; Pause }
        '7'  { ipconfig /all | Out-Host; Pause }
        '8'  { Toggle-NIC }
        '9'  { Get-MpComputerStatus | Select AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled | Format-List | Out-Host; Pause }
        '10' { Start-MpScan -ScanType QuickScan | Out-Host; Pause }
        '11' { Clear-MSStoreCache }
        '12' { DISM /Online /Cleanup-Image /StartComponentCleanup | Out-Host; Pause }
        '13' { Backup-Registry }
        '14' { secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb | Out-Host; Pause }
        '15' { wevtutil epl Application "$env:USERPROFILE\Desktop\Application.evtx"; wevtutil epl System "$env:USERPROFILE\Desktop\System.evtx"; Write-Host "Logs exportados para a Área de Trabalho."; Pause }
        '16' { if (Confirm "Deseja apagar logs Application/System?") { wevtutil cl Application; wevtutil cl System; Write-Host "Logs limpos." } ; Pause }
        '17' { Start-Process services.msc }
        '18' { Start-Process taskschd.msc }
        '19' { Clear-BrowserCaches }
        '20' { return }
        default { Write-Host "Opção inválida."; Pause }
    }
    Show-Maintenance
}

function Reset-WU {
    $services = 'wuauserv','bits','cryptsvc'
    foreach ($s in $services) { Stop-Service $s -Force -ErrorAction SilentlyContinue }
    Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\System32\catroot2" -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($s in $services) { Start-Service $s -ErrorAction SilentlyContinue }
    Write-Host "Windows Update resetado."
    Pause
}

function Clear-MSStoreCache {
    wsreset.exe | Out-Host
    Write-Host "Cache da Microsoft Store limpo."
    Pause
}

function Toggle-NIC {
    Get-NetAdapter | Format-Table -AutoSize | Out-Host
    $name = Read-Host "Digite o Nome da Interface para alternar (Enable/Disable)"
    if (-not $name) { return }
    $adp = Get-NetAdapter -Name $name -ErrorAction SilentlyContinue
    if (-not $adp) { Write-Host "Interface não encontrada."; Pause; return }
    if ($adp.Status -eq 'Up') { Disable-NetAdapter -Name $name -Confirm:$false }
    else { Enable-NetAdapter -Name $name -Confirm:$false }
    Pause
}

function Backup-Registry {
    $desk = "$env:USERPROFILE\Desktop"
    reg export HKLM "$desk\HKLM_backup.reg" /y | Out-Host
    reg export HKCU "$desk\HKCU_backup.reg" /y | Out-Host
    Write-Host "Backup do Registro exportado para a Área de Trabalho."
    Pause
}

# ========================= Start =========================
Show-MainMenu