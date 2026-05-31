gg.require("101.1", 16142)

-- ========================================================
-- CONFIGURAÇÕES INTERNAS E OCULTAS (PROTEGIDAS)
-- ========================================================
local LIB_NAME = "libgame.so"
local BASE_OFFSET = 0x94F38
local FINAL_OFFSET = 0x2C

-- ========================================================
-- MOTOR DE PROCESSAMENTO OCULTO (NINJA)
-- ========================================================
local function executarOtimizacaoPacotes()
    gg.toast("🔍 Procurando, agurde...")
    
    local mapas = gg.getRangesList('^/data/*.so*$')
    local base_modulo = nil

    for _, map in ipairs(mapas) do
        local nome_atual = map.internalName:gsub('^.*/', '')
        if nome_atual:find(LIB_NAME) and map.state == 'Cb' then
            base_modulo = map.start
            break
        end
    end

    if not base_modulo then
        for _, map in ipairs(mapas) do
            if map.internalName:find(LIB_NAME) then
                base_modulo = map.start
                break
            end
        end
    end

    -- Erro genérico camuflado
    if not base_modulo then 
        gg.alert("ℹ️ Erro: Fala com o suporte no WhatsApp +244930753344")
        return 
    end

    local endereco_ponteiro_base = base_modulo + BASE_OFFSET
    local ti = gg.getTargetInfo()
    local tipo_leitura = ti.x64 and gg.TYPE_QWORD or gg.TYPE_DWORD

    local valores_lidos = gg.getValues({{ address = endereco_ponteiro_base, flags = tipo_leitura }})
    local endereco_intermediario = valores_lidos[1].value

    if not ti.x64 then 
        endereco_intermediario = endereco_intermediario & 0xFFFFFFFF 
    end

    if endereco_intermediario == 0 then 
        gg.alert(" ❌ Erro: Para resolver, entra no Hlicoptero e depois sai. Executar o script novamente.")
        return 
    end

    local endereco_final_real = endereco_intermediario + FINAL_OFFSET
    local valor_atual = gg.getValues({{ address = endereco_final_real, flags = gg.TYPE_DWORD }})[1].value

    local results = {{ address = endereco_final_real, value = valor_atual }}

    -- Valores estáticos automáticos
    local valorBase = 1000
    local valorBase8 = 1000

    -- FILTRAGEM DE SEGURANÇA INTERNA
    local basesValidas = {}

    for _, res in ipairs(results) do
        local base = res.address

        if math.abs(res.value) >= 1000000 then

            local scan = gg.getValues({
                { address = base, flags = gg.TYPE_DWORD }, 
                { address = base + 4, flags = gg.TYPE_DWORD }, 
                { address = base + 8, flags = gg.TYPE_DWORD }, 
                { address = base + 12, flags = gg.TYPE_DWORD }, 
                { address = base + 16, flags = gg.TYPE_DWORD }, 
                { address = base + 20, flags = gg.TYPE_DWORD } 
            })

            local v1 = scan[2].value
            local v2 = scan[3].value
            local v3 = scan[4].value
            local v4 = scan[5].value
            local v5 = scan[6].value

            if
                v1 == v2
                and v3 == v5
                and (v4 ~= v1 and v4 ~= v3)
                and math.abs(v1) >= 1000000
                and math.abs(v3) >= 1000000
                and math.abs(v4) >= 1000000
            then
                table.insert(basesValidas, base)
            end
        end
    end

    -- Falha camuflada
    if #basesValidas == 0 then
        gg.alert("ℹ️ Erro: Fala com o suporte no WhatsApp +244930753344")
        return
    end

    -- INJEÇÃO DE PROTOCOLO EM LOTE (A SUA ESTRUTURA EXPANDIDA)
    local alteracoes = {}

    for _, base in ipairs(basesValidas) do
        table.insert(alteracoes, { address = base - 4, flags = gg.TYPE_DWORD, value = 0 })
        table.insert(alteracoes, { address = base + 4, flags = gg.TYPE_DWORD, value = 0 })
        table.insert(alteracoes, { address = base, flags = gg.TYPE_DWORD, value = valorBase })
        table.insert(alteracoes, { address = base + 8, flags = gg.TYPE_DWORD, value = valorBase8 })
        table.insert(alteracoes, { address = base + 28, flags = gg.TYPE_DWORD, value = 0 })
        table.insert(alteracoes, { address = base + 32, flags = gg.TYPE_DWORD, value = 1000 })
    end

    gg.setValues(alteracoes)
    gg.clearResults()
    
    gg.toast("✅ Sucesso!")
end

-- ========================================================
-- INTERFACE DE MENU PRINCIPAL (UX CAMUFLADA)
-- ========================================================
local function abrirMenuNinja()
    -- Exibe o menu principal para o utilizador de forma sutil
    local opcao = gg.choice({
        "🪙 Moedas + 💵 Notas + 🔷 XP  [OK]",
        "❌ Sair do Painel"
    }, nil, "== 🌐 TOWNSHIP-SCRIPT V1.1 Demo ==")

    -- Tratamento das escolhas do menu
    if opcao == 1 then
        executarOtimizacaoPacotes()
    elseif opcao == 2 or opcao == nil then
        gg.toast("ℹ️ Painel encerrado com segurança.")
        os.exit()
    end
end

-- ========================================================
-- LOOP DE CONTROLO DO MENU (EVITA QUE O SCRIPT FECHE SÓ)
-- ========================================================
while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        abrirMenuNinja()
    end
    gg.sleep(100)
end
