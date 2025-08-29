local QBCore = exports['qb-core']:GetCoreObject()
local HudVisible = true
local PlayerData = {}

local icons = {
    id = "<i class='fa-solid fa-id-badge'></i>",
    bank = "<i class='fa-solid fa-university'></i>",
    cash = "<i class='fa-solid fa-money-bill-wave'></i>",
    job = {
        police = "<i class='fa-solid fa-shield-halved'></i>",
        ambulance = "<i class='fa-solid fa-hospital'></i>",
        mechanic = "<i class='fa-solid fa-wrench'></i>",
        taxi = "<i class='fa-solid fa-taxi'></i>",
        burgershot = "<i class='fa-solid fa-hamburger'></i>",
        default = "<i class='fa-solid fa-briefcase'></i>"
    },
    gang = {
        ballas = "<i class='fa-solid fa-skull-crossbones'></i>",
        families = "<i class='fa-solid fa-hand-fist'></i>",
        vagos = "<i class='fa-solid fa-dragon'></i>",
        default = "<i class='fa-solid fa-users'></i>"
    }
}

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
            jobIcon = "<i class='fa-solid fa-user'></i>"
        else
            if onDuty then
                jobIcon = icons.job[jobName] or icons.job.default
            else
                jobIcon = "<i class='fa-solid fa-circle-xmark'></i>"
            end
        end
    end

    -- GANG
    local gangLabel, gangIcon = "None", icons.gang.default
    if PlayerData.gang then
        local gangName = PlayerData.gang.name
        local grade = PlayerData.gang.grade and PlayerData.gang.grade.name or ""
        gangLabel = ("%s (%s)"):format(PlayerData.gang.label, grade)

        if gangName == "none" then
            gangIcon = "<i class='fa-solid fa-ban'></i>"
        else
            gangIcon = icons.gang[gangName] or icons.gang.default
        end
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
    while true do
        Wait(300)
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= `WEAPON_UNARMED` then
            local _, ammoClip = GetAmmoInClip(ped, weapon)
            local ammoTotal = GetAmmoInPedWeapon(ped, weapon)

            SendNUIMessage({
                action = "updateWeapon",
                weapon = { icon = "fa-solid fa-gun" },
                ammoClip = ammoClip,
                ammoTotal = ammoTotal
            })
        else
            SendNUIMessage({ action = "updateWeapon", weapon = false })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(200)
        local talking = NetworkIsPlayerTalking(PlayerId())
        SendNUIMessage({ action = "voice", talking = talking })
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        SendNUIMessage({ action = "vehicleHud", inVehicle = inVehicle })
    end
end)

CreateThread(function()
    local lastState = false
    while true do
        Wait(500)
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

RegisterCommand("logoon", function()
    ShowHud()
end, false)

RegisterCommand("logoof", function()
    HideHud()
end, false)