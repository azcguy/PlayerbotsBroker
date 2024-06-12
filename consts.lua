PlayerbotsBroker.consts = {}
local _self = PlayerbotsBroker.consts

local _strbyte = string.byte

--=================================================================================
-- Various simple constants

_self.prefixCode              = "pb8aj2" --[[
    prefix used to identify broker messages, should match the one baked into server code, 
    can act as a password? sort of, if server changes this, and addon/player doesnt know the prefix, they wont be able to communicate
    ]]
_self.HEADER_LENGHT           = 8
_self.MSG_SEPARATOR           = ":"
_self.NULL_LINK               = "~"
_self.BYTE_NULL_LINK          = _strbyte("~")
_self.MSG_SEPARATOR_BYTE      = _strbyte(":")
_self.FLOAT_DOT_BYTE          = _strbyte(".")
_self.BYTE_ZERO               = _strbyte("0")
_self.BYTE_MINUS              = _strbyte("-")
_self.UTF8_NUM_FIRST          = _strbyte("1") -- 49
_self.UTF8_NUM_LAST           = _strbyte("9") -- 57
_self.BYTE_LINK_SEP           = _strbyte("|")
_self.BYTE_LINK_TERMINATOR    = _strbyte("r")


--=================================================================================
-- H E A D E R

_self.MSG_HEADER = {}
_self.MSG_HEADER.SYSTEM       = _strbyte("s")
_self.MSG_HEADER.REPORT       = _strbyte("r")
_self.MSG_HEADER.QUERY        = _strbyte("q")
_self.MSG_HEADER.COMMAND      = _strbyte("c")

--=================================================================================
-- S Y S T E M

_self.SYS_MSG_TYPE = {}
_self.SYS_MSG_TYPE.HANDSHAKE  = _strbyte("h")
_self.SYS_MSG_TYPE.PING       = _strbyte("p")
_self.SYS_MSG_TYPE.LOGOUT     = _strbyte("l")

--=================================================================================
-- R E P O R T

_self.REPORT = {}
_self.REPORT.ITEM_EQUIPPED     = _strbyte("g") -- gear item equipped or unequipped
_self.REPORT.CURRENCY          = _strbyte("c") -- currency changed
_self.REPORT.INVENTORY         = _strbyte("i") -- inventory changed (bag changed, item added / removed / destroyed)
_self.REPORT.TALENTS           = _strbyte("t") -- talent learned / spec changed / talents reset
_self.REPORT.SPELLS            = _strbyte("s") -- spell learned
_self.REPORT.QUEST             = _strbyte("q") -- single quest accepted, abandoned, changed, completed
_self.REPORT.EXPERIENCE        = _strbyte("e") -- level, experience
_self.REPORT.STATS             = _strbyte("S") -- all stats and combat ratings

--=================================================================================
-- Q U E R Y

_self.QUERY = {}
_self.QUERY.WHO        =         _strbyte("w") -- level, class, spec, location, experience and more
_self.QUERY.CURRENCY   =         _strbyte("c") -- money, honor, tokens
_self.QUERY.CURRENCY_MONEY=      _strbyte("g") -- subtype: money
_self.QUERY.CURRENCY_OTHER=      _strbyte("c") -- subtype: other currency (with id)
_self.QUERY.GEAR       =         _strbyte("g") -- only what is equipped
_self.QUERY.INVENTORY  =         _strbyte("i") -- whats in the bags and bags themselves
_self.QUERY.TALENTS    =         _strbyte("t") -- talents and talent points 
_self.QUERY.SPELLS     =         _strbyte("s") -- spellbook
_self.QUERY.QUESTS     =         _strbyte("q") -- all quests
_self.QUERY.STRATEGIES =         _strbyte("S")
_self.QUERY.STATS      =         _strbyte("T") -- all stats
--[[ Stats are grouped and sent together 
    subtypes:
        b - base + resists
        m - melee
        r - ranged
        s - spell
        d - defenses
]] 
_self.QUERY.STATS_BASE     =         _strbyte("b") -- base stats + resists
_self.QUERY.STATS_MELEE    =         _strbyte("m") -- melee stats
_self.QUERY.STATS_RANGED   =         _strbyte("r") -- ranged stats
_self.QUERY.STATS_SPELL    =         _strbyte("s") -- spell stats
_self.QUERY.STATS_DEFENSES =         _strbyte("d") -- defense stats
_self.QUERY.REPUTATION     =         _strbyte("r") -- all reputations

--=================================================================================
-- Q U E R Y OPCODE

_self.QUERY_OPCODE = {}
_self.QUERY_OPCODE.PROGRESS =         _strbyte("p") -- query is in progress
_self.QUERY_OPCODE.FINAL    =         _strbyte("f") -- final message of the query, contains the final payload, and closes query
-- bytes 49 - 57 are errors

--=================================================================================
-- C O M M A N D

_self.COMMAND = {}
_self.COMMAND.STATE        =          _strbyte("s")
--[[ 
    subtypes:
        s - stay
        f - follow
        g - grind
        F - flee
        r - runaway (kite mob)
        l - leave party
]] 
_self.COMMAND.ITEM          =         _strbyte("i")
_self.COMMAND.ITEM_EQUIP    =         _strbyte("e")
_self.COMMAND.ITEM_UNEQUIP  =         _strbyte("u")
_self.COMMAND.ITEM_USE      =         _strbyte("U")
_self.COMMAND.ITEM_USE_ON   =         _strbyte("t")
_self.COMMAND.ITEM_DESTROY  =         _strbyte("d")
_self.COMMAND.ITEM_SELL     =         _strbyte("s")
_self.COMMAND.ITEM_SELL_JUNK=         _strbyte("j")
_self.COMMAND.ITEM_BUY      =         _strbyte("b")
--[[ 
    subtypes:
        e - equip
        u - unequip
        U - use
        t - use on target
        d - destroy
        s - sell
        j - sell junk
        b - buy
]] 
_self.COMMAND.GIVE_GOLD     =         _strbyte("g")
_self.COMMAND.BANK          =         _strbyte("b")
--[[ 
    subtypes:
        d - bank deposit
        w - bank withdraw
        D - guild bank deposit 
        W - guild bank withdraw
]]
_self.COMMAND.QUEST          =         _strbyte("b")
--[[ 
    subtypes:
        a - accept quest
        A - accept all
        d - drop quest
        r - choose reward item
        t - talk to quest npc
        u - use game object (use los query to obtain the game object link)
]]
_self.COMMAND.MISC           =         _strbyte("m")
--[[ 
    subtypes:
        t - learn from trainer
        c - cast spell
        h - set home at innkeeper
        r - release spirit when dead
        R - revive when near spirit healer
        s - summon
]]
