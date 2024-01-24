local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...
local PLAYER_UNIT_NAME = 'player'

local availableZones = {}
local player = nil


-- todo: verify zone altitude on helipads
local function isUnitInsideZone(unit, zone)
    local unitPosition = unit:getPoint()

    local result = unitPosition.x >= (zone.point.x - zone.radius)
        and unitPosition.x <= (zone.point.x + zone.radius)
        and unitPosition.y >= (zone.point.y - zone.radius)
        and unitPosition.y <= (zone.point.y + zone.radius)

    -- trigger.action.outText('zone'
    --     .. '\nX: ' .. zone.point.x .. ' Z: ' .. zone.point.z
    --     .. ' alt: ' .. zone.point.y .. ' radius: ' .. zone.radius
    --     .. '\n\nplayer'
    --     .. '\nX: ' .. unitPosition.x .. ' Z: ' .. unitPosition.z
    --     .. ' alt: ' .. unitPosition.y
    --     .. '\n\nunit inside zone: ' .. (result and 'true' or 'false')
    -- , 1)

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

local function startMission(route)
    trigger.action.outText('Go to the origin of the route at '
        .. route.origin.point.x .. ' and notify the central.', 10)

    -- todo: at least add a mark point on lz
end

local function initMenu(route)
    missionCommands.addSubMenu('Transport Mission')
    missionCommands.addCommand(route.origin.point.x .. ' to ' .. route.destiny.point.x,
        { [1] = 'Transport Mission' }, startMission, route)
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
        trigger.action.outText('Unit named "player" needed to run script.', 10)
        return
    end

    initMenu(getRandomRoute())
end

main()