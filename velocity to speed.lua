-- SPEED and VELOCITY
-- Speed is the time rate at which an object is moving along a path, while velocity is the rate and direction of an object’s
-- movement. Put another way, speed is a scalar value, while velocity is a vector. For example, 50 km/hr (31 mph) describes
-- the speed at which a car is traveling along a road, while 50 km/hr west describes the velocity at which it is traveling.

-- it looks like TS(true speed) and GS(ground speed) are the same thing
-- TS is the unit used to set the speed of all groups in mission editor. keep in mind that the speed unit typically used in
-- aviation is IAS(indicated airspeed), so inside the mission this will be the one shown to aircrafts. but even though the
-- units are different, AI aircrafts will be flying at TS (IAS typically lower number)

-- converts velocity to speed
local function velocityToSpeed(velocity)
    return math.sqrt(velocity.z * velocity.z + velocity.x * velocity.x)     -- game unit is meters per second
end

-- converts meters per second to kilometers an hour
local function MStoKMH(speed)
    return speed * 3.6
end


-- test the script
function run()
    local velocity = Unit.getByName('test'):getVelocity()
    local speed = velocityToSpeed(velocity)
    speed = MStoKMH(speed)

    trigger.action.outText(math.floor(speed + 0.5) .. ' km/h', 1)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

run()   -- execution (may be called in another trigger)

-- use math.sqrt(velocity.z * velocity.z + velocity.x * velocity.x) to find GS(ground speed) and velocity.y for vertical speed