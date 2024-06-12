-- Public interfaces for use by other addons all in one place
local _self = PlayerbotsBroker
local _store = PlayerbotsBroker.store
local _broker = PlayerbotsBroker.broker

function _self.RegisterByName(name)
    if _store:RegisterBot(name) then
        _broker:DoHandshakeAfterRegistration(name)
    end
end

function _self.UnregisterByName(name)
    _store:UnregisterBot(name)
end

function _self.GetBot(name)
    return _store:GetBot(name)
end

function _self.GetBotStatus(name)
    return _store:GetBotStatus(name)
end

--- Provide the actual bot table.
--- local bot = GetBot(name)
--- StartQuery(qtype, bot)
function _self.StartQuery(queryType, bot)
    _broker:StartQuery(queryType, bot)
end

function _self.GenerateCommand(bot, cmdType, cmdSubtype, arg1, arg2, arg3)
    _broker:GenerateCommand(bot, cmdType, cmdSubtype, arg1, arg2, arg3)
end

