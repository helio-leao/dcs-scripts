local customEventHandler = {}

function customEventHandler:onEvent(event)

    if (world.event.S_EVENT_LANDING_AFTER_EJECTION == event.id) then

        local pilot = event.initiator
        local pilotLocation = pilot:getPoint()

        local info = pilot:getName() .. '\n'
            .. 'point x:' .. pilotLocation.x .. ' y:' .. pilotLocation.y .. ' z:' .. pilotLocation.z .. '\n'
            .. 'coalition ' .. pilot:getCoalition() .. '\n'
            .. 'life ' .. pilot:getLife() .. '\n'
            .. 'surface type: ' .. land.getSurfaceType({y = pilotLocation.z, x = pilotLocation.x})

        trigger.action.outText(info, 10)
    end

end

world.addEventHandler(customEventHandler);

-- há um problema no dcs onde o piloto as vezes cai na água e o evento S_EVENT_LANDING_AFTER_EJECTION dispara