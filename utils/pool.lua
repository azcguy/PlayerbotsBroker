PlayerbotsBroker.util.pool = {}
local _self = PlayerbotsBroker.util.pool

function _self.Create(onNew, onClear)
    local pool = {}
    pool.elems = {}
    pool.count = 0
    pool.onNew = onNew
    pool.onClear = onClear
    pool.Get = function (self)
        local elems = self.elems
        local count = self.count
        if self.count == 0 then
            return self.onNew()
        else
            local elem = elems[count]
            elems[count] = nil
            self.count = count - 1
            return elem
        end
    end

    pool.Release = function  (self, elem)
        if not elem then return end
        local count = self.count
        count = count + 1
        self.elems[count] = elem
        self.count = count
        if onClear then
            self.onClear(elem)
        end
    end

    return pool
end