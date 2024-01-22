-- The following will create a laser point and update the point of the ray every half a second. Once the target unit is destroyed it will remove the laser.
-- direto do hoggit, página da função setPoint, modificado para usar o scheduleFunction dentro da função ao invés de fora passando tempo da próxima
-- execução ou nil para terminar. nesse caso ele vai ficar setando o schedule quando entrar numa certa condição da própria função

local jtac = Unit.getByName('jtac')
local target = Unit.getByName('target')
local ray = Spot.createLaser(jtac, { x = 0, y = 1, z = 0 }, target:getPoint(), 1337)

local function updateRay()
    if target:getLife() > 0 then
        ray:setPoint(target:getPoint())
        timer.scheduleFunction(updateRay, {}, timer.getTime() + 0.5)
    else
        ray:destroy()
    end
end

updateRay()
