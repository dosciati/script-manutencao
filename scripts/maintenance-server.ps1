#requires -RunAsAdministrator
<#
    Maintenance - Server Edition (PowerShell)
    Focused on Windows Server administration tasks.
    Author (original menus): André Forlin Dosciati
    Date: 2025-09-05
#>

# ==================== Encoding / Console ====================
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
} catch {}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$OutputEncoding = [System.Text.Encoding]::UTF8

# ==================== Utilities ====================
function Pause { Read-Host "Pressione ENTER para continuar" | Out-Null }
function Confirm($msg) { (Read-Host "$msg [S/N]") -match '^[sSyY]' }
function Try-Import($module){ try { Import-Module $module -ErrorAction Stop; $true } catch { $false } }

function Show-Header {
    Clear-Host
    Write-Host "====================================================="
    Write-Host "         SERVER EDITION - SUPORTE TECNICO            "
    Write-Host "====================================================="
    if ($Global:Target) {
        Write-Host ("Alvo remoto: {0}" -f $Global:Target)
    } else {
        Write-Host "Alvo: LOCAL"
    }
    Write-Host "====================================================="
}

# ==================== Remote Target ====================
$Global:Target = $null   # ex.: "SRV-01"
$Global:Cred   = $null

function Set-RemoteTarget {
    $name = Read-Host "Servidor-alvo (vazio = local)"
    if ($name) {
        $Global:Target = $name
        if (Confirm "Deseja informar credenciais?") { $Global:Cred = Get-Credential } else { $Global:Cred = $null }
    } else { $Global:Target = $null; $Global:Cred = $null }
}

function Run-LocalOrRemote { param([scriptblock]$Script, [object[]]$ArgumentList)
    if ($Global:Target) {
        if ($Global:Cred) { Invoke-Command -ComputerName $Global:Target -Credential $Global:Cred -ScriptBlock $Script -ArgumentList $ArgumentList }
        else { Invoke-Command -ComputerName $Global:Target -ScriptBlock $Script -ArgumentList $ArgumentList }
    } else { & $Script @ArgumentList }
}

# ==================== Capabilities ====================
function Get-ServerCapabilities {
    $isServer = $false
    try { $isServer = ((Get-CimInstance Win32_OperatingSystem).ProductType -ge 2) } catch {}
    $hasSM = Try-Import ServerManager
    $caps = [ordered]@{
        IsServer               = $isServer
        HasServerManager       = $hasSM
        HasADTools             = (Try-Import ActiveDirectory)
        HasDNSServer           = $false
        HasDHCPServer          = $false
        HasHyperV              = $false
        HasFailoverClustering  = $false
        HasDNSServerModule     = (Try-Import DnsServer)
        HasDHCPModule          = (Try-Import DHCPServer)
        HasHyperVModule        = (Try-Import Hyper-V)
        HasClusterModule       = (Try-Import FailoverClusters)
    }
    if ($hasSM) {
        try { $caps.HasDNSServer          = (Get-WindowsFeature -Name DNS -ErrorAction SilentlyContinue).InstallState -eq 'Installed' } catch {}
        try { $caps.HasDHCPServer         = (Get-WindowsFeature -Name DHCP -ErrorAction SilentlyContinue).InstallState -eq 'Installed' } catch {}
        try { $caps.HasHyperV             = (Get-WindowsFeature -Name Hyper-V -ErrorAction SilentlyContinue).InstallState -eq 'Installed' } catch {}
        try { $caps.HasFailoverClustering = (Get-WindowsFeature -Name Failover-Clustering -ErrorAction SilentlyContinue).InstallState -eq 'Installed' } catch {}
    }
    [pscustomobject]$caps
}
$Global:Caps = Get-ServerCapabilities

# ==================== Inventory & Health ====================
function Check-CoreServices {
    $names = 'NetLogon','W32Time','DNS','DHCPServer','DFSR','NTDS','WinRM'
    foreach ($n in $names) {
        $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
        if ($svc) { "{0,-15} {1}" -f $svc.Name, $svc.Status } else { "{0,-15} (não instalado)" -f $n }
    }
}

function Server-Inventory {
    Run-LocalOrRemote {
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $bios = Get-CimInstance Win32_BIOS
        [pscustomobject]@{
            Hostname = $env:COMPUTERNAME
            OS       = $os.Caption
            Version  = $os.Version
            Build    = $os.BuildNumber
            Install  = $os.InstallDate
            Uptime_d = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays,2)
            Model    = $cs.Model
            Manufacturer = $cs.Manufacturer
            BIOS     = $bios.SMBIOSBIOSVersion
            RAM_GB   = [math]::Round(($cs.TotalPhysicalMemory/1GB),2)
            CPU      = (Get-CimInstance Win32_Processor | Select -First 1 -ExpandProperty Name)
        } | Format-List * | Out-Host
    }
    Write-Host "`nServiços core:"
    Check-CoreServices
}

