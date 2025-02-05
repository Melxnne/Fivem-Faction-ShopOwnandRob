ESX = nil
local activeraub = falsey

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

RegisterNetEvent("MFS_Frakladen:sell")
AddEventHandler("MFS_Frakladen:sell", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    local item = xPlayer.getInventoryItem(Config.Item)
    local preis = 5000
    if item.count >= 5 then
        TriggerClientEvent("MFS_Frakladen:animsell", xPlayer.source)
        Wait(5)
        xPlayer.removeInventoryItem(item.name, 5)
        xPlayer.addAccountMoney('black_money', preis)
        TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Du verkaufst 5x Meth für "..preis.."$")
    else
        TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Du brauchst mindestens 5x Meth zum verkaufen.")
    end
end)

RegisterNetEvent("MFS_Frakladen:wash")
AddEventHandler("MFS_Frakladen:wash", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackmoney = xPlayer.getAccount('black_money').money
    
    if xPlayer.getAccount('black_money').money >= Config.MinSchwarzgeld then
        TriggerClientEvent("MFS_Frakladen:animsell", xPlayer.source)
        TriggerEvent((Config.ProgressbarTrigger), (Config.WashTime * 1000 -1))
        Wait(Config.WashTime * 1000)
        xPlayer.removeAccountMoney('black_money', blackmoney)
        xPlayer.addMoney(blackmoney/Config.percent)
        TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Du hast erfolgreich dein  Schwarzgeld gewaschen")
        
    else
        TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Du brauchst mindestens "..Config.MinSchwarzgeld.."$ Schwarzgeld zum waschen.")
    end
end)

RegisterNetEvent("MFS_Frakladen:checkladen")
AddEventHandler("MFS_Frakladen:checkladen", function()
    xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM frakshops", {}, function(result)
        for k,v in pairs(result) do
            TriggerClientEvent("MFS_Frakladen:setBlips", xPlayer.source, v.id, v.fraktion)
            TriggerClientEvent("MFS_Frakladen:getladen", xPlayer.source, v.id, v.fraktion)
        end
    end)
end)

RegisterServerEvent("MFS_Frakladen:start")
AddEventHandler("MFS_Frakladen:start", function(att, def, pcoords, id)
    local src = source
    local death = false
    local leave = false
    local trigger = false
    local rtime = Config.time * 60
    local frakmembers = ESX.GetExtendedPlayers('job',def)
    if #frakmembers >= 0 then
    if not activeraub then
        activeraub = true
        for _,playerId in ipairs(ESX.GetPlayers()) do
            local xjob = ESX.GetPlayerFromId(playerId).job.label
            if xjob == att then
                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, true, id)
                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), 'Ihr habt den Laden von '..def.. ' angegriffen! '..Config.time..' Minuten verbleibend!', 'white',  10000)
                TriggerEvent((Config.ProgressbarTrigger), 60)
            elseif xjob == def then
                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, true, id)
                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), "Euer Laden wird von "..att.." angegriffen! "..Config.time.." Minuten verbleibend!", 'white',  10000)
            end
        end
        Citizen.CreateThread(function()
            while rtime > 0 do
                Citizen.Wait(1000)
                if rtime > 0 then
                    rtime = rtime - 1
                    local distance = #(pcoords - GetEntityCoords(GetPlayerPed(src)))
                    if distance > Config.RobRadius - 5 then
                        TriggerClientEvent((Config.Notify), src, "error", (Config.Translation), 'Bleibe in dem Gebiet um den Angriff fortzusetzen!')
                    end
                    if distance > Config.RobRadius then
                        leave = true
                        rtime = 0
                    end
                end
                if rtime <= 0 then
                    if death then
                        for _,playerId in ipairs(ESX.GetPlayers()) do
                            local xjob = ESX.GetPlayerFromId(playerId).job.label
                            if xjob == att or xjob == def then
                                activeraub = false
                                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, false, id)
                                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), "Der Ladenraub wurde abgebrochen!", 'white',  10000)
                                TriggerEvent((Config.ProgressbarTrigger), 1)
                            end
                        end
                        death = false
                    elseif leave then
                        for _,playerId in ipairs(ESX.GetPlayers()) do
                            local xjob = ESX.GetPlayerFromId(playerId).job.label
                            if xjob == att or xjob == def then
                                activeraub = false
                                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, false, id)
                                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), "Der Ladenraub wurde abgebrochen!", 'white',  10000)
                            end
                        end
                        leave = false
                    else
                        MySQL.Async.execute('UPDATE frakshops SET fraktion = @fraktion WHERE id = @id',{['@fraktion'] = att, ['@id'] =  id})  
                        TriggerClientEvent("MFS_Frakladen:getladen", -1, id, att)
                        TriggerClientEvent("MFS_Frakladen:setBlips", -1, id, att)
                        activeraub = false
                        for _,playerId in ipairs(ESX.GetPlayers()) do
                            local xjob = ESX.GetPlayerFromId(playerId).job.label
                            if xjob == def then
                                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, false, id)
                                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), "Euer Laden wurde von "..att.." übernommen!", 'white',  10000)
                            elseif xjob == att then
                                TriggerClientEvent("MFS_Frakladen:routeblip", playerId, false, id)
                                TriggerClientEvent((Config.Announce), playerId, (Config.Translation), "Ihr habt den Laden von "..def.." erfolgreich übernommen!", 'white',  10000)
                            end
                        end
                    end
                end
            end
        end)
        RegisterServerEvent('esx:onPlayerDeath')
        AddEventHandler('esx:onPlayerDeath', function(data)
            if source == src then
                death = true
                rtime = 0
            end
        end)
    else
        TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Es ist bereits ein aktiver Ladenraub im Gange!")
    end
else
    TriggerClientEvent((Config.Notify), xPlayer.source, "error", (Config.Translation), "Es sind nicht genügend Leute aus der gegen Partei da!")
end
end)


