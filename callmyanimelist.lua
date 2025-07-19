local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'
local versionCheckerBaseURL = "https://version.arifldhewo.my.id"
local malBaseURL = "https://api.myanimelist.net/v2"
local malToken = "PUT YOUR TOKEN HERE" 
local currentVersion = "1.3.0"

mp.add_key_binding("Ctrl+Shift+f", "update-anime", function ()
    local mediaTitleFull = mp.get_property("media-title")
    local mediaFileName = mp.get_property("playlist-path")
    local mediaTitleFullLen = string.len(mediaTitleFull)
    local eps = tonumber(string.sub(mediaTitleFull, mediaTitleFullLen - 1, mediaTitleFullLen))
    local mediaFileNameSplit = delimiter(mediaFileName, "\\")
    local mediaFileNameSplitLen = #mediaFileNameSplit
    local mediaFileNameSplitLast = mediaFileNameSplit[mediaFileNameSplitLen]
    local getSlugTitle = delimiter(mediaFileNameSplitLast, ".")
    local mediaTitleEncoded = string.gsub(getSlugTitle[1],"-", "+")
    local mediaTitleEncoded64 = string.sub(mediaTitleEncoded, 1, 64)

    local getAnimeListRaw = utils.subprocess({
        args = {
            'curl',
            '-s',
            '-H',
            string.format('Authorization: Bearer %s', malToken),
            string.format('%s/anime?q=%s&limit=1&fields=num_episodes', malBaseURL, mediaTitleEncoded64)
        },
        cancellable = false
    })
    
    local getAnimeListJSON = utils.parse_json(getAnimeListRaw.stdout)

    if getAnimeListJSON.error then
        mp.osd_message("Error is occured when getAnimeList (Check Console for Details press [`] tilde)", 5)
        msg.warn(getAnimeListRaw.stdout)
        return
    end
    
    local animeID = getAnimeListJSON.data[1].node.id
    local title = getAnimeListJSON.data[1].node.title
    local lastEps = getAnimeListJSON.data[1].node.num_episodes

    local currentStatus = setStatus(eps, lastEps)

    local postAnimeByID = utils.subprocess({
        args = {
            'curl',
            string.format('%s/anime/%s/my_list_status', malBaseURL, animeID),
            '-s',
            '-H',
            string.format('Authorization: Bearer %s', malToken),
            '-H',
            'Content-Type: application/x-www-form-urlencoded',
            '-X',
            'PUT',
            '-d',
            string.format('status=%s', currentStatus),
            '-d', 
            string.format('num_watched_episodes=%s', eps)
        },
        cancellable = false
    })

    mp.osd_message(string.format("Success update%s to MAL", mediaTitleFull), 2.5)
end)

mp.register_event("file-loaded", function () 
    local getNewestVersionRaw = utils.subprocess({
        args = {
            'curl', 
            '-s',
            string.format("%s/version/callmyanimelist", versionCheckerBaseURL),
        },
        cancellable = false,
    })

    local formatJSON = utils.parse_json(getNewestVersionRaw.stdout)

    if formatJSON.tag_name ~= currentVersion then 
        mp.osd_message(string.format("Hey, There's a new version [%s] current [%s]", formatJSON.tag_name, currentVersion))
    else
        msg.info("Version is up to date")
    end
end)

------------------------------------------------------------------------------------------- A LINE BETWEEN HELPER AND ACTION

function setStatus(eps, lastEps) 
    if eps == lastEps then
        return "completed"
    else 
        return "watching"
    end
end

function delimiter(string, delimiter) 
    local result = {}
    local pattern = "([^".. delimiter .."]+)"

    for match in string:gmatch(pattern) do 
        table.insert(result, match)
    end

    return result
end

msg.info("Script Loaded")