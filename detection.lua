blue = Unit.getByName('blue')
red = Unit.getByName('red')

function detect()
    local detected = Controller.isTargetDetected(blue:getController(), red, Controller.Detection.VISUAL)

    if(detected) then
        trigger.action.outText('is detected', 1);
    else
        trigger.action.outText('not detected', 1);
    end

    return timer.getTime() + 1
end

timer.scheduleFunction(detect, {}, timer.getTime() + 1)


-- Controller.Detection  
--   VISUAL  1
--   OPTIC   2
--   RADAR   4
--   IRST    8
--   RWR     16
--   DLINK   32