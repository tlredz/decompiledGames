local ChocoBerry = {}
ChocoBerry.Name = "ChocoBerry"
ChocoBerry.Cost = 600
ChocoBerry.DandyStore = true

function ChocoBerry.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and not part:HasTag("DontChangeTexture") then
			part.TextureID = "rbxassetid://80785358680340"
		elseif part:IsA("MeshPart") and part:HasTag("DontChangeTexture") then
			print("Skipping texture change for part with DontChangeTexture tag:", part.Name, part:GetFullName())
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://107771852734095"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://80785358680340"
	blinkTexture.Texture = "rbxassetid://114455104394566"
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
		Hat = "Sprout_rig_v002:Head_geo",
		Cap = "Sprout_rig_v002:Head_geo",
		Berry = "Sprout_rig_v002:Head_geo",
		BerryHat = "Sprout_rig_v002:Head_geo",
		ChocoBerryHat = "Sprout_rig_v002:Head_geo",
		ChocolateDrip = "Sprout_rig_v002:Head_geo",
		ChocolateDrip1 = "Sprout_rig_v002:Head_geo",
		ChocolateDrip2 = "Sprout_rig_v002:Torso_geo",
		BerryAccessory = "Sprout_rig_v002:Head_geo",
		Strawberry = "Sprout_rig_v002:Head_geo",
		ChocolateChip = "Sprout_rig_v002:Torso_geo",
		ChocolateBar = "Sprout_rig_v002:RightArm",
		Accessory = "Sprout_rig_v002:Torso_geo",
		BackAccessory = "Sprout_rig_v002:Torso_geo",
		ArmAccessory = "Sprout_rig_v002:RightArm",
		LegAccessory = "Sprout_rig_v002:RightLeg",
		Charm_Savory = "Sprout_rig_v002:Charm_Savory"
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

	if folder:FindFirstChild("Animations") and folder:FindFirstChild("Animations"):FindFirstChild("Decode") then
		local decode = folder:FindFirstChild("Animations"):FindFirstChild("Decode")
		decode.AnimationId = "rbxassetid://83606906784741"
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function ChocoBerry.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(92, 51, 23)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 51, 23)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 102, 153)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 90, 43))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 51, 23)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 153, 204)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 114, 66))
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

return ChocoBerry