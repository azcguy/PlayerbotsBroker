PlayerbotsBroker.util.event = {}
local _self = PlayerbotsBroker.util.event
local _wipe = wipe

function _self.Create()
    local event = {}
    event.callbacks = {}
    event.targets = {}

    event.Invoke = function (self, arg1, arg2, arg3, arg4)
        for k,cb in pairs(self.callbacks) do
            if cb then
                local target = self.targets[cb]
                if target then
                    cb(target, arg1, arg2, arg3, arg4)
                else
                    cb(arg1, arg2, arg3, arg4)
                end
            end
        end
    end

    event.Add = function (self, callback, invokeTarget)
        self.callbacks[callback] = callback
        self.targets[callback] = invokeTarget
    end

    event.Remove = function (self, callback)
        self.callbacks[callback] = nil
        self.targets[callback] = nil
    end

    event.Clear = function (self)
        _wipe(event.callbacks)
        _wipe(event.targets)
    end

    return event
end