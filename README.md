<p align="center">
  <img src="https://img.shields.io/badge/status-stable-brightgreen?style=for-the-badge" alt="Status: Stable"/>
  <img src="https://img.shields.io/badge/stack-PowerShell-blue?style=for-the-badge" alt="Stack: PowerShell"/>
  <img src="https://img.shields.io/badge/domain-Suporte%20Técnico%20%26%20Servidores-334155?style=for-the-badge" alt="Domínio: Suporte Técnico & Servidores"/>
  <img src="https://img.shields.io/badge/version-2.0-0ea5e9?style=for-the-badge" alt="Versão"/>
  <img src="https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge" alt="License: MIT"/>
</p>

# 🛠️ Maintenance Toolkit (PowerShell)

Conjunto de scripts PowerShell para suporte técnico e administração de sistemas Windows.  
Este repositório contém duas versões principais:

- **maintenance-advanced.ps1** → voltado para **estações de trabalho** e **helpdesk avançado**
- **maintenance-server.ps1** → voltado para **servidores Windows**, com foco em AD, DNS/DHCP, Hyper-V, Clustering e administração remota

---

## 📌 Requisitos

- **Windows PowerShell 5.1** (nativo no Windows 10/11 e Windows Server)
- **Executar como Administrador**
- Alguns módulos podem ser necessários:
  - `ServerManager` (para Roles & Features)
  - `ActiveDirectory` (RSAT AD DS Tools)
  - `DnsServer`, `DHCPServer` (se os papéis estiverem instalados)
  - `Hyper-V` (se o papel Hyper-V estiver ativo)
  - `FailoverClusters` (se clustering estiver ativo)

Para permitir a execução do script (somente na sessão atual):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## ⚡ Uso

Clone o repositório ou baixe os scripts.  
Execute no PowerShell **como Administrador**:

```powershell
.\maintenance-advanced.ps1
```
ou
```powershell
.\maintenance-server.ps1
```

---

## 🖥️ maintenance-advanced.ps1

<p align="left">
  <img src="https://img.shields.io/badge/compatibility-Windows%2010%2F11-blueviolet?style=for-the-badge" alt="Compatibilidade: Windows 10/11"/>
  <img src="https://img.shields.io/badge/focus-Helpdesk%20%26%20Desktop%20Advanced-lightgrey?style=for-the-badge" alt="Foco: Helpdesk & Desktop"/>
</p>

Voltado para **estações de trabalho** (Windows 10/11).  
Principais menus:

- **Rede** → ipconfig, flushdns, ping, reset winsock/TCP-IP
- **Impressoras** → listar impressoras, spooler, instalação de impressoras de rede, correções comuns (0x0000011b/709/0bcb)
- **Manutenção** → SFC, DISM, limpeza de temporários, SystemInfo
- **Avançado** → Reset do Windows Update, WMI repair, MS Store cache, logs (exportar/limpar), Defender (status e quick scan), ponto de restauração, backup do Registro
- **Firewall** → ativar/desativar/exibir perfis
- **GPO** → gpupdate, gpresult, secpol.msc

Ideal para **helpdesk** e **suporte avançado em desktops**.

---

## 🖥️ maintenance-server.ps1 (Server Edition)

<p align="left">
  <img src="https://img.shields.io/badge/compatibility-Windows%20Server%202016%2F2019%2F2022-orange?style=for-the-badge" alt="Compatibilidade: Windows Server 2016/2019/2022"/>
  <img src="https://img.shields.io/badge/focus-Infraestrutura%20%26%20Servidores-critical?style=for-the-badge" alt="Foco: Infraestrutura & Servidores"/>
</p>

Voltado para **Windows Server**.  
Principais menus:

- **Inventário & Saúde do Servidor** → informações do sistema, uptime, serviços core (NetLogon, W32Time, DNS, DHCP, etc.)
- **Rede** → WinRM, NIC Teaming, VLAN ID, inventário de adaptadores
- **Storage & Discos** → inicializar discos, criar volumes, formatar, estender partições
- **Roles & Features** → listar/instalar/remover papéis e recursos
- **Active Directory** → consultas a usuários/computadores, health check (dcdiag/ports)
- **Hyper-V** → listar VMs, iniciar/parar VMs
- **Failover Cluster** → status do cluster e grupos
- **DNS / DHCP** → visão geral de zonas e escopos
- **Updates & Servicing** → DISM (RestoreHealth, Cleanup, Analyze), Reset Windows Update
- **Segurança & Firewall** → ativar/desativar firewall, criar regras rápidas de porta
- **Logs & Monitoramento** → exportar/limpar logs, abrir Event Viewer, health de serviços
- **Administração remota** → definir alvo remoto e executar ações via `Invoke-Command`

Inclui **Transcript automático** (logs de execução salvos em `C:\ProgramData\Maint-Logs`).

---

## 🔍 Comparativo de Menus

| **Funcionalidade**        | **Advanced (Desktop/Helpdesk)** | **Server Edition** |
|---------------------------|---------------------------------|--------------------|
| **Rede**                  | ipconfig, flushdns, ping, reset winsock | Inventário de NICs, WinRM, NIC Teaming, VLAN ID |
| **Impressoras**           | Listar impressoras, spooler, instalar de rede, correções 0x0000011b/709/0bcb | ❌ |
| **Manutenção**            | SFC, DISM, limpar temporários, SystemInfo | Substituído por *Servicing* (DISM, Reset WU) |
| **Avançado**              | Reset WU, WMI repair, MS Store cache, logs, Defender, NIC toggle, restore point, backup do registro | Incluído em menus separados (Servicing, Logs, Segurança) |
| **Firewall**              | Ativar/desativar perfis, exibir estado | Ativar/desativar, exibir estado, criar regra inbound rápida |
| **GPO**                   | gpupdate, gpresult, secpol.msc | ❌ (uso de GPO centralizado no AD) |
| **Inventário**            | Básico (SystemInfo) | Detalhado (hardware, uptime, BIOS, RAM, CPU, serviços core) |
| **Roles & Features**      | ❌ | Listar, instalar, remover roles/features |
| **Active Directory**      | ❌ | Get-ADUser, Get-ADComputer, dcdiag, health check |
| **Hyper-V**               | ❌ | Listar VMs, iniciar/parar |
| **Failover Cluster**      | ❌ | Status do cluster e grupos |
| **DNS / DHCP**            | ❌ | Visão geral de zonas DNS e escopos DHCP |
| **Logs & Monitoramento**  | Exportar/limpar Application/System | Exportar/limpar, health de serviços, transcript automático |
| **Administração Remota**  | ❌ | Definir alvo remoto e executar via `Invoke-Command` |

✅ = incluído  
❌ = não incluído  

---

---

## 📜 Licença

Este projeto é distribuído sob a licença MIT.  
Sinta-se livre para usar, modificar e contribuir!

---

## 🤝 Créditos

- Scripts originais: **André Forlin Dosciati**
- Conversão e refatoração para PowerShell: **GPT-5 Thinking (OpenAI)**
