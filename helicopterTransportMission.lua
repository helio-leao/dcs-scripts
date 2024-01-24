local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...

local availableZones = {}


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

-- todo: adjust
local function getCurrentZone()
    availableZones = getAllZones()

    local currentZoneIndex = math.random(#availableZones)
    local currentZone = availableZones[currentZoneIndex]

    table.remove(availableZones, currentZoneIndex)

    return currentZone
end

-------------------------------------------------------------------------------------------------------------------------

local function f(vars)
    trigger.action.outText(vars.message, 10)
    missionCommands.removeItem({ [1] = 'Submenu test' })
end


local function main()
    missionCommands.addSubMenu('Submenu test')
    missionCommands.addCommand("Command test", { [1] = 'Submenu test' }, f, { message = 'removing submenu' })
end

main()