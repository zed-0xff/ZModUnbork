ZModUnbork.stats = ZModUnbork.stats or {}

local logger = ZModUnbork.logger

--- count or log
function ZModUnbork.clog(key, fmt, ...)
    if ZModUnbork.Config.get('verbose_logs') then
        logger:info(fmt, ...)
    else
        ZModUnbork.stats[key] = (ZModUnbork.stats[key] or 0) + 1
    end
end

function ZModUnbork.clog_once(key, fmt, ...)
    if ZModUnbork.Config.get('verbose_logs') then
        ZModUnbork.log_once(fmt, ...)
    else
        ZModUnbork.stats[key] = (ZModUnbork.stats[key] or 0) + 1
    end
end

function ZModUnbork.logStats()
    if not ZModUnbork.Config.get('log_stats', true) then return end

    logger:info("stats / parameters fixed:")
    local keys = {}
    for key in pairs(ZModUnbork.stats) do
        table.insert(keys, key)
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
        logger:info("  %20s: %5d", key, ZModUnbork.stats[key])
    end
    if ZModUnbork.Config.get('verbose_logs') then
        logger:info("(disable verbose logs in ModOptions to see only summary counters)")
    else
        logger:info("(enable verbose logs in ModOptions to see each item change)")
    end
end

if Events then
    -- on game session end
    if Events.OnPostSave then
        Events.OnPostSave.Add(ZModUnbork.logStats)
    end
    if Events.OnMainMenuEnter then
        Events.OnMainMenuEnter.Add(ZModUnbork.logStats)
    end
end
