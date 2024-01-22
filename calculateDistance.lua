-- DISTANCE --
-- calculates the distance between 2 units
-- this is a study of vec3 and vec2 calculations and lua math functions
-- converts vec3d to vec2d

-- x is directed to the north, z is directed to the east, y is directed up
-- note that 'z' in vec3 is 'y' in vec2
-- these and more details at 'Basic terms and types' - https://www.digitalcombatsimulator.com/en/support/faq/1256/

local function VEC3toVEC2(point)
    return {
        x = point.x,
        y = point.z,
    };
end

-- calculates distance between 2 vec2 points
-- units used in game is METERS
local function getDistance(point1, point2)
    local xd = point1.x - point2.x;
    local yd = point1.y - point2.y;

    return math.sqrt(xd * xd + yd * yd);
end

-- main function
function main()

    -- gets vec3 positions of units
    local blueLocation = Unit.getByName('blue'):getPoint();
    local redLocation = Unit.getByName('red'):getPoint();

    -- calculations
    local distance = 0;

    blueLocation = VEC3toVEC2(blueLocation);
    redLocation = VEC3toVEC2(redLocation);

    distance = getDistance(blueLocation, redLocation);
    distance = distance / 1000; -- converts to km

    -- shows result
    trigger.action.outText(math.floor(distance + 0.5) .. ' km', 10); -- shows rounded distance

end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main(); -- execution (may be called in another trigger)
