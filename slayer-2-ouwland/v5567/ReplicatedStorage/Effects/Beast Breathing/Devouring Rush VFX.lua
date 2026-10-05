local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CAM = ReplicatedStorage.CAM
local hold = script:WaitForChild("Hold")
local sounds = script:WaitForChild("Sounds")
local cutscene = script:WaitForChild("Cutscene")
local loop = ReplicatedStorage.Skills["Beast Breathing"]["Devouring Rush"]["Devouring Rush"]:WaitForChild("Loop")
local DebrisModule = require(CAM.DebrisModule)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local NightIllumination = require(CAM.Client.Modules.NightIllumination)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["Beast Breathing"]["Devouring Rush"].Config)
local v = {
	Type = "Constant"
}
local v2 = {
	{ 0, 70, v },
	{ 1.8333333333333333, 70 },
	{ 2.033333333333333, 70 },
	{ 2.5, 90 },
	{ 3.75, 90, v },
	{ 3.9833333333333334, 45 }
}
local v3 = {
	ColorCorrectionEffect = {
		Saturation = {
			{ 0, 0.5 },
			{ 0.5, 0.3, v },
			{ 1.6166666666666667, 0.7 },
			{ 1.9166666666666667, 0.3, v },
			{ 6.05, -1 }
		},
		Contrast = {
			{ 0, 0.6 },
			{ 0.5, 0.1, v },
			{ 1.6166666666666667, 0.7 },
			{ 1.9166666666666667, 0.1, v },
			{ 6.05, -0.1 }
		},
		TintColor = {
			{ 0, Color3.new(0, 0, 0) },
			{ 0.5, Color3.new(1, 1, 1) },
			{ 7.15, Color3.new(1, 1, 1) },
			{ 7.366666666666666, Color3.new(0, 0, 0) }
		},
		Brightness = {
			{ 0, -0.3 },
			{ 0.3333333333333333, 0, v },
			{ 1.6166666666666667, -0.5 },
			{ 1.9166666666666667, -0.05, v },
			{ 3.75, 0 }
		}
	},
	DepthOfFieldEffect = {
		FarIntensity = {
			{ 0, 1 }
		},
		FocusDistance = {
			{ 0, 10 }
		},
		InFocusRadius = {
			{ 0, 10 }
		},
		NearIntensity = {
			{ 0, 10 }
		}
	},
	Lighting = {
		ExposureCompensation = {
			{ 0.05, 0.1 },
			{ 0.08333333333333333, 1 },
			{ 0.11666666666666667, 0 },
			{ 1.1, 0.1 },
			{ 1.1333333333333333, 1 },
			{ 1.1666666666666667, 0 },
			{ 1.5666666666666667, 0.1 },
			{ 1.6, 1 },
			{ 1.6333333333333333, 0, v },
			{ 2.0166666666666666, -0.1 },
			{ 2.05, 0.3 },
			{ 2.0833333333333335, 0, v },
			{ 2.1666666666666665, -0.1 },
			{ 2.2, 0.3 },
			{ 2.2333333333333334, 0, v },
			{ 2.283333333333333, -0.1 },
			{ 2.316666666666667, 0.3 },
			{ 2.35, 0, v },
			{ 2.4166666666666665, -0.1 },
			{ 2.45, 0.3 },
			{ 2.4833333333333334, 0, v },
			{ 2.5166666666666666, -0.1 },
			{ 2.55, 0.3 },
			{ 2.5833333333333335, 0, v },
			{ 2.6333333333333333, -0.1 },
			{ 2.6666666666666665, 0.3 },
			{ 2.7, 0, v },
			{ 2.783333333333333, -0.1 },
			{ 2.816666666666667, 0.3 },
			{ 2.85, 0, v },
			{ 2.933333333333333, -0.1 },
			{ 2.966666666666667, 0.3 },
			{ 3, 0, v },
			{ 3.05, -0.1 },
			{ 3.0833333333333335, 0.3 },
			{ 3.1166666666666667, 0, v },
			{ 3.2, -0.1 },
			{ 3.2333333333333334, 0.3 },
			{ 3.2666666666666666, 0, v }
		},
		Ambient = {
			{ 0, Color3.new(0.2745, 0.2745, 0.2745), v }
		},
		OutdoorAmbient = {
			{ 0, Color3.new(0.2745, 0.2745, 0.2745), v }
		}
	}
}
local v4 = {
	FadeInTime = 0.03,
	Frequency = 0.18,
	Amplitude = 0.1,
	SustainTime = 0.1,
	FadeOutTime = 0.3,
	RotationInfluence = createVector(0.3, 0.3, 0.3),
	PositionInfluence = createVector(3.5, 3.5, 3.5)
}
local v5 = {}

