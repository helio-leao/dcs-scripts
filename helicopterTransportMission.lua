local ZONE_BASE_NAME = 'lz' -- lz-1, lz-2...

function isUnitInsideZone(unit, zone)
    local unitPosition = unit:getPoint()

    local result = unitPosition.x >= (zone.point.x - zone.radius)
        and unitPosition.x <= (zone.point.x + zone.radius)
        and unitPosition.y >= (zone.point.y - zone.radius)
        and unitPosition.y <= (zone.point.y + zone.radius)

    trigger.action.outText('zone'
        .. '\nX: ' .. zone.point.x .. ' Z: ' .. zone.point.z
        .. ' alt: ' .. zone.point.y .. ' radius: ' .. zone.radius
        .. '\n\nplayer'
        .. '\nX: ' .. unitPosition.x .. ' Z: ' .. unitPosition.z
        .. ' alt: ' .. unitPosition.y
        .. '\n\nunit inside zone: ' .. (result and 'true' or 'false')
    , 1)

    return result
end

function getAllLandingZones()
    local allLandingZones = {}
    local index = 1
    local landingZone = trigger.misc.getZone(ZONE_BASE_NAME .. '-' .. index)

    while landingZone do
        table.insert(allLandingZones, landingZone)
        index = index + 1
        landingZone = trigger.misc.getZone(ZONE_BASE_NAME .. '-' .. index)
    end

    return allLandingZones
end

function main()
    local allLandingZones = getAllLandingZones()
    trigger.action.outText('landing zones count: ' .. #allLandingZones, 1)

    -- isUnitInsideZone(Unit.getByName('blue'),
    --     trigger.misc.getZone('hel-1'))
end

main()