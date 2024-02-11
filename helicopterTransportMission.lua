-- note: add punishment for canceling mission?
-- note: use points or cash for mission list refreshing?
-- note: add missions history with ponctuation or cash?
-- note: refactor getRandomRoute and getRandomRouteList?

-- vec3 = { x: number, y: number, z: number }
-- zone = { id: number, point: vec3, radius: number }
-- route = { origin: zone, destiny: zone, distance: number }

-------------------------------------------------------------------------------------------------------------------------

local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...
local PLAYER_UNIT_NAME = 'player'
local MAIN_SUBMENU_NAME = 'Transport'
local CARGO_MIN_WEIGHT = 500 -- kg
local CARGO_MAX_WEIGHT = 1500 -- kg
local AVERAGE_SPEED = 180 -- km/h

local MESSAGE_SCREEN_TIME = 20

local colors = {
    ACTIVE = { 0, 0, 1, 1 },
    INACTIVE = { 0, 0, 0, 1 }
}

local availableZones = {}
local player

-------------------------------------------------------------------------------------------------------------------------

local function getTravelTimeInSeconds(distanceInMeters, averageSpeedInKmh)
    local metersPerSecond = (averageSpeedInKmh * 1000) / 3600
    return distanceInMeters / metersPerSecond
end

local function getDistance(point1, point2)
    local xd = point1.x - point2.x;
    local zd = point1.z - point2.z;
    return math.sqrt(xd * xd + zd * zd);
end

local function secondsToMinutes(seconds)
    return seconds / 60;
end

local function metersToKilometers(meters)
    return meters / 1000;
end