local function stopListening(p)
	for _, connection in v5[p] or {} do
		connection:Disconnect()
	end

	v5[p] = nil
end

local function destroyFolder(p)
	stopListening(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-DevouringRushVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-DevouringRushVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 6.8)
	return configuration
end

local function findFolder(p)
	return workspace.Debree:FindFirstChild((`{p.Name}-DevouringRushVFX`))
end

local function alive(instance)
	return instance.Parent ~= nil and instance.Name ~= "--"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function emitAt(instance, parent, childName: string, instance2)
	local child = hold:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(instance2.CFrame)
	clone.Parent = parent
	DebrisModule:AddItem(clone, 4)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(instance2.Position)))
	Cam_Shaker(instance2.Position, v4)
end

local function emitDash(instance, configuration, humanoidRootPart)
	local dash = hold:FindFirstChild("Dash")

	if dash == nil then
		return
	end

	local clone = dash:Clone()
	local root = clone:FindFirstChild("Root")

	if root == nil then
		return
	end

	clone:PivotTo(humanoidRootPart.CFrame)

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = root
	weldConstraint.Parent = root
	clone.Parent = configuration
	DebrisModule:AddItem(clone, 4)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
	Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
end

local function listenForSlashes(instance, configuration, humanoidRootPart)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		return
	end

	local v6 = {}
	v5[instance] = v6

	local function onSlash(value: string)
		local parent = configuration
		local v8

		if parent.Parent == nil then
			v8 = false
		else
			v8 = parent.Name ~= "--"
		end

		if not v8 then
			return
		end

		emitAt(instance, configuration, value, humanoidRootPart)
		local v9 = tonumber(string.match(value, "%d+"))

		if v9 ~= nil then
			vfxUtility.PlaySound(sounds, `PS2beastULTlunge{v9 + 1}`, humanoidRootPart, true)
		end
	end

	local animationPlayedConnection = nil
	animationPlayedConnection = animator.AnimationPlayed:Connect(function(object)
		if object.Animation == nil or object.Animation.AnimationId ~= loop.AnimationId then
			return
		end

		animationPlayedConnection:Disconnect()

		for i = 1, 5 do
			local formatted = `Slash{i}`
			table.insert(v6, object:GetMarkerReachedSignal(formatted):Connect(function()
				onSlash(formatted)
			end))
		end

		table.insert(v6, object.KeyframeReached:Connect(function(value: string)
			if string.match(value, (`^Slash[1-{5}]$`)) then
				onSlash(value)
			end
		end))
	end)
	table.insert(v6, animationPlayedConnection)
	task.delay(Config.MAX_HOLD + 0.5, function()
		if v5[instance] == v6 then
			stopListening(instance)
		end
	end)
end

local v6 = {
	AuraEmit = true,
	Dash = true,
	Fall = true
}
local v7 = {
	{ 0, "Dash" },
	{ 1.1166666666666667, "Impale" },
	{ 1.1166666666666667, "ScreenaURA" },
	{ 1.6, "ScreenaURA" },
	{ 2.05, "AuraEmit" },
	{ 2.05, "ScreenAuraDur" },
	{ 2.05, "BeamLight" },
	{ 3.75, "TransitionParticles" },
	{ 3.9833333333333334, "BeamWindFall" },
	{ 3.9833333333333334, "Fall" },
	{ 6.05, "End", 7 }
}

