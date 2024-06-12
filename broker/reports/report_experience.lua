local _array = PlayerbotsBroker.reports
local RTYPE = PlayerbotsBroker.consts.REPORT
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events

_array[RTYPE.EXPERIENCE] = function(id,payload,bot,status) 
    _parser:start(payload)
    bot.level = _parser:nextInt()
    bot.expLeft = _parser:nextFloat()
    _events.EXPERIENCE_CHANGED:Invoke(  bot)
end