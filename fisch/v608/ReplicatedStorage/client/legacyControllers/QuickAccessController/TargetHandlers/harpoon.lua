local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local harpoonGuns = require(ReplicatedStorage.shared.modules.library.harpoonGuns)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local remoteFunction = Net:RemoteFunction("HarpoonGun/SetEquipped")
local v2 = nil
local v3 = nil
local Harpoon = {
	GetOptions = function()
		playerDataReplicator:WaitForLoaded()
		local result = {}

		for k in playerDataReplicator:Index({ "HarpoonGuns", "Owned" }) do
			if harpoonGuns[k] then
				table.insert(result, k)
			end
		end

		table.sort(result)
		return result
	end,
	Select = function(childName: string)
		if v2 == childName and v3 ~= childName and v3 then
			childName = v3
		end

		if v2 ~= childName then
			remoteFunction:InvokeServer(childName)
			v.Backpack:WaitForChild(childName, 15)
		end

		Backpack.equipHarpoonGun()
	end,
	GetDisplay = function(p: string)
		if v2 == p and v3 ~= p and v3 then
			p = v3
		end

		local harpoonGun = harpoonGuns[p]

		if harpoonGun and harpoonGun.Icon and harpoonGun.Icon ~= "" then
			return "Icon", harpoonGun.Icon
		end

		return "Text", p
	end,
	GetDescription = function(p: string)
		if v2 == p and v3 ~= p and v3 then
			p = v3
		end

		return (`Equip {p}`)
	end
}
playerDataReplicator:Observe({ "HarpoonGuns", "Equipped" }, function(p, p2)
	v2 = p
	v3 = p2 or p
end)
return Harpoon