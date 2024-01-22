group1 = Group.getByName('red1')
group2 = Group.getByName('red2')


local eventHandler = {}
function eventHandler:onEvent(event)

    if world.event.S_EVENT_DEAD == event.id then

        local g1Dead = false
        local g2Dead = false


        -- if not group1 or not group1:isExist() then
        --     g1Dead = true
        -- end

        -- if not group2 or not group2:isExist() then
        --     g2Dead = true
        -- -- end

        -- if not group1 then
        --     g1Dead = true
        -- elseif not group1:isExist() then
        --     g1Dead = true
        -- end

        -- if not group2 then
        --     g2Dead = true
        -- elseif not group2:isExist() then
        --     g2Dead = true
        -- end

        local isAlive = false

        if group1 then
            local units = group1:getUnits()

            for _, unit in ipairs(units) do
                if unit:getLife() > 0 then
                    isAlive = true
                    break
                end
            end
        end

        trigger.action.outText(isAlive and 'alive' or 'dead', 10)

        -- trigger.action.outText('g1 ' ..
        --     (g1Dead and 'dead' or 'not dead') .. ' | g2 ' .. (g2Dead and 'dead' or 'not dead'), 5)

        -- if group1 and group2 then
        --     trigger.action.outText('all dead', 5)
        -- end

    end

end

world.addEventHandler(eventHandler)
