local BakerSprout = {}
BakerSprout.Name = "Salted Caramel"
BakerSprout.Cost = 600
BakerSprout.DandyStore = true

function BakerSprout.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and not part:HasTag("DontChangeTexture") then
			part.TextureID = "rbxassetid://136555522228132"
		elseif part:IsA("MeshPart") and part:HasTag("DontChangeTexture") then
			print("Skipping texture change for part with DontChangeTexture tag:", part.Name, part:GetFullName())
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://120705047569413"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://136555522228132"
	blinkTexture.Texture = "rbxassetid://123999870270631"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local v = {
		["Sprout_rig_v002:Head"] = "Sprout_rig_v002:Head_geo",
		["Sprout_rig_v002:Torso"] = "Sprout_rig_v002:Torso_geo",
		["Sprout_rig_v002:LeftArm"] = "Sprout_rig_v002:LeftArm",
		["Sprout_rig_v002:RightArm"] = "Sprout_rig_v002:RightArm",
		["Sprout_rig_v002:LeftLeg"] = "Sprout_rig_v002:LeftLeg",
		["Sprout_rig_v002:RightLeg"] = "Sprout_rig_v002:RightLeg",
		Head = "Sprout_rig_v002:Head_geo",
		Torso = "Sprout_rig_v002:Torso_geo",
		LeftArm = "Sprout_rig_v002:LeftArm",
		RightArm = "Sprout_rig_v002:RightArm",
		LeftLeg = "Sprout_rig_v002:LeftLeg",
		RightLeg = "Sprout_rig_v002:RightLeg",
		Charm_Savory = "Sprout_rig_v002:Charm_Savory",
		Charm = "Sprout_rig_v002:Charm_Savory",
		CharmPart = "Sprout_rig_v002:Charm_Savory",
		Hat = "Sprout_rig_v002:Head_geo",
		Apron = "Sprout_rig_v002:Torso_geo",
		BakingAccessory = "Sprout_rig_v002:Torso_geo",
		Gloves = "Sprout_rig_v002:RightArm",
		LeftGlove = "Sprout_rig_v002:LeftArm",
		RightGlove = "Sprout_rig_v002:RightArm"
	}

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("MeshPart") or part:HasTag("DontChangeTexture") then
			continue
		end

		if not (part.Name:find("Sprout_rig_v002:") or part.Name == "Head" or part.Name == "Torso" or part.Name:find("Arm") or part.Name:find("Leg")) then
			continue
		end

		part.Transparency = 1
	end

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local v2 = v[part.Name] or part.Name
		local child = folder:FindFirstChild(v2)

		if not child and part.Name:find("Sprout_rig_v002:") then
			child = folder:FindFirstChild("Sprout_rig_v002:" .. part.Name:gsub("Sprout_rig_v002:", ""))
		end

		local v3 = child or folder:FindFirstChild(v2, true)

		if v3 then
			if not v3:HasTag("DontChangeTexture") then
				local weld = Instance.new("Weld")
				part.Parent = v3
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = v3
				part.Anchored = false
			end
		else
			warn("Target part not found for: " .. part.Name .. ", skipping...")
		end
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function BakerSprout.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(204, 153, 102)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 102, 51)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 153))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(204, 153, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 229, 204))
		})
	end

	local function chase()
		local position = clone.Position
		Movement.parabola(clone, position, p2, 20, 25, 0.5)
	end

	local position = clone.Position
	Movement.parabola(clone, position, p2, 20, 25, 0.5)

	if clone then
		clone.SmokePart.Enabled = false
		clone.Transparency = 1
		clone.HeartPart:Emit(10)

		if clone:FindFirstChild("Eat") then
			clone.Eat:Play()
		end
	end
end

return BakerSprout