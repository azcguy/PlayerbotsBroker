PlayerbotsBroker.broker = {}
PlayerbotsBroker.queries = {}
local _self = PlayerbotsBroker.broker
local _util = PlayerbotsBroker.util
local _const = PlayerbotsBroker.consts
local _cfg = PlayerbotsBroker.config
local _debug = PlayerbotsBroker.debug
local _store = PlayerbotsBroker.store
local _events = PlayerbotsBroker.events
local queryTemplates = PlayerbotsBroker.queries

local QUERY_OPCODE = _const.QUERY_OPCODE
local QUERY_TYPE = _const.QUERY
local MSG_HEADER = _const.MSG_HEADER
local SYS_MSG_TYPE = _const.SYS_MSG_TYPE
_self.parser = _util.parser.Create()
local _bots = {}
local _updateHandler = {}

local _activeQueries = {} -- [botName][QUERY_TYPE] Stores queues per query type, per bot
local _activeQueriesById = {} -- optimization, duplicates references to queries in _queries but accelerates lookup by int
local _freeIdsStack = {}
local _freeIdsCount = 0
local _activeIdsCount = 0
local _queryPool = {}
local _queryPoolCount = 0

local _prefixCode = _const.prefixCode
local MSG_SEPARATOR_BYTE = _const.MSG_SEPARATOR_BYTE
local UTF8_NUM_FIRST = _const.UTF8_NUM_FIRST
local UTF8_NUM_LAST = _const.UTF8_NUM_LAST
local MSG_SEPARATOR = _const.MSG_SEPARATOR

-- ============================================================================================
-- ============== Locals optimization, use in hotpaths
-- ============================================================================================

local _strbyte = string.byte
local _strchar = string.char
local _strsplit = strsplit
local _strsub = string.sub
local _strlen = string.len
local _tonumber = tonumber
local _strformat = string.format
local _pairs = pairs
local _tinsert = table.insert
local _tremove = table.remove
local _tconcat = table.concat
local _getn = getn
local _sendAddonMsg = SendAddonMessage
local _pow = math.pow
local _floor = math.floor
local _eval = _util.CompareAndReturn
local _wipe = wipe

local _evalEmptyString = function (val)
    if val == nil then
        return ""
    else
        return val
    end
end

local _msgBuffer = {}

