local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local CraterExtension = require(CAM.Client.Modules.Effects.Craters.CraterExtension)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local debree = workspace.Debree
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-Chaotic_Afterglow`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-Chaotic_Afterglow`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 20)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return (debree:FindFirstChild((`{instance.Name}-Chaotic_Afterglow`)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearFolder(folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

local function fadeFolder(folder)
	for _, part in folder:GetChildren() do
		vfxUtility.ToggleWithColor(part, false)

		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.15), {
				Transparency = 1
			}):Play()
		end

		for _, light in part:QueryDescendants("BasePart, Decal, PointLight") do
			if light:IsA("PointLight") then
				TweenService:Create(light, TweenInfo.new(0.1), {
					Brightness = 0
				}):Play()
			else
				TweenService:Create(light, TweenInfo.new(0.15), {
					Transparency = 1
				}):Play()
			end
		end

		DebrisModule:AddItem(part, 0.3)
	end
end

local function clearAttachments(instance)
	local v2 = v[instance]

	if not v2 then
		return
	end

	for _, v3 in v2 do
		if not v3 then
			continue
		end

		vfxUtility.ToggleWithColor(v3, false)
		DebrisModule:AddItem(v3, 1)
	end

	v[instance] = nil
end

local function flickerColorCorrection()
	local WAIT_INTERVAL = 0.03333333333333333
	local clone = assets.ColorCorrection:Clone()
	clone.Parent = Lighting
	clone.Enabled = true
	task.wait(WAIT_INTERVAL)
	clone.Enabled = false
	task.wait(WAIT_INTERVAL)
	clone.Enabled = true
	task.wait(WAIT_INTERVAL)
	clone.Enabled = false
	DebrisModule:AddItem(clone, 0.2)
end

local function getRandomCFrame(p)
	local v2 = p.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
	local v3 = math.rad((math.random(-360, 360)))
	return v2 * CFrame.Angles(v3, v3, 0)
end

local v2 = {
	Flash = {
		scaleTime = 0.2,
		fadeDelay = 0.2
	},
	Wind = {
		scaleTime = 0.7,
		fadeDelay = 0.4
	},
	Fist = {
		scaleTime = 0.2,
		fadeDelay = 0.3
	}
}

local function animatePunchDescendants(clone, flag: boolean)
	for _, v3 in clone:QueryDescendants("MeshPart") do
		if v3.Name == "Particles" then
			continue
		end

		local size = v3.Size
		local transparency = v3.Transparency
		v3.Size = size / 100
		v3.Transparency = 1
		TweenService:Create(v3, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = size,
			Transparency = transparency
		}):Play()
		local v4 = v3
		task.delay(0.2, function()
			if not v4.Parent then
				return
			end

			TweenService:Create(v4, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
		end)
	end

	for _, v3 in clone:QueryDescendants("SpecialMesh") do
		local v4 = v2[v3.Name]

		if not v4 then
			continue
		end

		local scale = v3.Scale
		v3.Scale = scale / 100
		TweenService:Create(v3, TweenInfo.new(v4.scaleTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
		local parent

		if v3.Name == "Fist" then
			parent = v3.Parent
		else
			parent = v3.Parent.Decal
		end

		local v6 = v3
		local v8 = v3.Name == "Fist" and 0.3 or 0.2
		task.delay(v4.fadeDelay, function()
			if not v6.Parent then
				return
			end

			TweenService:Create(parent, TweenInfo.new(v8), {
				Transparency = 1
			}):Play()
		end)
	end

	for _, v3 in clone:QueryDescendants("Decal") do
		if v3.Name ~= "FistPart" then
			continue
		end

		local transparency = v3.Transparency
		v3.Transparency = 1
		TweenService:Create(v3, TweenInfo.new(0.3), {
			Transparency = transparency
		}):Play()
		local v4 = v3
		task.delay(0.3, function()
			if not v4.Parent then
				return
			end

			TweenService:Create(v4, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
		end)
	end

	if flag then
		for _, v3 in clone:QueryDescendants("ParticleEmitter") do
			v3.TimeScale /= 10
			local v4 = v3
			task.delay(1, function()
				if not v4.Parent then
					return
				end

				v4.TimeScale *= 10
			end)
		end
	end

	for _, v3 in clone:QueryDescendants("PointLight") do
		local v4 = v3
		task.delay(0.3, function()
			if not v4.Parent then
				return
			end

			TweenService:Create(v4, TweenInfo.new(0.1), {
				Brightness = 0
			}):Play()
		end)
	end
end

local function spawnEarlyPunch(configuration, humanoidRootPart)
	local clone = assets.RapidPunch:Clone()
	clone:PivotTo((getRandomCFrame(humanoidRootPart)))
	clone.Parent = configuration
	DebrisModule:AddItem(clone, 2)
	clone:ScaleTo(math.random(1.4, 1.5))
	local primaryPart = clone.PrimaryPart
	TweenService:Create(primaryPart, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		CFrame = primaryPart.CFrame * CFrame.new(math.random(5, 20), 0, 0)
	}):Play()
	task.delay(0.8, function()
		if not clone.Parent then
			return
		end

		vfxUtility.ToggleWithColor(clone, false)
	end)
	vfxUtility.EmitAll(clone, vfxUtility.Owned(humanoidRootPart))
	animatePunchDescendants(clone, true)
end

local function spawnEarlyPunchSecondary(configuration, humanoidRootPart)
	local clone = assets.SecondPunchMesh:Clone()
	clone:PivotTo((getRandomCFrame(humanoidRootPart)))
	clone.Parent = configuration
	DebrisModule:AddItem(clone, 2)
	local primaryPart = clone.PrimaryPart
	TweenService:Create(primaryPart, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		CFrame = primaryPart.CFrame * CFrame.new(0, 0, math.random(-30, -20))
	}):Play()
	task.delay(0.9, function()
		if not clone.Parent then
			return
		end

		vfxUtility.ToggleWithColor(clone, false)
	end)
	vfxUtility.EmitAll(clone, vfxUtility.Owned(humanoidRootPart))

	for _, instance in clone:QueryDescendants("MeshPart, ParticleEmitter") do
		if instance:IsA("MeshPart") then
			local v3 = instance
			task.delay(1, function()
				if not v3.Parent then
					return
				end

				TweenService:Create(v3, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
			end)
		end

		if not instance:IsA("ParticleEmitter") then
			continue
		end

		instance.TimeScale /= 10
		local v3 = instance
		task.delay(1, function()
			if not v3.Parent then
				return
			end

			v3.TimeScale *= 10
		end)
	end
end

local function spawnHeavyPunch(folder, humanoidRootPart)
	local clone = assets.RapidPunch:Clone()
	clone:PivotTo((getRandomCFrame(humanoidRootPart)))
	clone.Parent = folder
	DebrisModule:AddItem(clone, 1)
	clone:ScaleTo(math.random(1.4, 3))
	local primaryPart = clone.PrimaryPart
	TweenService:Create(primaryPart, TweenInfo.new(0.3), {
		CFrame = primaryPart.CFrame * CFrame.new(math.random(10, 25), 0, 0)
	}):Play()
	task.delay(0.2, function()
		if not clone.Parent then
			return
		end

		vfxUtility.ToggleWithColor(clone, false)
	end)
	vfxUtility.EmitAll(clone, vfxUtility.Owned(humanoidRootPart))
	animatePunchDescendants(clone, false)
end

local function spawnHeavyPunchSecondary(folder, humanoidRootPart)
	local clone = assets.SecondPunchMesh:Clone()
	clone:PivotTo((getRandomCFrame(humanoidRootPart)))
	clone.Parent = folder
	DebrisModule:AddItem(clone, 0.5)
	local primaryPart = clone.PrimaryPart
	TweenService:Create(primaryPart, TweenInfo.new(0.2), {
		CFrame = primaryPart.CFrame * CFrame.new(0, 0, math.random(-30, -15))
	}):Play()
	task.delay(0.15, function()
		if not clone.Parent then
			return
		end

		vfxUtility.ToggleWithColor(clone, false)
		task.wait(0.1)

		if not clone.Parent then
			return
		end

		local clone2 = (math.random(1, 2) == 1 and assets.Impact1 or assets.Impact2):Clone()
		clone2.Parent = folder
		clone2.CFrame = primaryPart.CFrame
		DebrisModule:AddItem(clone2, 2)
		vfxUtility.ScaleParticleDescendants(clone2, 0.6)
		local raycastResult = workspace:Raycast(
			clone2.Position + createVector(0, 2, 0),
			createVector(-0, -5, -0),
			RaycastHelper.Crater
		)

		if not raycastResult then
			vfxUtility.EmitAll(clone2.Air, vfxUtility.Owned(humanoidRootPart))
			return
		end

		vfxUtility.EmitAll(clone2, vfxUtility.Owned(humanoidRootPart))
		clone2.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		) + createVector(0, 0.4, 0)
	end)
	vfxUtility.EmitAll(clone, vfxUtility.Owned(humanoidRootPart))

	for _, v3 in clone:QueryDescendants("MeshPart") do
		local v4 = v3
		task.delay(0.2, function()
			if not v4.Parent then
				return
			end

			TweenService:Create(v4, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
		end)
	end
end

return function(instance, p: string, _)
	if not instance then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		clearAttachments(instance)
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-Chaotic_Afterglow`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 20)
		local v3 = {}
		v[instance] = v3
		local rightHand = instance:FindFirstChild("RightHand")

		if rightHand and rightHand:IsA("BasePart") then
			local clone = assets.Attachments.HandTrail:Clone()
			clone.Parent = rightHand
			vfxUtility.ToggleWithColor(clone, true, nil, nil, instance)
			v3.HandTrailR = clone
		end

		local leftHand = instance:FindFirstChild("LeftHand")

		if leftHand and leftHand:IsA("BasePart") then
			local clone = assets.Attachments.HandTrail:Clone()
			clone.Parent = leftHand
			vfxUtility.ToggleWithColor(clone, true, nil, nil, instance)
			v3.HandTrailL = clone
		end

		task.wait(0.35)

		if configuration.Parent == nil or configuration:GetAttribute("FinalTriggered") then
			return
		end

		local clone = assets.Final:Clone()
		clone.Parent = configuration
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.83, 0))
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		local rightFoot = instance:FindFirstChild("RightFoot")
		CraterExtension.Ground(rightFoot.Position, 15, createVector(0.3, 0.5, 0.5), nil, 3, false, 0.5)
		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE2start", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.4,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(7.5, 7.5, 7.5)
		})
		task.wait(0.3)

		if configuration.Parent == nil or configuration:GetAttribute("FinalTriggered") then
			return
		end

		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE2indipunch1", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(7.5, 7.5, 7.5)
		})

		for _ = 1, 10 do
			if configuration.Parent == nil or configuration:GetAttribute("FinalTriggered") then
				return
			end

			spawnEarlyPunch(configuration, humanoidRootPart)
			spawnEarlyPunchSecondary(configuration, humanoidRootPart)
			task.wait(0.03)
		end

		local clone2 = assets.ViolentBurst:Clone()
		clone2.Parent = configuration
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
		Ouwmit.Enable(clone2, true, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone2, 5)
	elseif p == "Pulse" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil or folder:GetAttribute("FinalTriggered") then
			return
		end

		if not folder:GetAttribute("StartupFlickerDone") then
			folder:SetAttribute("StartupFlickerDone", true)
			task.spawn(flickerColorCorrection)
		end

		local cam_Shaker = Cam_Shaker(humanoidRootPart, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.2,
			SustainTime = 3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		while folder.Parent ~= nil and not folder:GetAttribute("FinalTriggered") do
			spawnHeavyPunch(folder, humanoidRootPart)
			spawnHeavyPunchSecondary(folder, humanoidRootPart)
			task.wait(0.0375)
		end

		task.wait(0.35)
		cam_Shaker:Destroy()
	elseif p == "PulseFinal" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil or folder:GetAttribute("FinalTriggered") then
			return
		end

		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE2explo3", humanoidRootPart, true)
		folder:SetAttribute("FinalTriggered", true)

		if not folder:GetAttribute("StartupFlickerDone") then
			fadeFolder(folder)
		end

		local violentBurst = folder:FindFirstChild("ViolentBurst")

		if violentBurst then
			vfxUtility.ToggleWithColor(violentBurst, false)
		end

		local clone = assets.Final2:Clone()
		clone.Parent = folder
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		task.wait(0.4)

		if folder.Parent == nil then
			return
		end

		if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
			OuwCraters.Scales({
				Center = humanoidRootPart.CFrame,
				ScaleMult = 1,
				Duration = 3,
				Radius = 8
			})
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.5,
				SustainTime = 0.2,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.75, 0.75, 0.75),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
		end

		task.spawn(flickerColorCorrection)

		for _ = 1, 10 do
			if folder.Parent == nil then
				return
			else
				spawnHeavyPunchSecondary(folder, humanoidRootPart)
			end
		end

		clearAttachments(instance)
		task.wait(4)

		if folder.Parent == nil then
			return
		end

		clearFolder(folder) -- equivalent call inferred; original call site unknown
		DebrisModule:AddItem(folder, 0.2)
	elseif p == "Cancel" then
		clearAttachments(instance)
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder then
			fadeFolder(folder)
			DebrisModule:AddItem(folder, 1)
		end

		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	end
end