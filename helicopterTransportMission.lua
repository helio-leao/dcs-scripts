-- todo: delivery time
-- todo: cancel mission
-- note: add missions history with ponctuation or cash?

local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...
local PLAYER_UNIT_NAME = 'player'
local SUBMENU_NAME = 'Transport Mission'
local CARGO_WEIGHT = 1000   -- note: 10 people

local availableZones = {}
local player = nil

-------------------------------------------------------------------------------------------------------------------------

-- todo: verify zone altitude on helipads
-- note:  is checking whether a unit is inside a square-shaped zone rather than a circular one
-- issue: precision is off (easy to see on small zones)
local function isUnitInsideZone(unit, zone)
    local unitPosition = unit:getPoint()

    return unitPosition.x >= (zone.point.x - zone.radius)
        and unitPosition.x <= (zone.point.x + zone.radius)
        and unitPosition.y >= (zone.point.y - zone.radius)
        and unitPosition.y <= (zone.point.y + zone.radius)
end

local function getAllZones()
    local allZones = {}
    local index = 1

    repeat
        local zoneName = ZONE_BASE_NAME .. '-' .. index
        local zone = trigger.misc.getZone(zoneName)

        if zone then
            table.insert(allZones, {
                name = zoneName,
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

    repeat randomZoneIndex2 = math.random(#availableZones)
        until randomZoneIndex2 ~= randomZoneIndex1

    return {
        origin = availableZones[randomZoneIndex1],
        destiny = availableZones[randomZoneIndex2]
    }
end

local function getRandomRouteList()
    local routeList = {}

    while #routeList ~= 2 do
        local randomRoute = getRandomRoute()
        local isRouteDuplicate = false

        for i = 1, #routeList, 1 do
            if(routeList[i].origin.name == randomRoute.origin.name and
                routeList[i].destiny.name == randomRoute.destiny.name) then
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

local  updateCommands -- note: forward declaration of function


local function unloadCargo(route)
    -- verify if player is on zone
    local isPlayerOnLz = isUnitInsideZone(player, route.destiny)

    if not isPlayerOnLz then
        trigger.action.outText('Not on LZ', 10)
        return
    end

    -- remove cargo from aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, 0)
    trigger.action.outText('Cargo unloaded. Route finished.', 10)

    -- restart commands
    missionCommands.removeItem({ [1] = SUBMENU_NAME })
    updateCommands()
end

local function loadCargo(route)
    -- verify if player is on zone
    local isPlayerOnLz = isUnitInsideZone(player, route.origin)

    if not isPlayerOnLz then
        trigger.action.outText('Not on LZ', 10)
        return
    end

    -- add cargo to aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, CARGO_WEIGHT)

    -- updates commands for cargo unloading
    missionCommands.removeItem({ [1] = SUBMENU_NAME })
    missionCommands.addSubMenu(SUBMENU_NAME)
    missionCommands.addCommand('Unload Cargo', { [1] = SUBMENU_NAME }, unloadCargo, route)
end

local function selectRoute(route)
    -- updates commands for cargo loading
    missionCommands.removeItem({ [1] = SUBMENU_NAME })
    missionCommands.addSubMenu(SUBMENU_NAME)
    missionCommands.addCommand('Load Cargo', { [1] = SUBMENU_NAME }, loadCargo, route)
    -- todo: add route "info" with zones names and coordinates
end

updateCommands = function()
    local routes = getRandomRouteList()

    -- set submenu and commands
    missionCommands.addSubMenu(SUBMENU_NAME)

    for _, route in ipairs(routes) do
        missionCommands.addCommand(route.origin.name .. ' to ' .. route.destiny.name,
            { [1] = SUBMENU_NAME }, selectRoute, route)
    end
end

-------------------------------------------------------------------------------------------------------------------------

-- todo: change the type of markings on map
local function markAllZones()
    for index, zone in ipairs(availableZones) do
        trigger.action.markToAll(index, zone.name, zone.point)
    end
end

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