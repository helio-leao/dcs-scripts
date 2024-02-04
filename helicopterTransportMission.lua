-- todo: delivery time
-- todo: add more route options
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

    -- returns route zones to availableZones
    -- todo: refactor this so it's not removed and added again
    table.insert(availableZones, route.origin)
    table.insert(availableZones, route.destiny)

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
    -- todo: updater for map marks in case player deletes them
end

updateCommands = function()
    local route = getRandomRoute()

    -- routes available for choosing
    missionCommands.addSubMenu(SUBMENU_NAME)
    missionCommands.addCommand(route.origin.name .. ' to ' .. route.destiny.name,
        { [1] = SUBMENU_NAME }, selectRoute, route)
    -- todo: updater for map marks in case player deletes them
end

-------------------------------------------------------------------------------------------------------------------------

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