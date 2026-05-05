ZModUnbork = ZModUnbork or {}
ZModUnbork.MOD_ID = "ZModUnbork"

ZModUnbork.Config = ZModUnbork.Config or {}

-- private

local Config  = ZModUnbork.Config
local _fname  = ZModUnbork.MOD_ID .. ".ini"
local _loaded = false
local _data   = {}

local function load()
    local reader = getFileReader(_fname, false)
    if reader then
        local line = reader:readLine()
        while line do
            local pos = line:find("=")
            if pos then
                local key   = line:sub(0, pos - 1):trim()
                local value = line:sub(pos + 1):trim()

                if value == "true" then
                    value = true
                elseif value == "false" then
                    value = false
                end

                _data[key] = value
            end
            line = reader:readLine()
        end
        reader:close()
    end
end

local function maybe_load()
    if not _loaded then
        load()
        _loaded = true
    end
end

local function save()
    maybe_load()
    local writer = getFileWriter(_fname, true, false)
    if writer then
        for key, value in pairs(_data) do
            writer:write(key .. "=" .. tostring(value) .. "\n")
        end
        writer:close()
    end
end

-- Public API

function Config.get(key, default)
    maybe_load()
    local value = _data[key]
    if value ~= nil then return value end
    return default
end

function Config.set(key, value)
    maybe_load()
    _data[key] = value
    save()
end
