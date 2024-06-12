local _array = PlayerbotsBroker.queries
local QTYPE = PlayerbotsBroker.consts.QUERY
local _parser = PlayerbotsBroker.broker.parser
local _events = PlayerbotsBroker.events

_array[QTYPE.WHO] = 
{
    qtype = QTYPE.WHO,
    onStart          = function(query)
    end,
    onProgress       = function(query, payload)
        -- CLASS(token):LEVEL(1-80):SECOND_SPEC_UNLOCKED(0-1):ACTIVE_SPEC(1-2):POINTS1:POINTS2:POINTS3:POINTS4:POINTS5:POINTS6:FLOAT_EXP:LOCATION
        -- PALADIN:65:1:1:5:10:31:40:5:10:0.89:Blasted Lands 
        _parser:start(payload)
        local class = _parser:nextString()
        local level = _parser:nextInt()
        local secondSpecUnlocked = _parser:nextBool()
        local activeSpec = _parser:nextInt()
        local points1 = _parser:nextInt()
        local points2 = _parser:nextInt()
        local points3 = _parser:nextInt()
        local points4 = _parser:nextInt()
        local points5 = _parser:nextInt()
        local points6 = _parser:nextInt()
        local expLeft = _parser:nextFloat()
        local zone = _parser:nextString()
        if not _parser.broken then 
            -- this code is very verbose, but it is the most optimized way, think of it as inlining
            local bot = query.bot
            local botname = bot.name

            bot.class = class

            local changed_level = false
            local changed_spec_data = false
            local changed_exp = false
            local changed_zone = false

            local function evalChange(newval, obj, oldval)
                if newval ~= obj[oldval] then
                    obj[oldval] = newval
                    return true
                end
            end

            changed_level = evalChange(level, bot, "level")
            changed_spec_data = evalChange(secondSpecUnlocked, bot.talents, "dualSpecUnlocked")
            changed_spec_data = evalChange(activeSpec, bot.talents, "activeSpec")

            local spec1 = bot.talents.specs[1]
            local spec1tabs = spec1.tabs
            local p1 = 1
            if points2 > points1 then p1 = 2 end
            if points3 > points2 then p1 = 3 end
            
            changed_spec_data = evalChange(p1, spec1, "primary")
            changed_spec_data = evalChange(points1, spec1tabs[1], "points")
            changed_spec_data = evalChange(points2, spec1tabs[2], "points")
            changed_spec_data = evalChange(points3, spec1tabs[3], "points")

            local spec2 = bot.talents.specs[2]
            local spec2tabs = spec2.tabs
            local p2 = 1
            if points5 > points4 then p2 = 2 end
            if points6 > points5 then p2 = 3 end

            changed_spec_data = evalChange(p2, spec2, "primary")
            changed_spec_data = evalChange(points4, spec2tabs[1], "points")
            changed_spec_data = evalChange(points5, spec2tabs[2], "points")
            changed_spec_data = evalChange(points6, spec2tabs[3], "points")

            changed_exp = evalChange(expLeft, bot, "expLeft")
            
            changed_zone = evalChange(zone, bot, "zone")

            if changed_level then _events.LEVEL_CHANGED:Invoke(bot) end
            if changed_exp then _events.EXPERIENCE_CHANGED:Invoke(bot) end
            if changed_zone then _events.ZONE_CHANGED:Invoke(bot) end
            if changed_spec_data then _events.SPEC_DATA_CHANGED:Invoke(bot) end
        end
    end,
    onFinalize       = function(query) end,
}