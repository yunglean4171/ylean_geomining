local playerSteps = 0
local shopItems = Ylean.Shop

-- NUI
RegisterCommand(Ylean.OpenCommandName, function()
    TriggerServerEvent("yleangm:updateSteps", playerSteps)
    Wait(150)
    TriggerServerEvent("yleangm:openNui")
    playerSteps = 0
end, false)



function SetDisplay(_display, name, stepss)
    display = _display
    SetNuiFocus(display, display)
    SendNUIMessage({
        type = _display and "open" or "close",
        value = display,
        playerName = name,
        steps = stepss
    })
end

RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent("yleangm:BuyItem", data.name, data.price, data.amount, data.label)
    cb('ok')
end)

RegisterNetEvent("yleangm:updateLeaderboard")
AddEventHandler("yleangm:updateLeaderboard", function(leaderboard)
    SendNUIMessage({
        action = "updateLeaderboard",
        leaderboard = leaderboard
    })
    SendNUIMessage({
        action = "updateShop",
        shopItems = shopItems
    })
end)

RegisterNetEvent("yleangm:closeNUI")
AddEventHandler("yleangm:closeNUI", function(leaderboard)
    SendNUIMessage({action = "closeNUI"})
    SetDisplay(false)
end)

RegisterNUICallback('close', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNetEvent("yleangm:receivePlayerNameAndSteps")
AddEventHandler("yleangm:receivePlayerNameAndSteps", function(receivedName, steps)
    TriggerServerEvent("yleangm:updateSteps", playerSteps)
    Wait(150)
    playerName = receivedName
    SetDisplay(true, playerName, steps)
end)



local function CountSteps(playerId)
    local playerPed = GetPlayerPed(playerId)
    if IsPedWalking(playerPed) and not IsPedInAnyVehicle(playerPed, true) and not IsPedFalling(playerPed) and not IsPedSwimming(playerPed) and IsPedOnFoot(playerPed) then
        if playerSteps == 0 then
            playerSteps = 1/18
        else
            playerSteps = playerSteps + 1/18
        end
    end
end

local function CountRunningSteps(playerId)
    local playerPed = GetPlayerPed(playerId)
    if IsPedRunning(playerPed) and not IsPedInAnyVehicle(playerPed, true) and not IsPedFalling(playerPed) and not IsPedSwimming(playerPed) and IsPedOnFoot(playerPed) then
        if playerSteps == 0 then
            playerSteps = 0.8
        else
            playerSteps = playerSteps + 0.8
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerId = PlayerId()
        CountSteps(playerId)
        CountRunningSteps(playerId)
    end
end)

AddEventHandler("onResourceStop", function(rN)
    TriggerServerEvent("yleangm:updateSteps", playerSteps)
end)