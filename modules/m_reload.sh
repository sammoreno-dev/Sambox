#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Submódulo Dedicado a Hot-Reload de Ambiente para Servidores
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.
# -----------------------------------------------------------------------------

exec_hot_reload() {
    printf "\n  ${YELLOW}[+] Resetando barramento e re-escaneando 'modules/'... 🔄${RST}\n"
    
    # Zera as tabelas de símbolos na RAM do motor principal
    SAMBOX_MODULE_NAMES=()
    SAMBOX_MODULE_FUNCS=()
    
    # Re-executa o loop de carregamento do arquivo mestre
    if [[ -d "${MODULES_DIR}" ]]; then
        for module in "${MODULES_DIR}"/m_*.sh; do
            local mod_name="${module##*/}"
            # Ignora o menu principal e a si mesmo para evitar loops infinitos
            [[ -f "${module}" && "${mod_name}" != "m_mainmenu.sh" && "${mod_name}" != "m_reload.sh" ]] && source "${module}"
        done
    fi
    
    _msg "Módulos administrativos recarregados a quente! ツ"
    sleep 1
}

# Auto-registro vivo: Adiciona a si mesmo como uma opção comum no menu principal!
register_sambox_module "🔄  Recarregar Módulos (Hot-Reload)" "exec_hot_reload"
