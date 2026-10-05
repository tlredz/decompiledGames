local shared = script.Shared
local RunContext = require(shared.RunContext)
game:GetService("LogService")
pcall(function() end)

for _, child in script.Shared:GetChildren() do
	xpcall(require, function(_) end, child)
end

local RelicsPlayer

if RunContext.IsClient or RunContext.IsEdit then
	RelicsPlayer = require(script.RelicsPlayer)
else
	RelicsPlayer = table.freeze({
		new = function(_) end
	})
end

return table.freeze({
	Auras = require(shared.Auras),
	Emotes = require(shared.Emotes),
	Boombox = require(shared.Boombox),
	Settings = require(shared.Settings),
	Favorites = require(shared.Favorites),
	MusicData = require(shared.MusicData),
	GamePasses = require(shared.GamePasses),
	RelicsPlayer = RelicsPlayer
})