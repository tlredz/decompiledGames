local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v4 = require3(ReplicatedStorage2.Shared.UntradableItems)
local v5 = require3(ReplicatedStorage2.Shared.Inventory.Internal.DefaultItems)
local v6 = {
	"Id",
	"TradeLock",
	"Kills",
	"Serial",
	"IsSelected",
	"Description",
	"IsCustom"
}
local localPlayer = Players.LocalPlayer
local RAPController = {
	_enabled = true,
	_IGNORE_ATTRIBUTES = v6,
	IsEnabled = function(p)
		return p._enabled
	end,
	ShouldShowRAP = function(self, p, p2: string)
		if localPlayer:GetAttribute("HoverInfoDebugEnabled") then
			return true
		end

		if v4[p] and table.find(v4[p], p2) then
			return false
		end

		local v7 = v5[p]
		return p2 ~= v7 and (typeof(v7) ~= "table" or not table.find(v7, p2))
	end,
	GetFilteredItemKey = function(self, p, p2)
		return client:ItemToKey(p, p2, v6)
	end,
	GetItemRAPAsync = function(object, p, p2: string)
		local uUIDToKey = client:UUIDToKey(p, p2, v6)

		if uUIDToKey then
			return object:GetRAPAsync(p, uUIDToKey, true)
		end
	end
}
local v7 = {}

function RAPController:FastGetRAPAsync(p, p2, p3: string)
	if not self._enabled then
		return
	end

	local v8 = v.Client:WaitReplion("ItemRAP")

	if not (v8 and self:ShouldShowRAP(p, p2.Name)) then
		return
	end

	local v9 = v8:Get({ "Items", p, p3 })

	if v9 then
		local v10 = v8:Get({ "LastUpdate", p, p3 })

		if not v10 or workspace:GetServerTimeNow() - v10 < 300 then
			return v9
		end
	end

	while v7[p3] do
		task.wait()
	end

	local v10 = v8:Get({ "Items", p, p3 })

	if v10 then
		return v10
	end

	v7[p3] = true
	local v11, v12, v13 = xpcall(function()
		return v2:Invoke("RequestItemRAP", p, p3)
	end, warn)
	v7[p3] = nil

	if v11 and v12 then
		return v13
	end
end

function RAPController:GetRAPAsync(p, p2: string, flag: boolean?)
	if not self._enabled then
		return
	end

	local keyToItem = client:KeyToItem(p2)

	if not flag then
		p2 = client:ItemToKey(p, keyToItem, v6)
	end

	if self:ShouldShowRAP(p, keyToItem.Name) then
		return self:FastGetRAPAsync(p, keyToItem, p2)
	end
end

function RAPController:FastGetRAP(p, p2, p3: string)
	local replion = v.Client:GetReplion("ItemRAP")

	if not replion then
		return
	end

	if self:ShouldShowRAP(p, p2.Name) then
		return (replion:Get({ "Items", p, p3 }))
	end
end

function RAPController:GetRAP(p, filteredItemKey: string, flag: boolean?)
	local keyToItem = client:KeyToItem(filteredItemKey)

	if not flag then
		filteredItemKey = self:GetFilteredItemKey(p, keyToItem)
	end

	return self:FastGetRAP(p, keyToItem, filteredItemKey)
end

function RAPController:GetItemRAP(p, p2: string)
	local uUIDToKey = client:UUIDToKey(p, p2, v6)

	if uUIDToKey then
		return self:GetRAP(p, uUIDToKey, true)
	end
end

function RAPController.OnRAPUpdated(_, _, p: string, callback)
	local v8 = v.Client:WaitReplion("ItemRAP")

	if v8 then
		return v8:OnDescendantChange({ "Items" }, function(_, p2, p3)
			if typeof(p2) == "table" and typeof(p3) == "table" and p2[p] ~= p3[p] then
				callback(p2[p], p3[p])
			end
		end)
	end
end

function RAPController:Start()
	local v8 = v.Client:WaitReplion("ItemRAP")

	if not v8 then
		return
	end

	local v9 = v.Client:WaitReplion("Data")

	if not v9 then
		return
	end

	local function updateEnabled()
		self._enabled = v3:GetKey("RAPServiceEnabled") == true and v8:Get("Enabled") == true and v9:GetExpect("TotalStats.Wins") >= 1
	end

	v3.DataUpdatedEvent:Connect(updateEnabled)
	v8:OnChange("Enabled", updateEnabled)
	local enabled

	if v3:GetKey("RAPServiceEnabled") == true and v8:Get("Enabled") == true then
		enabled = v9:GetExpect("TotalStats.Wins") >= 1
	else
		enabled = false
	end

	self._enabled = enabled
end

return RAPController