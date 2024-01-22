-- This code is the junction of calculateDistance and calculateBearing codes

-- output in meters for altitude/km for distance

-- differences from AWACS
-- awacs rounds altitude by multiples of 500 until 5000 meters, then it rounds by multiples of 1000 (done on exibition line)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getBearing(a, b)
    local aLatRad = math.rad(a.lat)
    local bLatRad = math.rad(b.lat)

    local dLRad = math.rad(b.lon - a.lon)

    local x = math.cos(bLatRad) * math.sin(dLRad)
    local y = math.cos(aLatRad) * math.sin(bLatRad) - math.sin(aLatRad) * math.cos(bLatRad) * math.cos(dLRad)

    local bearing = math.atan2(x, y)

    local degrees = math.deg(bearing)

    return (degrees + 360) % 360
end

function getCoordObject(point)
    local lat, lon, alt = coord.LOtoLL(point)
    return { lat = lat, lon = lon, alt = alt }
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getDistance(point1, point2)
    local xd = point1.x - point2.x
    local zd = point1.z - point2.z

    return math.sqrt(xd * xd + zd * zd)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function round(number, multipleOf)
    local rounded = math.floor(number + 0.5) -- rounds decimals
    rounded = math.floor(rounded / multipleOf + 0.5) * multipleOf -- rounds to multiples of given number
    return rounded
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- main function
function main()
    local bluePoint = Unit.getByName('blue'):getPoint()
    local redPoint = Unit.getByName('red'):getPoint()

    local bearing = 0
    local distance = 0

    -- calculating bearing
    local blueCoord = getCoordObject(bluePoint)
    local redCoord = getCoordObject(redPoint)
    bearing = getBearing(blueCoord, redCoord)

    -- calculating distance
    distance = getDistance(bluePoint, redPoint)
    distance = distance / 1000 -- converts to km

    -- shows BRA
    trigger.action.outText('BRA, ' ..
        (math.floor(bearing + 0.5) - 6) .. -- -6 is the magnetic declination???
        ' for ' .. round(distance, 10) .. ', at '
        .. ((redCoord.alt < 5000) and round(redCoord.alt, 500) or round(redCoord.alt, 1000)), 10)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main() -- execution (may be called in another trigger)