-- reuses a single table to construct strings
local function BufferConcat(separator, count, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    local buffer = _msgBuffer
    buffer[1] = a1
    buffer[2] = separator
    buffer[3] = a2
    buffer[4] = separator
    buffer[5] = a3
    buffer[6] = separator
    buffer[7] = a4
    buffer[8] = separator
    buffer[9] = a5
    if count > 5 then
        buffer[10] = separator
        buffer[11] = a6
        buffer[12] = separator
        buffer[13] = a7
        buffer[14] = separator
        buffer[15] = a8
        buffer[16] = separator
        buffer[17] = a9
        buffer[18] = separator
        buffer[19] = a10
    end
    return _tconcat(buffer, nil, 1, count * 2 - 1)
end

-- ID must be uint16
---comment
---@param target string name of the bot
---@param header number byte header id
---@param subtype number byte subtype
---@param id number id, currently only used by queries
---@param payload string 
function _self:GenerateMessage(target, header, subtype, id, payload)
    if not id then id = 0 end
    local msg = BufferConcat(_const.MSG_SEPARATOR, 4, _strchar(header), _strchar(subtype), _strformat("%03d", id), _eval(payload, payload, ""))
    _sendAddonMsg(_const.prefixCode, msg, "WHISPER", target)
    _debug:LevelDebug(2, "|cff7afffb >> " .. target .. " |r "..  msg)
end

-- bots - reference to _dbchar.bots
function _self:Init()
    _updateHandler = PlayerbotsBroker.updateHandler
    _updateHandler.onUpdate:Add(_self.OnUpdate)
    _bots = PlayerbotsBroker.store.bots

    for name, bot in _pairs(_bots) do
        local status = _store:GetBotStatus(bot.name)
        status.party = UnitInParty(bot.name) ~= nil
        _self:GenerateMessage(bot.name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.PING)
    end
end

function _self:OnEnable()
    for name, bot in _pairs(_bots) do
        _self:GenerateMessage(bot.name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.PING)
    end
end

function _self:OnDisable()
    for name, bot in _pairs(_bots) do
        _self:GenerateMessage(bot.name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.LOGOUT)
    end
end

function _self:OnUpdate(elapsed)
    local time = _updateHandler.totalTime

    local closeWindow = _cfg.queryCloseWindow
    for id, query in _pairs(_activeQueriesById) do
        if query ~= nil and query.lastMessageTime ~= nil then
            if query.lastMessageTime  + closeWindow < time then
                _self:FinalizeQuery(query)
            end
        end
    end
end

function _self:StartQuery(qtype, bot)
    if bot == nil or ( type(bot) ~= "table" ) then 
        print("Attempted to start a query on a nil bot")
        return
    end
    local status = _store:GetBotStatus(bot.name)
    if not status.online then return end -- abort query because the bot is either not available or offline
    local array = _self:GetQueriesArray(bot.name)
    local query = array[qtype]
    if query then
        return
    end
    query = _self:ConstructQuery(qtype, bot.name)
    if query then
        array[qtype] = query
        _activeQueriesById[query.id] = query
        query:onStart(query)
        _self:GenerateQueryMsg(query, nil)
    end
end

local function RentQueryID()
    local id = 0
    if _freeIdsCount == 0 then
        id = _activeIdsCount + 1
    else
        id = tremove(_freeIdsStack)
        _freeIdsCount = _freeIdsCount - 1
    end
    _activeIdsCount = _activeIdsCount + 1
    return id
end

local function ReleaseQueryID(id)
    _tinsert(_freeIdsStack, id)
    _freeIdsCount = _freeIdsCount + 1
    _activeIdsCount = _activeIdsCount - 1
end


function _self:ConstructQuery(qtype, name)
    local template = queryTemplates[qtype]
    if template then
        local bot = _store:GetBot(name)
        if not bot then return end
        local query = nil
        if _queryPoolCount > 0 then
            query = _queryPool[_queryPoolCount]
            _queryPool[_queryPoolCount] = nil
            _queryPoolCount = _queryPoolCount - 1
        else
            query = {}
        end

        query.qtype = template.qtype
        query.hasError = false
        query.opcode = QUERY_OPCODE.PROGRESS
        query.bot = bot
        query.botStatus = _store:GetBotStatus(name)
        query.id = RentQueryID()
        query.lastMessageTime = _updateHandler.totalTime
        query.onStart = template.onStart
        query.onProgress = template.onProgress
        query.onFinalize = template.onFinalize
        
        if query.ctx1 == nil then
            query.ctx1 = {} -- context is a table any code can use for any reason that gets wiped when the query returns to the pool
        end

        if query.ctx2 == nil then
            query.ctx2 = {} -- context is a table any code can use for any reason that gets wiped when the query returns to the pool
        end

        if query.ctx3 == nil then
            query.ctx3 = {} -- context is a table any code can use for any reason that gets wiped when the query returns to the pool
        end
        return query
    end
    return nil
end

function _self:FinalizeQuery(query)
    if not query.hasError then
        query:onFinalize(query)
    end

    local queries = _self:GetQueriesArray(query.bot.name)
    queries[query.qtype] = nil
    _activeQueriesById[query.id] = nil
    ReleaseQueryID(query.id)

    wipe(query.ctx1)
    wipe(query.ctx2)
    wipe(query.ctx3)
    _queryPoolCount = _queryPoolCount + 1
    _queryPool[_queryPoolCount] = query
end

local SYS_MSG_HANDLERS = {}
SYS_MSG_HANDLERS[SYS_MSG_TYPE.HANDSHAKE] = function(id,payload, bot, status)
    if not status.online then
        status.online = true
        status.party = UnitInParty(bot.name) ~= nil
        _events.STATUS_CHANGED:Invoke( bot, status)
    end
    _self:GenerateMessage(bot.name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.HANDSHAKE)
    _self:StartQuery(QUERY_TYPE.WHO, bot)
    _self:StartQuery(QUERY_TYPE.CURRENCY, bot)
end

SYS_MSG_HANDLERS[SYS_MSG_TYPE.PING] = function(id,payload, bot, status)
    if not status.online then
        status.online = true
        status.party = UnitInParty(bot.name) ~= nil
        _events.STATUS_CHANGED:Invoke( bot, status)
    end
end

SYS_MSG_HANDLERS[SYS_MSG_TYPE.LOGOUT] = function(id,payload, bot, status)
    if status.online then
        status.online = false
        _events.STATUS_CHANGED:Invoke( bot, status)
    end
end

local MSG_HANDLERS = {}
MSG_HANDLERS[_const.MSG_HEADER.SYSTEM] = SYS_MSG_HANDLERS
MSG_HANDLERS[MSG_HEADER.REPORT] = PlayerbotsBroker.reports

function _self:CHAT_MSG_ADDON(prefix, message, channel, sender)
    if prefix == _prefixCode then 
        local bot = _bots[sender]
        if bot then
            _debug:LevelDebug(2,  "|cffb4ff29 << " .. bot.name .. " |r " .. message)
            local status = _store:GetBotStatus(bot.name)
            if not status then return end
            status.lastMessageTime = _updateHandler.totalTime
            -- confirm that the message has valid format
            local header, sep1, subtype, sep2, idb1, idb2, idb3, sep3 = _strbyte(message, 1, 8)
            local _separatorByte = MSG_SEPARATOR_BYTE
            -- BYTES
            -- 1 [HEADER] 2 [SEPARATOR] 3 [SUBTYPE/QUERY_OPCODE] 4 [SEPARATOR] 5-6-7 [ID] 8 [SEPARATOR] 9 [PAYLOAD]
            -- s:p:999:payload
            if sep1 == _separatorByte and sep2 == _separatorByte and sep3 == _separatorByte then
                -- first determine if its an ongoing query response
                -- if it is we treat it differently, because format is differnt
                -- instead of subtype the bit3 carries error code 0-9, 0 == no error
                if header == MSG_HEADER.QUERY then
                    -- idb contains UTF8 0-9, so bytes 49-57, we offset them by 48, and mult by mag
                    local id = ((idb1-48) * 100) + ((idb2-48) * 10) + (idb3-48) 
                    local query = _activeQueriesById[id]
                    if query then
                        query.opcode = subtype -- grab the opcode, it can be (p), (f), (1-9), more later possible
                        if subtype == QUERY_OPCODE.PROGRESS then
                            local payload = _strsub(message, 9)
                            query.onProgress(query, payload)
                        elseif subtype == QUERY_OPCODE.FINAL then
                            local payload = _strsub(message, 9)
                            if payload and _strlen(payload) > 0 then
                                query.onProgress(query, payload)
                            end
                            _self:FinalizeQuery(query)
                        elseif subtype >= UTF8_NUM_FIRST and subtype <= UTF8_NUM_LAST then
                            query.hasError = true
                            _debug:LevelDebug(1, "Query:", query.id, " returned an error: ", query.opcode)
                            _self:FinalizeQuery(query)
                        end
                    end
                else
                    local handlers = MSG_HANDLERS[header]
                    if handlers then
                        local handler = handlers[subtype]
                        if handler then
                            local id = ((idb1-48) * 100) + ((idb2-48) * 10) + (idb3-48)
                            local payload = _strsub(message, 9)
                            handler(id, payload, bot, status)
                        end
                    end
                end
            end
        end
    end
end

-- for now the queue only allows a single query of one type to be ran at a time
function _self:GetQueriesArray(name)
    if not name then
        _debug:LevelDebug(2, "PlayerbotsBroker:GetQueries", "name is nil")
    end
    local array = _activeQueries[name]
    if not array then
        array = {}
        _activeQueries[name] = array
    end
    return array
end

function _self:GenerateCommand(bot, cmd, subcmd, arg1, arg2, arg3)
    local count = 1
    if arg1 then count = count + 1 end
    if arg2 then count = count + 1 end
    if arg3 then count = count + 1 end
    local payload = BufferConcat(MSG_SEPARATOR, count, _strchar(subcmd), arg1, arg2, arg3)
    _self:GenerateMessage(bot.name, MSG_HEADER.COMMAND, cmd, 0, payload)
end

function _self:GenerateQueryMsg(query, payload)
    _self:GenerateMessage(query.bot.name, MSG_HEADER.QUERY, query.qtype, query.id, payload)
end

function _self:DoHandshakeAfterRegistration(name)
    local bot = _store:GetBot(name)
    if bot then
        _self:GenerateMessage(name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.HANDSHAKE)
        _self:GenerateMessage(name, MSG_HEADER.SYSTEM, SYS_MSG_TYPE.PING)
        _updateHandler:DelayCall(1, function ()
            _self:StartQuery(QUERY_TYPE.WHO, bot)
        end)
    end
end

function _self:PARTY_MEMBERS_CHANGED()
    for name, bot in pairs(_bots) do
        local status = _store:GetBotStatus(name)
        local inparty =  UnitInParty(name) ~= nil
        if inparty ~= status.party then
            status.party = inparty
            _events.STATUS_CHANGED:Invoke( bot, status)
        end
    end
end

function _self:PARTY_MEMBER_ENABLE()

end

function _self:PARTY_MEMBER_DISABLE(id)
    print(id)
end
