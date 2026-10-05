local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local spears = require(ReplicatedStorage.shared.modules.library.spears)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local _ = ReplicatedStorage.events.anno_localthought
local remoteFunction = Net:RemoteFunction("Spear/EquipAsync")
local spear = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("spear")
local value = spear.Value
local v2 = value
local Spear = {
	GetOptions = function()
		local result = {}
		playerDataReplicator:WaitForLoaded()
		local spears2 = playerDataReplicator.Data and playerDataReplicator.Data.Spears

		if not spears2 then
			return result
		end

		for k in spears2 do
			if spears[k] then
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

		Backpack.equipSpear()
	end,
	GetDisplay = function(p: string)
		if value == p and v2 ~= p then
			p = v2
		end

		local spear2 = spears[p]

		if spear2 and typeof(spear2) == "table" and spear2.Icon and spear2.Icon ~= "" then
			return "Icon", spear2.Icon
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
spear.Changed:Connect(function(p)
	v2 = value
	value = p
end)
return Spear