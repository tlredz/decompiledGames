local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("InfinityTrial", function(instance)
	if not Replion.Client:WaitReplion("Inventory") then
		return nil
	end

	local endTime = instance:GetAttribute("EndTime")

	local function updateOwned()
		if #client:FindItems("Ability", "Infinity", function(p)
			return not p.TradeLock or p.TradeLock.Type ~= "Trial"
		end) > 0 then
			instance:SetAttribute("EndTime", 0)
		else
			instance:SetAttribute("EndTime", endTime)
		end
	end

	local v = client:OnChange("Ability", updateOwned)
	task.spawn(updateOwned)
	return function()
		if v then
			v:Destroy()
		end
	end
end)