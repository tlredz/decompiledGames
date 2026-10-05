local createVector = vector.create
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local cameraPart = require(game.ReplicatedStorage.Modules.Utils.cameraPart)
local SpringFeverArt = {
	Config = {
		ParticleRate = 15,
		ParticleLifetime = {
			min = 3,
			max = 6
		},
		ParticleSpeed = {
			min = 0.5,
			max = 2
		},
		ParticleTexture = "rbxassetid://6891053759",
		ParticleColors = { Color3.fromRGB(255, 200, 230), Color3.fromRGB(255, 230, 180), Color3.fromRGB(
				220,
				180,
				255
			) },
		BaseBlurSize = 2,
		SpeedBlurThreshold = 20,
		SpeedBlurMax = 60,
		MaxEdgeBlurFar = 0.6,
		MaxEdgeBlurNear = 0.4
	},
	PartReferences = {}
}
local v = {}
local blurEffect = nil
local depthOfFieldEffect = nil
local changedConnection = nil
local v2 = nil
local v3 = nil

function SpringFeverArt.AdjustBlackout()
	game.Lighting.FogColor = Color3.fromRGB(26, 14, 33)
	local floorHaze = SpringFeverArt.PartReferences.floorHaze

	if floorHaze then
		floorHaze:PivotTo(CFrame.new(v2 + createVector(0, 0, 0)))
		floorHaze:Destroy()
		SpringFeverArt.PartReferences.floorHaze = nil
	end

	local ceilingHaze = SpringFeverArt.PartReferences.ceilingHaze

	if ceilingHaze then
		for _, part in pairs(ceilingHaze:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.Color = Color3.fromRGB(131, 4, 135)
			end
		end
	end
end

function SpringFeverArt.CreatePollenEmitter(parent)
	local config = SpringFeverArt.Config
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "SpringFeverParticle"
	particleEmitter.Texture = config.ParticleTexture
	particleEmitter.Rate = config.ParticleRate
	particleEmitter.Lifetime = NumberRange.new(config.ParticleLifetime.min, config.ParticleLifetime.max)
	particleEmitter.Speed = NumberRange.new(config.ParticleSpeed.min, config.ParticleSpeed.max)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.LightEmission = 0.3
	particleEmitter.LightInfluence = 0.8
	particleEmitter.Drag = 2
	particleEmitter.VelocityInheritance = 0.1
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, config.ParticleColors[1]),
		ColorSequenceKeypoint.new(0.5, config.ParticleColors[2]),
		ColorSequenceKeypoint.new(1, config.ParticleColors[3])
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.3, 0.15),
		NumberSequenceKeypoint.new(0.7, 0.12),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.3),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Parent = parent
	return particleEmitter
end

function SpringFeverArt.AttachParticles(instance)
	SpringFeverArt.DetachParticles()
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "SpringFeverAttachment"
	attachment.Position = createVector(0, 5, 0)
	attachment.Parent = humanoidRootPart
	local pollenEmitter = SpringFeverArt.CreatePollenEmitter(attachment)
	table.insert(v, {
		emitter = pollenEmitter,
		attachment = attachment
	})
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "SpringFeverAttachment2"
	attachment2.Position = createVector(3, 3, -2)
	attachment2.Parent = humanoidRootPart
	local pollenEmitter2 = SpringFeverArt.CreatePollenEmitter(attachment2)
	pollenEmitter2.Rate = 10
	table.insert(v, {
		emitter = pollenEmitter2,
		attachment = attachment2
	})
	local screen = SpringFeverArt.PartReferences.screen

	if not screen then
		screen = game.ReplicatedStorage.Assets.pollenStorm_screen:Clone()
		screen.Parent = workspace
	end

	cameraPart.Attach(screen, CFrame.new(0, 0, -13))
end

function SpringFeverArt.DetachParticles()
	for _, v4 in ipairs(v) do
		if v4.emitter and v4.emitter.Parent then
			v4.emitter:Destroy()
		end

		if v4.attachment and v4.attachment.Parent then
			v4.attachment:Destroy()
		end
	end

	v = {}
	cameraPart.Detach()
end

