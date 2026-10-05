local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local v = {}

local function SetupRoot(instance)
	if not instance:FindFirstAncestor("RapidDogBlade") or instance:GetAttribute("DogSlayerSmartBoneReady") then
		return
	end

	CollectionService:RemoveTag(instance, "SmartBone")
	instance:SetAttribute("Roots", "Center")
	instance:SetAttribute("Force", createVector(0, 45, 0))
	instance:SetAttribute("WindInfluence", 0.35)
	instance:SetAttribute("AnchorsRotate", true)
	instance:SetAttribute("Damping", 0.38)
	instance:SetAttribute("Inertia", 0.35)
	instance:SetAttribute("Stiffness", 0.8)
	instance:SetAttribute("Elasticity", 0.18)
	instance:SetAttribute("ActivationDistance", 600)
	instance:SetAttribute("ThrottleDistance", 200)
	instance:SetAttribute("DogSlayerSmartBoneReady", true)
	CollectionService:AddTag(instance, "SmartBone")
end

local function SetupDogSlayer(folder)
	local equippedWeapon = folder:FindFirstChild("EquippedWeapon")

	if equippedWeapon then
		for _, part in ipairs(equippedWeapon:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "RootPart" then
				SetupRoot(part)
			end
		end
	end

	local unequippedWeapon = folder:FindFirstChild("UnequippedWeapon")

	if unequippedWeapon then
		for _, part in ipairs(unequippedWeapon:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "RootPart" then
				SetupRoot(part)
			end
		end
	end

	for _, model in ipairs(folder:GetDescendants()) do
		if not (model:IsA("Model") and model.Name == "RapidDogBlade") then
			continue
		end

		local rootPart = model:FindFirstChild("RootPart", true)

		if rootPart and rootPart:IsA("BasePart") then
			SetupRoot(rootPart)
		end
	end
end

return function(player)
	local character = player.Character

	if not character then
		return
	end

	if player.SwordName == "RapidDogBlade" then
		SetupDogSlayer(character)
	end

	if v[character] then
		return
	end

	v[character] = true
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Model") and (descendant.Name == "EquippedWeapon" or descendant.Name == "UnequippedWeapon" or descendant.Name == "RapidDogBlade") then
			task.defer(function()
				if descendant.Parent then
					SetupDogSlayer(character)
				end
			end)
		elseif descendant:IsA("BasePart") and descendant.Name == "RootPart" then
			task.defer(function()
				if descendant.Parent then
					SetupDogSlayer(character)
				end
			end)
		end
	end)
	character.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			v[character] = nil
		end
	end)
end