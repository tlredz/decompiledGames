local createVector = vector.create
local DreamAstro = {
	Name = "Star-Time Astro"
}
local Debris = game:GetService("Debris")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

function DreamAstro.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				if descendant.Name == "MagicR" then
					descendant.Color = Color3.fromRGB(98, 155, 179)
				elseif descendant.Name == "MagicL" then
					descendant.Color = Color3.fromRGB(157, 141, 83)
				end
			else
				descendant.TextureID = "rbxassetid://80976639934716"
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

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	hurtTexture.Texture = "rbxassetid://117686758561110"
	blinkTexture.Texture = "rbxassetid://139702229637464"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://80976639934716"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local v = {
		Hat = "Head",
		Hat_Geo = "HatGeo",
		Cap = "Head",
		Helmet = "Head",
		Hair = "Head",
		Crown = "Head",
		Headband = "Head",
		Headwear = "Head"
	}
	local v2 = {
		Hat = true,
		Hat_Geo = true,
		Cap = true,
		Helmet = true,
		Hair = true,
		Crown = true,
		Headband = true,
		Headwear = true
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local child = folder:WaitForChild(v[part.Name] or part.Name)
		local weld = Instance.new("Weld")
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false

		if not v2[part.Name] then
			child.Transparency = 1
		end
	end

	folder.RootPart["root.x"]:Destroy()
	clone.RootPart["root.x"].Parent = folder.RootPart
	folder.Animate.Enabled = false
	folder.Animate.Enabled = true
	local children = clone.Animations:GetChildren()

	for _, v3 in pairs(children) do
		folder.Animations[tostring(v3)].AnimationId = v3.AnimationId
	end

	folder.Animate.Enabled = false
	folder.Animate.Enabled = true

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