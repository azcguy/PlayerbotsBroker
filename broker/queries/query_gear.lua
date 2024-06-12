local _array = PlayerbotsBroker.queries
local QTYPE = PlayerbotsBroker.consts.QUERY
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events

_array[QTYPE.GEAR] = 
{
    qtype = QTYPE.GEAR,
    onStart          = function(query)

    end,
    onProgress       = function(query, payload)
        _parser:start(payload)
        local slot = _parser:nextInt()
        local count = _parser:nextInt()
        local link = _parser:nextLink()
        query.ctx1[slot] = link
        query.ctx2[slot] = count
        query.ctx1.changed = true
    end,
    onFinalize       = function(query)
        if query.ctx1.changed then
            local items = query.bot.items
            for i=1, 19 do
                local link = query.ctx1[i]
                local item = items[i]
                if link then
                    item.link = link
                    item.count = query.ctx2[i]
                else
                    item.link = nil
                    item.count = 0
                end
            end
            _events.EQUIPMENT_CHANGED:Invoke( query.bot)
        end
    end,
}