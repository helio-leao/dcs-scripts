
-- SCRIPT THAT RESPAWNS GROUND GROUP IN A SQUARE AROUND CENTER OF A TRIGGER ZONE
-- the size of the square is the (radius * 2) of the trigger zone (needs reworking to use radius instead)
-- this particular script only respawns groups while they're still alive, not hard to adjust this if wanted though

-- function calls examples. could be called from another trigger (Caucasus example coordinates)
-- respawnGroupAtPoint('Ground-1', {y: 00630100, x: -00321444})
-- respawnGroupAtRandomPointInZone('Ground-1', 'Spawn Zone-1')

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- receives trigger zone and returns random vec2 point inside circular zone
-- todo: return point inside of circle instead of square
function createRandomPointInZone(zone)
    local zoneVec2 = {x = zone.point.x, y = zone.point.z}
    local zoneRadius = zone.radius

    local randomVec2 = {}
    randomVec2.x = math.random(zoneVec2.x - zoneRadius, zoneVec2.x + zoneRadius)
    randomVec2.y = math.random(zoneVec2.y - zoneRadius, zoneVec2.y + zoneRadius)
    
    return randomVec2
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function createUnitsData(units, pointVec2)
    local unitsData = {}

    local mainUnitPoint = {y = units[1]:getPoint().z, x = units[1]:getPoint().x}

    for key, unit in pairs(units) do
        local unitPoint = {y = unit:getPoint().z, x = unit:getPoint().x}

        local distanceY = (-1) * (mainUnitPoint.y - unitPoint.y)
        local distanceX = (-1) * (mainUnitPoint.x - unitPoint.x)

        unitsData[key] = {
            ["name"] = unit:getName(),
            ["type"] = unit:getTypeName(),
            ["y"] = pointVec2.y + distanceY,
            ["x"] = pointVec2.x + distanceX,
        }
    end

    return unitsData
end

function createGroupData(group, pointVec2)
    local units = group:getUnits()

    local groupData = {
        ["name"] = group:getName(),
        ["task"] = "Ground Nothing",
        ["units"] = createUnitsData(units, pointVec2),
    }

    return groupData
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- receives a point(vec2) and group name. respawns group at given point
function respawnGroupAtPoint(groupName, pointVec2)
    local group = Group.getByName(groupName)
    if not group then return end
    
    local groupData = createGroupData(group, pointVec2)
    local country = group:getUnits()[1]:getCountry()
    local category = group:getCategory()

    coalition.addGroup(country, category, groupData)
end

-- receives a trigger zone name and group name. respawns group at random point close to the center of zone
function respawnGroupAtRandomPointInZone(groupName, zoneName)
    local spawnZone = trigger.misc.getZone(zoneName)
    if not spawnZone then return end
    
    local randomVec2 = createRandomPointInZone(spawnZone)

    respawnGroupAtPoint(groupName, randomVec2)
end
