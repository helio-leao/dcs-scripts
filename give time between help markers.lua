local REFRESH_RATE = 1 -- script will be run in this interval (1 second). determines precision of time too, might want 0.1
local MESSAGE_DURATION = 10

local FLAG = '1'

local LAST_WAYPOINT = 2


local raceStartTime = 0
local raceEndTime = 0


local function verifyRaceEnd()
    local flag = trigger.misc.getUserFlag(FLAG)

    if flag == LAST_WAYPOINT then
        raceEndTime = timer.getAbsTime() - raceStartTime
        trigger.action.outText(raceEndTime .. ' seconds', MESSAGE_DURATION)

        return nil
    end

    return timer.getTime() + REFRESH_RATE
end

local function verifyRaceStart()
    local flag = trigger.misc.getUserFlag(FLAG)

    if (flag == 1) then
        raceStartTime = timer.getAbsTime()
        trigger.action.outText('START', MESSAGE_DURATION)

        timer.scheduleFunction(verifyRaceEnd, {}, timer.getTime() + REFRESH_RATE)
        return nil
    end

    return timer.getTime() + REFRESH_RATE
end

function execute()
    timer.scheduleFunction(verifyRaceStart, {}, timer.getTime() + REFRESH_RATE)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

execute() -- execution (could be called in another trigger)
