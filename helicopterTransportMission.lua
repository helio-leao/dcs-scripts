local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...
local PLAYER_UNIT_NAME = 'player'
local CARGO_WEIGHT = 5000

local availableZones = {}
local player = nil

-------------------------------------------------------------------------------------------------------------------------

-- todo: verify zone altitude on helipads
local function isUnitInsideZone(unit, zone)
    local unitPosition = unit:getPoint()

    local result = unitPosition.x >= (zone.point.x - zone.radius)
        and unitPosition.x <= (zone.point.x + zone.radius)
        and unitPosition.y >= (zone.point.y - zone.radius)
        and unitPosition.y <= (zone.point.y + zone.radius)

    return result
end

local function getAllZones()
    local allZones = {}
    local index = 1

    repeat
        local landingZone = trigger.misc.getZone(ZONE_BASE_NAME .. '-' .. index)

        if landingZone then
            table.insert(allZones, landingZone)
            index = index + 1
        end
    until not landingZone

    return allZones
end

local function getRandomZone()
    local randomZoneIndex = math.random(#availableZones)
    local randomZone = availableZones[randomZoneIndex]

    table.remove(availableZones, randomZoneIndex)

    return randomZone
end

local function getRandomRoute()
    return { origin = getRandomZone(), destiny = getRandomZone()}
end

-------------------------------------------------------------------------------------------------------------------------

local function unloadCargo(route)
    -- verify if player is on zone
    local isPlayerOnLz = isUnitInsideZone(player, route.destiny)

    if not isPlayerOnLz then
        trigger.action.outText('Not on LZ', 10)
        return
    end

    -- remove mark from the map
    trigger.action.removeMark(1)

    -- add cargo to aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, 0)
    trigger.action.outText('Cargo unloaded. Route finished.', 10)
    
    -- returns route zones to availableZones
    table.insert(availableZones, route.origin)
    table.insert(availableZones, route.destiny)
    
    trigger.action.outText('available zones count: ' .. #availableZones, 10)
    
    -- todo: restart commands
end

local function loadCargo(route)
    -- verify if player is on zone
    local isPlayerOnLz = isUnitInsideZone(player, route.origin)

    if not isPlayerOnLz then
        trigger.action.outText('Not on LZ', 10)
        return
    end
    
    -- remove mark from the map
    trigger.action.removeMark(1)

    -- add cargo to aircraft
    trigger.action.setUnitInternalCargo(PLAYER_UNIT_NAME, CARGO_WEIGHT)

    -- add mark to destiny on f10 map
    trigger.action.markToAll(1, 'route destiny', route.destiny.point) -- issue: not working
    trigger.action.outText('Route destiny marked on F10 map.', 10)

    -- update commands
    missionCommands.removeItem({ [1] = 'Transport Mission' })
    missionCommands.addSubMenu('Transport Mission')
    missionCommands.addCommand('Unload Cargo',
        { [1] = 'Transport Mission' }, unloadCargo, route)
end

local function selectRoute(route)
    -- add mark to origin on f10 map
    trigger.action.markToAll(1, 'route origin', route.origin.point)
    trigger.action.outText('Route origin marked on F10 map.', 10)

    -- update commands
    missionCommands.removeItem({ [1] = 'Transport Mission' })
    missionCommands.addSubMenu('Transport Mission')
    missionCommands.addCommand('Load Cargo',
        { [1] = 'Transport Mission' }, loadCargo, route)
end

local function initMenu()
    local route = getRandomRoute()

    missionCommands.addSubMenu('Transport Mission')
    missionCommands.addCommand(route.origin.point.x .. ' to ' .. route.destiny.point.x,
        { [1] = 'Transport Mission' }, selectRoute, route)
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

    initMenu()
end

main()