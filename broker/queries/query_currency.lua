local _array = PlayerbotsBroker.queries
local QTYPE = PlayerbotsBroker.consts.QUERY
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events

_array[QTYPE.CURRENCY] = 
{
    qtype = QTYPE.CURRENCY,
    onStart          = function(query)

    end,
    onProgress       = function(query, payload)
        _parser:start(payload)
        local subtype = _parser:nextCharAsByte()
        local botCurrencies = query.bot.currency
        if subtype == QTYPE.CURRENCY_MONEY then
            local gold = _parser:nextInt()
            botCurrencies.gold = gold
            local silver = _parser:nextInt()
            botCurrencies.silver = silver
            local copper = _parser:nextInt()
            botCurrencies.copper = copper
            _events.MONEY_CHANGED:Invoke(query.bot, gold, silver, copper)
        elseif subtype == QTYPE.CURRENCY_OTHER then
            local currencyId = _parser:nextInt()
            local count = _parser:nextInt()
            local currency = botCurrencies[currencyId]
            if not currency then
                currency = {
                    itemId = currencyId,
                    count = count
                }
                botCurrencies[currencyId] = currency
            end
            _events.CURRENCY_CHANGED:Invoke(query.bot, currencyId, count)
        end
    end,
    onFinalize       = function(query)
    end,
}