local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return function(p: string, childName: string, p2: string, p3: string)
	return function(_, _)
		local data = Utility.GetData(Players.LocalPlayer)
		local v = Quests.Holder[p]

		if data == nil or v == nil then
			return p3
		end

		local child = data.Quests.Holder:FindFirstChild(v.QuestInstance.Name)

		if child == nil then
			return p3
		end

		local v2

		if v.TaskSpecs ~= nil then
			v2 = v.TaskSpecs[childName] or nil
		end

		local function held(p4: string)
			local heldItem = Utility.HeldItem(data, p4)
			local amount

			if heldItem ~= nil then
				amount = heldItem:FindFirstChild("Amount") or nil
			end

			if heldItem == nil then
				return 0
			end

			if amount == nil then
				return 1
			end

			return amount.Value
		end

		if v2 == nil or v2.RequiredItem == nil then
			if v2 ~= nil and type(v2.RequiredItems) == "table" then
				local total = 0

				for _, requiredItem in v2.RequiredItems do
					local heldItem = Utility.HeldItem(data, requiredItem)
					local amount

					if heldItem ~= nil then
						amount = heldItem:FindFirstChild("Amount") or nil
					end

					total += heldItem == nil and 0 or amount == nil and 1 or amount.Value
				end

				if total <= 0 then
					return p3
				end
			end
		else
			local child2 = child.Tasks:FindFirstChild(childName)
			local count = v2.Count or child2 == nil and 1 or child2.Max.Value or 1
			local requiredItem = v2.RequiredItem
			local heldItem = Utility.HeldItem(data, requiredItem)
			local amount

			if heldItem ~= nil then
				amount = heldItem:FindFirstChild("Amount") or nil
			end

			if (heldItem == nil and 0 or amount == nil and 1 or amount.Value) < count then
				return p3
			end
		end

		SignalEvent.ToServer("QuestProgress", p, childName)
		return p2
	end
end