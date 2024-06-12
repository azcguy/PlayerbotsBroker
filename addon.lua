local _self = PlayerbotsBroker
local _debug = PlayerbotsBroker.debug
local _cfg = PlayerbotsBroker.config
local _store = PlayerbotsBroker.store
local _broker = PlayerbotsBroker.broker


_self.commands = {
    type = 'group',
    args = {
        clearAll = {
            name = "clearall",
            desc = "Clears all bot data",
            type = 'execute',
            func = function() 
                _store:ClearAll()
            end
        },
        dumpStatus = {
            name = "dumpstatus",
            desc = "dumps status for all bots",
            type = 'execute',
            func = function() 
                _store:DumpStatus()
            end
        },
        queryWho = {
            name = "querywho",
            desc = "who query for all bots",
            type = 'execute',
            func = function() 
                for name, bot in pairs(_store.bots) do
                    PlayerbotsBroker:StartQuery(_self.consts.QUERY.WHO, bot)
                end
            end
        }
    }
}

function _self:OnInitialize()
    _debug:SetDebugging(true)
    _debug:SetDebugLevel(_cfg.debugLevel)
    _self.updateHandler = _self.util.updateHandler.Create()
    _self.store:Init(_self.db)
    _self.broker:Init()
    _self:RegisterChatCommand("/pp_broker", self.commands)
    _self:RegisterEvent("CHAT_MSG_ADDON")
    _self:RegisterEvent("PLAYER_LOGIN")
    _self:RegisterEvent("PLAYER_LOGOUT")
    _self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    _self:RegisterEvent("PARTY_MEMBER_ENABLE")
    _self:RegisterEvent("PARTY_MEMBER_DISABLE")
end

function _self:OnEnable()
    _self:SetDebugging(true)
    PlayerbotsBroker.rootFrame:Show()
    _broker:OnEnable()
end

function _self:OnDisable()
    _self:SetDebugging(false)
    _broker:OnDisable()
end

function _self:Update(elapsed)
    _self.updateHandler:Update(elapsed)
end

function _self:CHAT_MSG_ADDON(prefix, message, channel, sender)
    _broker:CHAT_MSG_ADDON(prefix, message, channel, sender)
end

function _self:PLAYER_LOGIN()
    --_broker:PLAYER_LOGIN()
end

function _self:PLAYER_LOGOUT()
    --_broker:PLAYER_LOGOUT()
end

function _self:PARTY_MEMBERS_CHANGED()
    _broker:PARTY_MEMBERS_CHANGED()
end

function _self:PARTY_MEMBER_ENABLE()
    _broker:PARTY_MEMBER_ENABLE()
end

function _self:PARTY_MEMBER_DISABLE()
    _broker:PARTY_MEMBER_DISABLE()
end
