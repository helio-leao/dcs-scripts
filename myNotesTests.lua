-- JTAC SCRIPT

-- muitas vezes coloco no script a chamada de uma função principal como sendo algo a executar em outro trigger in game mais adiante, isso tem como finalidade não repetir declaração
-- de funções por exemplo, o que ficaria sobrescrevendo a função. a ideia é evitar de botar num trigger repetitivo o script todo, até pq idealmente não é legal
-- colocar nem a chamada de alguma função do script num trigger repetitivo.
-- já que tá fazendo script, melhor usar o schedule function que dá o controle de quando parar a função assim como intervalo de tempo, algo q o trigger repetitivo
-- do ME não
-- dá. (vai executar até o fim da missão num intervalo sempre de 1 segundo). se o script tiver a repeticao programada nele mesmo pode ser tudo num arquivo só.

-- é bom lembrar que existe o initialization script na tela de triggers que efetivamente pode receber essa parte de declarações e tal e até a execução se for por menus ou schedule
-- pode ter algum problema, em um post antigo grimes disse q nao carrega de arquivo, só de texto, mas é muito provavel q tenha sido corrigido. de todo modo observar. acho q seria
-- melhor utilizar as declarações ali do que 1 segundo depois em um trigger
-- https://forums.eagle.ru/topic/172089-initialization-script/

-- menu, schedule e event handlers
-- menu e schedule não são as únicas maneiras de pensar em como disparar funções, os eventos também são interessantes e provavelmente tornam o script mais leve que o schedule.
-- dependendo do que está rodando nos menus esse é imbatível pq pode fazer chamadas apenas quando solicitado. a escolha de qual tipo vai depender da necessidade.

-- -melhor lugar para usar como referência é o hoggit, tem até o conteúdo do próprio site da ED melhor organizado e alguns exemplos de código em algumas
--  das páginas das funções
-- -no canal FlightControl, do criador do framework Moose para DCS, há uma playlist que contém vídeos com o básico de Lua. a partir do terceiro vídeo dá
--  para aprender o básico. na mesma lista mais adiante há vídeos sobre o Moose.

-- it isn't possible to run an infinite loop. a dev explained that the simulation stops while running the script and resumes after completed

-- the position of the functions matters in lua, if you create a function above calling one below it won't work, but it won't give an error most times
-- so organize your functions better. the option is to have a lot of global functions that I suppose is not a good practice

-- the simulation stops while running script. so it will be the same time throughout the execution of script


MARKED_GROUPS = {}


MESSAGE_DURATION = 40

-- variáveis globais. para ser local deve ter o modificador 'local' antes do nome da variável
unit = Unit.getByName('jtac')

-- outra maneira de obter o controller é unit:getController(). as funções em lua podem receber o objeto que fez a chamada por argumento. a exemplo:
-- Controller Group.getController(Class Self ) . Em alguns casos em lua é possível, ao invés de passar o objeto pelo argumento, chamar o método com ':', ele
-- estará sendo passado como self
-- Mais detalhes em funções vídeo do canal FlightControl e outros tutoriais
detectedTargets = Controller.getDetectedTargets(unit)


trigger.action.outText('Total de alvos: ' .. #detectedTargets, MESSAGE_DURATION) -- é com # que se consegue a quantidade de elementos de uma tabela em lua

-- for index = 1, #detectedTargets, 1 do    -- primeiro índice é o '1' em lua
--     // DO SOMETHING
-- end

-- exibe algumas informações e interage com alvos detectados
for index, target in ipairs(detectedTargets) do

    local targetObject = target.object

    local targetInfo = 'Index: ' .. index .. ' | '
        .. targetObject:getTypeName() .. ' | '
        .. targetObject:getName() .. ' | '
        .. country.name[targetObject:getCountry()] .. '\n' -- exemplo para uso de enum


    -- latitude e longitude
    -- segundo a documentação, deveria receber vec3, mas dá pra passar o target table
    local lat, lon, alt = coord.LOtoLL(targetObject) -- para converter para vec3: coord.LLtoLO(GeoCoord latitude , GeoCoord longitude , number altitude)
    targetInfo = targetInfo ..
        'Coordenadas:\nLatitude: ' .. lat .. ' \nLongitude: ' .. lon .. '\nAltitude: ' .. alt .. '\n'

    -- mgrs
    -- segundo a documentação, deve receber lat e long, mas dá pra passar a tabela LL diretamente: coord.LOtoLL(targetObject)
    local grid = coord.LLtoMGRS(lat, lon)
    targetInfo = targetInfo ..
        grid.UTMZone .. ' ' .. grid.MGRSDigraph .. ' ' .. grid.Easting .. ' ' .. grid.Northing .. '\n'


    trigger.action.outText(targetInfo, MESSAGE_DURATION)

    trigger.action.smoke(targetObject:getPoint(), trigger.smokeColor.White)

    -- funciona bem com unidade, em grupo o raio fica todo ferrado. fica atualizando a posição de origem, mesmo em movimento. não atualiza a posicão para onde apontou
    -- em funcoes que nao precisa de uma unidade apontando, como luz ou fumaça, pode ser grupo, pq na real vc só tá usando o grupo para pegar as unidades detectadas,
    -- mas se tiver apontamento como infra vermelho ou laser, tem q ser com uma unidade
    -- não mantém alvos em movimento apontados, mantém o laser na mesma posição de quando começou o apontamento, se o alvo já saiu o laser continua no mesmo lugar.
    -- curiosamente é possível criar vários lasers do mesmo ponto de origem para vários pontos de destino.
    local ray = Spot.createInfraRed(jtac, { x = 0, y = 1, z = 0 }, targetObject:getPoint())
    local ray = Spot.createLaser(jtac, { x = 0, y = 1, z = 0 }, targetObject:getPoint(), 1337) -- não precisa de ponto de origem

    ray:destroy() -- if you don't want the ray anymore like when target is destroyed, destroy the ray too. maybe it's a good idea to have rays on global table
    -- também pode ser atualizada a posição do raio, caso seja transferido para outro alvo, sem necessidade de destruir o raio com:
    --function Spot.setPoint(Class Self , table vec3 )      source: hoggit

    break -- para executar apenas para o primeiro alvo detectado, se quiser fazer para todos é só tirar essa linha
end
