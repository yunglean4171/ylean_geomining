local QBCore = nil
QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand("reset steps", function()
    exports.ghmattimysql:executeSync("UPDATE playersSET steps = 0;",{})
    Wait(150)
    print("steps has been reseted")
    playerSteps = 0
end, true)

function GetLicense(source)
    local identifiers = GetPlayerIdentifiers(source)
    local license

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "license:") then license = identifier end
    end

    return license
end

function GetSteps(source)
    local license = GetLicense(source)
    local steps = 0
    local result = exports.ghmattimysql:executeSync("SELECT steps FROM players WHERE license = @license", {["@license"] = license})
  
    if result and #result > 0 then
      steps = result[1].steps
    end

    return steps
end

function GetCharacterName(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local firstname = xPlayer.PlayerData.charinfo.firstname
    local lastname = xPlayer.PlayerData.charinfo.lastname
    return firstname .. ' ' .. lastname
end

function updateLeaderboard(source)
    local query = "SELECT * FROM players ORDER BY steps DESC LIMIT 5"
    exports.ghmattimysql:execute(query, {}, function(result)
        local leaderboard = {}

        for i=1, #result do
            local player = result[i]
            local charinfo = json.decode(player.charinfo)
            local name = charinfo.firstname .. ' ' .. charinfo.lastname

            table.insert(leaderboard, {
                name = name,
                steps = player.steps
            })
        end


        while #leaderboard < 5 do
            table.insert(leaderboard, {
                name = "-",
                steps = "-"
            })
        end

        TriggerClientEvent("yleangm:updateLeaderboard", source, leaderboard)
    end)
end


RegisterNetEvent('yleangm:updateSteps')
AddEventHandler('yleangm:updateSteps', function(steps)
    if steps > 0 then
        local _source = source
        local newSteps = tonumber(GetSteps(_source) + math.floor(steps))
        local license = GetLicense(_source)
        exports.ghmattimysql:execute('UPDATE players SET steps = @steps WHERE license = @license', { ['@steps'] = newSteps, ['@license'] = license })
    end
end)

RegisterNetEvent("yleangm:openNui")
AddEventHandler("yleangm:openNui", function()
    local _source = source
    local playerName = GetCharacterName(_source)
    local steps = GetSteps(_source)
    TriggerClientEvent("yleangm:receivePlayerNameAndSteps", _source, playerName, steps)
    updateLeaderboard(_source)
end)

RegisterNetEvent("yleangm:BuyItem")
AddEventHandler("yleangm:BuyItem", function(item, price, amount, label)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local steps = tonumber(GetSteps(src))
    local newSteps = tonumber(GetSteps(src)) - price
    local license = GetLicense(src)

    if item == "cash" then
        if steps >= price then
            exports.ghmattimysql:execute('UPDATE players SET steps = @steps WHERE license = @license', { ['@steps'] = newSteps, ['@license'] = license })
            Player.Functions.AddMoney('cash', amount)
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You have purchased $"..amount.." in "..label, "success", 5000)
        else
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You do not have enough steps to purchase "..label.." x", "error", 5000)
        end
    elseif item == "bank" then
        if steps >= price then
            exports.ghmattimysql:execute('UPDATE players SET steps = @steps WHERE license = @license', { ['@steps'] = newSteps, ['@license'] = license })
            Player.Functions.AddMoney('bank', amount)
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You have purchased $"..amount, "success", 5000)
        else
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You do not have enough steps to purchase "..label, "error", 5000)
        end
    else
        if steps >= price then
            exports.ghmattimysql:execute('UPDATE players SET steps = @steps WHERE license = @license', { ['@steps'] = newSteps, ['@license'] = license })
            Player.Functions.AddItem(item, amount)
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You have purchased x"..amount.." "..label, "success", 5000)
        else
            TriggerClientEvent("yleangm:closeNUI", src)
            TriggerClientEvent('QBCore:Notify', src, "You do not have enough steps to purchase "..label, "error", 5000)
        end
    end
end)