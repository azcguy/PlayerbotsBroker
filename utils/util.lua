PlayerbotsBroker.util = {}
local _self = PlayerbotsBroker.util

function _self.CompareAndReturn(eval, ifTrue, ifFalse)
    if eval then
        return ifTrue
    else
        return ifFalse
    end
end

function _self.Where(_table, predicate)
    for k,v in pairs(_table) do
        if(predicate(k,v)) then
            return _table[k]
        end    
    end
end

function _self.FindIndex(_table, obj)
    local t = 1
    for k,v in pairs(_table) do
        if v == obj then
            return t
        end    
        t = t + 1
    end
    return -1
end

function _self.IndexOf(_table, predicate)
    local t = 1
    for k,v in pairs(_table) do
        if(predicate(k,v)) then
            return t
        end    
        t = t + 1
    end
    return -1
end

-- copies the table and returns a new one
function _self.RemoveByKey(_table, key)
    local n = {}
    for k,v in pairs(_table) do
        if k ~= key then
            n[k] = v
        end
    end
    return n
end

function _self.DumpTable(_table)
    if type(_table) ~= "table" then
        print("NOT A TABLE!")
    end
    _self.Where(_table, function(k,v)
        print(k, v)
    end)
end


