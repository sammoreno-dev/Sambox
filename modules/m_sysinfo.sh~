#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Módulo de Informações do Sistema & Auditoria de Código (Source Dump)
# Copyright (c) 2026, Sam Moreno
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------

# Função do Menu Principal: Exibe informações gerais e gerencia o Source Dump
show_system_info() {
    clear 2>/dev/null || true
    
    local hostname kernel_version os_name uptime_raw shell_ver disk_usage
    hostname=$(hostname)
    kernel_version=$(uname -r)
    shell_ver="${BASH_VERSION}"
    
    # Captura amigável do nome da distribuição Linux
    if [[ -f /etc/os-release ]]; then
        os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
    else
        os_name="Sistemas POSIX / Linux Genérico"
    fi
    
    uptime_raw=$(uptime -p | sed 's/up //')
    
    # Cálculos leves de RAM direto do /proc/meminfo (Zero overhead)
    local mem_t_kb mem_a_kb mem_u_mb mem_t_mb
    mem_t_kb=$(grep -E '^MemTotal:' /proc/meminfo | awk '{print $2}')
    mem_a_kb=$(grep -E '^MemAvailable:' /proc/meminfo | awk '{print $2}')
    mem_t_mb=$(( mem_t_kb / 1024 ))
    mem_u_mb=$(( (mem_t_kb - mem_a_kb) / 1024 ))
    
    disk_usage=$(df -h / | awk 'NR==2 {print $5}')

    # Renderização da interface TUI
    printf "\n"
    printf "${CYAN}${BOLD}  ℹ️  Informações Gerais do Sistema${RST}\n"
    _sep
    printf "  ${BOLD}Host:${RST}          %s\n" "${hostname}"
    printf "  ${BOLD}OS:${RST}            %s\n" "${os_name}"
    printf "  ${BOLD}Kernel:${RST}        %s\n" "${kernel_version}"
    printf "  ${BOLD}Bash Version:${RST}  %s\n" "${shell_ver}"
    printf "  ${BOLD}Uptime:${RST}        %s\n" "${uptime_raw}"
    _sep
    printf "  ${BOLD}Memória RAM:${RST}   %s MB / %s MB utilizados\n" "${mem_u_mb}" "${mem_t_mb}"
    printf "  ${BOLD}Disco (/):${RST}     %s preenchido\n" "${disk_usage}"
    _sep
    printf "\n"
    
    # Sub-menu de auditoria polido com a numeração no seu padrão simétrico
    printf "  ${BOLD}AUDITORIA DE CÓDIGO-FONTE${RST}\n\n"
    printf "  ${CYAN}[1]${RST}  📝  Consolidar Source Dump localmente (/tmp)\n"
    printf "  ${CYAN}[2]${RST}  🚀  Exportar Source Dump para a Nuvem (Link Seguro via cURL)\n"
    printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
    printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"
    
    local audit_opt
    read -rp "  $(printf "${BOLD}")Selecione [0-2]:$(printf "${RST}") " audit_opt
    
    case "${audit_opt}" in
        1) _generate_source_dump "local" ;;
        2) _generate_source_dump "cloud" ;;
        0) return ;;
        *) _warn "Opção inválida no sub-menu." ;;
    esac
}

# ── Sub-função Interna Oculta de Geração e Envio de Dump ──────────────────────
_generate_source_dump() {
    local mode="$1"
    local output_file="/tmp/sambox_source_dump.txt"
    
    printf "\n${YELLOW}[+]${RST} Iniciando varredura e consolidação técnica dos arquivos...\n"
    
    # Monta o cabeçalho oficial do dump na régua legal
    {
        echo "=========================================================================="
        echo " SAMBOX SOFTWARE AUDIT - SOURCE CODE CONSOLIDATED DUMP"
        echo " Generated on: $(date)"
        echo " Copyright (c) 2026, Sam Moreno. All rights reserved."
        echo " License: BSD 2-Clause License (Simplified)"
        echo "=========================================================================="
        printf "\n\n"
        
        echo "=== [ENTRYPOINT] sambox ==="
        cat "${SAMBOX_DIR}/sambox" 2>/dev/null || echo "Erro ao ler entrypoint"
        printf "\n\n"
    } > "${output_file}"

    # Faz o loop dinâmico lendo o interior de cada módulo da pasta modules/
    local mod
    for mod in "${MODULES_DIR}"/*.sh; do
        if [[ -f "${mod}" ]]; then
            {
                echo "=== [MODULE] $(basename "${mod}") ==="
                cat "${mod}"
                printf "\n\n"
            } >> "${output_file}"
        fi
    done

    # Trata o destino com base na escolha do usuário (Corrigido na Régua!)
    if [[ "${mode}" == "local" ]]; then
        _msg "Código-fonte unificado com sucesso para auditoria local!"
        printf "    Arquivo gerado: ${CYAN}${BOLD}%s${RST}\n" "${output_file}"
    elif [[ "${mode}" == "cloud" ]]; then
        printf "${YELLOW}[+]${RST} Disparando cURL para upload anônimo e seguro (0x0.st)...\n"
        
        # O curl envia o dump de texto de forma minimalista sem carregar dependências gordas
        local upload_url
        upload_url=$(curl -s -F "file=@${output_file}" https://0x0.st)
        
        if [[ -n "${upload_url}" ]]; then
            printf "${GREEN}[✔]${RST} Upload concluído! Compartilhe o link para revisão remota:\n"
            printf "    URL Direta: ${CYAN}${BOLD}%s${RST}\n" "${upload_url}"
        else
            _err "Falha na comunicação com o servidor de upload remoto."
        fi
        
        # Limpeza cirúrgica pós-upload para não deixar rastros no /tmp
        rm -f "${output_file}"
    fi
}

