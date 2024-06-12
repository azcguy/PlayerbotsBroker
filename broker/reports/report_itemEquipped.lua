local _array = PlayerbotsBroker.reports
local RTYPE = PlayerbotsBroker.consts.REPORT
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events
local _debug = PlayerbotsBroker.debug
local _eval = PlayerbotsBroker.util.CompareAndReturn
local _const = PlayerbotsBroker.consts

_array[RTYPE.ITEM_EQUIPPED] = function(id,payload,bot,status)
    _parser:start(payload)
    local slotNum = _parser:nextInt()
    local countNum = _parser:nextInt()
    local link = _parser:nextLink()
    local item = bot.items[slotNum]
    local changed = false;

    if not item then
        _debug:LevelDebug(1, "Tried to update non existing slot number?")
        return
    end

    local resultLink = _eval(link == _const.NULL_LINK, nil, link)
    if resultLink ~= item.link then
        item.link = resultLink
        changed = true
    end

    if countNum ~= item.count then
        item.count = countNum
        changed = true
    end

    if changed then
        _events.EQUIP_SLOT_CHANGED:Invoke(  bot, slotNum)
    end
end