local function easeInfo(p, duration: number)
	local linear = Enum.EasingStyle.Linear
	local out = Enum.EasingDirection.Out

	if p == nil then
		return TweenInfo.new(duration, linear, out)
	end

	local success, result = pcall(function()
		return Enum.EasingStyle[p.Type]
	end)

	if success and result ~= nil then
		linear = result
	end

	if p.Direction ~= nil then
		local success2, result2 = pcall(function()
			return Enum.EasingDirection[p.Direction]
		end)

		if success2 and result2 ~= nil then
			out = result2
		end
	end

	return TweenInfo.new(duration, linear, out)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localValuesFolder()
	local localPlayer = Players.LocalPlayer
	return localPlayer and ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropFov()
	local v8 = localValuesFolder() -- equivalent call inferred; original call site unknown
	local devouringRushFOV = v8 and v8:FindFirstChild("DevouringRushFOV")

	if devouringRushFOV ~= nil then
		devouringRushFOV:Destroy()
	end
end

local function playFov()
	dropFov() -- equivalent call inferred; original call site unknown
	local parent = localValuesFolder() -- equivalent call inferred; original call site unknown

	if parent == nil then
		return
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "DevouringRushFOV"
	CollectionService:AddTag(numberValue, "FOV")
	numberValue.Value = v2[1][2]
	numberValue.Parent = parent
	DebrisModule:AddItem(numberValue, Config.CUTSCENE_DURATION)
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		humanoid.Died:Once(function()
			if numberValue.Parent ~= nil then
				numberValue:Destroy()
			end
		end)
	end

	for k, v9 in v2 do
		local v11 = v9
		local v12 = v2[k + 1]

		local function beat()
			if numberValue.Parent == nil then
				return
			end

			numberValue.Value = v11[2]

			if v12 == nil or v12[2] == v11[2] or v11[3] ~= nil and v11[3].Type == "Constant" then
				return
			end

			TweenService:Create(numberValue, easeInfo(v11[3], v12[1] - v11[1]), {
				Value = v12[2]
			}):Play()
		end

		if v9[1] <= 0 then
			beat()
		else
			task.delay(v9[1], beat)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCutsceneFolder(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-DevouringRushCutsceneVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local v8 = nil

local function dropLighting()
	local v9 = v8

	if v9 == nil then
		return
	end

	v8 = nil

	for _, tween in v9.tweens do
		tween:Cancel()
	end

	for _, effect in v9.effects do
		if effect.Parent ~= nil then
			effect:Destroy()
		end
	end

	if v9.snapshot ~= nil then
		for k, v10 in v9.snapshot do
			Lighting[k] = v10
		end

		NightIllumination.Release("DevouringRushCutscene")
	end
end

local function playLighting()
	dropLighting()
	local v9 = {
		effects = {},
		tweens = {},
		snapshot = nil
	}
	v8 = v9

	for className, v10 in v3 do
		local instance

		if className == "Lighting" then
			instance = Lighting
			local snapshot = {}

			for k in v10 do
				snapshot[k] = Lighting[k]
			end

			v9.snapshot = snapshot
			NightIllumination.Hold("DevouringRushCutscene")
		else
			instance = Instance.new(className)
			instance.Name = "DevouringRushCutscene_" .. className
			instance.Parent = Lighting
			table.insert(v9.effects, instance)
		end

		for k, v11 in v10 do
			for k2, v12 in v11 do
				local v14 = k
				local v15 = v12
				local v16 = v11[k2 + 1]

				local function beat()
					if v8 ~= v9 then
						return
					end

					instance[v14] = v15[2]

					if v16 == nil or v15[3] ~= nil and v15[3].Type == "Constant" then
						return
					end

					local tween = TweenService:Create(instance, easeInfo(v15[3], v16[1] - v15[1]), {
						[v14] = v16[2]
					})
					table.insert(v9.tweens, tween)
					tween:Play()
				end

				if v12[1] <= 0 then
					beat()
				else
					task.delay(v12[1], beat)
				end
			end
		end
	end

	task.delay(Config.CUTSCENE_DURATION, function()
		if v8 == v9 then
			dropLighting()
		end
	end)
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		humanoid.Died:Once(function()
			if v8 == v9 then
				dropLighting()
			end
		end)
	end
end

local function runCutscene(instance, cFrame: CFrame?, childName: string?, p, owner)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	destroyCutsceneFolder(instance) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{instance.Name}-DevouringRushCutsceneVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 13.05)
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local v9

	if owner == nil then
		v9 = false
	else
		v9 = table.find(owner, character) ~= nil
	end

	if v9 and typeof(cFrame) == "CFrame" then
		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 ~= nil then
			humanoidRootPart2.CFrame = cFrame
		end
	end

	if v9 then
		playFov()
		playLighting()
	end

	local playSound = vfxUtility.PlaySound
	local v12

	if v9 then
		v12 = workspace.CurrentCamera
	else
		v12 = humanoidRootPart
	end

	playSound(sounds, "PS2beastULT", v12, true)
	local part2 = nil

	if v9 then
		task.spawn(function()
			local v14 = p or childName and workspace.Debree:WaitForChild(childName, 3)
			local bone = v14 and v14:WaitForChild("Bone", 3)

			if bone ~= nil and bone:IsA("BasePart") then
				part2 = bone
			end
		end)
	end

	local function play(childName2: string, value: number?)
		local parent = configuration
		local v15

		if parent.Parent == nil then
			v15 = false
		else
			v15 = parent.Name ~= "--"
		end

		if not v15 then
			return
		end

		local child = cutscene.CameraVFX:FindFirstChild(childName2)

		if child == nil then
			local child2 = cutscene:FindFirstChild(childName2)

			if child2 == nil then
				return
			end

			local clone = child2:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = configuration
			DebrisModule:AddItem(clone, value or 4)
			local v16

			if v6[childName2] then
				v16 = groundDust(humanoidRootPart.Position)
			end

			Ouwmit.Emit(clone, Ouwmit.Owned(instance, v16))
		else
			if not v9 then
				return
			end

			local clone = child:Clone()
			local weld = clone:FindFirstChild("Weld")
			local root = clone:FindFirstChild("Root")

			if weld == nil and root ~= nil and root:IsA("BasePart") and clone:IsA("Model") then
				if part2 == nil then
					return
				end

				clone:PivotTo(part2.CFrame)

				for _, part in clone:GetDescendants() do
					if part:IsA("BasePart") then
						part.Anchored = false
					end
				end

				local weld2 = root:FindFirstChild("Weld")

				if weld2 == nil then
					return
				end

				weld2.Part0 = part2
				clone.Parent = configuration
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			elseif weld == nil then
				clone.Parent = configuration
				Ouwmit.Emit(clone, {
					Owner = owner
				})
			else
				if part2 == nil then
					return
				end

				weld.Part0 = part2
				clone.Parent = configuration
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			end

			DebrisModule:AddItem(clone, 4)
		end
	end

	for _, v14 in v7 do
		local v15 = v14[1]
		local v16 = v14[2]
		local v17 = v14[3]

		if v15 <= 0 then
			play(v16, v17)
		else
			task.delay(v15, play, v16, v17)
		end
	end
end

return function(instance, p: string, cFrame, p3, p4, owner)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance)
		destroyCutsceneFolder(instance) -- equivalent call inferred; original call site unknown
		dropFov() -- equivalent call inferred; original call site unknown
		dropLighting()
	elseif p == "Cutscene" then
		stopListening(instance)
		runCutscene(instance, cFrame, p3, p4, owner)
	elseif p == "Start" then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-DevouringRushVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 6.8)
		listenForSlashes(instance, configuration, humanoidRootPart)
		task.delay(0.55, function()
			local parent = configuration
			local v10

			if parent.Parent == nil then
				v10 = false
			else
				v10 = parent.Name ~= "--"
			end

			if not v10 or humanoidRootPart.Parent == nil then
				return
			end

			emitDash(instance, configuration, humanoidRootPart)
			vfxUtility.PlaySound(sounds, "PS2beastULTlunge1", humanoidRootPart, true)
		end)
	else
		if not (workspace.Debree:FindFirstChild((`{instance.Name}-DevouringRushVFX`)) ~= nil and p ~= "Rush") then
			return
		end

		if p == "Capture" then
		end
	end
end