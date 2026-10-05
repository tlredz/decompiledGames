local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Items }

function FindEmptySlot(items)
	for _, item in pairs(items) do
		if #workspace:GetPartsInPart(item, overlapParams) == 0 then
			return item
		end
	end
end

function StorageFolderAdded(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	local parts = {}

	for _, part in pairs(instance:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name:sub(1, 4) == "Slot") then
			continue
		end

		table.insert(parts, part)
	end

	table.sort(parts, function(a, b)
		return tonumber(a.Name:sub(5)) < tonumber(b.Name:sub(5))
	end)
	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent:GetAttribute("Interaction") or parent:GetAttribute("AutoStacked") then
			return
		end

		if instance:GetAttribute("StackWhitelist") and not instance:GetAttribute("StackItem_" .. parent.Name) then
			return
		end

		if instance:GetAttribute("OnlyFood") and not parent:GetAttribute("RestoreHunger") or parent:GetAttribute("PlayerBody") then
			return
		end

		if Client.InteractionHandler.GetDraggingItem() == parent or time() - (parent:GetAttribute("LastDropTime") or 0) < 1 and parent:GetAttribute("LastOwner") == localPlayer.UserId then
			parent:SetAttribute("AutoStacked", true)
			local v = FindEmptySlot(parts)

			if v then
				local cframe = CFrame.new()

				if parent.PrimaryPart:FindFirstChild("StackingOffset") then
					cframe = parent.PrimaryPart.StackingOffset.CFrame
				end

				parent:PivotTo(v.CFrame * cframe)
				parent.PrimaryPart.AssemblyLinearVelocity = createVector(0, 10, 0)
				parent.PrimaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				Client.Events.StopDraggingItem:Fire(0.5)

				if instance.Parent and instance.Parent.Name == "Wood Rain Storage" then
					Client.Events.RequestRainStorageDry:FireServer(parent, instance.Parent)
				end
			end
		end
	end)
	touchZone.TouchEnded:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent == nil or parent:GetAttribute("Interaction") == nil then
			return
		end

		parent:SetAttribute("AutoStacked", nil)
	end)
end

Client.Utility.ForAllTagged("AutoStack", StorageFolderAdded)
return {}