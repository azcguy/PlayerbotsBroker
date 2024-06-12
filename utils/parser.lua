PlayerbotsBroker.util.parser = {}
local _self = PlayerbotsBroker.util.parser
local _const = PlayerbotsBroker.consts

local _strbyte = string.byte
local _strchar = string.char
local _strsub = string.sub
local _strlen = string.len
local _tconcat = table.concat
local _pow = math.pow
local _floor = math.floor

--- This is a forward parser, call next..() functions to get value of type required by the msg
-- If the payload is null, the parser is considered broken and functions will return default non null values
function _self.Create()
    local parser = {
        separator = _const.MSG_SEPARATOR_BYTE,
        dotbyte = _const.FLOAT_DOT_BYTE,
        buffer = {}
    }

    parser.start = function (self, payload)
        if not payload then 
            self.broken = true
            return
        end
        self.payload = payload
        self.len = _strlen(payload)
        self.broken = false
        self.bufferCount = 0
        self.cursor = 1
    end
    parser.nextString = function(self)
        if self.broken then
            return "NULL"
        end
        local strbyte = _strbyte
        local strchar = _strchar
        local buffer = self.buffer
        local p = self.payload
        for i = self.cursor, self.len+1 do
            local c = strbyte(p, i)
            if c == nil or c == self.separator then
                local bufferCount = self.bufferCount
                if bufferCount > 0 then
                    self.cursor = i + 1
                    if buffer[1] == _const.NULL_LINK then
                        self.bufferCount = 0
                        return nil 
                    end

                    local result = _tconcat(buffer, nil, 1, bufferCount)
                    self.bufferCount = 0
                    return result
                else
                    return nil
                end
            else
                self.cursor = i
                local bufferCount = self.bufferCount + 1
                self.bufferCount = bufferCount
                buffer[bufferCount] = strchar(c)
            end
        end
    end

    parser.stringToEnd = function(self)
        if self.broken then
            return "NULL"
        end
        self.bufferCount = 0
        local p = self.payload
        local c = _strbyte(p, self.cursor)
        if c == _const.BYTE_NULL_LINK then
            return nil 
        else
            return _strsub(p, self.cursor)
        end
    end

    parser.nextLink = function(self)
        if self.broken then
            return nil
        end
        local strbyte = _strbyte
        local strchar = _strchar
        local buffer = self.buffer
        local p = self.payload
        local start = self.cursor
        local v = false -- validate  the | char
        -- if after the validator proceeds an 'r' then we terminate the link
        for i = self.cursor, self.len+1 do
            local c = strbyte(p, i)
            self.cursor = i
            if v == true then
                if c == _const.BYTE_LINK_TERMINATOR then
                    local result = _strsub(p, start, i)
                    self.cursor = i + 2 -- as we dont end on separator we jump 1 ahead
                    return result
                else
                    v = false
                end
            end

            if c == _const.BYTE_LINK_SEP then
                v = true
            end

            if c == _const.NULL_LINK then
                self.cursor = i + 1
                return nil
            end

            if c == nil then
                -- we reached the end of payload but didnt close the link, the link is either not a link or invalid
                -- return null?
                return nil
            end
        end
    end

    parser.nextInt = function(self)
        if self.broken then
            return 0
        end
        local buffer = self.buffer
        local p = self.payload
        local strbyte = _strbyte
        local pow = _pow
        local floor = _floor
        for i = self.cursor, self.len + 1 do
            local c = strbyte(p, i)
            if c == nil or c == self.separator then
                local bufferCount = self.bufferCount
                if bufferCount > 0 then
                    self.cursor = i + 1
                    local result = 0
                    local sign = 1
                    local start = 1
                    if buffer[1] == _const.BYTE_MINUS then
                        sign = -1
                        start = 2
                    end
                    for t= start, bufferCount do
                        result = result + ((buffer[t]-48)*pow(10, bufferCount - t))
                    end
                    result = result * sign
                    self.bufferCount = 0
                    return floor(result)
                end
            else
                self.cursor = i
                local bufferCount = self.bufferCount + 1
                self.bufferCount = bufferCount
                buffer[bufferCount] = c
            end
        end
    end
    parser.nextFloat = function(self)
        if self.broken then
            return 0.0
        end
        local tobyte = string.byte
        local buffer = self.buffer
        local p = self.payload
        local pow = _pow
        for i = self.cursor, self.len + 1 do
            local c = tobyte(p, i)
            if c == nil or c == self.separator then
                local bufferCount = self.bufferCount
                if bufferCount > 0 then
                    self.cursor = i + 1
                    local result = 0
                    local dotPos = -1
                    local sign = 1
                    local start = 1
                    if buffer[1] == _const.BYTE_MINUS then
                        sign = -1
                        start = 2
                    end
                    -- find dot
                    for t=1, bufferCount do
                        if buffer[t] == self.dotbyte then
                            dotPos = t
                            break
                        end
                    end
                    -- if no dot, use simplified int algo
                    if dotPos == -1 then
                        for t=start, bufferCount do
                            result = result + ((buffer[t]-48)*_pow(10, bufferCount - t))
                        end
                        result = result * sign
                        self.bufferCount = 0
                        return result -- still returns a float because of pow
                    else
                        for t=start, dotPos-1 do -- int
                            result = result + ((buffer[t]-48)*_pow(10, dotPos - t - 1))
                        end
                        for t=dotPos+1, bufferCount do -- decimal
                            result = result + ((buffer[t]-48)* _pow(10, (t-dotPos) * -1))
                        end
                        result = result * sign
                        self.bufferCount = 0
                        return result
                    end
                end
            else
                self.cursor = i
                local bufferCount = self.bufferCount + 1
                self.bufferCount = bufferCount
                buffer[bufferCount] = c
            end
        end
    end
    parser.nextBool = function (self)
        if self.broken then
            return false
        end
        local strbyte = _strbyte
        local buffer = self.buffer
        local p = self.payload
        for i = self.cursor, self.len+1 do
            local c = strbyte(p, i)
            if c == nil or c == self.separator then
                if self.bufferCount > 0 then
                    self.cursor = i + 1
                    self.bufferCount = 0
                    if buffer[1] == _const.BYTE_ZERO then
                        return false
                    else
                        return true
                    end
                else
                    return nil
                end
            else
                self.cursor = i
                local bufferCount = self.bufferCount + 1
                self.bufferCount = bufferCount
                buffer[bufferCount] = c
            end
        end
    end

    parser.nextChar = function (self)
        if self.broken then
            return false
        end
        local strbyte = _strbyte
        local strchar = _strchar
        local p = self.payload
        local result = nil
        for i = self.cursor, self.len+1 do
            local c = strbyte(p, i)
            if c == nil or c == self.separator then
                self.cursor = i + 1
                self.bufferCount = 0
                return result
            else
                self.cursor = i
                if not result then
                    result = strchar(c)
                end
            end
        end
    end

    parser.nextCharAsByte = function (self)
    ---@diagnostic disable-next-line: param-type-mismatch
        return _strbyte(self:nextChar())
    end

    parser.validateLink = function(link)
        if link == nil then return false end
        local l = _strlen(link)
        local v1 = _strbyte(link, l) == _const.BYTE_LINK_TERMINATOR
        local v2 = _strbyte(link, l-1) == _const.BYTE_LINK_SEP
        return v1 and v2
    end

    return parser
end