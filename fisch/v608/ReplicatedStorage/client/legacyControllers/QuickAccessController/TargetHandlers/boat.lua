local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(ReplicatedStorage.client.modules.ui.Backpack)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local remoteEvent = Net:RemoteEvent("Boats/Close")
local remoteFunction = Net:RemoteFunction("Boats/Spawn")
local Boat = {}

function Boat.GetOptions()
	playerDataReplicator:WaitForLoaded()
	local result = {}

	for k, v2 in vessels.library do
		if typeof(v2) == "table" and vessels:Has(v, k) then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

function Boat.Select(p: string)
	if not vessels:Has(v, p) then
		anno_localthought:Fire("You don't own this boat anymore!")
		return
	end

	if v:GetAttribute("LastDock") ~= "None" then
		remoteEvent:FireServer()
		v:GetAttributeChangedSignal("LastDock"):Wait()
	end

	remoteFunction:InvokeServer(p)
end

function Boat.GetDisplay(p: string)
	local v2 = vessels.library[p]

	if v2 and v2.Icon and v2.Icon ~= "" then
		return "Icon", v2.Icon
	end

	return "Text", p
end

function Boat.GetDescription(p: string)
	return (`Spawn {p}`)
end

return Boat