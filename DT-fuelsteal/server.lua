local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('mt-stealfuel:server:GiveJerryCan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem('empty_jerry_can', 1) then
        Player.Functions.AddItem('jerry_can', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["jerry_can"], "add")
        TriggerClientEvent('QBCore:Notify', src, 'You received a jerry can!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have an empty jerry can!', 'error')
    end
end)

RegisterNetEvent('mt-stealfuel:server:RemoveJerryCan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem('jerry_can', 1) then
        Player.Functions.AddItem('empty_jerry_can', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["empty_jerry_can"], "add")
        TriggerClientEvent('QBCore:Notify', src, 'You received a empty jerry can!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have an jerry can!', 'error')
    end
end)

QBCore.Functions.CreateCallback('QBCore:HasItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasItem = Player.Functions.GetItemByName(itemName) ~= nil
    cb(hasItem)
end)
