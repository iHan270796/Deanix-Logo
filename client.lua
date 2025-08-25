local QBCore = exports['qb-core']:GetCoreObject()
local HudVisible = true
local PlayerData = {} -- cache sendiri

local jobIcons = {
    police = "👮",
    ambulance = "🚑",
    mechanic = "🔧",
    taxi = "🚖",
    burgershot = "🍔"
}

--- Update HUD
local function UpdateHud()
    if not HudVisible then return end
    if not PlayerData or not PlayerData.job then return end

    local onDuty = PlayerData.job.onduty or false
    local gradeName = PlayerData.job.grade and PlayerData.job.grade.name or ""
    local dutyStatus = onDuty and " | On Duty" or " | Off Duty"

    local jobLabel = ("%s (%s)%s"):format(PlayerData.job.label, gradeName, dutyStatus)
    local jobIcon = onDuty and (jobIcons[PlayerData.job.name] or "👔") or "❌"

    SendNUIMessage({
        action = "update",
        id = GetPlayerServerId(PlayerId()),
        job = jobLabel,
        jobIcon = jobIcon,
        gang = PlayerData.gang and PlayerData.gang.label or "None",
        bank = PlayerData.money and PlayerData.money.bank or 0,
        cash = PlayerData.money and PlayerData.money.cash or 0
    })
end

--- Show / Hide
exports('showhud', function()
    HudVisible = true
    UpdateHud()
    SendNUIMessage({ action = "show" })
end)

exports('hidehud', function()
    HudVisible = false
    SendNUIMessage({ action = "hide" })
end)

--- Saat resource start
AddEventHandler("onResourceStart", function(resName)
    if GetCurrentResourceName() ~= resName then return end
    CreateThread(function()
        while not LocalPlayer.state.isLoggedIn do Wait(200) end
        PlayerData = QBCore.Functions.GetPlayerData()
        Wait(500)
        UpdateHud()
    end)
end)

--- Saat player load
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(500)
    UpdateHud()
end)

--- Saat player unload
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    SendNUIMessage({ action = "hide" })
end)

--- Saat mati/hidup
RegisterNetEvent('QBCore:Client:OnPlayerDeath', function()
    SendNUIMessage({ action = "hide" })
end)

RegisterNetEvent('QBCore:Client:OnPlayerRevive', function()
    UpdateHud()
end)

--- Saat ganti duty
RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty -- update cache langsung
    end
    UpdateHud()
end)

--- Event perubahan data
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    if not PlayerData then PlayerData = {} end
    PlayerData.job = job
    UpdateHud()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    if not PlayerData then PlayerData = {} end
    PlayerData.gang = gang
    UpdateHud()
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange', function(type, amount, isMinus)
    if not PlayerData then PlayerData = {} end
    PlayerData.money = QBCore.Functions.GetPlayerData().money
    UpdateHud()
end)



-- RegisterCommand("logoof", function()
--     exports['deanix_logo']:hidehud()
-- end, false)

-- RegisterCommand("logoon", function()
--     exports['deanix_logo']:showhud()
-- end, false)