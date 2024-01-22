local checkid = 74023650;
local function handler (self, event)
   if event.id ~= 8 or event.initiator.id_ ~= checkid then return false end
   trigger.action.setUserFlag(1,true);
   world.removeEventHandler(self);
end
world.addEventHandler {onEvent = handler}


-- deveria checar se uma construção do mapa configurada com botao direito foi destruída