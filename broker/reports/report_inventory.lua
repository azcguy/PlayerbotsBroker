local _array = PlayerbotsBroker.reports
local RTYPE = PlayerbotsBroker.consts.REPORT
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events
_array[RTYPE.INVENTORY] = function(id,payload,bot,status) 
    _parser:start(payload)
    local subtype = _parser:nextChar()

    if subtype == 'b' then
        local bagSlot = _parser:nextInt()
        local bagSize = _parser:nextInt()
        local bagLink = _parser:nextLink()
        local bag = bot.bags[bagSlot]
        PlayerbotsPanel.InitBag(bag, bagSize, bagLink)
    elseif subtype == 'i' then
        local bagSlot = _parser:nextInt()
        local itemSlot = _parser:nextInt()
        local itemCount = _parser:nextInt()
        local itemLink = _parser:nextLink()
        local bag = bot.bags[bagSlot]
        PlayerbotsPanel.SetBagItemData(bag, itemSlot, itemCount, itemLink)
    end

    _events.INVENTORY_CHANGED:Invoke(  bot)
end