local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AstroStar = {}
AstroStar.Name = "Starry Night"
AstroStar.Cost = 600
AstroStar.DandyStore = true
AstroStar.OverwriteAnimations = {
	Walk = "rbxassetid://99830561123237",
	Run = "rbxassetid://75856022532736",
	Quirk = "rbxassetid://82767619921654",
	Idle = "rbxassetid://112602905752015",
	Decode = "rbxassetid://82600544001248"
}
AstroStar.FaceTextures = {
	Blink = "rbxassetid://83716440516398",
	Hurt = "rbxassetid://90405702447868",
	Normal = "rbxassetid://71647795710115"
}
AstroStar.USE_SKIN_MODEL = true

function AstroStar.ApplySkin(folder, p)
	local function splitPath(value: string)
		local result = {}

		for k in value:gsub("\\%.", "\1"):gmatch("[^.]+") do
			table.insert(result, (k:gsub("\1", ".")))
		end

		return result
	end

	local function waitFor(child, p2: string, p3: number)
		for _, childName in ipairs((splitPath(p2))) do
			if not child then
				return nil
			end

			child = child:WaitForChild(childName, p3)
		end

		return child
	end

	task.spawn(function()
		local function moveParticleOver(p2, p3, color)
			local v = waitFor(p, p2, 5)
			local parent = waitFor(folder, p3, 5)

			if v then
				local clone = v:Clone()
				local particleEmitter = clone:WaitForChild("ParticleEmitter", 5)

				if particleEmitter then
					particleEmitter.Color = ColorSequence.new(color)
					clone.Parent = parent
				else
					clone:Destroy()
				end
			end
		end

		moveParticleOver(
			"RootPart.root\\.x.spine_01\\.x.StarBig.Attachment",
			"RootPart.root\\.x.spine_01\\.x.StarBig",
			Color3.fromRGB(255, 207, 123)
		)
		moveParticleOver(
			"RootPart.root\\.x.spine_01\\.x.StarSmall.Attachment",
			"RootPart.root\\.x.spine_01\\.x.StarSmall",
			Color3.fromRGB(255, 207, 123)
		)
	end)

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				descendant.Color = Color3.fromRGB(255, 207, 123)
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 207, 123)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 207, 123))
			})
		end
	end

	if folder.HumanoidRootPart:FindFirstChild("ToonLight") then
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(255, 207, 123)
	end
end

function AstroStar.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.AstroPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	clone.Color = Color3.fromRGB(255, 207, 123)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return AstroStar