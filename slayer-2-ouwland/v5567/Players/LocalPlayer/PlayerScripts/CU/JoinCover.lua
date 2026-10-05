local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)

if not gameSettings.loadingScreenEnabled then
	return
end

local v = Worlds.ById[game.PlaceId]
local minigame = workspace:GetAttribute("Minigame")
local v2

if v == nil or v.Ignore then
	if minigame == nil then
		return
	else
		v2 = {
			Title = "Minigame",
			SubTitle = tostring(minigame)
		}
	end
else
	v2 = {
		Title = v.Name
	}
end

local lastTime = os.clock()
Teleporter.ShowCover(v2)

repeat
	task.wait(0.1)
until os.clock() - lastTime >= 1.25 and (game:IsLoaded() or os.clock() - lastTime >= 3)

Teleporter.HideCover()