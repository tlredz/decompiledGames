local SweetRoll = {}
SweetRoll.Name = "Sweet Roll"
SweetRoll.TowerName = "Cosmo"
SweetRoll.Description = "No description yet"
SweetRoll.Mastery = false
SweetRoll.Cost = 600
SweetRoll.Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0)
SweetRoll.Christmas = true
SweetRoll.HolidaySkin = true

function SweetRoll.ApplySkin(instance)
	local config = instance:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://90489343727112"
	hurtTexture.Texture = "rbxassetid://104169958445540"
	normalTexture.Texture = "rbxassetid://82923875987576"
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	instance.Cosmo["root.x"]:Destroy()
	local rootx = clone.RootPart["root.x"]
	rootx.Parent = instance.Cosmo
	print(rootx.Parent)
	local animations = instance:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = instance:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function SweetRoll.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(174, 227, 255),
		Color_2 = Color3.fromRGB(241, 164, 255),
		Color_3 = Color3.fromRGB(174, 254, 255),
		Color_4 = Color3.fromRGB(233, 202, 255)
	}

	if clone:IsA("BasePart") then
		clone.Color = v.Color_1
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_1),
			ColorSequenceKeypoint.new(1, v.Color_3)
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_2),
			ColorSequenceKeypoint.new(1, v.Color_4)
		})
	end

	if clone:FindFirstChild("HeartPart") then
		clone.HeartPart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_1),
			ColorSequenceKeypoint.new(1, v.Color_3)
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

return SweetRoll