PlayerbotsBroker.store = {}
local _self = PlayerbotsBroker.store
local _util = PlayerbotsBroker.util
local _debug = PlayerbotsBroker.debug
_self.bots = {}
local _bots = _self.bots
local _botStatus = {}

local _pool_bagslotdata = _util.pool.Create(
    function ()
        return { link = nil, count = 0 }
    end,
    function (elem)
        elem.link = nil
        elem.count = 0
    end )

function _self:Init(db)
    if db.char.bots == nil then
        db.char.bots = {}
        _bots = db.char.bots
    end
    for name, bot in pairs(_bots) do
        _self:ValidateBotData(bot)
    end
end

function _self:ClearAll()
    print("Clearing all bot data")
    wipe(_bots)
    ReloadUI()
end

function _self:DumpStatus()
    for k,bot in pairs(_bots) do
        local status = _self:GetBotStatus(bot.name)
        print("-----> " .. bot.name)
        print("online:" .. tostring(status.online))
        print("party:" .. tostring(status.party))
    end
end

function _self:CreateBotData(name)
    if not name then
        error("Invalid name")
        return
    end
        
    if _bots[name] then
        print("Bot ".. name .. " is already registered!")
        return
    end
    
    local bot = {}
    bot.name = name
    _self:ValidateBotData(bot)
    _bots[name] = bot
    return bot
end

function _self:GetBotStatus(name)
    local status = _botStatus[name]
    if not status then
        status = {}
        status.lastMessageTime = 0.0
        status.lastPing = 0.0
        status.online = false
        status.party = false
        _botStatus[name] = status
    end
    return status
end

function  _self.InitBag(bag, size, link)
    bag.link = link
    bag.size = size
    bag.freeSlots = size
    local contents = bag.contents
    for k,v in pairs(contents) do
        _pool_bagslotdata:Release(v)
    end
    wipe(bag.contents)
end

function _self.SetBagItemData(bag, slotNum, count, link)
    local size = bag.size
    local contents = bag.contents
    if slotNum > size then
        _debug.LevelDebug(1, "Slot num is larger than bag size!")
        return
    end

    local slot = contents[slotNum]

    if not link then
        if not slot then return end -- no incoming link and no existing slot, do nothing
        local existingLink = slot.link
        if existingLink then -- removed an item
            bag.freeSlots = bag.freeSlots + 1
        end
        contents[slotNum] = nil
        _pool_bagslotdata:Release(slot)
    else
        local added = false
        if not slot then 
            slot = _pool_bagslotdata:Get()
            contents[slotNum] = slot
            added = true
        else
            local existingLink = slot.link
            if not existingLink then -- added item
                added = true
            end
        end
        slot.link = link
        slot.count = count
        if added then
            bag.freeSlots = bag.freeSlots - 1
        end
    end
end

function _self:CreateBagData(name, size)
    local bag = {}
    bag.name = name
    bag.link = nil
    bag.freeSlots = size
    bag.size = size
    bag.contents = {}
    _self.InitBag(bag, bag.size, nil)
    return bag
end

