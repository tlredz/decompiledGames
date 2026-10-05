local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Shared.UntradableItems)
require3(ReplicatedStorage2.Shared.Inventory.Internal.DefaultItems)
require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local _ = Players.LocalPlayer
local v3 = nil
local ExistCounterController = {}
ExistCounterController._enabled = true

function ExistCounterController.IsEnabled(p)
	return p._enabled
end

function ExistCounterController:Get(p, p2: string, _: boolean?, value: string?)
	local v4 = value == nil and v3 or v.Client:WaitReplion(value or "ClientExistCount")

	if not v4 then
		return
	end

	local keyToItem = client:KeyToItem(p2)
	return (v4:Get({
		"Items",
		p == "Sword" and keyToItem.Finisher and "Finisher" or p == "Sword" and keyToItem.Accessory and "SwordAccessory" or p,
		keyToItem.Name
	}))
end

function ExistCounterController:GetItem(p, p2: string, p3: string?)
	local item = client:GetItem(p, p2)

	if item then
		return self:Get(p, client:ItemToKey(p, item), true, p3)
	end
end

function ExistCounterController.OnUpdated(_, p, p2: string, callback, value: string?)
	local v4 = value == nil and v3 or v.Client:WaitReplion(value or "ClientExistCount")
	local keyToItem = client:KeyToItem(p2)
	return v4:OnChange(
		{
			"Items",
			p == "Sword" and keyToItem.Finisher and "Finisher" or p == "Sword" and keyToItem.Accessory and "SwordAccessory" or p
		},
		function(p3, p4)
			if not p3 or not p4 or typeof(p3) == "table" and typeof(p4) == "table" and p3[keyToItem.Name] ~= p4[keyToItem.Name] then
				local v6

				if p3 then
					v6 = p3[keyToItem.Name]
				end

				local v7

				if p4 then
					v7 = p4[keyToItem.Name]
				end

				callback(v6, v7)
			end
		end
	)
end

function ExistCounterController.Start(p)
	v3 = v.Client:WaitReplion("ClientExistCount")

	if not (v3 and v.Client:WaitReplion("Data")) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateEnabled()
		p._enabled = v3:Get("Enabled") == true
	end

	v2.DataUpdatedEvent:Connect(updateEnabled)
	v3:OnChange("Enabled", updateEnabled)
	updateEnabled() -- equivalent call inferred; original call site unknown
end

return ExistCounterController