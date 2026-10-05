local DessertfulScientist = {}
DessertfulScientist.Name = "Dessertful Scientist"
DessertfulScientist.TowerName = "Cosmo"
DessertfulScientist.Description = "No description yet"
DessertfulScientist.Mastery = false
DessertfulScientist.Cost = 1200
DessertfulScientist.Requirement1 = { "Halloween2025", 1200 }
DessertfulScientist.Requirement2 = { "Coin", 1200 }
DessertfulScientist.Halloween = true
DessertfulScientist.HolidaySkin = true

function DessertfulScientist.ApplySkin(parent)
	local config = parent:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://80396267384288"
	hurtTexture.Texture = "rbxassetid://119686772105743"
	normalTexture.Texture = "rbxassetid://134448086348191"
	local clone = game.ServerStorage.SkinModelStorage[parent.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	parent.Cosmo["root.x"]:Destroy()
	local rootx = clone.RootPart["root.x"]
	rootx.Parent = parent.Cosmo
	rootx.Parent.Name = "RootPart"
	local animations = parent:WaitForChild("Animations")

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
		local child = parent:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local yellowelectricity = clone:WaitForChild("Yellow electricity")
	yellowelectricity.Parent = parent
	local rigidConstraint = yellowelectricity:WaitForChild("RigidConstraint")
	rigidConstraint.Attachment0 = yellowelectricity:WaitForChild("Attachment")
	rigidConstraint.Attachment1 = parent:WaitForChild("RootPart"):WaitForChild("root.x"):WaitForChild("spine_01.x")
	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function DessertfulScientist.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
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

return DessertfulScientist