--- May seem overboard but it allows to adjust the layout of the data after it was already serialized
function _self:ValidateBotData(bot)
    local function vf(owner, name, value)  -- validate field
        if not owner[name] then
            owner[name] = value
        end
    end

    vf(bot, "race", "HUMAN")
    vf(bot, "class", "PALADIN")
    vf(bot, "level", 1)
    vf(bot, "expLeft", 0.0)
    vf(bot, "zone", "Unknown")
    vf(bot, "talents", {})
    vf(bot.talents, "dualSpecUnlocked", false)
    vf(bot.talents, "activeSpec", 1)
    vf(bot.talents, "specs", {})

    vf(bot.talents.specs,1, {})
    local spec1 = bot.talents.specs[1]
    vf(spec1,"primary", 1)
    vf(spec1,"tabs", {})
    vf(spec1.tabs,1, {})
    vf(spec1.tabs[1], "points", 0)
    vf(spec1.tabs,2, {})
    vf(spec1.tabs[2], "points", 0)
    vf(spec1.tabs,3, {})
    vf(spec1.tabs[3], "points", 0)

    vf(bot.talents.specs,2, {})
    local spec2 = bot.talents.specs[2]
    vf(spec2,"primary", 1)
    vf(spec2,"tabs", {})
    vf(spec2.tabs,1, {})
    vf(spec2.tabs[1], "points", 0)
    vf(spec2.tabs,2, {})
    vf(spec2.tabs[2], "points", 0)
    vf(spec2.tabs,3, {})
    vf(spec2.tabs[3], "points", 0)

    vf(bot, "currency", {})
    vf(bot.currency, "copper", 0)
    vf(bot.currency, "silver", 0)
    vf(bot.currency, "gold", 0)
    vf(bot.currency, "other", {})

    vf(bot, "items", {})
    for i=0, 19 do
        vf(bot.items, i, {})
    end
    
    vf(bot, "bags", {})
    local bags = bot.bags
    vf(bags, -2, _self:CreateBagData("Keyring", 32))
    vf(bags, -1, _self:CreateBagData("Bank Storage", 28)) -- bank 0
    vf(bags, 0,  _self:CreateBagData("Backpack", 16)) 
    vf(bags, 1,  _self:CreateBagData(nil, 0))
    vf(bags, 2,  _self:CreateBagData(nil, 0))
    vf(bags, 3,  _self:CreateBagData(nil, 0))
    vf(bags, 4,  _self:CreateBagData(nil, 0))
    vf(bags, 5,  _self:CreateBagData(nil, 0)) -- bank 1
    vf(bags, 6,  _self:CreateBagData(nil, 0)) 
    vf(bags, 7,  _self:CreateBagData(nil, 0)) 
    vf(bags, 8,  _self:CreateBagData(nil, 0)) 
    vf(bags, 9,  _self:CreateBagData(nil, 0)) 
    vf(bags, 10, _self:CreateBagData(nil, 0)) 
    vf(bags, 11, _self:CreateBagData(nil, 0)) -- bank 7

    vf(bot, "stats", {})
    vf(bot.stats, "base", {})
    local function ensureBaseStat(index)
        vf(bot.stats.base, index, {})
        vf(bot.stats.base[index], "effectiveStat", 0)
        vf(bot.stats.base[index], "positive", 0)
        vf(bot.stats.base[index], "negative", 0)
    end

    for i=1, 5 do
        ensureBaseStat(i)
        if i == 1 then -- STRENGTH
            vf(bot.stats.base[i], "attackPower", 0)
        elseif i == 2 then -- AGILITY
            vf(bot.stats.base[i], "attackPower", 0)
            vf(bot.stats.base[i], "agilityCritChance", 0)
        elseif i == 3 then -- STAMINA
            vf(bot.stats.base[i], "maxHpModifier", 0)
        elseif i == 4 then
            vf(bot.stats.base[i], "intellectCritChance", 0)
        elseif i == 5 then -- spirit
            vf(bot.stats.base[i], "healthRegenFromSpirit", 0)
            vf(bot.stats.base[i], "manaRegenFromSpirit", 0)
        end
    end

    vf(bot.stats, "resists", {})
    local function ensureResist(index)
        vf(bot.stats.resists, index, {})
        vf(bot.stats.resists[index], "resistance", 0)
        vf(bot.stats.resists[index], "positive", 0)
        vf(bot.stats.resists[index], "negative", 0)
    end

    for i=1, 5 do
        ensureResist(i)
    end

    vf(bot.stats, "melee", {})
    local melee = bot.stats.melee
    vf(melee, "minMeleeDamage", 0)
    vf(melee, "maxMeleeDamage", 0)
    vf(melee, "minMeleeOffHandDamage", 0)
    vf(melee, "maxMeleeOffHandDamage", 0)
    vf(melee, "meleePhysicalBonusPositive", 0)
    vf(melee, "meleePhysicalBonusNegative", 0)
    vf(melee, "meleeDamageBuffPercent", 0)
    vf(melee, "meleeSpeed", 0)
    vf(melee, "meleeOffhandSpeed", 0)
    vf(melee, "meleeAtkPowerBase", 0)
    vf(melee, "meleeAtkPowerPositive", 0)
    vf(melee, "meleeAtkPowerNegative", 0)
    vf(melee, "meleeHaste", 0)
    vf(melee, "meleeHasteBonus", 0)
    vf(melee, "meleeCritRating", 0)
    vf(melee, "meleeCritRatingBonus", 0)
    vf(melee, "meleeCritChance", 0)
    vf(melee, "meleeHit", 0)
    vf(melee, "meleeHitBonus", 0)
    vf(melee, "armorPen", 0)
    vf(melee, "armorPenPercent", 0)
    vf(melee, "armorPenBonus", 0)
    vf(melee, "expertise", 0)
    vf(melee, "offhandExpertise", 0)
    vf(melee, "expertisePercent", 0)
    vf(melee, "expertiseOffhandPercent", 0)
    vf(melee, "expertiseRating", 0)
    vf(melee, "expertiseRatingBonus", 0)

    vf(bot.stats, "ranged", {})
    local ranged = bot.stats.ranged

    vf(ranged, "rangedAttackSpeed", 0)
    vf(ranged, "rangedMinDamage", 0)
    vf(ranged, "rangedMaxDamage", 0)
    vf(ranged, "rangedPhysicalBonusPositive", 0)
    vf(ranged, "rangedPhysicalBonusNegative", 0)
    vf(ranged, "rangedDamageBuffPercent", 0)
    vf(ranged, "rangedAttackPower", 0)
    vf(ranged, "rangedAttackPowerPositive", 0)
    vf(ranged, "rangedAttackPowerNegative", 0)
    vf(ranged, "rangedHaste", 0)
    vf(ranged, "rangedHasteBonus", 0)
    vf(ranged, "rangedCritRating", 0)
    vf(ranged, "rangedCritRatingBonus", 0)
    vf(ranged, "rangedCritChance", 0)
    vf(ranged, "rangedHit", 0)
    vf(ranged, "rangedHitBonus", 0)

    vf(bot.stats, "spell", {})
    local spell = bot.stats.spell

    vf(spell, "spellBonusDamage", {})

    for i=2, MAX_SPELL_SCHOOLS do 
        vf(spell.spellBonusDamage, i, 0)
    end

    vf(spell, "spellBonusHealing", 0)
    vf(spell, "spellHit", 0)
    vf(spell, "spellHitBonus", 0)
    vf(spell, "spellPenetration", 0)

    vf(spell, "spellCritChance", {})
    for i=2, MAX_SPELL_SCHOOLS do 
        vf(spell.spellCritChance, i, 0)
    end
    vf(spell, "spellCritRating", 0)
    vf(spell, "spellCritRatingBonus", 0)
    vf(spell, "spellHaste", 0)
    vf(spell, "spellHasteBonus", 0)
    vf(spell, "baseManaRegen", 0)
    vf(spell, "castingManaRegen", 0)

    vf(bot.stats, "defenses", {})
    local defenses = bot.stats.defenses

    vf(defenses, "effectiveArmor", 0)
    vf(defenses, "armorPositive", 0)
    vf(defenses, "armorNegative", 0)
    vf(defenses, "effectivePetArmor", 0)
    vf(defenses, "armorPetPositive", 0)
    vf(defenses, "armorPetNegative", 0)
    vf(defenses, "baseDefense", 0)
    vf(defenses, "modifierDefense", 0)
    vf(defenses, "defenseRating", 0)
    vf(defenses, "defenseRatingBonus", 0)
    vf(defenses, "dodgeChance", 0)
    vf(defenses, "dodgeRating", 0)
    vf(defenses, "dodgeRatingBonus", 0)
    vf(defenses, "blockChance", 0)
    vf(defenses, "shieldBlock", 0)
    vf(defenses, "blockRating", 0)
    vf(defenses, "blockRatingBonus", 0)
    vf(defenses, "parryChance", 0)
    vf(defenses, "parryRating", 0)
    vf(defenses, "parryRatingBonus", 0)
    vf(defenses, "meleeResil", 0)
    vf(defenses, "meleeResilBonus", 0)
    vf(defenses, "rangedResil", 0)
    vf(defenses, "rangedResilBonus", 0)
    vf(defenses, "spellResil", 0)
    vf(defenses, "spellResilBonus", 0)
end

--- Returns true if registered a new bot, otherwise false
function _self:RegisterBot(name)
    print(type(name))
    if _bots[name] == nil then
        _bots[name] = _self:CreateBotData(name)
        print("Created bot data for: " .. name)
        return true
    end
    return false
end

function _self:UnregisterBot(name)
    if _bots[name] ~= nil then
        _bots = _util.RemoveByKey(_bots, name)
    end
end

function _self:GetBot(name)
    if _bots ~= nil then
        return _bots[name]
    end
end