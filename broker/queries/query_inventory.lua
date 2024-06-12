local _array = PlayerbotsBroker.queries
local QTYPE = PlayerbotsBroker.consts.QUERY
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events
local _store = PlayerbotsBroker.store
local _eval = PlayerbotsBroker.util.CompareAndReturn

_array[QTYPE.INVENTORY] = 
{
    qtype = QTYPE.INVENTORY,
    onStart          = function(query)
        _store.InitBag(query.bot.bags[-2], 32, nil) -- keyring
        for i=0, 4 do
            local size = _eval(i == 0, 16, 0)
            _store.InitBag(query.bot.bags[i], size, nil)
        end
    end,
    onProgress       = function(query, payload)
        _parser:start(payload)
        local bot = query.bot
        local subtype = _parser:nextChar()
        if subtype == 'b' then
            local bagNum = _parser:nextInt()
            local bagSize = _parser:nextInt()
            local bagLink = _parser:nextLink()

            local bag = bot.bags[bagNum]
            _store.InitBag(bag, bagSize, bagLink)
            query.ctx1[bagNum] = true -- track which bags are added by the query
        elseif subtype == 'i' then
            local bagNum = _parser:nextInt()
            local bagSlot = _parser:nextInt()
            local itemCount = _parser:nextInt()
            local itemLink = _parser:nextLink()

            local bag = bot.bags[bagNum]
            _store.SetBagItemData(bag, bagSlot, itemCount, itemLink)
        end
    end,
    onFinalize       = function(query)
        _events.INVENTORY_CHANGED:Invoke(query.bot)
    end,
}