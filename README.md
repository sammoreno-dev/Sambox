# Sambox

![License](https://img.shields.io/badge/License-BSD%202--Clause-blue) ![Language](https://img.shields.io/badge/Language-Shell-green)

**Toolbox para administradores e entusiastas do minimalismo, feita 100% em Bash puro.**

Uma central modular, leve e de alta eficiência para administração, diagnóstico e gerenciamento de pacotes em sistemas Linux — desenvolvida sem amarras ideológicas e focada em performance bruta.

---

# 🏷️ Origem do Nome (Sambox)

O nome **Sambox** reflete a união entre autoria, utilidade prática e arquitetura limpa:

- **Sam:** A minha assinatura de propriedade técnica e minha responsabilidade como criador (**Sam** Moreno).
- **Box:** O conceito vem de uma caixa de ferramentas minimalista e cirúrgica (*Tool**box***), projetada para atuar como uma central de controle ou painel de controle enxuto, sem o inchaço (*bloatware*) e os atritos que poluem os utilitários de mercado.

---

## ⚙️ Filosofia do Sambox

- **Bash Puro:** Sem Python, C++, ou interpretadores externos redundantes.
- **Zero Dependências de Interface:** Apenas comandos internos do Bash (`builtins`) + utilitários POSIX fundamentais (`grep`, `awk`, `sed`, `cat`). Zero dependência de `whiptail`, `dialog` ou interfaces gráficas (GUI).
- **Universalidade CLI/TUI:** Interface limpa e minimalista renderizada via códigos de escape ANSI nativos. Funciona instantaneamente em qualquer terminal mínimo ou sessão remota via SSH.
- **Arquitetura Modular:** Cada funcionalidade reside em seu próprio módulo isolado, carregado dinamicamente via `source` na inicialização do motor.

---

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

## Opcional: Instalação no Sistema

Para invocar o Sambox de qualquer lugar do terminal, crie um link simplificado no seu $PATH:

```bash
sudo ln -s "$(pwd)/sambox" /usr/local/bin/sambox
sambox
```

## 📦 Módulos Disponíveis

| **Contexto** | **Arquivo** | **Função Principal** | **Descrição** |
| --- | --- | --- | --- |
| **Hardware** | `modules/m_hardware.sh` | `menu_hardware_central` | Central de diagnósticos: performance de CPU/clocks, suporte KVM, barra ASCII de RAM, detecção de mídia (NVMe/SSD/HDD), sensores térmicos e DMI/BIOS. |
| **System** | `modules/m_system.sh` | `purge_system_bloat` | Limpeza de caches residuais, eliminação de logs antigos e liberação segura de RAM via drop_caches. |
| **Uninstaller** | `modules/m_uninstaller.sh` | `menu_uninstall_central` | Central de remoção: desinstalação completa de pacotes (`purge`), remoção de chaves GPG/repositórios externos e eliminação de processos ociosos e coisas que são inúteis pro user em segundo plano. |
| **Network** | `modules/m_network.sh` | `ssh_fast_connect` | Gerenciador ágil de aliases e IPs locais para conexões remotas simplificadas via SSH(Secure Shell), além de diagnóstico físico de placas de rede e instalação de firmwares para não deixar na mão quem precisa de placa de rede ou Wi-Fi. |
| **Packages** | `modules/m_packages.sh` | `menu_packages_central` | Central APT: Ativação de repositórios (`contrib/non-free`), instalação de drivers de GPU, Wine mínimo, ambientes mais leves (LXQt/XFCE/Cinnamon), upgrade de sistema, instalação do File Roller nativo via APT, Axel também em APT e QEMU em APT também. |
| **SysInfo** | `modules/m_sysinfo.sh` | `show_system_info` | Resumo conciso e em tempo real do sistema (OS, Kernel, RAM, Uptime) + função integrada de **Source Dump** para consolidar ou exportar os códigos-fontes da toolbox via CLI para auditoria rápida e sem fricção. |

###### (Nota: Ambientes pesados/inflados e altamente ideológicos como GNOME/KDE e navegadores com contradições e hipocrisias de mercado como Firefox foram cirurgicamente removidos do escopo de automação).

## 📂 Estrutura do Projeto:

```
sambox/
├── sambox                  # Entry-point principal (Orquestrador de módulos)
├── modules/
│   ├── m_hardware.sh       # Diagnóstico de hardware e monitoramento de CPU
│   ├── m_system.sh         # Ferramentas de manutenção e debloat de caches
│   ├── m_uninstaller.sh    # Central de desinstalação profunda e remoção de repositórios
│   ├── m_network.sh        # Gerenciador de rede, SSH e firmwares proprietários
│   ├── m_packages.sh       # Central de automação APT, drivers e virtualização
│   └── m_sysinfo.sh        # Visão geral do sistema e exportador/dump de código-fonte
├── LICENSE                 # Termos da licença BSD-2-Clause
└── README.md               # Este arquivo de documentação
```

## 🛠️ Requisitos Mínimos:

> **Interpretador: Bash** >= 4.0 (O Sambox roda em qualquer "batata eletrônica" estável, gastando poucos Megabytes de RAM).

> **Utilitários:** Ferramentas POSIX padrão do ecossistema Linux (`grep`, `awk`, `sed`, `lspci`, `curl`).

> **Terminal:** Suporte a codificação UTF-8 (para renderização correta de caixas de texto e símbolos) e suporte a cores ANSI.

> **Privilégios:** Acesso de superusuário (`sudo`) é requerido exclusivamente para a execução de tarefas que modificam o sistema (limpeza profunda, alteração de repositórios e instalações do `apt`).

##

## ⚖️ Licença

Distribuído sob os termos estáveis da **BSD 2-Clause License (Simplified)** — veja o arquivo [LICENSE](https://github.com/sammoreno-dev/sambox/blob/main/LICENSE) para detalhes técnicos. Uma licença pacífica, pragmática, comercialmente livre e sem atritos ou policiamentos ideológicos.

Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.