# ==================== Network (Server) ====================
function Configure-WinRM {
    Run-LocalOrRemote { Enable-PSRemoting -Force | Out-Null; winrm quickconfig -q | Out-Null }
    Write-Host "WinRM habilitado."
}

function Test-ServerNetwork {
    Run-LocalOrRemote {
        Write-Host "NICs:"
        Get-NetAdapter | Sort-Object Name | Format-Table Name,Status,LinkSpeed,MacAddress
        Write-Host "`nEndereços:"
        Get-NetIPAddress | Format-Table InterfaceAlias,IPAddress,PrefixLength,AddressFamily
    }
    Pause
}

function Create-NICTeam {
    $team = Read-Host "Nome do Team"
    if (-not $team) { return }
    Run-LocalOrRemote {
        param($teamName)
        $nics = (Get-NetAdapter | ? Status -eq 'Up').Name
        if ($nics.Count -lt 2) { Write-Host "Mínimo 2 NICs ativas para Teaming."; return }
        try { New-NetLbfoTeam -Name $teamName -TeamMembers $nics -Confirm:$false | Out-Host }
        catch { Write-Host "LBFO indisponível nesta versão/edição." } } -ArgumentList @($team)
    Pause
}

function Set-NICVlan {
    $nic = Read-Host "Interface"
    $vlan = Read-Host "VLAN ID"
    if ($nic -and $vlan) {
        Run-LocalOrRemote { param($n,$v) Set-NetAdapterAdvancedProperty -Name $n -RegistryKeyword 'VlanID' -RegistryValue $v }.`
            GetNewClosure().Invoke($nic, [int]$vlan)
        Write-Host "VLAN ajustada (se NIC suportar)."
    }
    Pause
}

# ==================== Storage & Disks ====================
function New-DataVolume {
    Run-LocalOrRemote {
        $disk = Get-Disk | ? PartitionStyle -eq 'RAW' | Select -First 1
        if ($null -eq $disk) { Write-Host "Nenhum disco RAW disponível."; return }
        Initialize-Disk -Number $disk.Number -PartitionStyle GPT
        $p = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
        Format-Volume -Partition $p -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
        Get-Volume -DriveLetter $p.DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size
    }
    Pause
}

function Format-ExistingVolume {
    $vol = Read-Host "Letra do volume (sem dois pontos)"
    $label = Read-Host "Rótulo"
    if (-not $vol) { return }
    Run-LocalOrRemote {
        param($v,$l)
        Format-Volume -DriveLetter $v -FileSystem NTFS -NewFileSystemLabel $l -Confirm:$false
        Get-Volume -DriveLetter $v | Format-Table DriveLetter,FileSystemLabel,FileSystem,SizeRemaining,Size } -ArgumentList @($vol, $label)
    Pause
}

function Resize-PartitionUI {
    $vol = Read-Host "Letra do volume a estender (sem dois pontos)"
    if (-not $vol) { return }
    Run-LocalOrRemote { param($v) Resize-Partition -DriveLetter $v -Size (Get-PartitionSupportedSize -DriveLetter $v).SizeMax }.`
        GetNewClosure().Invoke($vol)
    Pause
}

# ==================== Roles & Features ====================
function Show-RolesFeatures {
    if (-not $Global:Caps.HasServerManager) { Write-Host "ServerManager indisponível."; Pause; return }
    while ($true) {
        Show-Header
        Write-Host "====== ROLES & FEATURES ======"
        Write-Host "0 - Voltar"
        Write-Host "1 - Listar"
        Write-Host "2 - Instalar"
        Write-Host "3 - Remover"
        $op = Read-Host "Escolha (0-3)"
        switch ($op) {
            '0' { return }
            '1' { Run-LocalOrRemote { Get-WindowsFeature | Sort DisplayName | Format-Table Name,DisplayName,InstallState }; Pause }
            '2' {
                $name = Read-Host "Nome da feature"
                if ($name) { Run-LocalOrRemote { param($n) Install-WindowsFeature -Name $n -IncludeManagementTools | Out-Host } -ArgumentList @($name) }
                Pause
            }
            '3' {
                $name = Read-Host "Nome da feature"
                if ($name) { Run-LocalOrRemote { param($n) Uninstall-WindowsFeature -Name $n | Out-Host } -ArgumentList @($name) }
                Pause
            }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

# ==================== AD & Identity ====================
function AD-UserLookup {
    if (-not $Global:Caps.HasADTools) { Write-Host "RSAT-AD não disponível."; Pause; return }
    $u = Read-Host "sAMAccountName/UPN"
    if ($u) { Run-LocalOrRemote { param($id) Get-ADUser -Identity $id -Properties * | Select Name,SamAccountName,Enabled,WhenCreated,LastLogonDate | Format-List | Out-Host } -ArgumentList @($u) }
    Pause
}

function AD-ComputerLookup {
    if (-not $Global:Caps.HasADTools) { Write-Host "RSAT-AD não disponível."; Pause; return }
    $c = Read-Host "Nome do computador (AD)"
    if ($c) { Run-LocalOrRemote { param($id) Get-ADComputer -Identity $id -Properties * | Select Name,IPv4Address,OperatingSystem,LastLogonDate | Format-List | Out-Host } -ArgumentList @($c) }
    Pause
}

function AD-QuickHealth {
    if (-not $Global:Caps.HasADTools) { Write-Host "RSAT-AD não disponível."; Pause; return }
    Run-LocalOrRemote { try {
            $dc = (Get-ADDomainController -Discover).HostName
            Write-Host "DC Descoberto: $dc"
            Test-NetConnection $dc -Port 389 | Out-Host
            Test-NetConnection $dc -Port 53  | Out-Host
            try { dcdiag | Out-Host } catch { Write-Host "dcdiag indisponível." }
        } catch { Write-Host "Falha ao consultar AD/DC." }
    }
    Pause
}

# ==================== Hyper-V ====================
function HV-ListVM {
    if (-not $Global:Caps.HasHyperVModule) { Write-Host "Módulo Hyper-V indisponível."; Pause; return }
    Run-LocalOrRemote { Get-VM | Select Name,State,CPUUsage,MemoryAssigned | Format-Table | Out-Host }
    Pause
}
function HV-StartStopVM {
    if (-not $Global:Caps.HasHyperVModule) { Write-Host "Módulo Hyper-V indisponível."; Pause; return }
    $name = Read-Host "Nome da VM"
    if (-not $name) { return }
    $op = Read-Host "Ação (start/stop)"
    Run-LocalOrRemote {
        param($vm,$act)
        if ($act -eq 'start') { Start-VM -Name $vm | Out-Host } elseif ($act -eq 'stop') { Stop-VM -Name $vm -Force | Out-Host } else { Write-Host "Ação inválida." } } -ArgumentList @($name,$op)
    Pause
}

# ==================== Failover Cluster ====================
function Cluster-Status {
    if (-not $Global:Caps.HasClusterModule) { Write-Host "Módulo FailoverClusters indisponível."; Pause; return }
    Run-LocalOrRemote {
        Get-Cluster | Format-List Name,State
        Get-ClusterGroup | Format-Table Name,State,OwnerNode
    }
    Pause
}

# ==================== DNS / DHCP ====================
function DNS-Overview {
    if (-not ($Global:Caps.HasDNSServer -or $Global:Caps.HasDNSServerModule)) { Write-Host "DNS Server não instalado/modulo indisponível."; Pause; return }
    Run-LocalOrRemote { Get-DnsServerZone | Format-Table ZoneName,ZoneType,IsDsIntegrated }
    Pause
}

function DHCP-Overview {
    if (-not ($Global:Caps.HasDHCPServer -or $Global:Caps.HasDHCPModule)) { Write-Host "DHCP Server não instalado/modulo indisponível."; Pause; return }
    Run-LocalOrRemote { Get-DhcpServerv4Scope | Format-Table ScopeId, Name, State, LeaseDuration }
    Pause
}

# ==================== Updates & Servicing ====================
function DISM-Servicing {
    while ($true) {
        Show-Header
        Write-Host "===== SERVICING / DISM ====="
        Write-Host "0 - Voltar"
        Write-Host "1 - RestoreHealth"
        Write-Host "2 - StartComponentCleanup"
        Write-Host "3 - AnalyzeComponentStore"
        Write-Host "4 - Reset Windows Update"
        $op = Read-Host "Escolha (0-4)"
        switch ($op) {
            '0' { return }
            '1' { Run-LocalOrRemote { DISM /Online /Cleanup-Image /RestoreHealth | Out-Host }; Pause }
            '2' { Run-LocalOrRemote { DISM /Online /Cleanup-Image /StartComponentCleanup | Out-Host }; Pause }
            '3' { Run-LocalOrRemote { DISM /Online /Cleanup-Image /AnalyzeComponentStore | Out-Host }; Pause }
            '4' {
                Run-LocalOrRemote {
                    $services = 'wuauserv','bits','cryptsvc'
                    foreach ($s in $services) { Stop-Service $s -Force -ErrorAction SilentlyContinue }
                    Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:windir\System32\catroot2" -Recurse -Force -ErrorAction SilentlyContinue
                    foreach ($s in $services) { Start-Service $s -ErrorAction SilentlyContinue }
                    Write-Host "Windows Update resetado."
                }
                Pause
            }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

# ==================== Security & Firewall ====================
function Security-Firewall {
    while ($true) {
        Show-Header
        Write-Host "=========== FIREWALL & SECURITY ==========="
        Write-Host "0 - Voltar"
        Write-Host "1 - Ativar Firewall (allprofiles)"
        Write-Host "2 - Desativar Firewall (allprofiles)"
        Write-Host "3 - Mostrar estado"
        Write-Host "4 - Criar regra inbound rápida (porta)"
        $op = Read-Host "Escolha (0-4)"
        switch ($op) {
            '0' { return }
            '1' { Run-LocalOrRemote { netsh advfirewall set allprofiles state on  | Out-Host }; Pause }
            '2' { Run-LocalOrRemote { netsh advfirewall set allprofiles state off | Out-Host }; Pause }
            '3' { Run-LocalOrRemote { netsh advfirewall show allprofiles          | Out-Host }; Pause }
            '4' {
                                $port = Read-Host "Porta TCP"
                $name = Read-Host "Nome da regra (vazio = Allow TCP <porta>)"
                if ($port) {
                    if (-not $name -or $name.Trim() -eq "") { $name = "Allow TCP $port" }
                    Run-LocalOrRemote { param($p,$n) New-NetFirewallRule -DisplayName $n -Direction Inbound -Action Allow -Protocol TCP -LocalPort $p -Profile Any | Out-Host } -ArgumentList @([int]$port, $name)
                }
                Pause
    
            }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

# ==================== Logs & Monitoring ====================
function Logs-Monitor {
    while ($true) {
        Show-Header
        Write-Host "============== LOGS & MONITOR =============="
        Write-Host "0 - Voltar"
        Write-Host "1 - Exportar Application/System"
        Write-Host "2 - Limpar Application/System"
        Write-Host "3 - Abrir Event Viewer"
        Write-Host "4 - Health rápido (serviços core)"
        $op = Read-Host "Escolha (0-4)"
        switch ($op) {
            '0' { return }
            '1' { Run-LocalOrRemote { wevtutil epl Application "$env:USERPROFILE\Desktop\Application.evtx"; wevtutil epl System "$env:USERPROFILE\Desktop\System.evtx" }; Write-Host "Exportado p/ Desktop do alvo."; Pause }
            '2' {
                if (Confirm "Apagar logs Application/System?") {
                    Run-LocalOrRemote { wevtutil cl Application; wevtutil cl System }
                    Write-Host "Logs limpos."
                }
                Pause
            }
            '3' { Run-LocalOrRemote { Start-Process eventvwr.msc } }
            '4' { Server-Inventory; Pause }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

# ==================== Menus ====================
function Show-NetworkMenu {
    while ($true) {
        Show-Header
        Write-Host "================ REDE ================"
        Write-Host "0 - Voltar"
        Write-Host "1 - Inventário de rede"
        Write-Host "2 - Habilitar WinRM (PSRemoting)"
        Write-Host "3 - Criar NIC Team (LBFO)"
        Write-Host "4 - Definir VLAN em NIC"
        $op = Read-Host "Escolha (0-4)"
        switch ($op) {
            '0' { return }
            '1' { Test-ServerNetwork }
            '2' { Configure-WinRM; Pause }
            '3' { Create-NICTeam }
            '4' { Set-NICVlan }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-StorageMenu {
    while ($true) {
        Show-Header
        Write-Host "=============== STORAGE & DISKS ==============="
        Write-Host "0 - Voltar"
        Write-Host "1 - Provisionar novo volume (RAW -> NTFS)"
        Write-Host "2 - Formatar volume existente (NTFS)"
        Write-Host "3 - Estender partição até o máximo"
        $op = Read-Host "Escolha (0-3)"
        switch ($op) {
            '0' { return }
            '1' { New-DataVolume }
            '2' { Format-ExistingVolume }
            '3' { Resize-PartitionUI }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-ADMenu {
    while ($true) {
        Show-Header
        Write-Host "=============== ACTIVE DIRECTORY ==============="
        Write-Host "0 - Voltar"
        Write-Host "1 - Consultar usuário (Get-ADUser)"
        Write-Host "2 - Consultar computador (Get-ADComputer)"
        Write-Host "3 - Health rápido (dcdiag/ports)"
        $op = Read-Host "Escolha (0-3)"
        switch ($op) {
            '0' { return }
            '1' { AD-UserLookup }
            '2' { AD-ComputerLookup }
            '3' { AD-QuickHealth }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-HyperVMenu {
    while ($true) {
        Show-Header
        Write-Host "================== HYPER-V =================="
        Write-Host "0 - Voltar"
        Write-Host "1 - Listar VMs"
        Write-Host "2 - Iniciar/Parar VM"
        $op = Read-Host "Escolha (0-2)"
        switch ($op) {
            '0' { return }
            '1' { HV-ListVM }
            '2' { HV-StartStopVM }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-ClusterMenu {
    while ($true) {
        Show-Header
        Write-Host "============= FAILOVER CLUSTER ============="
        Write-Host "0 - Voltar"
        Write-Host "1 - Status do cluster e grupos"
        $op = Read-Host "Escolha (0-1)"
        switch ($op) {
            '0' { return }
            '1' { Cluster-Status }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-DNSDHCPMenu {
    while ($true) {
        Show-Header
        Write-Host "================ DNS / DHCP ================"
        Write-Host "0 - Voltar"
        Write-Host "1 - Visão geral DNS"
        Write-Host "2 - Visão geral DHCP"
        $op = Read-Host "Escolha (0-2)"
        switch ($op) {
            '0' { return }
            '1' { DNS-Overview }
            '2' { DHCP-Overview }
            default { Write-Host "Opção inválida."; Pause }
        }
    }
}

function Show-ServicingMenu { DISM-Servicing }
function Show-SecurityMenu  { Security-Firewall }
function Show-LogsMenu      { Logs-Monitor }

# ==================== Main Menu (Server Edition) ====================
function Show-MainMenu {
    # transcript for auditing
    try {
        $ts = Join-Path $env:ProgramData ("Maint-Logs\log_{0:yyyyMMdd_HHmm}.txt" -f (Get-Date))
        New-Item -ItemType Directory -Path (Split-Path $ts) -Force | Out-Null
        Start-Transcript -Path $ts -Append | Out-Null
    } catch {}

    while ($true) {
        Show-Header
        Write-Host "0  - Sair"
        Write-Host "1  - Inventário & Saúde do Servidor"
        Write-Host "2  - Rede (WinRM, NIC, VLAN, Teaming)"
        Write-Host "3  - Storage & Discos"
        Write-Host "4  - Roles & Features"
        Write-Host "5  - Active Directory"
        Write-Host "6  - Hyper-V"
        Write-Host "7  - Failover Cluster"
        Write-Host "8  - DNS / DHCP"
        Write-Host "9  - Updates & Servicing (DISM/WU)"
        Write-Host "10 - Segurança & Firewall"
        Write-Host "11 - Logs & Monitoramento"
        Write-Host "12 - Definir alvo remoto (local/servidor)"
        $op = Read-Host "Escolha (0-12)"
        switch ($op) {
            '0'  { break }
            '1'  { Server-Inventory; Pause }
            '2'  { Show-NetworkMenu }
            '3'  { Show-StorageMenu }
            '4'  { Show-RolesFeatures }
            '5'  { Show-ADMenu }
            '6'  { if ($Global:Caps.HasHyperV -or $Global:Caps.HasHyperVModule) { Show-HyperVMenu } else { Write-Host "Hyper-V não instalado."; Pause } }
            '7'  { if ($Global:Caps.HasFailoverClustering -or $Global:Caps.HasClusterModule) { Show-ClusterMenu } else { Write-Host "Failover Clustering não instalado."; Pause } }
            '8'  { Show-DNSDHCPMenu }
            '9'  { Show-ServicingMenu }
            '10' { Show-SecurityMenu }
            '11' { Show-LogsMenu }
            '12' { Set-RemoteTarget }
            default { Write-Host "Opção inválida."; Pause }
        }
    }

    try { Stop-Transcript | Out-Null } catch {}
    Write-Host "Até mais!"
}

# ==================== Start ====================
Show-MainMenu
