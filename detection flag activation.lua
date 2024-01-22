-- config
local SCRIPT_LOOP_INTERVAL = 1

local FLAG_NUMBER = 1
local UNIT_NAME = 'radar'

-- variables
local unit = Unit.getByName(UNIT_NAME)

-- function
function detect()
    local detectedTargets = unit:getController():getDetectedTargets()

    if (#detectedTargets > 0) then
        trigger.action.setUserFlag(FLAG_NUMBER, true)
        return nil
    end

    return timer.getTime() + SCRIPT_LOOP_INTERVAL
end

timer.scheduleFunction(detect, {}, timer.getTime() + 1)


-- Controller.Detection
--   VISUAL  1
--   OPTIC   2
--   RADAR   4
--   IRST    8
--   RWR     16
--   DLINK   32
