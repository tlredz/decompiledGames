local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BerryBeast = {}
BerryBeast.Name = "Berry Beast"
BerryBeast.TowerName = "Sprout"
BerryBeast.Description = "No description yet"
BerryBeast.Mastery = false
BerryBeast.Cost = 1200
BerryBeast.Halloween = true
BerryBeast.HolidaySkin = true

function BerryBeast.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and not part:HasTag("DontChangeTexture") then
			part.TextureID = "rbxassetid://136555522228132"
		elseif part:IsA("MeshPart") and part:HasTag("DontChangeTexture") then
			print("Skipping texture change for part with DontChangeTexture tag:", part.Name, part:GetFullName())
		end
	end

	local config = folder:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://95674360488410"
	hurtTexture.Texture = "rbxassetid://115055815651949"
	normalTexture.Texture = "rbxassetid://78402540625790"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	folder.RootPart["Sprout_rig_v002:root"]:Destroy()
	clone.RootPart.root.Parent = folder.RootPart

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("MeshPart") or part:HasTag("DontChangeTexture") then
			continue
		end

		if not (part.Name:find("Sprout_rig_v002:") or part.Name == "Head" or part.Name == "Torso" or part.Name:find("Arm") or part.Name:find("Leg")) then
			continue
		end

		part.Transparency = 1
	end

	local animations = folder:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {
		Charm_Savory = "Sprout_rig_v002:Charm_Savory",
		Head = "Sprout_rig_v002:Head_geo",
		LeftArm = "Sprout_rig_v002:LeftArm",
		LeftLeg = "Sprout_rig_v002:LeftLeg",
		RightArm = "Sprout_rig_v002:RightArm",
		RightLeg = "Sprout_rig_v002:RightLeg",
		Torso = "Sprout_rig_v002:Torso_geo",
		["Yellow electricity"] = "Sprout_rig_v002:Torso_geo"
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = folder:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local yellowelectricity = clone:WaitForChild("Yellow electricity")
	yellowelectricity.Parent = folder
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(clone, 10)
end

function BerryBeast.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

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

return BerryBeast