-- AUTO MARK --

-- this script is for marking marking first detected unit of each group of detected targets

-- author: Hélio Marcus Leão

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

GROUPS_IN_MEMORY = {}    -- where unique groups marked are stored with their timeMarked. format: {name, timeMarked}


-- CONFIGS
TIME_TO_UPDATE_MARK = 300    -- for an element to be removed from GROUPS_IN_MEMORY it has to not have been detected by jtac after this time in seconds (300 is smoke duration)

SCRIPT_REPEAT_INTERVAL = 10     -- for auto marking (schedule function)

COALITION = coalition.side.BLUE
JTAC_NAME = 'JTAC'
SMOKE_COLOR = trigger.smokeColor.White

MESSAGE_DURATION = 10


-- adds unique detected groups to memory
function addUniqueGroupsMemory (detectedTargets)

    for _, target in pairs(detectedTargets) do

        target = target.object

        if target then  -- sometimes the object from detected targets is nil

            local targetGroupName = target:getGroup():getName()
            local inMemory = false


            for _, markedGroup in pairs(GROUPS_IN_MEMORY) do

                if markedGroup.name == targetGroupName then
                    inMemory = true
                    break
                end
            end
            

            if not inMemory then

                local groupInfo = {}
                groupInfo.name = targetGroupName
                groupInfo.timeMarked = timer.getTime()

                table.insert(GROUPS_IN_MEMORY, groupInfo)

            end
        end

    end
end


-- calls functions to save unique groups, updates groups detected after TIME_TO_UPDATE_MARK, deletes groups not detected after TIME_TO_UPDATE_MARK,
-- marks first detected unit from groups in memory accordingly, shows how many targets were marked
function updateMemoryAndMarks (detectedTargets)
    addUniqueGroupsMemory (detectedTargets)


    local gameTime = timer.getTime()

    local targetsMarked = 0


    for i = #GROUPS_IN_MEMORY, 1, -1 do

        local inMemory = false
        local targetLocation = nil


        for _, target in pairs(detectedTargets) do

            target = target.object

            if target then

                local targetGroupName = target:getGroup():getName()
                targetLocation = target:getPoint()

                if GROUPS_IN_MEMORY[i].name == targetGroupName then
                    inMemory = true
                    break
                end

            end
        end

        
        if inMemory and GROUPS_IN_MEMORY[i].timeMarked + TIME_TO_UPDATE_MARK < gameTime  then
            GROUPS_IN_MEMORY[i].timeMarked = gameTime  -- updates timeMarked for units still detected after TIME_TO_UPDATE_MARK
        end

        if inMemory and GROUPS_IN_MEMORY[i].timeMarked - gameTime == 0 then
            trigger.action.smoke(targetLocation, SMOKE_COLOR)   -- smokes units from groups marked for it in this execution of script
            targetsMarked = targetsMarked + 1

        elseif not inMemory and GROUPS_IN_MEMORY[i].timeMarked + TIME_TO_UPDATE_MARK < gameTime then
            table.remove(GROUPS_IN_MEMORY, i)  -- removes group with no unit detected and TIME_TO_UPDATE_MARK higher than gameTime from memory
        end
        
    end

    if targetsMarked > 0 then
        trigger.action.outTextForCoalition(COALITION, targetsMarked .. ' TARGET(S) MARKED', MESSAGE_DURATION)
    end
end

-- can be called by itself without repeat
function markGroups()
    local jtac = Group.getByName(JTAC_NAME)

    if not jtac or jtac:getSize() == 0 then
        trigger.action.outTextForCoalition(COALITION, 'JTAC NOT DETECTED', MESSAGE_DURATION)
        return nil
    end

    updateMemoryAndMarks(Controller.getDetectedTargets(jtac))

    return timer.getTime() + SCRIPT_REPEAT_INTERVAL
end

function autoMark()
    timer.scheduleFunction(markGroups, {}, timer.getTime() + SCRIPT_REPEAT_INTERVAL)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- EXECUTION (may be called in another trigger)
autoMark() -- if desired behavior is smoke when required, call markGroups() instead when needed

-- using radios here instead of ME trigger would be a next step
-- another step would be to calculate some distances to make some decisions on where to place smoke
-- other option would be to find units throughout the map, maybe close to aircraft to not get limited just to 'JTAC' named group
-- this code could be adapted to units, just change code where group name to unit name
-- trigger.action.illuminationBomb({x = targetLocation.x, y = 1000, z = targetLocation.z} , 1000000) if night maybe