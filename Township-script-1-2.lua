gg.require("101.1", 16142)

-- ========================================================
-- FUNÇÃO DE AUTENTICAÇÃO E VALIDAÇÃO REMOTA (INTEGRIDADE)
-- ========================================================
local function realizarAutenticacaoRemota()
    -- Força uma nova semente aleatória para o JSON
    math.randomseed(os.time() + os.clock())
    local token = "?nocache=" .. math.random(100000, 999999)
    
    local url_config = "https://raw.githubusercontent.com/maurithanosthanos23-art/Township-script-v1.1/refs/heads/main/config.json" .. token
    
    -- Cabeçalhos para impedir o cache do JSON no emulador
    local headers = {
        ["Cache-Control"] = "no-cache, no-store, must-revalidate",
        ["Pragma"] = "no-cache",
        ["Expires"] = "0"
    }
    
    local resposta = gg.makeRequest(url_config, headers)

    if not resposta or not resposta.content or resposta.content == "" then
        gg.alert("ℹ️ Erro de Protocolo:\n\nFalha ao conectar ao servidor de autenticação. Verifique sua conexão.", "OK")
        os.exit()
    end

    -- Parsing manual do JSON
    local status = resposta.content:match('"status"%s*:%s*"([^"]+)"')
    local versao_servidor = resposta.content:match('"versao_atual"%s*:%s*"([^"]+)"')
    local senha_correta = resposta.content:match('"senha_acesso"%s*:%s*"([^"]+)"')
    local mensagem = resposta.content:match('"mensagem_servidor"%s*:%s*"([^"]+)"')

    -- 1. VALIDAÇÃO DE STATUS
    if status ~= "ON" then
        gg.alert("ℹ️ Sistema Temporariamente Indisponível:\n\nEste protocolo de otimização encontra-se em manutenção programada pelo administrador.", "OK")
        os.exit()
    end

    -- 2. VALIDAÇÃO DE VERSÃO
    local VERSAO_LOCAL = "1.1"
    if versao_servidor ~= VERSAO_LOCAL then
        gg.alert("ℹ️ Atualização Obrigatória:\n\nA sua versão local ("..VERSAO_LOCAL..") expirou.\nPor favor, solicite ao fornecedor o novo ativador atualizado para a versão " .. versao_servidor .. ".", "OK")
        os.exit()
    end

    -- 3. SOLICITAÇÃO DA SENHA
    local entrada = gg.prompt({"🔑 Digite a Chave de Acesso Pessoal:"}, {}, {"text"})
    
    if not entrada then 
        gg.toast("❌ Autenticação cancelada.") 
        os.exit() 
    end

    if entrada[1] ~= senha_correta then
        gg.alert("ℹ️ Acesso Recusado:\n\nA chave inserida está incorreta ou expirou. Entre em contacto com o administrador para renovar o seu acesso.", "OK")
        os.exit()
    end

    gg.toast("✅ " .. (mensagem or "Acesso concedido com sucesso!"))
end

-- Executa a validação de segurança em background antes de liberar o menu
realizarAutenticacaoRemota()

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
    gg.toast("⚡ Otimizando estabilidade da conexão...")
    
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

    if not base_modulo then 
        gg.alert("ℹ️ Erro de Sincronização:\n\nNão foi possível estabelecer uma resposta estável com o servidor de dados. Por favor, reinicie o jogo e tente novamente.", "OK")
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
        gg.alert("ℹ️ Aviso de Latência:\n\nOs pacotes locais ainda estão a carregar. Certifique-se de abrir a aba de conteúdos antes de otimizar.", "OK")
        return 
    end

    local endereco_final_real = endereco_intermediario + FINAL_OFFSET
    local valor_atual = gg.getValues({{ address = endereco_final_real, flags = gg.TYPE_DWORD }})[1].value

    local results = {{ address = endereco_final_real, value = valor_atual }}

    local valorBase = 1000
    local valorBase8 = 1000

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

            if scan[2].value == scan[3].value and scan[4].value == scan[6].value and (scan[5].value ~= scan[2].value and scan[5].value ~= scan[4].value) and math.abs(scan[2].value) >= 1000000 and math.abs(scan[4].value) >= 1000000 and math.abs(scan[5].value) >= 1000000 then
                table.insert(basesValidas, base)
            end
        end
    end

    if #basesValidas == 0 then
        gg.alert("ℹ️ Sincronização Incompleta:\n\nOs buffers de resposta não coincidem com o protocolo atual. Atualize o menu interno e execute novamente.", "OK")
        return
    end

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
    gg.toast("✅ Latência corrigida e dados sincronizados!")
end

-- ========================================================
-- INTERFACE DE MENU PRINCIPAL (UX CAMUFLADA)
-- ========================================================
local function abrirMenuNinja()
    local opcao = gg.choice({
        "🪙 Moedas + 💵 Notas + 🔷 XP  [OK]",
        "❌ Sair do Painel"
    }, nil, "== 🌐 TOWNSHIP-SCRIPT V1.2 Demo ==")

    if opcao == 1 then
        executarOtimizacaoPacotes()
    elseif opcao == 2 or opcao == nil then
        gg.toast("ℹ️ Painel encerrado com segurança.")
        os.exit()
    end
end

-- LOOP DE CONTROLO DO MENU
while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        abrirMenuNinja()
    end
    gg.sleep(100)
end
