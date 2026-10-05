local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HalloweenAstro = {}
HalloweenAstro.Name = "Scarlet Night"
HalloweenAstro.TowerName = "Astro"
HalloweenAstro.Description = "No description yet"
HalloweenAstro.Mastery = false
HalloweenAstro.Cost = 600
HalloweenAstro.Halloween = true
HalloweenAstro.HolidaySkin = true
HalloweenAstro.HolidayYear = 2025
HalloweenAstro.OverwriteAnimations = {
	Decode = "rbxassetid://82600544001248",
	Idle = "rbxassetid://112602905752015",
	Quirk = "rbxassetid://82767619921654",
	Run = "rbxassetid://75856022532736",
	Walk = "rbxassetid://99830561123237"
}
HalloweenAstro.FaceTextures = {
	Blink = "rbxassetid://78390931262716",
	Hurt = "rbxassetid://121181308088501",
	Normal = "rbxassetid://122029372950698"
}
HalloweenAstro.USE_SKIN_MODEL = true

function HalloweenAstro.ApplySkin(p, p2)
	if p.HumanoidRootPart:FindFirstChild("ToonLight") then
		p.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(200, 50, 50)
	end

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
			Color3.fromRGB(255, 0, 0)
		)
		moveParticleOver(
			"RootPart.root\\.x.spine_01\\.x.StarSmall.Attachment",
			"RootPart.root\\.x.spine_01\\.x.StarSmall",
			Color3.fromRGB(255, 0, 0)
		)
	end)
end

function HalloweenAstro.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(255, 87, 87)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return HalloweenAstro