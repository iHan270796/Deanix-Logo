local QBCore = exports['qb-core']:GetCoreObject()
local HudVisible = true
local PlayerData = {}
local icons = Config.Icons

local function UpdateHud()
    if not HudVisible then return end
    if not PlayerData then return end

    -- JOB
    local jobLabel, jobIcon = "None", icons.job.default
    if PlayerData.job then
        local jobName = PlayerData.job.name
        local onDuty = PlayerData.job.onduty or false
        local grade = PlayerData.job.grade and PlayerData.job.grade.name or ""
        local dutyStatus = onDuty and " | On Duty" or " | Off Duty"
        jobLabel = ("%s (%s)%s"):format(PlayerData.job.label, grade, dutyStatus)

        if jobName == "unemployed" then
            jobIcon = icons.job.unemployed
        else
            if onDuty then
                jobIcon = icons.job[jobName] or icons.job.default
            else
                jobIcon = icons.job.offduty
            end
        end
    end

    -- GANG
    local gangLabel, gangIcon = "None", icons.gang.default
    if PlayerData.gang then
        local gangName = PlayerData.gang.name
        local grade = PlayerData.gang.grade and PlayerData.gang.grade.name or ""
        gangLabel = ("%s (%s)"):format(PlayerData.gang.label, grade)

        gangIcon = icons.gang[gangName] or icons.gang.default
    end

    SendNUIMessage({
        action = "update",
        id = GetPlayerServerId(PlayerId()),
        job = jobLabel,
        jobIcon = jobIcon,
        gang = gangLabel,
        gangIcon = gangIcon,
        bank = PlayerData.money and PlayerData.money.bank or 0,
        cash = PlayerData.money and PlayerData.money.cash or 0
    })
end

CreateThread(function()
    local ped, weapon
    local lastWeaponCheck, lastVoiceCheck, lastVehicleCheck, lastPauseCheck = 0, 0, 0, 0
    local lastState = false

    while true do
        Wait(100)

        ped = PlayerPedId()

        local now = GetGameTimer()

        if now - lastWeaponCheck > 300 then
            lastWeaponCheck = now
            weapon = GetSelectedPedWeapon(ped)
            if weapon ~= `WEAPON_UNARMED` then
            local _, ammoClip = GetAmmoInClip(ped, weapon)
            local ammoTotal = GetAmmoInPedWeapon(ped, weapon)
            SendNUIMessage({
                action = "updateWeapon",
                weapon = { icon = icons.weapon },
                ammoClip = ammoClip,
                ammoTotal = ammoTotal,
                crosshair = Config.Crosshair
            })
            else
                SendNUIMessage({ action = "updateWeapon", weapon = false, crosshair = false })
            end
        end

        if now - lastVoiceCheck > 200 then
            lastVoiceCheck = now
            local talking = NetworkIsPlayerTalking(PlayerId())
            SendNUIMessage({ action = "voice", talking = talking })
        end

        if now - lastVehicleCheck > 1000 then
            lastVehicleCheck = now
            local inVehicle = IsPedInAnyVehicle(ped, false)
            SendNUIMessage({ action = "vehicleHud", inVehicle = inVehicle })
        end

        if now - lastPauseCheck > 500 then
            lastPauseCheck = now
            local pauseActive = IsPauseMenuActive()
            if pauseActive and not lastState then
                lastState = true
                HudVisible = false
                SendNUIMessage({ action = "hide" })
                SendNUIMessage({ action = "updateWeapon", weapon = false })
                SendNUIMessage({ action = "voice", talking = false })
            elseif not pauseActive and lastState then
                lastState = false
                HudVisible = true
                UpdateHud()
                SendNUIMessage({ action = "show" })
            end
        end
    end
end)

AddEventHandler("onResourceStart", function(resName)
    if GetCurrentResourceName() ~= resName then return end
    CreateThread(function()
        while not LocalPlayer.state.isLoggedIn do Wait(200) end
        PlayerData = QBCore.Functions.GetPlayerData()
        Wait(500)
        UpdateHud()
    end)
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty
    end
    UpdateHud()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(500)
    UpdateHud()
end)

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

local function ShowHud()
    HudVisible = true
    UpdateHud()
    SendNUIMessage({ action = "show" })
end

local function HideHud()
    HudVisible = false
    SendNUIMessage({ action = "hide" })
    SendNUIMessage({ action = "updateWeapon", weapon = false })
    SendNUIMessage({ action = "voice", talking = false })
end

exports('showhud', ShowHud)
exports('hidehud', HideHud)

-- RegisterCommand("logoon", function()
--     ShowHud()
-- end, false)

-- RegisterCommand("logoof", function()
--     HideHud()
-- end, false)

-- exports['deanix_logo']:showhud()
-- exports['deanix_logo']:hidehud()