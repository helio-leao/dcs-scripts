-- LASE SUBMENU --

-- Creates submenu for lasing detected targets from a unit ('jtac')

-- author: Hélio Marcus Leão

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DESIGN DETAILS
-- The script does not round coordinates. it just removes decimal places.
-- The script does round altitude. the decision with these were made so the numbers would match the ones shown in ME.
-- Creates coords formats that can be quickly adapted for a lot of aircrafts. most will need only removing some decimal places or padding zeroes
-- The jtac only monitors a target when lasing it. chosen target is used to get information on position and target storage for lasing
-- The script does not verify if jtac exists after setup. If the mission has an immortal jtac it is of no consequence, otherwise it would be necessary to do
-- this on many functions to destroy laser(if necessary) and menu.

-- submenuPageIndex STRUCTURE
--                     [1] Establish contact
-- [1] JTAC...
--                     [1] Choose Target...         [1] Tank (many targets with pagination)
--                     [2] Change Code...           [1] 1688 (up to 10 codes)
--                     [3] Autolase ON
--                     [4] Autolase OFF
--                     [5] Check out

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CONFIGS (won't change in execution)

JTAC_NAME = 'jtac'
COALITION = coalition.side.BLUE
LASER_CODE_LIST = { 1688, 1621, 1732, 1777, 1782, 1788, 1113 } -- last code works on su-25t

MESSAGE_DURATION = {
    STANDARD = 10,
    LONG = 10
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL VARIABLES

jtac = Unit.getByName(JTAC_NAME)

isAutoLaseOn = false
laserCode = LASER_CODE_LIST[1]

laser = nil

selectedTarget = nil

updateLaserFunctionId = nil

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getLatHemisphere(lat)
    return lat > 0 and 'N' or 'S'
end

function getLonHemisphere(lon)
    return lon > 0 and 'E' or 'W'
end

function DDtoDMM(decimalDegrees) -- decimal degrees to degrees and decimal minutes
    if decimalDegrees < 0 then decimalDegrees = -decimalDegrees end

    local degrees = math.floor(decimalDegrees)
    local decimalMinutes = (decimalDegrees - degrees) * 60

    return degrees, decimalMinutes
end

function DDtoDMS(decimalDegrees) -- decimal degrees to degrees, minutes, and decimal seconds
    local degrees, decimalMinutes = DDtoDMM(decimalDegrees)

    local minutes = math.floor(decimalMinutes)
    local decimalSeconds = (decimalMinutes - minutes) * 60

    return degrees, minutes, decimalSeconds
end

function getLatDMSString(lat)
    local degrees, minutes, decimalSeconds = DDtoDMS(lat)
    local seconds = math.floor(decimalSeconds * 100) / 100

    return getLatHemisphere(lat) ..
        ' ' ..
        string.format('%02d', degrees) ..
        'º' .. string.format('%02d', minutes) .. "'" .. string.format('%.2f', seconds) .. '"'
end

function getLonDMSString(lon)
    local degrees, minutes, decimalSeconds = DDtoDMS(lon)
    local seconds = math.floor(decimalSeconds * 100) / 100

    return getLonHemisphere(lon) ..
        ' ' ..
        string.format('%03d', degrees) ..
        'º' .. string.format('%02d', minutes) .. "'" .. string.format('%.2f', seconds) .. '"'
end

function getLatDMMString(lat)
    local degrees, decimalMinutes = DDtoDMM(lat)
    local minutes = math.floor(decimalMinutes * 10000) / 10000

    return getLatHemisphere(lat) .. ' ' .. string.format('%02d', degrees) .. 'º' ..
        string.format('%.4f', minutes) .. "'"
end

function getLonDMMString(lon)
    local degrees, decimalMinutes = DDtoDMM(lon)
    local minutes = math.floor(decimalMinutes * 10000) / 10000

    return getLonHemisphere(lon) .. ' ' .. string.format('%03d', degrees) .. 'º' ..
        string.format('%.4f', minutes) .. "'"
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getTargetPositionReport(target)
    local lat, lon, alt = coord.LOtoLL(target:getPoint())

    local altitudeInMeters = string.format('%.f', alt)
    local altitudeInFeet = string.format('%.f', metersToFeet(alt))

    local grid = coord.LLtoMGRS(lat, lon)

    local report = target:getTypeName() .. '\n\n'
        ..
        'Grid:\n' .. grid.UTMZone .. ' ' .. grid.MGRSDigraph .. ' ' .. grid.Easting .. ' ' .. grid.Northing .. '\n\n'
        .. 'Lat Long:\n'
        .. getLatDMSString(lat) .. '  ' .. getLonDMSString(lon) .. '\n'
        .. getLatDMMString(lat) .. '  ' .. getLonDMMString(lon) .. '\n\n'
        .. 'Altitude:\n' .. altitudeInMeters .. ' meters\n' .. altitudeInFeet .. ' feet'

    return report
end

function metersToFeet(meters)
    return meters * 3.28084
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function stopLasing()
    timer.removeFunction(updateLaserFunctionId)
    updateLaserFunctionId = nil

    laser:destroy()
    laser = nil
    trigger.action.outTextForCoalition(COALITION, 'Laser off', MESSAGE_DURATION.STANDARD)
end

function changeCode(code)
    if laser then laser:setCode(code) end
    laserCode = code
end

function updateLaserPoint(target, time)
    if not target:isExist() then
        selectedTargetDestroyedUpdate()
        stopLasing()
        updateJtacSubmenu()
        return nil
    end

    laser:setPoint(target:getPoint())
    return time + 0.5
end

function startLasing(target)
    if target:isExist() then
        laser = Spot.createLaser(jtac, { x = 0, y = 1, z = 0 }, target:getPoint(), laserCode) -- could be createInfraRed
        trigger.action.outTextForCoalition(COALITION, 'Lasing on code ' .. laserCode, MESSAGE_DURATION.STANDARD)
        updateLaserFunctionId = timer.scheduleFunction(updateLaserPoint, target, timer.getTime() + 0.5)
    else
        selectedTargetDestroyedUpdate()
        updateJtacSubmenu()
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function selectedTargetDestroyedUpdate()
    trigger.action.outTextForCoalition(COALITION, 'Target destroyed', MESSAGE_DURATION.STANDARD)
    selectedTarget = nil
end

function chooseTargetCommand(target)
    if laser then stopLasing() end

    if target:isExist() then
        trigger.action.outTextForCoalition(COALITION, getTargetPositionReport(target), MESSAGE_DURATION.LONG)
        if isAutoLaseOn then startLasing(target) end
        selectedTarget = target
    else
        selectedTargetDestroyedUpdate()
        updateJtacSubmenu()
    end
end

function autolaseOnCommand()
    if laser then stopLasing() end

    if selectedTarget then
        startLasing(selectedTarget)
    else
        trigger.action.outTextForCoalition(COALITION, 'Autolase ON', MESSAGE_DURATION.STANDARD)
    end

    isAutoLaseOn = true
end

function autolaseOffCommand()
    if laser then
        stopLasing()
    else
        trigger.action.outTextForCoalition(COALITION, 'Autolase OFF', MESSAGE_DURATION.STANDARD)
    end

    isAutoLaseOn = false
end

function checkoutCommand()
    isAutoLaseOn = false
    selectedTarget = nil

    if laser then stopLasing() end

    trigger.action.outTextForCoalition(COALITION, 'Checking out', MESSAGE_DURATION.STANDARD)
    setJtacSubmenuWithContactCommand()
end

function changeCodeCommand(code)
    changeCode(code)
    trigger.action.outTextForCoalition(COALITION, 'Code changed to ' .. laserCode, MESSAGE_DURATION.STANDARD)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function addTargetsToSubmenu(targets, submenu)
    local submenuPageCount = math.ceil(#targets / 9) -- submenus with max 9 targets

    local submenuPage = nil

    for submenuPageIndex = 1, submenuPageCount do
        local firstSubmenuCommandIndex = 0
        local lastSubmenuCommandIndex = 0

        if submenuPageIndex == 1 then
            firstSubmenuCommandIndex = 1
        else
            firstSubmenuCommandIndex = ((submenuPageIndex * 9) + 1) - 9
        end

        if submenuPageIndex == submenuPageCount then
            lastSubmenuCommandIndex = #targets
        else
            lastSubmenuCommandIndex = submenuPageIndex * 9
        end


        for submenuIndex = firstSubmenuCommandIndex, lastSubmenuCommandIndex do -- adds 9 commands for each submenuPage
            local target = targets[submenuIndex].object

            if (submenuPageIndex == 1) then
                missionCommands.addCommandForCoalition(COALITION, target:getTypeName(), submenu, chooseTargetCommand,
                    target)
            else
                missionCommands.addCommandForCoalition(COALITION, target:getTypeName(), submenuPage, chooseTargetCommand
                    , target)
            end
        end

        if submenuPageIndex < submenuPageCount then -- adds aditional submenuPages for each 9 targets
            local submenuName = 'More Targets'

            if submenuPageIndex == 1 then
                submenuPage = missionCommands.addSubMenuForCoalition(COALITION, submenuName, submenu)
            else
                submenuPage = missionCommands.addSubMenuForCoalition(COALITION, submenuName, submenuPage)
            end
        end

    end
end

function addCodesToSubmenu(changeCodeSubmenu)
    for i = 1, #LASER_CODE_LIST do
        missionCommands.addCommandForCoalition(COALITION, LASER_CODE_LIST[i], changeCodeSubmenu, changeCodeCommand,
            LASER_CODE_LIST[i])
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getAliveTargets(targetsList)
    local aliveTargets = {}

    for _, target in pairs(targetsList) do
        if target.object and target.object:getLife() > 1 then -- cooking targets have 1hp
            table.insert(aliveTargets, target)
        end
    end

    return aliveTargets
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function updateJtacSubmenu()
    local detectedTargets = jtac:getController():getDetectedTargets()
    local targets = getAliveTargets(detectedTargets)

    if #targets > 0 then
        setJtacSubmenuWithOptionsItems(targets)
        trigger.action.outTextForCoalition(COALITION, #targets .. ' targets. Waiting for orders.',
            MESSAGE_DURATION.STANDARD)
    else
        trigger.action.outTextForCoalition(COALITION, 'No targets detected. Checking out.', MESSAGE_DURATION.STANDARD)
        setJtacSubmenuWithContactCommand()
    end
end

function resetJtacSubmenu()
    missionCommands.removeItemForCoalition(COALITION, { [1] = 'JTAC' })
    missionCommands.addSubMenuForCoalition(COALITION, 'JTAC')
end

function setJtacSubmenuWithContactCommand()
    resetJtacSubmenu()
    missionCommands.addCommandForCoalition(COALITION, 'Establish contact', { [1] = 'JTAC' }, updateJtacSubmenu)
end

function setJtacSubmenuWithOptionsItems(targets)
    resetJtacSubmenu()

    local laseTargetSubmenu = missionCommands.addSubMenuForCoalition(COALITION, 'Choose target', { [1] = 'JTAC' })
    addTargetsToSubmenu(targets, laseTargetSubmenu)
    local changeCodeSubmenu = missionCommands.addSubMenuForCoalition(COALITION, 'Change code', { [1] = 'JTAC' })
    addCodesToSubmenu(changeCodeSubmenu)

    missionCommands.addCommandForCoalition(COALITION, 'Autolase ON', { [1] = 'JTAC' }, autolaseOnCommand)
    missionCommands.addCommandForCoalition(COALITION, 'Autolase OFF', { [1] = 'JTAC' }, autolaseOffCommand)
    missionCommands.addCommandForCoalition(COALITION, 'Check out', { [1] = 'JTAC' }, checkoutCommand)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function main()
    if not jtac then
        return trigger.action.outTextForCoalition(COALITION, 'NO UNIT NAMED "' .. JTAC_NAME .. '". SCRIPT WILL NOT RUN.'
            , MESSAGE_DURATION.STANDARD)
    end

    setJtacSubmenuWithContactCommand()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main()
