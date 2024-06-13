-- Public interfaces for use by other addons all in one place
local _self = PlayerbotsBroker
local _store = PlayerbotsBroker.store
local _broker = PlayerbotsBroker.broker

local function validateName(name)
    if name == nil or type(name) ~= "string" or name == "" then
        return nil
    end
    return true
end

function _self.RegisterByName(name)
    if not validateName(name) then return end
    if _store:RegisterBot(name) then
        _broker:DoHandshakeAfterRegistration(name)
    end
end

function _self.UnregisterByName(name)
    if not validateName(name) then return end
    _store:UnregisterBot(name)
end

function _self.GetBot(name)
    if not validateName(name) then return end
    return _store:GetBot(name)
end

function _self.GetBotStatus(name)
    if not validateName(name) then return end
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

