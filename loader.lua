local Games = {
    [10851599] = "rts",
    [6022383883] = "mr"
}

local Id = game.PlaceId
local Found = Games[Id]
if Found then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/rks-hub/refs/heads/main/games/"..Found..".lua"))()
else
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/rks-hub/refs/heads/main/assets/ui.lua"))({theme="cherry", smoothDragging=false})
    Library.notify({
        title = "Place id: '" .. Id .. "' isn't in pea hub!",
        message = 'OK',
        duration = 5
    })
end
