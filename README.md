# Sambox

![License](https://img.shields.io/badge/License-BSD%202--Clause-blue) ![Language](https://img.shields.io/badge/Language-Shell-green)

**Toolbox para SysAdmins minimalista, construída 100% em Bash puro e orientada a dados.**

Uma central modular de altíssima eficiência e agilidade bare-metal para administração, diagnóstico físico e provisionamento de infraestrutura em sistemas Linux — desenvolvida sem inchaço (*bloatware*), livre de amarras ideológicas e focada em performance bruta de execução.

---

# 🏷️ Origem do Nome

O nome **Sambox** reflete a união entre autoria, utilidade pragmática e design limpo:

- **Sam:** A assinatura de propriedade técnica e a responsabilidade do criador (**Sam** Moreno).
- **Box:** O conceito vem de uma caixa de ferramentas cirúrgica (*Tool**box***), projetada para atuar como um painel de controle em espaço de usuário, eliminando atritos e desperdício de ciclos de processamento no kernel.

---

## ⚙️ Filosofia e Diferenciais Técnicos

- **Bash Puro & Bare-Metal:** Sem Python, C++ ou interpretadores externos redundantes. O motor consome milissegundos e roda direto na tabela de símbolos da memória RAM.
- **Zero Inchaço de Interface:** Recusa estrita a dependências de `whiptail`, `dialog` ou interfaces gráficas pesadas (GUI). A TUI interativa é desenhada de forma nativa e leve através de códigos de escape ANSI.
- **Micro-Kernel em Espaço de Usuário:** Os submódulos são totalmente independentes e se auto-registram dinamicamente nos vetores globais do motor principal através de reflexão (`declare -f`), eliminando menus estáticos ou códigos fantasmas.
- **Hot-Reload em Tempo Real:** Inclui um barramento dedicado de gerenciamento de estado (`m_reload.sh`). Você pode alterar ou criar um script novo na pasta de módulos, acionar a recarga a quente e o menu se reconstrói sozinho, sem precisar fechar o terminal.
- **UX Humana e Calorosa:** Longe da frieza mecânica de scripts genéricos de mercado, o Sambox dialoga com o administrador, audita chipsets de placas de rede e processadores em tempo real e fornece feedbacks descontraídos (`ツ`).

---

## 🚀 Instalação & Uso

Clone o repositório estável e configure as permissões de execução do motor principal:

```bash
git clone https://github.com/sammoreno-dev/Sambox.git && cd Sambox && chmod +x sambox
```

Execute a ferramenta interativa diretamente:

```bash
./sambox
```

### Opcional: Invocação Global no Sistema

Para disparar o Sambox de qualquer diretório do seu terminal através do seu `$PATH`, crie um link simbólico simplificado:

```bash
sudo ln -s "$(pwd)/sambox" /usr/local/bin/sambox
sambox
```

---

## 📦 Arquitetura e Catálogo de Módulos

O ecossistema do Sambox foi cirurgicamente fatiado e miniaturizado. Os submódulos de retaguarda (*core/perf/text*) trabalham em segundo plano para que o interpretador do Bash execute apenas o código estritamente necessário.

| **Painel Mestre** | **Arquivo Físico** | **Função Alvo** | **Descrição e Recursos Humanizados** |
| --- | --- | --- | --- |
| **Menu TUI** | `modules/m_mainmenu.sh` | `menu_principal_tui` | Roteador e renderizador visual de colchetes consecutivo, agnóstico de dados e blindado contra falhas em lote. |
| **Repositórios** | `modules/m_packages_repo.sh` | `menu_repo_central` | Central essencial de OS: Injeta componentes `contrib/non-free` tanto no formato clássico quanto no moderno DEB822 (`debian.sources`) e ativa o multiarch i386. |
| **Virtualização** | `modules/m_packages_virt.sh` | `menu_virt_central` | Provisiona a pilha de hipervisor QEMU-KVM em modo headless para servidores ou acoplado à interface técnica do `virt-manager`. Audita a BIOS em tempo real. |
| **Contêineres** | `modules/m_packages_container.sh` | `menu_container_central` | Configura o deploy do Podman para contêineres *rootless* (sem root e sem deamons) e ambientes de caixas de areia híbridas via Distrobox. |
| **Manutenção** | `modules/m_system.sh` | `menu_system_central` | Faxina de disco: Orquestra a higienização do APT, remoção molecular de pacotes residuais mortos (`status rc`), vácuo do Journald e purga precisa em MB do `/var/log`. |
| **Redes & SSH** | `modules/m_network.sh` | `ssh_fast_connect` | Central de rede: Abriga o gerenciador funcional de aliases e chaves ED25519/RSA (`m_network_ssh.sh`), conexões de transmissão (`m_network_ftp.sh`), inspeção de soquetes, IP WAN e chips PCI de rede (`m_network_diag.sh`). |
| **Desinstalação** | `modules/m_uninstall.sh` | `menu_uninstall_central` | Uninstaller profundo baseado em Catálogo Único (`m_uninstall_core.sh`). Purga de forma cirúrgica as stacks de Java, VSCodium, Wine, Chromium, KVM e Podman limpando chaves GPG órfãs automaticamente. |
| **Auditoria** | `modules/m_sysinfo.sh` | `show_system_info` | Monitor de performance em memória pura sem forks lentos (`m_sysinfo_dash.sh`) + Inspetor de Hardware e exportador anônimo de logs em nuvem (**Source Dump** via `0x0.st` em `m_sysinfo_tools.sh`). |
| **Hot-Reload** | `modules/m_reload.sh` | `exec_hot_reload` | O resetador do barramento. Zera as tabelas de símbolos e re-escaneia o diretório de módulos a quente sob o comando `[R]`. |
| **Manual** | `modules/m_manual.sh` | `show_manual_menu` | Documentação interativa baseada em paginação resiliente (`_pager_view` em `m_manual_text.sh`). Explica as diretrizes de governança e recusa a travas de mercado. |

###### *(Nota de Escopo: Ambientes inflados, pesados e altamente ideológicos como GNOME/KDE, e navegadores com contradições e hipocrisias de mercado como o Firefox foram removidos das rotinas de automação).*

---

## 📂 Árvore Estrutural do Projeto

```text
Sambox/
├── sambox                     # Ponto de entrada (Despachante CLI Flags / TUI)
├── LICENSE                    # Licença BSD 2-Clause (Simplificada)
├── README.md                  # Esta documentação oficial
└── modules/
    ├── m_mainmenu.sh          # Renderizador agnóstico do banner e índices vivos
    ├── m_reload.sh            # Sistema de Hot-Reload e varredura dinâmica de estado
    ├── m_manual.sh            # Menu interativo do manual do usuário
    ├── m_manual_text.sh       # Gaveta isolada sob demanda com os textos dos capítulos
    ├── m_packages_repo.sh     # Central de mutação de espelhos APT e dpkg i386
    ├── m_packages_virt.sh     # Central de deploy e checagem de BIOS do QEMU-KVM
    ├── m_packages_container.sh # Central de provisionamento do Podman e Distrobox
    ├── m_system.sh            # Orquestrador da central de manutenção e limpeza
    ├── m_system_apt.sh        # Faxineiro em memória viva dos caches do APT e resíduos rc
    ├── m_system_logs.sh       # Compactador do Journalctl e purga física do /var/log
    ├── m_hardware.sh          # Menu de diagnóstico térmico e sensores
    ├── m_hardware_perf.sh     # Monitor de clocks e governors indexado aos cores (/sys)
    ├── m_network.sh           # Menu mestre do barramento de protocolos e rede
    ├── m_network_ssh.sh       # Gerenciador de conexões rápidas e chaves assimétricas
    ├── m_network_ftp.sh       # Cliente interativo de transmissão FTP e SFTP nativo
    ├── m_network_diag.sh      # Inspetor PCI de chipsets de rede, IP WAN e latência
    ├── m_uninstall.sh         # Menu visual de expurgo de softwares instalados
    ├── m_uninstall_core.sh    # Motor unificado de purga de pacotes e repositórios órfãos
    └── template.sh            # Blueprint padrão para a criação de novos módulos
```

---

## 🛠️ Requisitos de Execução

- **Interpretador:** Bash >= 4.0 (O Sambox opera perfeitamente em qualquer "batata eletrônica" estável, gastando o mínimo de Megabytes de RAM).
- **Utilitários Fundamentais:** Ferramentas padrão do ecossistema POSIX (`grep`, `awk`, `sed`, `lspci`, `curl`).
- **Terminal:** Suporte a codificação UTF-8 (para renderização correta das caixas de texto estruturadas) e suporte a paleta de cores ANSI.
- **Privilégios:** Acesso de superusuário (`sudo`) é requerido de forma estrita e exclusiva para a execução de tarefas que alteram arquivos protegidos do sistema (purgas dpkg, alteração de fontes e instalações do `apt`).

---

## ⚖️ Licença e Governança

Distribuído sob os termos estáveis da **BSD 2-Clause License (Simplified)** — veja o arquivo [LICENSE](https://github.com/sammoreno-dev/Sambox/blob/main/LICENSE) para detalhes técnicos. 

Uma licença pacífica, pragmática, comercialmente livre, amigável para embutir em soluções corporativas e totalmente limpa de policiamentos ideológicos ou contaminações de licenças copyleft virais.

Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.
