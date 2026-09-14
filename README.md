# Sambox

![Licença BSD](https://img.shields.io/badge/License-BSD_2--Clause-blue.svg)
![Linguagem](https://img.shields.io/badge/Bash-100%25-4EAA25.svg)
![SO](https://img.shields.io/badge/OS-Debian-A81D33.svg)


Toolbox para administradores e entusiastas do minimalismo, feita 100% em Bash puro.

Uma central modular, leve e de alta eficiência para administração, diagnóstico e gerenciamento de pacotes em sistemas Linux — desenvolvida sem amarras ideológicas e focada em performance bruta.

---

## 🏷️ Origem do Nome (Sambox)

O nome **Sambox** reflete a união entre autoria, utilidade prática e arquitetura limpa:

- **Sam:** A minha assinatura de propriedade técnica e minha responsabilidade como criador (**Sam** Moreno).
- **Box:** O conceito vem de uma caixa de ferramentas minimalista e cirúrgica (*Tool**box***), projetada para atuar como uma central de controle ou painel de controle enxuto focado, sem o inchaço (*bloatware*) e os atritos que poluem os utilitários de mercado.

## ⚙️ Filosofia do Sambox

- **Bash Puro:** Sem Python, C++, ou interpretadores externos redundantes.
- **Zero Dependências de Interface:** Apenas comandos internos do Bash (`builtins`) + utilitários POSIX fundamentais (`grep`, `awk`, `sed`, `cat`). Zero dependência de `whiptail`, `dialog` ou interfaces gráficas (GUI).
- **Universalidade CLI/TUI:** Interface limpa e minimalista renderizada via códigos de escape ANSI nativos. Funciona instantaneamente em qualquer terminal mínimo ou sessão remota via SSH.
- **Arquitetura Modular:** Cada funcionalidade reside em seu próprio módulo isolado, carregado dinamicamente via `source` na inicialização do motor.

## 🚀 Instalação & Uso

Clone o repositório e configure as permissões de execução do motor principal:

```bash
git clone https://github.com/sammoreno-dev/sambox.git
cd sambox
chmod +x sambox
```

Execute a ferramenta diretamente:

```bash
./sambox
```

### Opcional: Instalação no Sistema

Para invocar o Sambox de qualquer lugar do terminal, crie um link simplificado no seu `$PATH`:

```bash
sudo ln -s "\$(pwd)/sambox" /usr/local/bin/sambox
sambox
```

## 📦 Módulos Disponíveis

| Contexto     | Arquivo                 | Função Principal        | Descrição                                                                                                                                                                                              |
|:------------ |:----------------------- |:----------------------- |:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Hardware** | `modules/m_hardware.sh` | `check_cpu_perf`        | Diagnóstico de CPU: modelo, clocks por core e otimizações multi-core (Ex: Intel Xeon).                                                                                                                 |
| **System**   | `modules/m_system.sh`   | `purge_system_bloat`    | Limpeza fina de caches residuais, eliminação de logs antigos e liberação segura de RAM via `drop_caches`.                                                                                              |
| **Network**  | `modules/m_network.sh`  | `ssh_fast_connect`      | Gerenciador ágil de aliases e IPs locais para conexões remotas simplificadas via SSH, além de diagnóstico físico de placas de rede e instalação de firmwares.                                          |
| **Packages** | `modules/m_packages.sh` | `menu_packages_central` | Central APT: Ativação de repositórios (`contrib/non-free`), instalação de drivers de GPU, Wine limpo, ambientes lightweight (LXQt/XFCE/Cinnamon), upgrade de sistema, File Roller nativo, Axel e QEMU. |
| **SysInfo**  | `modules/m_sysinfo.sh`  | `show_system_info`      | Resumo conciso e em tempo real do sistema (OS, Kernel, RAM, Uptime) + função integrada de **Source Dump** para consolidar ou exportar os códigos-fontes da toolbox via CLI para auditoria rápida.      |

*(Nota: Ambientes pesados/inflados e altamente ideológicos como GNOME/KDE e navegadores com contradições e hipocrisias de mercado como Firefox foram cirurgicamente removidos do escopo de automação).*

## 📂 Estrutura do Projeto

```mermaid
graph TD
    %% Nós principais
    ROOT["<b>sambox/</b><br><i>Diretório Raiz</i>"]
    MAIN["<b>sambox</b><br>Entry-point / Orquestrador"]
    MODS["<b>modules/</b><br>Módulos de Execução"]
    LIC["<b>LICENSE</b><br>Licença BSD-2-Clause"]
    DOC["<b>README.md</b><br>Documentação do Projeto"]

    %% Módulos internos
    M_HW["<b>m_hardware.sh</b><br>Diagnóstico de HW e CPU"]
    M_SYS["<b>m_system.sh</b><br>Manutenção e Debloat"]
    M_NET["<b>m_network.sh</b><br>Rede, SSH e Firmwares"]
    M_PKG["<b>m_packages.sh</b><br>APT, Drivers e Virtualização"]
    M_INFO["<b>m_sysinfo.sh</b><br>Visão Geral e Dump de Código"]

    %% Conexões
    ROOT --> MAIN
    ROOT --> MODS
    ROOT --> LIC
    ROOT --> DOC

    MODS --> M_HW
    MODS --> M_SYS
    MODS --> M_NET
    MODS --> M_PKG
    MODS --> M_INFO

    %% Estilização visual (Cores)
    classDef rootStyle fill:#1f2937,stroke:#374151,color:#fff;
    classDef mainStyle fill:#2563eb,stroke:#1d4ed8,color:#fff;
    classDef modFolderStyle fill:#d97706,stroke:#b45309,color:#fff;
    classDef modFileStyle fill:#374151,stroke:#4b5563,color:#e5e7eb;
    classDef docStyle fill:#059669,stroke:#047857,color:#fff;

    class ROOT rootStyle;
    class MAIN mainStyle;
    class MODS modFolderStyle;
    class M_HW,M_SYS,M_NET,M_PKG,M_INFO modFileStyle;
    class LIC,DOC docStyle;


## 🛠️ Requisitos Mínimos

- **Interpretador:** Bash >= 4.0 (O Sambox roda em qualquer "batata eletrônica" estável, gastando poucos Megabytes de RAM).
- **Terminal:** Suporte a codificação UTF-8 (para renderização correta de caixas de texto e símbolos) e suporte a cores ANSI.
- **Utilitários:** Ferramentas POSIX padrão do ecossistema Linux (`grep`, `awk`, `sed`, `lspci`, `curl`).
- **Privilégios:** Acesso de superusuário (`sudo`) é requerido exclusivamente para a execução de tarefas que modificam o sistema (limpeza profunda, alteração de repositórios e instalações do `apt`).
  
  ## ⚖️ Licença
  
  Distribuído sob os termos estáveis da **BSD 2-Clause License (Simplified)** — veja o arquivo [LICENSE](LICENSE) para detalhes técnicos. Uma licença pacífica, pragmática, comercialmente livre e sem atritos ou policiamentos ideológicos.
  Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.