function createCeilingHaze(folder)
	local parent = folder:FindFirstChild("particles")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "particles"
		parent.Parent = folder
	end

	local parts = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = 1
		table.insert(parts, part)
	end

	local boundingBox, v5 = folder:GetBoundingBox()

	local function randomPointInBounds()
		return boundingBox.Position + Vector3.new(
			(math.random() - 0.5) * v5.X,
			(math.random() - 0.5) * v5.Y,
			(math.random() - 0.5) * v5.Z
		)
	end

	local function spawnParticle()
		if #parts == 0 then
			return
		end

		local v6 = parts[math.random(1, #parts)]
		local clone = v6:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.Transparency = 1
		clone.CFrame = CFrame.new((randomPointInBounds())) * CFrame.new(0, math.random(-5, 5), 0)
		clone.Orientation = v6.Orientation
		clone.Parent = parent
		local tween = TweenService:Create(clone, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
			Transparency = 0.9
		})
		local tween2 = TweenService:Create(clone, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
			Transparency = 1
		})
		tween:Play()
		tween.Completed:Connect(function()
			tween2:Play()
		end)
		task.delay(5, function()
			if clone then
				clone:Destroy()
			end
		end)
	end

	task.spawn(function()
		while folder.Parent == workspace do
			spawnParticle()
			task.wait(0.4)
		end
	end)
end

function SpringFeverArt.CreatePostProcessing()
	local config = SpringFeverArt.Config
	depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
	depthOfFieldEffect.Name = "SpringFeverDoF"
	depthOfFieldEffect.FarIntensity = 0
	depthOfFieldEffect.FocusDistance = 50
	depthOfFieldEffect.InFocusRadius = 100
	depthOfFieldEffect.NearIntensity = 0
	depthOfFieldEffect.Enabled = true
	depthOfFieldEffect.Parent = Lighting
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "SpringFeverBlur"
	blurEffect.Size = config.BaseBlurSize
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
	local model = workspace.CurrentRoom:FindFirstChildWhichIsA("Model")

	if model then
		local descendants = {}
		local descendants2 = {}

		for _, descendant in pairs(model:GetDescendants()) do
			if descendant.Name == "Floor" then
				table.insert(descendants2, descendant)
			elseif descendant.Name == "Ceiling" then
				table.insert(descendants, descendant)
			end
		end

		table.sort(descendants2, function(a, b)
			return a.Position.Y < b.Position.Y
		end)
		table.sort(descendants, function(a, b)
			return a.Position.Y > b.Position.Y
		end)
		local v4 = descendants2[1]
		local v5 = descendants[1]

		if v4 and v5 then
			local v6 = workspace:FindFirstChild("TallestCeilingMarker")
			local v7 = workspace:FindFirstChild("LowestFloorMarker")

			if not v6 then
				v6 = Instance.new("Part")
				v6.Name = "TallestCeilingMarker"
				v6.Parent = workspace
				v6.Anchored = true
				v6.Material = Enum.Material.Neon
				v6.Transparency = 1
				v6.Color = Color3.fromRGB(0, 255, 17)
				v6.Size = createVector(2555, 1, 25555)
			end

			if not v7 then
				v7 = Instance.new("Part")
				v7.Name = "LowestFloorMarker"
				v7.Parent = workspace
				v7.Anchored = true
				v7.Material = Enum.Material.Neon
				v7.Transparency = 1
				v7.Color = Color3.fromRGB(255, 0, 0)
				v7.Size = createVector(2555, 1, 25555)
			end

			v6.Position = v5.Position - Vector3.new(0, v5.Size.Y / 2, 0)
			v7.Position = v4.Position
			v2 = v4.Position + Vector3.new(0, v4.Size.Y / 2, 0)
			v3 = v5.Position - Vector3.new(0, v5.Size.Y / 2, 0)

			if not SpringFeverArt.PartReferences.stormParticles then
				local clone = game.ReplicatedStorage.Assets.pollenStorm_particles:Clone()
				clone.Parent = workspace
				SpringFeverArt.PartReferences.stormParticles = clone
			end

			local floorHaze = SpringFeverArt.PartReferences.floorHaze

			if not floorHaze then
				floorHaze = game.ReplicatedStorage.Assets.pollenStorm_floorHaze:Clone()
				floorHaze.Parent = workspace
				SpringFeverArt.PartReferences.floorHaze = floorHaze
			end

			floorHaze:PivotTo(CFrame.new(v2 + createVector(0, 0, 0)))
			local ceilingHaze = SpringFeverArt.PartReferences.ceilingHaze

			if not ceilingHaze then
				ceilingHaze = game.ReplicatedStorage.Assets.pollenStorm_ceilingHaze:Clone()
				ceilingHaze.Parent = workspace
				SpringFeverArt.PartReferences.ceilingHaze = ceilingHaze
			end

			ceilingHaze:PivotTo(CFrame.new(v3 + createVector(0, -5, 0)))
			createCeilingHaze(ceilingHaze)
			local intro = SpringFeverArt.PartReferences.intro

			if not intro then
				intro = game.ReplicatedStorage.Assets.pollenStorm_intro:Clone()
				intro.Parent = workspace
				SpringFeverArt.PartReferences.intro = intro
			end

			intro.pollenStorm_particles.hiss:Play()
			local v8 = {
				sparkle = 30,
				clouds = 5,
				haze2 = 30
			}

			for _, descendant in pairs(intro:GetDescendants()) do
				if v8[descendant.Name] ~= nil then
					descendant:Emit(v8[descendant.Name])
				end
			end

			if changedConnection then
				changedConnection:Disconnect()
				changedConnection = nil
			end

			changedConnection = workspace.Info.BlackOut.Changed:Connect(function()
				if workspace.Info.BlackOut.Value == true then
					SpringFeverArt.AdjustBlackout()
				end
			end)

			if workspace.Info.BlackOut.Value == true then
				SpringFeverArt.AdjustBlackout()
			end
		end
	end
