-- FORMULA
-- https://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
-- calculates true heading

function getBearing(a, b)
    local aLatRad = math.rad(a.lat)
    local bLatRad = math.rad(b.lat)

    local dLRad = math.rad(b.lon - a.lon)

    local x = math.cos(bLatRad) * math.sin(dLRad)
    local y = math.cos(aLatRad) * math.sin(bLatRad) - math.sin(aLatRad) * math.cos(bLatRad) * math.cos(dLRad)

    local bearing = math.atan2(x, y)

    local degrees = (math.deg(bearing) + 360) % 360

    return degrees
end

function getCoordObject(point)
    local lat, lon, alt = coord.LOtoLL(point)
    return { lat = lat, lon = lon, alt = alt }
end

function main()
    local aPoint = Unit.getByName('blue'):getPoint()
    local bPoint = Unit.getByName('red'):getPoint()

    local aCoord = getCoordObject(aPoint)
    local bCoord = getCoordObject(bPoint)

    trigger.action.outText('bearing: ' .. math.floor(getBearing(aCoord, bCoord)), 10)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main() -- execution (may be called in another trigger)
