local triggerZone = trigger.misc.getZone('hel-1')
local playerPosition = Unit.getByName('blue'):getPoint()


function isUnitInsideTriggerZone()
    trigger.action.outText('zone\n' .. 'X: ' .. triggerZone.point.x .. ' Z: ' .. triggerZone.point.z
    .. ' alt: ' .. triggerZone.point.y .. ' radius: ' .. triggerZone.radius, 1)

    trigger.action.outText('player\n' .. 'X: ' .. playerPosition.x .. ' Z: ' .. playerPosition.z
        .. ' alt: ' .. playerPosition.y, 1)

    return playerPosition.x >= (triggerZone.point.x - triggerZone.radius)
        and playerPosition.x <= (triggerZone.point.x + triggerZone.radius)
        and playerPosition.y >= (triggerZone.point.y - triggerZone.radius)
        and playerPosition.y <= (triggerZone.point.y + triggerZone.radius)
end