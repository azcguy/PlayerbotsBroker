local _array = PlayerbotsBroker.queries
local QTYPE = PlayerbotsBroker.consts.QUERY
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events

_array[QTYPE.STATS] = 
{
    qtype = QTYPE.STATS,
    onStart          = function(query)

    end,
    onProgress       = function(query, payload)
        _parser:start(payload)
        local bot = query.bot
        local stats = bot.stats
        local subtype = _parser:nextCharAsByte()

        local c_base = false
        local c_resists = false
        local c_melee = false
        local c_ranged = false
        local c_spell = false
        local c_defenses = false

        local function evalChange(change, newval, obj, oldvalKey)
            if newval ~= obj[oldvalKey] then
                obj[oldvalKey] = newval
                return true
            else
                return change
            end
        end

        if subtype == QTYPE.STATS_BASE then
            local stats_base = stats.base
            local stats_res = stats.resists
            for i=1, 5 do -- loop basic stats
                --[[
                    index corresponds to blizzard index
                      1  Agility
                      2  Intellect
                      3  Spirit
                      4  Stamina
                      5  Strength
                ]]
                -- format > value : effectiveStat : positive : negative
                local statData = stats_base[i]
                c_base = evalChange(c_base, _parser:nextInt(), statData, "effectiveStat")
                c_base = evalChange(c_base, _parser:nextInt(), statData, "positive")
                c_base = evalChange(c_base, _parser:nextInt(), statData, "negative")

                if i == 1 then -- STRENGTH
                    c_base = evalChange(c_base,_parser:nextInt(), statData, "attackPower")
                elseif i == 2 then -- AGILITY
                    c_base = evalChange(c_base,_parser:nextInt(), statData, "attackPower")
                    c_base = evalChange(c_base,_parser:nextFloat(), statData, "agilityCritChance")
                elseif i == 3 then -- STAMINA
                    c_base = evalChange(c_base,_parser:nextInt(), statData, "maxHpModifier")
                elseif i == 4 then
                    c_base = evalChange(c_base,_parser:nextFloat(), statData, "intellectCritChance")
                elseif i == 5 then -- spirit
                    c_base = evalChange(c_base,_parser:nextInt(), statData, "healthRegenFromSpirit")
                    c_base = evalChange(c_base,_parser:nextFloat(), statData, "manaRegenFromSpirit")
                end
            end
            
            for i=1, 5 do -- loop resists
                --[[
                    1 - Arcane
                    2 - Fire
                    3 - Nature
                    4 - Frost
                    5 - Shadow
                ]]
                -- format > base : resistance : positive : negative

                local statData = stats_res[i]
                c_resists = evalChange(c_resists,_parser:nextInt(), statData, "resistance")
                c_resists = evalChange(c_resists,_parser:nextInt(), statData, "positive")
                c_resists = evalChange(c_resists,_parser:nextInt(), statData, "negative")
            end



        elseif subtype == QTYPE.STATS_MELEE then
            local melee = stats.melee

            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "minMeleeDamage")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "maxMeleeDamage")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "minMeleeOffHandDamage")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "maxMeleeOffHandDamage")
            c_melee = evalChange(c_melee, _parser:nextInt(), melee, "meleePhysicalBonusPositive")
            c_melee = evalChange(c_melee, _parser:nextInt(), melee, "meleePhysicalBonusNegative")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "meleeDamageBuffPercent")

            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeSpeed")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeOffhandSpeed")

            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeAtkPowerBase")
            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeAtkPowerPositive")
            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeAtkPowerNegative")

            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeHaste")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeHasteBonus")

            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeCritRating")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeCritRatingBonus")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeCritChance")

            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "meleeHit")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "meleeHitBonus")

            c_melee = evalChange(c_melee,_parser:nextInt(), melee, "armorPen")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "armorPenPercent")
            c_melee = evalChange(c_melee,_parser:nextFloat(), melee, "armorPenBonus")

            c_melee = evalChange(c_melee, _parser:nextInt(), melee, "expertise")
            c_melee = evalChange(c_melee, _parser:nextInt(), melee, "offhandExpertise")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "expertisePercent")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "expertiseOffhandPercent")
            c_melee = evalChange(c_melee, _parser:nextInt(), melee, "expertiseRating")
            c_melee = evalChange(c_melee, _parser:nextFloat(), melee, "expertiseRatingBonus")
        elseif subtype == QTYPE.STATS_RANGED then
            local ranged = stats.ranged

            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedAttackSpeed")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedMinDamage")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedMaxDamage")
            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedPhysicalBonusPositive")
            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedPhysicalBonusNegative")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedDamageBuffPercent")

            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedAttackPower")
            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedAttackPowerPositive")
            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedAttackPowerNegative")

            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedHaste")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedHasteBonus")

            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedCritRating")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedCritRatingBonus")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedCritChance")

            c_ranged = evalChange(c_ranged, _parser:nextInt(), ranged, "rangedHit")
            c_ranged = evalChange(c_ranged, _parser:nextFloat(), ranged, "rangedHitBonus")

        elseif subtype == QTYPE.STATS_SPELL then
            local spell = stats.spell

            for i=2, MAX_SPELL_SCHOOLS do -- skip physical, start at 2
                c_spell = evalChange(c_spell, _parser:nextInt(), spell.spellBonusDamage, i)
            end
        
            c_spell = evalChange(c_spell, _parser:nextInt(), spell, "spellBonusHealing")
        
            c_spell = evalChange(c_spell, _parser:nextInt(), spell, "spellHit")
            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "spellHitBonus")
            
            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "spellPenetration")

            for i=2, MAX_SPELL_SCHOOLS do -- skip physical, start at 2
                c_spell = evalChange(c_spell, _parser:nextFloat(), spell.spellCritChance, i)
            end
            
            c_spell = evalChange(c_spell, _parser:nextInt(), spell, "spellCritRating")
            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "spellCritRatingBonus")

            c_spell = evalChange(c_spell, _parser:nextInt(), spell, "spellHaste")
            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "spellHasteBonus")

            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "baseManaRegen")
            c_spell = evalChange(c_spell, _parser:nextFloat(), spell, "castingManaRegen")
        elseif subtype == QTYPE.STATS_DEFENSES then
            local defenses = stats.defenses
            
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "effectiveArmor")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "armorPositive")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "armorNegative")

            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "effectivePetArmor")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "armorPetPositive")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "armorPetNegative")

            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "baseDefense")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "modifierDefense")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "defenseRating")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "defenseRatingBonus")

            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "dodgeChance")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "dodgeRating")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "dodgeRatingBonus")

            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "blockChance")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "shieldBlock")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "blockRating")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "blockRatingBonus")

            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "parryChance")
            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "parryRating")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "parryRatingBonus")

            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "meleeResil")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "meleeResilBonus")

            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "rangedResil")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "rangedResilBonus")

            c_defenses = evalChange(c_defenses, _parser:nextInt(), defenses, "spellResil")
            c_defenses = evalChange(c_defenses, _parser:nextFloat(), defenses, "spellResilBonus")
        end
        if c_base then _events.STATS_CHANGED_BASE:Invoke(bot)  end
        if c_resists then _events.STATS_CHANGED_RESISTS:Invoke( bot)   end
        if c_melee then _events.STATS_CHANGED_MELEE:Invoke( bot)   end
        if c_ranged then _events.STATS_CHANGED_RANGED:Invoke( bot)   end
        if c_spell then _events.STATS_CHANGED_SPELL:Invoke( bot)   end
        if c_defenses then _events.STATS_CHANGED_DEFENSES:Invoke( bot)  end

        if c_base or c_defenses or c_melee or c_ranged or c_resists or c_spell then
            _events.STATS_CHANGED:Invoke(bot)
        end
    end,
    onFinalize       = function(query)
    end,
}