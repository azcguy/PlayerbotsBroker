PlayerbotsBroker.events = {}
local _self = PlayerbotsBroker.events
local _util = PlayerbotsBroker.util
local _ev = _util.event.Create

-- ============================================================================================
-- ============== PUBLIC API
-- ============================================================================================

_self.STATUS_CHANGED                = _ev() -- (bot, status) bot online/offline/in party
_self.STATS_CHANGED                 = _ev() -- (bot) Any stats changed 
_self.STATS_CHANGED_BASE            = _ev() -- (bot) Base stats changed 
_self.STATS_CHANGED_RESISTS         = _ev() -- (bot) Resists changed 
_self.STATS_CHANGED_MELEE           = _ev() -- (bot) Melee stats changed 
_self.STATS_CHANGED_RANGED          = _ev() -- (bot) Ranged stats changed 
_self.STATS_CHANGED_SPELL           = _ev() -- (bot) Spell stats changed 
_self.STATS_CHANGED_DEFENSES        = _ev() -- (bot) Defense stats changed 
_self.REPUTATION_CHANGED            = _ev() -- (bot) 
_self.MONEY_CHANGED                 = _ev() -- (bot) 
_self.CURRENCY_CHANGED              = _ev() -- (bot, currencyItemID, count)
_self.LEVEL_CHANGED                 = _ev() -- (bot) 
_self.EXPERIENCE_CHANGED            = _ev() -- (bot) 
_self.SPEC_DATA_CHANGED             = _ev() -- (bot) Stuff related to specs, available talent points, active spec, learned dual spec, spec changed
_self.ZONE_CHANGED                  = _ev() -- (bot) 
_self.EQUIP_SLOT_CHANGED            = _ev() -- (bot, slotNum) bot equips/unequips a single item
_self.EQUIPMENT_CHANGED             = _ev() -- (bot) full equipment update completed
_self.INVENTORY_CHANGED             = _ev() -- (bot) full bags update completed