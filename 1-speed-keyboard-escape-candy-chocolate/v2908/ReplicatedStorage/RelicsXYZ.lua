local shared = script.Shared
local RunContext = require(shared.RunContext)
local LogService = game:GetService("LogService")

if not pcall(function()
	LogService:Info("LOADING RELICSXYZ MODULE...")
end) then
	warn("LOADING RELICSXYZ MODULE")
end

for _, child in script.Shared:GetChildren() do
	local v = child
	xpcall(require, function(p)
		warn((`Error loading module {v.Name}: {p} {debug.traceback()}`))
	end, child)
end

local RelicsPlayer

if RunContext.IsClient or RunContext.IsEdit then
	RelicsPlayer = require(script.RelicsPlayer)
else
	RelicsPlayer = table.freeze({
		new = function(_)
			error("RelicsPlayer cannot be created on the server.")
		end
	})
end

return table.freeze({
	Auras = require(shared.Auras),
	Emotes = require(shared.Emotes),
	Boombox = require(shared.Boombox),
	Bundles = require(shared.Bundles),
	Settings = require(shared.Settings),
	Favorites = require(shared.Favorites),
	MusicData = require(shared.MusicData),
	Ownership = require(shared.Ownership),
	GamePasses = require(shared.GamePasses),
	Marketplace = require(shared.Marketplace),
	RelicsPlayer = RelicsPlayer
})