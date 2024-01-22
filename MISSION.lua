-- there's a difference between event on kill and dead. dead is completely dead, kill I guess cooking triggers it too. for infrantry kill worked better
-- maybe adding many event handlers would be better here. and remove then when it's mission is finished

-----------------------------------------------------------------------------------------------------------------------------------------------------

function activateGroup(name)
    local group = Group.getByName(name)
    trigger.action.activateGroup(group)
    return group
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function basesAttackStart()
    -- TODO
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function farpAttackStart()
    local heloGroup = Group.getByName('Rotary-1')

    trigger.action.outText('There are two helicopters on a FARP in the southeast of the city. Destroy them.', 20)


    -- EVENT HANDLER
    local eventHandler = {}
    function eventHandler:onEvent(event)
        if world.event.S_EVENT_DEAD == event.id then

            if not heloGroup then
                trigger.action.outText('Helos destroyed. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            end

        end
    end

    world.addEventHandler(eventHandler)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function sniperKillStart()

    trigger.action.outText('A Sniper is nested in a building in the northwest of the city. Marked with smoke. You are cleared to engage'
        , 20)

    local zone = trigger.misc.getZone('syria_city_house_14') -- point.y=0
    trigger.action.smoke({ x = zone.point.x, z = zone.point.z, y = 250 }, trigger.smokeColor.Red)

    -- EVENT HANDLER
    local eventHandler = {}
    function eventHandler:onEvent(event)
        if world.event.S_EVENT_HIT == event.id then

            if event.initiator.id_ == 210998323 then -- most(maybe all) lua objects have .id_
                trigger.action.outText('Sniper killed. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            end

        end
    end

    world.addEventHandler(eventHandler)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- WIP
function artilleryStrikeStart()
    local artillery = Group.getByName('Ground-19')
    local fort1 = Group.getByName('Ground-17')
    local fort2 = Group.getByName('Ground-15')
    local fort3 = Group.getByName('Ground-18')
    local fort4 = Group.getByName('Ground-20')
    local fort5 = Group.getByName('Ground-27')


    trigger.action.outText('Enemy artillery pounding allied positions.', 20)

    if fort1 then
        trigger.action.pushAITask(artillery, 1)
    elseif fort2 then
        trigger.action.pushAITask(artillery, 2)
    elseif fort3 then
        trigger.action.pushAITask(artillery, 3)
    elseif fort4 then
        trigger.action.pushAITask(artillery, 4)
    elseif fort5 then
        trigger.action.pushAITask(artillery, 5)
    end

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function scoutPartyStart()
    local lastAlliedFort = Group.getByName('Ground-27')
    local enemyScoutGroup = activateGroup('Ground-40')

    trigger.action.outText('Enemy scout party spotted going for the south allyed fortification' ..
        ' from east of town. Engage and destroy them.', 20)

    -- EVENT HANDLER
    local eventHandler = {}
    function eventHandler:onEvent(event)
        if world.event.S_EVENT_DEAD == event.id then

            if not enemyScoutGroup then
                trigger.action.outText('Enemy scout party destroyed. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            elseif not lastAlliedFort then
                trigger.action.outText('Ally fortifications destroyed. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            end

        end
    end

    world.addEventHandler(eventHandler)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function infantryDefenseStart() -- NOT CONSISTENT
    local alliedInfantry = Group.getByName('Ground-16')
    local enemyInfantry1 = activateGroup('Ground-41')
    local enemyInfantry2 = activateGroup('Ground-42')

    trigger.action.outText('Enemy infantry attacking allies northwest. Support required. Marked with smoke.', 20)

    trigger.action.smoke(alliedInfantry:getUnit(1):getPoint(), trigger.smokeColor.Green)


    -- EVENT HANDLER
    local eventHandler = {}
    function eventHandler:onEvent(event)
        if world.event.S_EVENT_DEAD == event.id then

            if (not enemyInfantry1 or not enemyInfantry1:isExist()) and
                (not enemyInfantry2 or not enemyInfantry2:isExist()) then
                trigger.action.outText('Enemy infantry dead. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            elseif not alliedInfantry or not alliedInfantry:isExist() then
                trigger.action.outText('Ally infantry killed. Return to station.', 5)
                nextMission()
                world.removeEventHandler(eventHandler)
            end

        end
    end

    world.addEventHandler(eventHandler)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

missionList = {
    -- {action = scoutPartyStart},
    { action = infantryDefenseStart },
    -- {action = sniperKillStart},
    -- {action = farpAttackStart},

    -- {action = basesAttackStart},
    -- {action = artilleryStrikeStart},
}


function startRandomMission()
    if #missionList == 0 then
        return trigger.action.outText('No further assistance required. You may RTB.', 5)
    end

    local i = math.random(#missionList)
    missionList[i].action()

    table.remove(missionList, i)
end

function nextMission()
    -- local randomTime = math.random(300, 600)
    local randomTime = math.random(20)

    timer.scheduleFunction(startRandomMission, {}, timer.getTime() + randomTime)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- nextMission()
