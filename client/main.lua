-- Variables
local washingVehicle = false

-- Events
RegisterNetEvent('qbx_carwash:client:washCar', function()
    washingVehicle = true
    if lib.progressBar({
        duration = math.random(4000, 8000),
        label = Lang:t('washing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            mouse = false,
            combat = true
        },
    }) then -- if completed
        SetVehicleDirtLevel(cache.vehicle, 0.0)
        SetVehicleUndriveable(cache.vehicle, false)
        WashDecalsFromVehicle(cache.vehicle, 1.0)
        washingVehicle = false
    else -- if cancel
        exports.qbx_core:Notify(Lang:t('canceled'), 'error')
        washingVehicle = false
    end
end)

-- Threads
CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(cache.ped)
        local driver = cache.seat == -1
        local dirtLevel = GetVehicleDirtLevel(cache.vehicle)
        local sleep = 1000
        if IsPedInAnyVehicle(cache.ped, false) then
            for i = 1, #Config.Locations do
                local dist = #(playerCoords - Config.Locations[i])
                if dist <= 7.5 and driver then
                    sleep = 0
                    if not washingVehicle then
                        DrawText3D('~g~E~w~ - Wash the car ($'..Config.DefaultPrice..')', Config.Locations[i])
                        if IsControlJustPressed(0, 38) then
                            if dirtLevel > Config.DirtLevel then
                                TriggerServerEvent('qbx_carwash:server:startWash')
                            else
                                exports.qbx_core:Notify(Lang:t('not_dirty'), 'error')
                            end
                        end
                    else
                        DrawText3D(Lang:t('not_available'), Config.Locations[i])
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    for i = 1, #Config.Locations do
        local carWash = AddBlipForCoord(Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z)
        SetBlipSprite(carWash, 100)
        SetBlipDisplay(carWash, 4)
        SetBlipScale(carWash, 0.75)
        SetBlipAsShortRange(carWash, true)
        SetBlipColour(carWash, 37)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Lang:t('label'))
        EndTextCommandSetBlipName(carWash)
    end
end)