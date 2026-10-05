local SnowtimeCosmo = {}
SnowtimeCosmo.Name = "Snow-Time Cosmo"

function SnowtimeCosmo.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://92140477601284"
		end
	end

	local config = folder:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://113949043102321"
	hurtTexture.Texture = "rbxassetid://74370278760373"
	normalTexture.Texture = "rbxassetid://92140477601284"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local v = {}

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

	local snowtimeTrail = clone.PrimaryPart:WaitForChild("SnowtimeTrail")
	snowtimeTrail.Parent = folder.PrimaryPart

	for _, emitter in pairs(clone.HumanoidRootPart:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name ~= "ParticleThing" then
			emitter.Parent = folder.HumanoidRootPart
		end
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function SnowtimeCosmo.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(210, 121, 255),
		Color_2 = Color3.fromRGB(193, 69, 255),
		Color_3 = Color3.fromRGB(248, 153, 255),
		Color_4 = Color3.fromRGB(255, 210, 251)
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

return SnowtimeCosmo