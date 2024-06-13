-- this class abstracts things related to update loop and time
PlayerbotsBroker.util.updateHandler = {}
local _self = PlayerbotsBroker.util.updateHandler
local _util = PlayerbotsBroker.util
local _eval = _util.CompareAndReturn
local _getn = getn
local _tremove = tremove
local _tinsert = tinsert

--[[
    Update handler can :
    - Invoke onUpdate event
    - Invoke delayed callbacks after x seconds
    - Invoke onMouseButton when a mouse button is pressed, globally anywhere
    You have to :
    - Call Update(elapsed) on it, from WOW Frame Update event
    You can : 
    you can mark global clicks as consumed, this allows to check if input was processed in frame events like OnClick
        SetGlobalMouseButtonConsumed(self, buttonNum)
        GetGlobalMouseButtonConsumed(self, buttonNum)
        these allow you to filter button press events globally, i.e. one frame reacts to a button press, and others check if the input was consumed
]]

function _self.Create()
    local updateHandler = {}

    updateHandler.onUpdate = _util.event.Create()
    -- fires when mouse button state changes (button, down)
    updateHandler.onMouseButton = _util.event.Create()
    -- total time since initialized
    updateHandler.totalTime = 0

    updateHandler.delayedCalls = {}

    updateHandler.consumedMouseClicks = {
        [1] = false,
        [2] = false,
        [3] = false
    }

    local function CreateMouseButtonHandler(self, button)
        local handler = {}
        handler.button = button
        handler.isdown = false
        handler.onChanged = self.onMouseButton
        handler.update = function (self)
            local down = IsMouseButtonDown(button)
            local state = _eval(down, true, false)
            if state ~= self.isdown then -- state changed
                self.isdown = state
                self.onChanged:Invoke(self.button, state)
            end
        end
        return handler
    end

    updateHandler.mouseButtonHandlers = {}
    updateHandler.mouseButtonHandlers[1] = CreateMouseButtonHandler(updateHandler, "LeftButton")
    updateHandler.mouseButtonHandlers[2] = CreateMouseButtonHandler(updateHandler, "RightButton")
    updateHandler.mouseButtonHandlers[3] = CreateMouseButtonHandler(updateHandler, "MiddleButton")

    function updateHandler.SetGlobalMouseButtonConsumed(self, buttonNum)
        self.consumedMouseClicks[buttonNum] = true
    end

    function updateHandler.GetGlobalMouseButtonConsumed(self, buttonNum)
        return self.consumedMouseClicks[buttonNum]
    end
    
    function updateHandler.Update(self, elapsed)
        self.totalTime = self.totalTime + elapsed
        for i=1, 3 do
            self.consumedMouseClicks[i] = false
            self.mouseButtonHandlers[i]:update()
        end
    
        self.onUpdate:Invoke(elapsed)
      
        local len = _getn(self.delayedCalls)
        for i = len, 1, -1 do
          local call = self.delayedCalls[i]
          if call.callAt < self.totalTime then
            call:callback()
            _tremove(self.delayedCalls, i)
          end
        end
    end
    
    function updateHandler.DelayCall(self, seconds, func)
      local call = {
        callAt = self.totalTime + seconds,
        callback = func
      }
      _tinsert(self.delayedCalls, call)
    end

    return updateHandler
end



