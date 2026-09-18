#!/usr/bin/env bash
# Sambox - Repositório Isolado de Textos e Documentação Oficial
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_load_manual_text() {
    local chapter="$1" content=""

    if [[ "${chapter}" == "1" ]]; then
        content="$(cat << EOF
${BOLD}${GREEN}=== CAPÍTULO 1: FILOSOFIA & GOVERNANÇA ===${RST}

${BOLD}1. Visão Geral:${RST}
O Sambox é um ecossistema moldado sob as diretrizes clássicas do UNIX. É feito
100% em Bash puro, ultra-leve, modular e agnóstico, focado em extrair a performance
bruta do hardware de servidores Debian e derivados.

${BOLD}2. Licenciamento BSD 2-Clause (Liberdade Comercial Pragmática):${RST}
- O código pertence a quem o usa. Livre para embutir, modificar e fechar se necessário.
- Totalmente imune a travas de licenças copyleft virais que engessam o mercado.
- Segurança jurídica absoluta contra contaminação ideológica de código.

${BOLD}3. Arquitetura Bare-Metal:${RST}
- Execução instantânea em milissegundos sem buffers de interpretadores redundantes.
- Consumo mínimo de memória RAM, respeitando os recursos de máquinas de produção.

(Pressione 'q' para fechar esta página e retornar ao índice)
EOF
)"
    elif [[ "${chapter}" == "2" ]]; then
        content="$(cat << EOF
${BOLD}${GREEN}=== CAPÍTULO 2: GUIA DAS CENTRAIS INTEGRADAS ===${RST}

Aqui está a função do seu arsenal de ferramentas indexado na memória:

${GREEN}• Hardware:${RST}   Audita clocks de núcleos em tempo real e monitora governors do kernel.
${GREEN}• Repositórios:${RST} Modifica espelhos APT, ativa fontes non-free e injeta multiarch i386.
${GREEN}• Virtualização:${RST} Monta hipervisores KVM puros ou com interface técnica Virt-Manager.
${GREEN}• Contêineres:${RST}  Efetua o deploy do Podman rootless e ambientes híbridos Distrobox.
${GREEN}• Manutenção:${RST}   Faxina profunda de caches do APT, logs antigos e vácuo do Journald.
${GREEN}• Network:${RST}      Gerencia aliases rápidos de conexões SSH e inspeciona soquetes ativos.

(Pressione 'q' para fechar esta página e retornar ao índice)
EOF
)"
    elif [[ "${chapter}" == "3" ]]; then
        content="$(cat << EOF
${BOLD}${YELLOW}======================================================================
               🧰 SAMBOX — MANUAL DE INSTRUÇÕES DEFINITIVO
======================================================================${RST}

${BOLD}AMBIENTE REQUERIDO:${RST} Interpretador Bash 4.0+ em distribuições Linux Debian-like.
${BOLD}LICENÇA DO MOTOR:${RST}   BSD 2-Clause (Livre de Fricção)

${GREEN}USO DIRECTO VIA SINALIZADORES (CLI):${RST}
  ./sambox              Abre a interface visual dinâmica (TUI)
  ./sambox --packages   Abre diretamente a central de software via linha de comando
  ./sambox --sysinfo    Dispara o painel sintético de métricas de performance
  ./sambox -h           Exibe os barramentos e flags de ajuda aceitos

${GREEN}COMPROMISSO TÉCNICO:${RST}
  O Sambox foi concebido sob o dogma da eficiência digital: frio, extremamente veloz
  e sem nenhum byte de inchaço ou desperdício de ciclos de processamento.

(Pressione 'q' para fechar e encerrar a leitura do manual)
EOF
)"
    fi

    if [[ -n "${content}" ]]; then
        _pager_view "${content}"
    fi
}
