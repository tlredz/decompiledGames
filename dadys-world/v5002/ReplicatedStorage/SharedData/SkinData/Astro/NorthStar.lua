local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local NorthStar = {}
NorthStar.Name = "North Star"
NorthStar.TowerName = "Astro"
NorthStar.Description = "No description yet"
NorthStar.Mastery = false
NorthStar.Cost = 600
NorthStar.Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0)
NorthStar.Christmas = true
NorthStar.HolidaySkin = true
NorthStar.OverwriteAnimations = {
	Run = "rbxassetid://138554016747757",
	Walk = "rbxassetid://73471530078604",
	Idle = "rbxassetid://91433954498003",
	Quirk = "rbxassetid://70731716324426",
	Decode = "rbxassetid://116274873037105",
	Ability = "rbxassetid://70603731952619"
}
NorthStar.FaceTextures = {
	Blink = "rbxassetid://110103961049129",
	Hurt = "rbxassetid://86316420625696",
	Normal = "rbxassetid://106373897802967"
}
NorthStar.USE_SKIN_MODEL = true

function NorthStar.ApplySkin(p, p2)
	local function splitPath(value: string)
		local result = {}

		for k in value:gsub("\\%.", "\1"):gmatch("[^.]+") do
			table.insert(result, (k:gsub("\1", ".")))
		end

		return result
	end

	local function waitFor(child, p3: string, p4: number)
		for _, childName in ipairs((splitPath(p3))) do
			if not child then
				return nil
			end

			child = child:WaitForChild(childName, p4)
		end

		return child
	end

	task.spawn(function()
		local function moveParticleOver(p3, p4, color)
			local v = waitFor(p2, p3, 5)
			local parent = waitFor(p, p4, 5)

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
			Color3.fromRGB(154, 190, 223)
		)
		moveParticleOver(
			"RootPart.root\\.x.spine_01\\.x.StarSmall.Attachment",
			"RootPart.root\\.x.spine_01\\.x.StarSmall",
			Color3.fromRGB(154, 190, 223)
		)
	end)

	if p.HumanoidRootPart:FindFirstChild("ToonLight") then
		p.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(165, 200, 231)
	end
end

function NorthStar.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(165, 200, 231)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return NorthStar