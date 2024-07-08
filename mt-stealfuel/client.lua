local QBCore = exports['qb-core']:GetCoreObject()

-- Load the configuration
Config = Config or {}
local ProgressBarTime = Config.ProgressBarTime or 5000
local FuelScript = Config.FuelScript or "ps-fuel"

local function loadAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end

local function moveToPosition(ped, position, heading)
    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.1, 0.1, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)

        local timeout = 3
        local elapsed = 0

        while not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.1, 0.1, false, true, 0) do
            Citizen.Wait(1000)
            elapsed = elapsed + 1

            if elapsed >= timeout then
                print("Timeout reached: Ped could not reach the target position.")
                break
            end
        end
    end
end

local function playAnimation(ped, animDict, animName)
    loadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, 8.0, 5.0, -1, 1, 1, false, false, false)
    Citizen.Wait(4500)
    ClearPedTasks(ped)
    RemoveAnimDict(animDict)
end

local function getFrontOfVehicle(vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleForwardVector = GetEntityForwardVector(vehicle)
    return vehicleCoords + (vehicleForwardVector * 2.5)
end

RegisterNetEvent('mt-stealfuel:client:StealFuel', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = QBCore.Functions.GetClosestVehicle(playerCoords)
    
    if vehicle and vehicle ~= 0 then
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasHose)
            if hasHose then
                local targetPos = getFrontOfVehicle(vehicle)
                moveToPosition(playerPed, targetPos, GetEntityHeading(vehicle) + 180)
                
                SetVehicleDoorOpen(vehicle, 4, false, false)
                QBCore.Functions.Progressbar('steal_fuel', 'STEALING VEHICLE FUEL...', ProgressBarTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = 'mini@repair',
                    anim = 'fixing_a_ped',
                    flags = 16,
                }, {}, {}, function()
                    local fuelLevel = exports[FuelScript]:GetFuel(vehicle)
                    ClearPedTasks(playerPed)
                    SetVehicleDoorShut(vehicle, 4, false, false)

                    if fuelLevel >= 20 then
                        TriggerServerEvent('mt-stealfuel:server:GiveJerryCan')
                        QBCore.Functions.Notify('You have robbed vehicle fuel!', 'success', 7500)
                        exports[FuelScript]:SetFuel(vehicle, fuelLevel - 20)
                    elseif fuelLevel > 0 then
                        QBCore.Functions.Notify('You have robbed vehicle fuel!', 'success', 7500)
                        exports[FuelScript]:SetFuel(vehicle, 0)
                    else
                        QBCore.Functions.Notify('This vehicle does not have enough fuel!', 'error', 7500)
                    end
                end)
            else
                QBCore.Functions.Notify('You don\'t have a hose!', 'error', 7500)
            end
        end, 'garden_hose')
    else
        QBCore.Functions.Notify('No vehicle nearby to steal fuel from!', 'error', 7500)
    end
end)

RegisterNetEvent('mt-stealfuel:client:RefuelVehicle', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = QBCore.Functions.GetClosestVehicle(playerCoords)
    
    if vehicle and vehicle ~= 0 then
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasCan)
            if hasCan then
                local targetPos = getFrontOfVehicle(vehicle)
                moveToPosition(playerPed, targetPos, GetEntityHeading(vehicle) + 180)
                
                SetVehicleDoorOpen(vehicle, 4, false, false)
                QBCore.Functions.Progressbar('refuel_vehicle', 'REFUELING VEHICLE...', ProgressBarTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = 'mini@repair',
                    anim = 'fixing_a_ped',
                    flags = 16,
                }, {}, {}, function()
                    local fuelLevel = exports[FuelScript]:GetFuel(vehicle)
                    ClearPedTasks(playerPed)
                    SetVehicleDoorShut(vehicle, 4, false, false)

                    if QBCore.Functions.HasItem('jerry_can') then
                        fuelLevel = fuelLevel + 20
                        TriggerServerEvent('mt-stealfuel:server:RemoveJerryCan')
                        exports[FuelScript]:SetFuel(vehicle, fuelLevel)
                        QBCore.Functions.Notify('You have refueled the vehicle with a jerry can!', 'success', 7500)
                    else
                        QBCore.Functions.Notify('You don\'t have any jerry cans!', 'error', 7500)
                    end
                end)
            else
                QBCore.Functions.Notify('You don\'t have a jerry can!', 'error', 7500)
            end
        end, 'jerry_can')
    else
        QBCore.Functions.Notify('No vehicle nearby to refuel!', 'error', 7500)
    end
end)



CreateThread(function()
    local bones = { "engine" }
    exports["qb-target"]:AddTargetBone(bones, {
        options = {
            {
                event = "mt-stealfuel:client:StealFuel",
                icon = "fas fa-wrench",
                label = "Rob vehicle fuel",
                item = "empty_jerry_can"
            },
            {
                event = "mt-stealfuel:client:RefuelVehicle",
                icon = "fas fa-gas-pump",
                label = "Refuel vehicle",
                item = "jerry_can"
            }
        },
        distance = 1.5
    })
end)
