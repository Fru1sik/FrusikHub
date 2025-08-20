-- 🌿 Определение JobId сервера

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Вебхук для отправки JobId
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404173568350093424/f_ND3zfZWAHapUMdFRlC77aU0ZdSbPmzFASONMUfhoaguz_zD8j_UDwuAsV5Lvj0rxIz"

-- Функция отправки вебхука
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

-- Определяем JobId
local currentJobId = game.JobId
local placeId = game.PlaceId

-- Отправляем через вебхук
sendWebhook("🌿 JobId текущего сервера: "..currentJobId.."\nPlaceId: "..placeId)
print("🌿 JobId отправлен в вебхук: "..currentJobId)
