local Games = {
    10851599 = "rts"
}

local Found = Games[game.PlaceId]
if Found then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/rks-hub/refs/heads/main/games/"..Found..".lua"))()
end
