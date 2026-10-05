local AnimalFeedingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function CanFeed(instance, p)
	for i = 1, 3 do
		local attribute = instance:GetAttribute("Food" .. i .. "Type")

		if attribute and (attribute == p.Name or "Cooked " .. attribute == p.Name) and instance:GetAttribute("Food" .. i .. "Done") == nil and instance:GetAttribute("Food" .. i .. "DoneLocal") == nil then
			return i
		end
	end
end

function IsFoodOption(instance, p)
	for i = 1, 3 do
		local attribute = instance:GetAttribute("Food" .. i .. "Type") or ""

		if attribute == p.Name or "Cooked " .. attribute == p.Name then
			return true
		end
	end
end

function AttemptFeedAnimal(instance, instance2)
	if instance2:GetAttribute("FoodRot") then
		return
	end

	if instance:GetAttribute("Tamed") then
		if IsFoodOption(instance, instance2) then
			local humanoid = instance:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health < humanoid.MaxHealth then
				instance2.Parent = game.ReplicatedStorage
				Client.Events.RequestFeedHealPet:FireServer(instance, instance2)
			end
		end
	else
		if instance:GetAttribute("PlayerFeeding") ~= localPlayer.UserId then
			return
		end

		local v2 = CanFeed(instance, instance2)

		if not v2 then
			return
		end

		instance2.Parent = game.ReplicatedStorage
		instance:SetAttribute("Food" .. v2 .. "DoneLocal", true)
		task.delay(2, function()
			instance:SetAttribute("Food" .. v2 .. "DoneLocal", nil)
		end)
		local v3 = Client.Events.RequestTame_Feed:InvokeServer(instance, instance2, v2)

		if not (v3 and v3.Success) then
			instance2.Parent = workspace.Items
		end
	end
end

function FeedAnimalAdded(parent)
	if v[parent] then
		v[parent]:Destroy()
		v[parent] = nil
	end

	local boundingBox, v2 = parent:GetBoundingBox()
	local part = Instance.new("Part")
	v[parent] = part
	part.CFrame = boundingBox
	part.Size = v2 * 1.2
	part.CanCollide = false
	part.Massless = true
	part.Transparency = 1
	part.CollisionGroup = "Items"
	part.Color = Color3.fromRGB(255, 0, 0)
	part.CanQuery = false
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = part
	weldConstraint.Part0 = part
	weldConstraint.Part1 = parent.PrimaryPart
	part.Parent = parent
	part.Touched:Connect(function(otherPart)
		local parent2 = otherPart.Parent

		if parent2 and (parent2:GetAttribute("Interaction") == "Item" or parent2:GetAttribute("Interaction") == "Tool") and (parent2:GetAttribute("Owner") == localPlayer.UserId or parent2:GetAttribute("LastOwner") == localPlayer.UserId) and parent2.Parent == workspace.Items then
			AttemptFeedAnimal(parent, parent2)
		end
	end)
end

function FeedAnimalRemoved(p)
	if v[p] then
		v[p]:Destroy()
		v[p] = nil
	end
end

function AnimalFeedingClient.Init()
	Client.Utility.ForAllTagged("CanFeed_" .. localPlayer.UserId, FeedAnimalAdded, FeedAnimalRemoved)
end

return AnimalFeedingClient