local function timeInSecondsToDHMS(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60
    return days, hours, minutes, remainingSeconds
end

-------------------------------------------------------------------------------------------------------------------------

-- note: no altitude verification
local function isPlayerInZone(zone)
    local playerPosition = player:getPoint()
    return getDistance(zone.point, playerPosition) <= zone.radius
end

local function getAllZones()
    local allZones = {}
    local index = 1

    repeat
        local zone = trigger.misc.getZone(ZONE_BASE_NAME .. '-' .. index)

        if zone then
            table.insert(allZones, {
                id = index,
                point = zone.point,
                radius = zone.radius
            })
            index = index + 1
        end
    until not zone

    return allZones
end

local function getRandomRoute()
    local randomZoneIndex1 = math.random(#availableZones)
    local randomZoneIndex2

    repeat
        randomZoneIndex2 = math.random(#availableZones)
    until randomZoneIndex2 ~= randomZoneIndex1

    local origin = availableZones[randomZoneIndex1]
    local destiny = availableZones[randomZoneIndex2]

    return {
        origin = origin,
        destiny = destiny,
        distance = getDistance(origin.point, destiny.point),
        cargoWeight = math.random(CARGO_MIN_WEIGHT, CARGO_MAX_WEIGHT)
    }
end

local function getRandomRouteList()
    local routesNumber = #availableZones > 2 and 4 or 2
    local routeList = {}

    while #routeList ~= routesNumber do
        local randomRoute = getRandomRoute()
        local isRouteDuplicate = false

        for i = 1, #routeList, 1 do
            if(routeList[i].origin.id == randomRoute.origin.id and
                routeList[i].destiny.id == randomRoute.destiny.id) then
                isRouteDuplicate = true
                break
            end
        end

        if not isRouteDuplicate then
            table.insert(routeList, randomRoute)
        end
    end

    return routeList
end

-------------------------------------------------------------------------------------------------------------------------

local function markAllZones()
    local transparent = { 0, 0, 0, 0 }
    local coalition = -1
    local lineType = 1
    local readOnly = false

    for index, zone in ipairs(availableZones) do
        trigger.action.circleToAll(coalition, index, zone.point,
            zone.radius, colors.INACTIVE, transparent, lineType, readOnly)
        trigger.action.textToAll(coalition, index + #availableZones,
            { x = zone.point.x + zone.radius, z = zone.point.z + zone.radius, y = zone.point.y },
            colors.INACTIVE, transparent, 20,  true, zone.id, readOnly)
    end
end

local function setSelectedRouteMarksColor(route, isSelected)
    local color = isSelected and colors.ACTIVE or colors.INACTIVE

    trigger.action.setMarkupColor(route.origin.id, color)
    trigger.action.setMarkupText(route.origin.id + #availableZones,
        isSelected and (route.origin.id .. ' - origin') or route.origin.id)
    trigger.action.setMarkupColor(route.origin.id + #availableZones, color)
    trigger.action.setMarkupColor(route.destiny.id, color)
    trigger.action.setMarkupText(route.destiny.id + #availableZones,
        isSelected and (route.destiny.id .. ' - destiny') or route.destiny.id)
    trigger.action.setMarkupColor(route.destiny.id + #availableZones, color)
end

-------------------------------------------------------------------------------------------------------------------------

-- note: forward declaration of function
local  startCommands


local function restartCommands()
    missionCommands.removeItem({ [1] = MAIN_SUBMENU_NAME })
    startCommands()
    trigger.action.outText('Route list updated.', MESSAGE_SCREEN_TIME)
end

local function showRouteInformation(params)
    local route = params.route
    local timeCargoLoaded = params.timeCargoLoaded

    local travelTime = getTravelTimeInSeconds(route.distance, AVERAGE_SPEED)
    local distance = metersToKilometers(route.distance)

    local data = route.origin.id .. ' to ' .. route.destiny.id .. '\n' ..
        'Weight: ' .. route.cargoWeight .. ' kg\n' ..
        'Distance: ' .. math.floor(distance) .. ' km\n' ..
        'Estimated time: ' .. math.floor(secondsToMinutes(travelTime)) .. ' min'

    if timeCargoLoaded then
        local _, hours, minutes, seconds = timeInSecondsToDHMS(timeCargoLoaded + travelTime)

        data = data .. '\nDelivery by ' .. string.format('%.2d', hours) ..
            ':' .. string.format('%.2d', minutes) .. ':' .. string.format('%.2d', seconds)
    end

    trigger.action.outText(data, MESSAGE_SCREEN_TIME)
end

local function cancelRoute(params)
    local route = params.route

    trigger.action.outText('Route Canceled.', MESSAGE_SCREEN_TIME)
    setSelectedRouteMarksColor(route, false)
    restartCommands()
end

local function unloadCargo(params)
    local route = params.route
    local timeCargoLoaded = params.timeCargoLoaded

    if not isPlayerInZone(route.destiny) then
        trigger.action.outText('Not on landing zone.', MESSAGE_SCREEN_TIME)
        return
    end

    -- calculate delivery time
    local timeCargoUnloaded = timer.getAbsTime()
    local travelTime = secondsToMinutes(timeCargoUnloaded - timeCargoLoaded)

    setSelectedRouteMarksColor(route, false)

    -- remove cargo from aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, 0)
    trigger.action.outText('Cargo unloaded.\nDelivery made in ' .. math.floor(travelTime)
        .. ' minutes.\nYou may choose another route.', MESSAGE_SCREEN_TIME)

    -- restart
    restartCommands()
end

local function loadCargo(params)
    local route = params.route

    if not isPlayerInZone(route.origin) then
        trigger.action.outText('Not on landing zone.', MESSAGE_SCREEN_TIME)
        return
    end

    local timeCargoLoaded = timer.getAbsTime()

    -- add cargo to aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, route.cargoWeight)

    trigger.action.outText('Cargo loaded.\nUnload cargo on destiny point.',
        MESSAGE_SCREEN_TIME)
    showRouteInformation({ route = route, timeCargoLoaded = timeCargoLoaded })

    -- updates commands for cargo unloading
    missionCommands.removeItem({ [1] = MAIN_SUBMENU_NAME })

    local mainSubmenu = missionCommands.addSubMenu(MAIN_SUBMENU_NAME)

    missionCommands.addCommand('Unload Cargo', mainSubmenu, unloadCargo,
        { route = route, timeCargoLoaded = timeCargoLoaded })
    missionCommands.addCommand('Information', mainSubmenu, showRouteInformation,
        { route = route, timeCargoLoaded = timeCargoLoaded })
    missionCommands.addCommand('Cancel', mainSubmenu, cancelRoute,
        { route = route })
end

local function selectRoute(params)
    local route = params.route

    trigger.action.outText('Route ' .. route.origin.id .. ' to '
        .. route.destiny.id .. ' selected.\nLoad cargo on origin point.', MESSAGE_SCREEN_TIME)

    setSelectedRouteMarksColor(route, true)

    -- updates commands for cargo loading
    missionCommands.removeItem({ [1] = MAIN_SUBMENU_NAME })

    local mainSubmenu = missionCommands.addSubMenu(MAIN_SUBMENU_NAME)

    missionCommands.addCommand('Load Cargo', mainSubmenu, loadCargo, { route = route })
    missionCommands.addCommand('Information', mainSubmenu, showRouteInformation, { route = route })
    missionCommands.addCommand('Cancel', mainSubmenu, cancelRoute, { route = route })
end

startCommands = function()
    local routes = getRandomRouteList()

    -- create main submenu
    local mainSubmenu = missionCommands.addSubMenu(MAIN_SUBMENU_NAME)

    -- create each route submenu and commands
    for _, route in ipairs(routes) do
        local distance = metersToKilometers(route.distance)

        local routeSubmenu = missionCommands.addSubMenu(route.origin.id .. ' to ' .. route.destiny.id
            .. ' | ' .. math.floor(distance) .. ' km | ' .. route.cargoWeight .. ' kg' , mainSubmenu)

        missionCommands.addCommand('Accept', routeSubmenu, selectRoute, { route = route })
        missionCommands.addCommand('Information', routeSubmenu, showRouteInformation, { route = route })
    end
    missionCommands.addCommand('Refresh', mainSubmenu, restartCommands)
end

-------------------------------------------------------------------------------------------------------------------------

local function main()
    availableZones = getAllZones()
    player = Unit.getByName(PLAYER_UNIT_NAME)

    if #availableZones < 2 then
        trigger.action.outText('More than 2 landing zones needed to run script.',
            MESSAGE_SCREEN_TIME)
        return
    end
    if not player then
        trigger.action.outText('Unit named "' .. PLAYER_UNIT_NAME ..
            '" needed to run script.', MESSAGE_SCREEN_TIME)
        return
    end
    markAllZones()
    startCommands()
end

main()