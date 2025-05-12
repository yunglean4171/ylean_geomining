ESX = exports["es_extended"]:getSharedObject()

RegisterCommand("resetsteps", function(source, args, rawCommand)
    if (source > 0) then
        MySQL.Async.execute("UPDATE users SET steps = 0;", {}, function()
            print("Steps have been reset")
            TriggerClientEvent("yleangm:closeNUI", source)
        end)
    end
end, true)

function GetSteps(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.Async.fetchAll("SELECT steps FROM users WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
        local steps = 0
        if result and #result > 0 then
            steps = result[1].steps
        end
        cb(steps)
    end)
end

function GetCharacterName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.getName()
    return name
end

function updateLeaderboard(source)
    local query = "SELECT * FROM users ORDER BY steps DESC LIMIT 5"
    MySQL.Async.fetchAll(query, {}, function(result)
        local leaderboard = {}

        for i=1, #result do
            local player = result[i]
            local name = player.firstname .. ' ' .. player.lastname

            table.insert(leaderboard, {
                name = name,
                steps = player.steps
            })
        end

        while #leaderboard < 10 do
            table.insert(leaderboard, {
                name = "-",
                steps = "-"
            })
        end

        TriggerClientEvent("yleangm:updateLeaderboard", source, leaderboard)
    end)
end

RegisterNetEvent('yleangm:updateStepsAndOpenNui')
AddEventHandler('yleangm:updateStepsAndOpenNui', function(steps)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()

    GetSteps(_source, function(currentSteps)
        local newSteps = tonumber(currentSteps + math.floor(steps))
        MySQL.Async.execute('UPDATE users SET steps = @steps WHERE identifier = @identifier', { ['@steps'] = newSteps, ['@identifier'] = identifier }, function()
            local playerName = GetCharacterName(_source)
            GetSteps(_source, function(updatedSteps)
                TriggerClientEvent("yleangm:receivePlayerNameAndSteps", _source, playerName, updatedSteps)
                updateLeaderboard(_source)
            end)
        end)
    end)
end)

RegisterNetEvent("yleangm:openNui")
AddEventHandler("yleangm:openNui", function()
    local _source = source
    local playerName = GetCharacterName(_source)
    GetSteps(_source, function(steps)
        TriggerClientEvent("yleangm:receivePlayerNameAndSteps", _source, playerName, steps)
        updateLeaderboard(_source)
    end)
end)

RegisterNetEvent("yleangm:BuyItem")
AddEventHandler("yleangm:BuyItem", function(item, price, amount, label)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.getIdentifier()

    GetSteps(src, function(currentSteps)
        local steps = tonumber(currentSteps)
        local newSteps = steps - price

        if steps >= price then
            MySQL.Async.execute('UPDATE users SET steps = @steps WHERE identifier = @identifier', { ['@steps'] = newSteps, ['@identifier'] = identifier }, function()
                if item == "cash" then
                    Player.addMoney(amount)
                    TriggerClientEvent("yleangm:closeNUI", src)
                    TriggerClientEvent('esx:showNotification', src, "You have purchased $"..amount.." in "..label)
                elseif item == "bank" then
                    Player.addAccountMoney('bank', amount)
                    TriggerClientEvent("yleangm:closeNUI", src)
                    TriggerClientEvent('esx:showNotification', src, "You have purchased $"..amount, "success")
                else
                    if string.sub(item, 1, 7):lower() == "weapon_" then
                        Player.addWeapon(item, 1)
                    else
                        Player.addInventoryItem(item, amount)
                    end
                    TriggerClientEvent("yleangm:closeNUI", src)
                    TriggerClientEvent('esx:showNotification', src, "~g~You have purchased "..label)
                end
            end)
        else
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('esx:showNotification', src, "You do not have enough steps to purchase "..label)
        end
    end)
end)