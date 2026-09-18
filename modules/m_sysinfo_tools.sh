#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Ferramentas Avançadas de Diagnóstico e Exportação de Dumps
# Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.
# Distribuído sob os termos estáveis da licença BSD 2-Clause.
# -----------------------------------------------------------------------------

_hardware_inspect() {
    printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
    printf "  ║     🧩  INSPETOR DETALHADO DE HARDWARE    ║\n"
    printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"

    printf "  ${BOLD}• Processador (CPU):${RST}\n"
    if [[ -f /proc/cpuinfo ]]; then
        local line="" key="" val="" model_name="Desconhecido" cores=0
        
        # Correção estrita: faz o parsing via case, evitando quebras do BASH_REMATCH
        while IFS=: read -r key val; do
            if [[ "${key}" =~ "model name" ]]; then
                model_name="${val#*[[:space:]]}"
            fi
            if [[ "${key}" =~ "processor" ]]; then
                local clean_core="${val//[[:space:]]/}"
                cores=$(( clean_core + 1 ))
            fi
        done < /proc/cpuinfo
        
        printf "    Model Name : ${DIM}%s${RST}\n" "${model_name}"
        printf "    Arquitetura: ${DIM}%d Threads ativos correspondentes${RST}\n" "${cores}"
    fi

    printf "\n  ${BOLD}• Dispositivos PCI em Destaque (VGA/Audio/Net):${RST}\n"
    if command -v lspci &>/dev/null; then
        printf "    ${DIM}Varrendo o barramento PCI do servidor em tempo real...${RST}\n"
        lspci | grep -E -i 'vga|3d|audio|network|ethernet' | sed 's/^/    • /'
    else
        printf "    ${DIM}lspci não instalado no sistema hospedeiro.${RST}\n"
    fi

    printf "\n  ${BOLD}• Suporte a Virtualização Bare-Metal (KVM):${RST}\n"
    if grep -E -q 'vmx|svm' /proc/cpuinfo 2>/dev/null; then
        printf "    Status     : ${GREEN}Suportado (VT-x/AMD-V ativo na BIOS) ツ${RST}\n"
    else
        printf "    Status     : ${RED}Não detectado ou desativado no hardware corporativo${RST}\n"
    fi
}

_top_processes() {
    printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
    printf "  ║     ⚡  TOP CONSUMIDORES DE RECURSOS      ║\n"
    printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"

    printf "  ${BOLD}%-8s %-10s %-6s %-6s %s${RST}\n" "PID" "USUÁRIO" "%CPU" "%MEM" "COMANDO"
    _sep
    
    # Coleta os 8 processos mais pesados de forma limpa e estruturada
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 9 | tail -n 8 | while read -r pid usr cpu mem cmd; do
        printf "  %-8s %-10s %-6s %-6s ${DIM}%s${RST}\n" "${pid}" "${usr}" "${cpu}" "${mem}" "${cmd}"
    done
    printf "\n  ${GREEN}[✓] Amostragem de processos concluída! (ツ)${RST}\n"
}

_generate_source_dump() {
    local target="$1"
    local dump_file="/tmp/sambox_source_dump_$(date +%Y%m%d_%H%M%S).txt"
    
    printf "\n${YELLOW}[+]${RST} Iniciando consolidação do seu arsenal de códigos... 📝\n"
    printf "    ${DIM}Compactando assinaturas e licenças de retaguarda...${RST}\n"
    
    # Consolida os cabeçalhos de todos os arquivos de módulos em um único arquivo de log
    printf "=========================================\n" > "${dump_file}"
    printf "SAMBOX SOURCE DUMP AUDIT - %s\n" "$(date)" >> "${dump_file}"
    printf "=========================================\n\n" >> "${dump_file}"
    
    if [[ -d "${MODULES_DIR}" ]]; then
        local f=""
        for f in "${MODULES_DIR}"/*.sh; do
            if [[ -f "${f}" ]]; then
                printf "--- ARQUIVO: %s ---\n" "${f##*/}" >> "${dump_file}"
                head -n 20 "${f}" >> "${dump_file}"
                printf "\n\n" >> "${dump_file}"
            fi
        done
    fi

    if [[ "${target}" == "local" ]]; then
        _msg "Dump consolidado localmente com sucesso! ツ"
        printf "    ${GREEN}📂 Arquivo de auditoria salvo em:${RST} ${CYAN}%s${RST}\n" "${dump_file}"
    elif [[ "${target}" == "cloud" ]]; then
        printf "    ${YELLOW}[+]${RST} Batendo na porta do barramento anônimo (0x0.st)... ☁️\n"
        if command -v curl &>/dev/null; then
            local cloud_link=""
            
            # CORREÇÃO: Envia o User-Agent customizado exigido pelos termos de uso do servidor 0x0.st
            cloud_link=$(curl -A "Sambox-SysAdmin-Toolbox" -F "file=@${dump_file}" https://0x0.st 2>/dev/null || echo "error")
            
            if [[ "${cloud_link}" != "error" && -n "${cloud_link}" ]]; then
                _msg "Dump exportado para a nuvem de forma anônima e segura! ツ"
                printf "    ${GREEN}🔗 Link Seguro (Válido por 30 dias):${RST} ${GREEN}${BOLD}%s${RST}\n" "${cloud_link}"
            else
                _warn "O barramento de upload reportou um timeout ou rejeição."
            fi
        else
            _err "Utilitário 'curl' não foi localizado. Impossível exportar para a nuvem."
        fi
    fi
}
