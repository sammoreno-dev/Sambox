#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Limpeza de Logs Mortos e Truncamento de Diários
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

clean_system_logs() {
    # Inicialização preventiva explícita para blindagem total com o 'set -u'
    local log_count=0 log_bytes=0 logfile="" fsize=0 log_mb=0

    printf "\n${YELLOW}[+]${RST} Iniciando purga cirúrgica de diários e logs acumulados... 📝\n"

    # Trunca o log do Systemd de forma segura
    if command -v journalctl &>/dev/null; then
        printf "    ${DIM}Executando vácuo do Journalctl para aliviar os indexes do Systemd...${RST}\n"
        sudo journalctl --vacuum-size=50M 2>/dev/null || true
        _msg "Journald compactado e limitado ao teto de segurança de 50MB! ツ"
    else
        _warn "journalctl não localizado. Pulando compressão de diários do sistema."
    fi

    printf "\n${YELLOW}[+]${RST} Varrendo o diretório /var/log em busca de arquivos rotacionados e mortos... 🔍\n"
    printf "    ${DIM}Eliminando resíduos antigos (.gz, .old, .xz) para reaver espaço bare-metal...${RST}\n"

    # Varredura direta e segura via find alimentando o loop nativo por espaço de memória isolado
    while IFS= read -r -d '' logfile; do
        fsize="$(stat -c '%s' "${logfile}" 2>/dev/null || echo 0)"
        log_bytes=$(( log_bytes + fsize ))
        log_count=$(( log_count + 1 ))
        sudo rm -f "${logfile}"
    done < <(find /var/log -type f \( -name '*.gz' -o -name '*.old' -o -name '*.xz' -o -name '*.1' \) -print0 2>/dev/null)

    # CORREÇÃO MATEMÁTICA: Conversão precisa de Bytes para Megabytes sem zerar dados fracionados
    if [[ ${log_bytes} -gt 0 ]]; then
        log_mb=$(( log_bytes / 1024 / 1024 ))
        # Se for menor que 1MB mas maior que zero, força a exibição de 1MB para não renderizar '0 MB'
        [[ ${log_mb} -eq 0 ]] && log_mb=1
    fi

    # UX Humana e contextualizada com o estado real do disco do servidor
    _sep
    if [[ ${log_count} -gt 0 ]]; then
        _msg "Faxina do /var/log concluída com sucesso! (ツ)"
        printf "    ${GREEN}🎉 Espaço recuperado:${RST} Removidos ${BOLD}%d${RST} logs mortos liberando cerca de ${GREEN}${BOLD}%d MB${RST} de disco.\n" "${log_count}" "${log_mb}"
    else
        _msg "Seu diretório de logs já está voando leve e sem resíduos antigos! ✨"
    fi
}
