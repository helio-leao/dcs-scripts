-- DISTANCE --
-- calculates the distance between 2 units
-- units used in game is METERS

-- x is directed to the north, z is directed to the east, y is directed up
-- these and more details at 'Basic terms and types' - https://www.digitalcombatsimulator.com/en/support/faq/1256/

local function getDistance(point1, point2)
    local xd = point1.x - point2.x;
    local zd = point1.z - point2.z;

    return math.sqrt(xd * xd + zd * zd);
end

-- main function
function main()
    -- gets vec3 positions of units
    local blueLocation = Unit.getByName('blue'):getPoint();
    local redLocation = Unit.getByName('red'):getPoint();

    -- calculations
    local distance = getDistance(blueLocation, redLocation);
    distance = distance / 1000; -- converts to km

    -- shows result
    trigger.action.outText(math.floor(distance + 0.5) .. ' km', 10); -- shows rounded distance
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main(); -- execution (may be called in another trigger)
