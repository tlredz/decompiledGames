local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(ReplicatedStorage.client.modules.ui.Backpack)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = ReplicatedStorage.events.anno_localthought
local remoteFunction = Net:RemoteFunction("Companion/Equip")
legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("rod")
local v = nil
local v2 = nil
local Companion = {
	GetOptions = function()
		playerDataReplicator:WaitForLoaded()
		local result = {}

		for k in playerDataReplicator:Index({ "Companions", "Owned" }) do
			if companions.Companions[k] then
				table.insert(result, k)
			end
		end

		table.sort(result)
		return result
	end,
	Select = function(p: string)
		if v == p and v2 ~= p and v2 then
			p = v2
		end

		if v ~= p then
			remoteFunction:InvokeServer(p)
		end
	end,
	GetDisplay = function(p: string)
		if v == p and v2 ~= p and v2 then
			p = v2
		end

		local companion = companions.Companions[p]

		if companion and companion.Icon and companion.Icon ~= "" then
			return "Icon", companion.Icon
		end

		return "Text", p
	end,
	GetDescription = function(p: string)
		if v == p and v2 ~= p and v2 then
			p = v2
		end

		return (`Equip {p}`)
	end
}
playerDataReplicator:Observe({ "Companions", "Equipped" }, function(p, p2)
	v = p
	v2 = p2 or p
end)
return Companion