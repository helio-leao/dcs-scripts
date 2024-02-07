-- todo: punishment for canceling mission
-- todo: change color of selected route zones markings on map
-- note: add missions history with ponctuation or cash?
-- todo: refactor getRandomRoute and getRandomRouteList

-- vec3 = { x: number, y: number, z: number }
-- zone = { id: number, point: vec3, radius: number }
-- route = { origin: zone, destiny: zone, distance: number }

-------------------------------------------------------------------------------------------------------------------------

local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...
local PLAYER_UNIT_NAME = 'player'
local MAIN_SUBMENU_NAME = 'Transport Mission'
local CARGO_WEIGHT = 1000   -- note: 10 people

local availableZones = {}
local player  -- note: start with nil?

-------------------------------------------------------------------------------------------------------------------------

-- note: no altitude verification
-- note: checking whether the player is inside a square-shaped zone rather than a circular one
-- issue: precision is off (easy to see on small zones)
local function isPlayerInZone(zone)
    local playerPosition = player:getPoint()

    return playerPosition.x >= (zone.point.x - zone.radius)
        and playerPosition.x <= (zone.point.x + zone.radius)
        and playerPosition.y >= (zone.point.y - zone.radius)
        and playerPosition.y <= (zone.point.y + zone.radius)
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

local function getDistance(point1, point2)
    local xd = point1.x - point2.x;
    local zd = point1.z - point2.z;
    return math.sqrt(xd * xd + zd * zd);
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
        distance = getDistance(origin.point, destiny.point)
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

-- note: forward declaration of function
-- note: start with some value?
local  updateCommands


local function restartCommands()
    missionCommands.removeItem({ [1] = MAIN_SUBMENU_NAME })
    updateCommands()
end

local function unloadCargo(args)
    local route = args.route
    local timeCargoLoaded = args.timeCargoLoaded

    if not isPlayerInZone(route.destiny) then
        trigger.action.outText('Not on LZ', 10)
        return
    end

    -- calculate delivery time
    local timeCargoUnloaded = timer.getAbsTime()
    local deliveryTime = timeCargoUnloaded - timeCargoLoaded

    -- remove cargo from aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, 0)
    trigger.action.outText('Cargo unloaded. Delivery made in '
        .. deliveryTime .. ' seconds', 10)

    -- restart
    restartCommands()
end

local function showRouteInformation(args)
    local route = args.route
    local timeCargoLoaded = args.timeCargoLoaded

    -- calculate approximate time in minutes, given a speed of 200 km/h
    local speedInMetersPerSecond = 200 * 1000 / 3600  -- convert km/h to m/s
    local aproxTimeInSeconds = route.distance / speedInMetersPerSecond
    local aproxTimeInMinutes = math.floor(aproxTimeInSeconds / 60)

    local data = route.origin.id .. ' to ' .. route.destiny.id .. '\n\n' ..
        'Distance: ' .. math.floor(route.distance) .. ' meters\n' ..
        'Approximate time: ' .. aproxTimeInMinutes .. ' minutes at 200km/h'

    if timeCargoLoaded then
        data = data .. '\nTime of cargo loading: ' .. timeCargoLoaded
    end

    trigger.action.outText(data, 10)
end

local function cancelRoute()
    trigger.action.outText('Route Canceled', 10)
    restartCommands()
end

local function loadCargo(args)
    local route = args.route

    if not isPlayerInZone(route.origin) then
        trigger.action.outText('Not on LZ', 10)
        return
    end

    local timeCargoLoaded = timer.getAbsTime()

    -- add cargo to aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, CARGO_WEIGHT)

    trigger.action.outText(CARGO_WEIGHT ..
        'kg cargo loaded at time ' .. timeCargoLoaded ..
        '. Select "unload cargo" on destiny point.', 10)

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

local function selectRoute(args)
    local route = args.route

    trigger.action.outText('Route ' .. route.origin.id .. ' to '
        .. route.destiny.id .. ' selected. Select "load cargo" on origin point.', 10)

    -- updates commands for cargo loading
    missionCommands.removeItem({ [1] = MAIN_SUBMENU_NAME })
    local mainSubmenu = missionCommands.addSubMenu(MAIN_SUBMENU_NAME)
    missionCommands.addCommand('Load Cargo', mainSubmenu, loadCargo, { route = route })
    missionCommands.addCommand('Information', mainSubmenu, showRouteInformation, { route = route })
    missionCommands.addCommand('Cancel', mainSubmenu, cancelRoute, { route = route })
end

updateCommands = function()
    local routes = getRandomRouteList()

    -- create main submenu
    local mainSubmenu = missionCommands.addSubMenu(MAIN_SUBMENU_NAME)

    -- create each route submenu and commands
    for _, route in ipairs(routes) do
        local routeSubmenu = missionCommands.addSubMenu(
            route.origin.id .. ' to ' .. route.destiny.id .. '(' ..
            math.floor(route.distance / 1000) .. 'm)', mainSubmenu)
        missionCommands.addCommand('Accept', routeSubmenu, selectRoute, { route = route })
        missionCommands.addCommand('Information', routeSubmenu, showRouteInformation, { route = route })
    end
end

local function markAllZones()
    local blue = {0, 0, 1, 1}
    local transparent = {0, 0, 0, 0}
    local coalition = -1
    local lineType = 1
    local radius = 2000

    for index, zone in ipairs(availableZones) do
        trigger.action.circleToAll(coalition, index, zone.point,
            radius, blue, transparent, lineType)
        trigger.action.textToAll(coalition, #availableZones + index,
            { x = zone.point.x + radius, z = zone.point.z + radius, y = zone.point.y },
            blue, transparent, 20,  true, zone.id)
    end
end

-------------------------------------------------------------------------------------------------------------------------

local function main()
    availableZones = getAllZones()
    player = Unit.getByName(PLAYER_UNIT_NAME)

    if #availableZones < 2 then
        trigger.action.outText('More than 2 landing zones needed to run script.', 10)
        return
    end
    if not player then
        trigger.action.outText('Unit named "' .. PLAYER_UNIT_NAME .. '" needed to run script.', 10)
        return
    end

    markAllZones()
    updateCommands()
end

main()