end

function SpringFeverArt.RemovePostProcessing()
	if depthOfFieldEffect then
		local v4 = depthOfFieldEffect
		depthOfFieldEffect = nil
		TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FarIntensity = 0,
			NearIntensity = 0,
			InFocusRadius = 100
		}):Play()
		task.delay(1.1, function()
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end)
	end

	if blurEffect then
		local v4 = blurEffect
		blurEffect = nil
		TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Size = 0
		}):Play()
		task.delay(1.1, function()
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end)
	end

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	local tallestCeilingMarker = workspace:FindFirstChild("TallestCeilingMarker")

	if tallestCeilingMarker then
		tallestCeilingMarker:Destroy()
	end

	local lowestFloorMarker = workspace:FindFirstChild("LowestFloorMarker")

	if lowestFloorMarker then
		lowestFloorMarker:Destroy()
	end

	for k, partReference in pairs(SpringFeverArt.PartReferences) do
		partReference:Destroy()
		SpringFeverArt.PartReferences[k] = nil
	end
end

function SpringFeverArt.UpdateSpeedBlur(p, _, p2)
	if not depthOfFieldEffect then
		return
	end

	local config = SpringFeverArt.Config
	local v4 = math.clamp((p - config.SpeedBlurThreshold) / (config.SpeedBlurMax - config.SpeedBlurThreshold), 0, 1)
	depthOfFieldEffect.FarIntensity += (v4 * config.MaxEdgeBlurFar - depthOfFieldEffect.FarIntensity) * 0.15
	depthOfFieldEffect.NearIntensity += (v4 * config.MaxEdgeBlurNear - depthOfFieldEffect.NearIntensity) * 0.15
	depthOfFieldEffect.InFocusRadius = 100 - v4 * 70
	depthOfFieldEffect.FocusDistance = v4 * 20 + 10
	local stormParticles = SpringFeverArt.PartReferences.stormParticles

	if stormParticles then
		stormParticles.CFrame = stormParticles.CFrame:Lerp(CFrame.new(p2.Position.X, v2.Y + 0.2, p2.Position.Z), 0.5)
	end
end

function SpringFeverArt.CreateDebuffBillboard(instance)
	if not (instance and instance.Parent) then
		return nil
	end

	local head = instance:FindFirstChild("Head")

	if not head or head:FindFirstChild("SpringFeverDebuffBB") then
		return nil
	end

	local config = SpringFeverArt.Config
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "SpringFeverDebuffBB"
	billboardGui.Size = UDim2.new(0, 120, 0, 30)
	billboardGui.StudsOffset = config.BillboardOffset
	billboardGui.AlwaysOnTop = false
	billboardGui.MaxDistance = 50
	billboardGui.Parent = head
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DebuffLabel"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = config.BillboardText
	textLabel.TextColor3 = config.BillboardTextColor
	textLabel.TextStrokeColor3 = config.BillboardStrokeColor
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	return billboardGui
end

function SpringFeverArt.RemoveDebuffBillboard(instance)
	if not instance then
		return
	end

	local head = instance:FindFirstChild("Head")
	local springFeverDebuffBB = head and head:FindFirstChild("SpringFeverDebuffBB")

	if springFeverDebuffBB then
		springFeverDebuffBB:Destroy()
	end
end

function SpringFeverArt.Activate(p)
	SpringFeverArt.AttachParticles(p)
	SpringFeverArt.CreatePostProcessing()
end

function SpringFeverArt.Deactivate()
	SpringFeverArt.DetachParticles()
	SpringFeverArt.RemovePostProcessing()
end

function SpringFeverArt.OnRespawn(p)
	SpringFeverArt.DetachParticles()
	SpringFeverArt.AttachParticles(p)
end

return SpringFeverArt