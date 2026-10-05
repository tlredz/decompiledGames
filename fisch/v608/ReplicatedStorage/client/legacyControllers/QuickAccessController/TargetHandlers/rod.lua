local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = ReplicatedStorage.events.anno_localthought
local remoteFunction = Net:RemoteFunction("Rod/Equip")
local rod = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("rod")
local value = rod.Value
local v2 = value
local Rod = {
	GetOptions = function()
		playerDataReplicator:WaitForLoaded()
		local result = {}

		for k in playerDataReplicator:Index({ "Rods" }) do
			if rods[k] and typeof(rods[k]) == "table" then
				table.insert(result, k)
			end
		end

		table.sort(result)
		return result
	end,
	Select = function(childName: string)
		if value == childName and v2 ~= childName then
			childName = v2
		end

		if value ~= childName then
			remoteFunction:InvokeServer(childName)
			v.Backpack:WaitForChild(childName, 15)
		end

		Backpack.equipRod()
	end,
	GetDisplay = function(p: string)
		if value == p and v2 ~= p then
			p = v2
		end

		local rod2 = rods[p]

		if rod2 and typeof(rod2) == "table" and rod2.Icon and rod2.Icon ~= "" then
			return "Icon", rod2.Icon
		end

		return "Text", p
	end,
	GetDescription = function(p: string)
		if value == p and v2 ~= p then
			p = v2
		end

		return (`Equip {p}`)
	end
}
rod.Changed:Connect(function(p)
	v2 = value
	value = p
end)
return Rod