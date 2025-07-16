local msg = require 'mp.msg'
local utils = require 'mp.utils'
local malToken = "PUT YOUR TOKEN HERE"

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
            string.format('https://api.myanimelist.net/v2/anime?q=%s&limit=1&fields=num_episodes', mediaTitleEncoded64)
        }
    })
    
    local getAnimeListJSON = utils.parse_json(getAnimeListRaw.stdout)
    
    local animeID = getAnimeListJSON.data[1].node.id
    local title = getAnimeListJSON.data[1].node.title
    local lastEps = getAnimeListJSON.data[1].node.num_episodes

    local currentStatus = setStatus(eps, lastEps)

    local postAnimeByID = utils.subprocess({
        args = {
            'curl',
            string.format('https://api.myanimelist.net/v2/anime/%s/my_list_status', animeID),
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
        }
    })

    msg.info(utils.format_json(postAnimeByID))
end)

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