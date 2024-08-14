-- // Script de Autofarm de Caixas

-- Variáveis Globais
local autoBoxEnabled = false
local stopRequested = false

-- Função para lidar com erros
local function handleError(errorMessage)
    warn("Erro: " .. errorMessage)
end

-- Função para teleportar sem interferir com animações
local function moveTo(position)
    if not autoBoxEnabled or stopRequested then return end

    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local activeTracks = humanoid:GetPlayingAnimationTracks()

    for _, track in ipairs(activeTracks) do
        track:Stop()
    end

    humanoidRootPart.CFrame = CFrame.new(position)

    for _, track in ipairs(activeTracks) do
        track:Play()
    end
end

-- Função para coletar a caixa
local function collectBox()
    if not autoBoxEnabled or stopRequested then return end

    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        local mapName = "1# Map"
        for _, map in pairs(workspace:GetChildren()) do
            if map.Name == mapName then
                local meshes = map:FindFirstChild("2 Meshes")
                if meshes then
                    local meshess = meshes:FindFirstChild("Meshess")
                    if meshess then
                        local handle = nil
                        for _, obj in pairs(meshess:GetChildren()) do
                            if obj:IsA("MeshPart") and obj.MeshId == "rbxassetid://17173724273" then
                                handle = obj
                                break
                            end
                        end

                        if handle then
                            local proximityPrompt = handle:FindFirstChildOfClass("ProximityPrompt")
                            if proximityPrompt then
                                proximityPrompt.ActionText = "Coletando..."
                                local success, errorMessage = pcall(function()
                                    proximityPrompt:InputHoldBegin()
                                end)
                                if not success then
                                    handleError("Erro ao simular input: " .. errorMessage)
                                    return false
                                end
                                
                                wait(1.5)

                                local backpack = player.Backpack
                                local box = backpack:FindFirstChild("Box")
                                if box and box:IsA("Tool") then
                                    local success, equipError = pcall(function()
                                        player.Character:WaitForChild("Humanoid"):EquipTool(box)
                                    end)
                                    if not success then
                                        handleError("Erro ao equipar a Box: " .. equipError)
                                    end
                                else
                                    handleError("Box não encontrada ou não é um Tool")
                                end

                                return true
                            else
                                handleError("ProximityPrompt não encontrado na Handle")
                            end
                        else
                            handleError("Handle com o MeshId especificado não encontrado em Meshess")
                        end
                    else
                        handleError("Meshess não encontrado em 2 Meshes")
                    end
                else
                    handleError("2 Meshes não encontrado em " .. mapName)
                end
            end
        end

        handleError("Mapa " .. mapName .. " não encontrado no Workspace")
    else
        handleError("HumanoidRootPart não encontrado")
    end

    return false
end

-- Posições de início e fim
local startPosition = Vector3.new(-1466.601318359375, 252.99972534179688, -596.7843017578125)
local endPosition = Vector3.new(-1535.427978515625, 252.99974060058594, -489.204833984375)

-- Função principal do loop de autofarm
local function autoFarm()
    while autoBoxEnabled do
        if stopRequested then
            print("AutoBox interrompido")
            break
        end

        moveTo(startPosition)
        wait(1)

        if not autoBoxEnabled or stopRequested then break end

        if collectBox() then
            moveTo(endPosition)
            wait(0)
        else
            handleError("Erro ao coletar a caixa")
        end

        wait(0)
    end
end

return {
    start = function()
        if autoBoxEnabled then
            print("AutoBox já está em execução")
            return
        end

        print("Iniciando AutoBox")
        autoBoxEnabled = true
        stopRequested = false
        autoFarm()
    end,
    stop = function()
        print("Solicitação para parar AutoBox recebida")
        stopRequested = true
    end
}
