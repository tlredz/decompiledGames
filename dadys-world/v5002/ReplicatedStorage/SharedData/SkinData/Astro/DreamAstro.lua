local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local DreamAstro = {}
DreamAstro.Name = "Star-Time Astro"
DreamAstro.OverwriteAnimations = {
	Decode = "rbxassetid://71839165003910",
	Idle = "rbxassetid://133381049380152",
	Quirk = "rbxassetid://116310151013976",
	Run = "rbxassetid://74648930855620",
	Walk = "rbxassetid://126952655705285"
}
DreamAstro.FaceTextures = {
	Blink = "rbxassetid://139702229637464",
	Hurt = "rbxassetid://117686758561110",
	Normal = "rbxassetid://80976639934716"
}
DreamAstro.USE_SKIN_MODEL = true

function DreamAstro.ApplySkin(folder, p)
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
			Color3.fromRGB(157, 141, 83)
		)
		moveParticleOver(
			"RootPart.root\\.x.spine_01\\.x.StarSmall.Attachment",
			"RootPart.root\\.x.spine_01\\.x.StarSmall",
			Color3.fromRGB(98, 155, 179)
		)
	end)

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				if descendant.Name == "MagicR" then
					descendant.Color = Color3.fromRGB(98, 155, 179)
				elseif descendant.Name == "MagicL" then
					descendant.Color = Color3.fromRGB(157, 141, 83)
				end
			end
		elseif descendant:IsA("ParticleEmitter") then
			if descendant.Parent.Name == "MagicR" then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 155, 179)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(98, 155, 179))
				})
			elseif descendant.Parent.Name == "MagicL" then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(157, 141, 83)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(157, 141, 83))
				})
			end
		end
	end

	if folder.HumanoidRootPart:FindFirstChild("ToonLight") then
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(117, 160, 207)
	end
end

function DreamAstro.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("DreamAstroPoof"):Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	local tweenInfo2 = TweenInfo.new(0.33, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	task.spawn(function()
		task.wait(0.1)
		local tween = TweenService:Create(clone, tweenInfo2, {
			Color = Color3.fromRGB(98, 155, 179)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, tweenInfo2, {
			Color = Color3.fromRGB(157, 141, 83)
		})
		tween2:Play()
		tween2.Completed:Wait()
	end)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return DreamAstro