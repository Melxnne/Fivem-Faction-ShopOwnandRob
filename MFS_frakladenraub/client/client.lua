ESX = nil
    local PlayerData = {}
    local ownedladen = {}
    local blips = {}
    local routeblip = nil
    local getladen = nil
    local timer = 0
    
    CreateThread(function()
        while ESX == nil do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Wait(0)
        end
    
        PlayerData = ESX.GetPlayerData()

        while getladen == nil do
            Wait(0)
            TriggerServerEvent("MFS_Frakladen:checkladen")
        end
    end)
    

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job

        TriggerServerEvent("MFS_Frakladen:checkladen")
    end)

    

    RegisterNetEvent("MFS_Frakladen:getladen")
    AddEventHandler("MFS_Frakladen:getladen", function(id, frak)
        getladen = true
        ownedladen[id] = {
            frak = frak
        }
    end)
    
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
    
            for i = 1, #Config.Laden, 1 do
                local x = Config.Laden[i]["x"]
                local y = Config.Laden[i]["y"]
                local z = Config.Laden[i]["z"]
                local x = Config.Laden[i]["x"]
                local y = Config.Laden[i]["y"]
                local z = Config.Laden[i]["z"]
                local ShopID = Config.Laden[i]["ID"]
                local distance = #(playerCoords - vector3(x, y, z))
                local distance2 = #(playerCoords - vector3(x, y, z))
    
                if distance < 10.0 then
                    if not (PlayerData.job.name == (Config.BlacklistedJobs) or PlayerData.job.name == "unemployed") then
                    DrawMarker((Config.MarkerDraw), x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, (Config.MarkerR), (Config.MarkerG), (Config.MarkerB), false, 64, true, false, false, false)
                    if distance < 1.0 and getladen then
                        if ownedladen[ShopID].frak ~= PlayerData.job.label then
                            ESX.ShowHelpNotification("Drücke ~g~E~w~ um den Laden von "..ownedladen[ShopID].frak.." anzugreifen!")
                            if IsControlJustPressed(0, 38) then
                                TriggerEvent((Config.ProgressbarTrigger), (Config.time * 60000 -1))
                                TriggerServerEvent("MFS_Frakladen:start", PlayerData.job.label, ownedladen[ShopID].frak, vector3(x, y, z), ShopID)
                            end
                        else
                            
                            if IsControlJustPressed(0, 38) then
                                if not cooldown then
                                    TriggerServerEvent("MFS_Frakladen:wash")
                                    
                                    --TriggerEvent((Config.ProgressbarTrigger), (Config.WashTime * 1000 -1))
                                    
                                    
                                    cooldowntimer()
                                else
                                    
                                    Wait(1)
                                    
                                end
                            end
                        end
                    end
                    if distance2 < 1.0 and getladen then
                        if ownedladen[ShopID].frak == PlayerData.job.label then
                            ESX.ShowHelpNotification("Drücke ~g~E~w~ um dein Schwarzgeld zu waschen")
                            if IsControlJustPressed(0, 38) then
                                if not cooldown then
                                    TriggerServerEvent("MFS_Frakladen:wash")
                                    cooldowntimer()
                                else
                                    Wait(1)
                                end
                            end
                        end
                    end
                end
                end
            end
        end
    end)
    
    cooldowntimer = function()
        cooldown = true
        SetTimeout(Config.WashTime * 1000, function()
            cooldown = false
        end)
    end

    RegisterNetEvent("MFS_Frakladen:animsell")
    AddEventHandler("MFS_Frakladen:animsell", function()
        local PlayerPed = GetPlayerPed(-1)
        ClearPedTasks(PlayerPed)
        TaskStartScenarioInPlace(PlayerPed, "PROP_HUMAN_BUM_BIN", 0, true)
        Wait(Config.WashTime * 1000)
        ClearPedTasksImmediately(PlayerPed)
    end)

    RegisterNetEvent('MFS_Frakladen:setBlips')
    AddEventHandler('MFS_Frakladen:setBlips', function(id, frak)
            for k,v in pairs(blips) do
                if v.id == id then
                    RemoveBlip(v.blip)
                    blips[k] = nil
                end
            end
            for i = 1, #Config.Laden, 1 do
                if Config.Laden[i]["ID"] == id and frak then
                    local blip = AddBlipForCoord(Config.Laden[i]["x"], Config.Laden[i]["y"], Config.Laden[i]["z"])
                    SetBlipSprite(blip, Config.Blip.Sprite)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Laden von: " ..frak)
                    EndTextCommandSetBlipName(blip)
                    SetBlipScale(blip, Config.Blip.Scale)
                    SetBlipAsShortRange(blip, true)
                    SetBlipColour(blip, Config.Blip.Color)

                    table.insert(blips, {blip = blip, id = id})
                end
            end
    end)




    RegisterNetEvent('MFS_Frakladen:routeblip')
    AddEventHandler('MFS_Frakladen:routeblip', function(status, id)
        if status then
            SendNUIMessage({
                action = "timer",
                show = true,
                time = Config.time * 60 - 1
            })
            for i = 1, #Config.Laden, 1 do
                if Config.Laden[i]["ID"] == id then
                    local blip = AddBlipForRadius(Config.Laden[i]["x"], Config.Laden[i]["y"], Config.Laden[i]["z"], Config.RobRadius)
                    SetBlipColour(blip, Config.Blip.Color)
                    SetBlipAlpha(blip, 128)
                    SetBlipRoute(blip, true)
                    PulseBlip(blip)
                    routeblip = blip
                end
            end
        else
            SendNUIMessage({
                action = "timer",
                show = false
            })
            RemoveBlip(routeblip)
            TriggerEvent((Config.ProgressbarTrigger), 1)
        end
    end)
