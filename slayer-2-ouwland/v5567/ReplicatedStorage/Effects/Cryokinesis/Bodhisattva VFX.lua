local createVector = vector.create
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local bodhisattvaRig = assets.BodhisattvaRig
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)

local function fadeOutBuddha(folder)
	if folder.Parent == nil or folder:GetAttribute("FadingOut") == true then
		return
	end

	folder:SetAttribute("FadingOut", true)
	local tweenInfo = TweenInfo.new(0.3)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			if descendant.Transparency < 1 then
				TweenService:Create(descendant, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("Highlight") then
			TweenService:Create(descendant, tweenInfo, {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end
	end

	vfxUtility.EnableAll(folder, false)
	DebrisModule:AddItem(folder, 0.3)
end

local function destroyFolder(p)
	local formatted = `{p.Name}-BodhisattvaVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		local buddahVFX = child:FindFirstChild("BuddahVFX")

		if buddahVFX ~= nil then
			buddahVFX.Parent = workspace.Debree
			fadeOutBuddha(buddahVFX)
		end

		child:Destroy()
	end
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-BodhisattvaVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 6)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-BodhisattvaVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function tweenWindBeams(asset, duration: number)
	for _, v in asset:QueryDescendants("Beam") do
		TweenService:Create(v, TweenInfo.new(duration), {
			Brightness = 0
		}):Play()
		TweenService:Create(v, TweenInfo.new(duration), {
			LightEmission = 1
		}):Play()
		TweenService:Create(v, TweenInfo.new(duration * 0.87), {
			TextureSpeed = 0
		}):Play()
	end
end

return function(instance, p: string, cframe: CFrame)
	local WAIT_INTERVAL = 0.08333333333333333

	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	destroyFolder(instance)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{instance.Name}-BodhisattvaVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 6)
	local position = cframe.Position

	local function aimCF()
		local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart2 == nil then
			return cframe
		end

		local _, v = humanoidRootPart2.CFrame:ToEulerAnglesYXZ()
		return CFrame.new(position) * CFrame.Angles(0, v, 0)
	end

	local buddahVFX = assets.SkillRigs:FindFirstChild("BuddahVFX")

	if buddahVFX == nil then
		return
	end

	vfxUtility.PlaySound(script, "PS2cryokenesisSKILL5", humanoidRootPart, true)
	local clone = buddahVFX:Clone()
	local cframe2 = CFrame.new(-0.092, -10.912, 0.031)
	clone:PivotTo(cframe * cframe2)
	clone.Parent = configuration
	task.delay(4, fadeOutBuddha, clone)
	DebrisModule:AddItem(clone, 4.3999999999999995)
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if clone.Parent == nil then
			postSimulationConnection:Disconnect()
		else
			clone:PivotTo(aimCF() * cframe2)
		end
	end)
	clone.Destroying:Once(function()
		postSimulationConnection:Disconnect()
	end)
	local track = clone:FindFirstChildWhichIsA("Animator", true):LoadAnimation(bodhisattvaRig)
	track:Play()
	DebrisModule:AddItem(track, 6)
	local asset = vfxUtility.cloneAsset(assets, configuration, "SkillInitialFX", aimCF() * CFrame.new(0, -1, 0), 3)
	vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
	Cam_Shaker(cframe, {
		FadeInTime = 0,
		Frequency = 0.25,
		Amplitude = 0.4,
		SustainTime = 0.1,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1.3, 1.3, 1.3)
	})
	task.wait(0.3333333333333333)

	if not findFolder(instance) then
		return
	end

	local clone2 = assets.Charging_VFX:Clone()
	clone2.Parent = configuration
	DebrisModule:AddItem(clone2, 1)
	vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
	local rightHand = instance:FindFirstChild("RightHand")
	local handAttach = clone2.Icicle.HandAttach
	handAttach.Parent = rightHand
	clone2.Icicle.RigidConstraint.Attachment1 = handAttach
	task.wait(WAIT_INTERVAL)

	if not findFolder(instance) or clone2.Parent == nil then
		return
	end

	clone2.Icicle.Transparency = 0
	task.wait(0.03333333333333333)

	if not findFolder(instance) or clone2.Parent == nil then
		return
	end

	vfxUtility.ToggleWithColor(clone2.Charge, true, nil, nil, instance)
	vfxUtility.ToggleWithColor(clone2.OuterEnergy, true, nil, nil, instance)
	task.wait(0.05)

	if not findFolder(instance) then
		return
	end

	local asset2 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"HandImpact",
		aimCF() * CFrame.new(-0.507, -2.879, -2.774) * CFrame.Angles(0, 1.5707963267948966, 0),
		4
	)
	vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance))
	Cam_Shaker(cframe, {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.5,
		SustainTime = 0.2,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
	task.wait(WAIT_INTERVAL)

	if not findFolder(instance) then
		return
	end

	local asset3 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"IceImpact",
		aimCF() * CFrame.new(-0.507, -12.879, -2.774) * CFrame.Angles(0, 1.5707963267948966, 0),
		3.2
	)
	vfxUtility.EmitAll(asset3, vfxUtility.Owned(instance))
	TweenService:Create(asset3.PrimaryPart, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
		CFrame = asset3.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
	}):Play()
	task.wait(WAIT_INTERVAL)

	if clone2.Parent then
		clone2.Icicle.Transparency = 1
		vfxUtility.ToggleWithColor(clone2, false)
	end

	if not findFolder(instance) or clone.Parent == nil then
		return
	end

	cframe2 = CFrame.new(-0.092, 3.912, 0.031)
	clone:PivotTo(aimCF() * cframe2)
	track:AdjustSpeed(0.01)
	task.wait(0.5)

	if not findFolder(instance) then
		return
	end

	if clone.Parent then
		track:AdjustSpeed(1)
	end

	local asset4 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"BuddhaComeUp",
		aimCF() * CFrame.new(-2.168, -1.41, -1.887) * CFrame.Angles(0, 0, 1.5707963267948966),
		5
	)
	vfxUtility.EmitAll(asset4, vfxUtility.Owned(instance))
	Cam_Shaker(cframe, {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.5,
		SustainTime = 0.2,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
	task.wait(0.6666666666666666)

	if not findFolder(instance) then
		return
	end

	if clone.Parent then
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
	end

	task.wait(0.3333333333333333)

	if not findFolder(instance) then
		return
	end

	local asset5 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"Wind",
		aimCF() * CFrame.new(-1, -3.5, -12.84) * CFrame.Angles(3.141592653589793, 0, 3.141592653589793),
		3
	)
	vfxUtility.EmitAll(asset5, vfxUtility.Owned(instance))
	tweenWindBeams(asset5, 1.5)
	local asset6 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"IceGustGroup1",
		humanoidRootPart.CFrame * CFrame.new(-1, -3.5, -30.84),
		2.2
	)
	local raycastResult = workspace:Raycast(
		asset6.PrimaryPart.Position + createVector(0, 20, 0),
		createVector(-0, -60, -0),
		RaycastHelper.Crater
	)

	if raycastResult then
		local pivot = asset6:GetPivot()
		asset6:PivotTo(CFrame.new(raycastResult.Position) * (pivot - pivot.Position) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		))
	end

	vfxUtility.EmitAll(asset6, vfxUtility.Owned(instance))
	TweenService:Create(asset6.PrimaryPart, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
		CFrame = asset6.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
	}):Play()
	Cam_Shaker(asset6.PrimaryPart.CFrame, {
		FadeInTime = 0,
		Frequency = 0.3,
		Amplitude = 0.55,
		SustainTime = 0.4,
		FadeOutTime = 0.75,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
	task.wait(1)

	if not findFolder(instance) then
		return
	end

	if asset6.Parent then
		TweenService:Create(asset6.PrimaryPart, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {
			CFrame = asset6.PrimaryPart.CFrame * CFrame.new(0, -10, 0)
		}):Play()
	end

	Cam_Shaker(asset6.PrimaryPart.CFrame, {
		FadeInTime = 0,
		Frequency = 0.2,
		Amplitude = 0.4,
		SustainTime = 0.3,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
	task.wait(0.16666666666666666)

	if not findFolder(instance) then
		return
	end

	local v = aimCF() * CFrame.new(-1, -2.5, -12.84)
	local asset7 = vfxUtility.cloneAsset(assets, configuration, "GroundImpactEmit", v, 4)
	vfxUtility.EmitAll(asset7, vfxUtility.Owned(instance))
	local asset8 = vfxUtility.cloneAsset(assets, configuration, "InitialGroundImpact", v * CFrame.new(0, -1, 0), 4)
	vfxUtility.EmitAll(asset8, vfxUtility.Owned(instance))
	local asset9 = vfxUtility.cloneAsset(assets, configuration, "Hit", v, 5)
	vfxUtility.EmitAll(asset9, vfxUtility.Owned(instance))
	Cam_Shaker(v, "medium_shake_preset")
	task.wait(0.06)

	if not findFolder(instance) then
		return
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Contrast = -100
	colorCorrectionEffect.Saturation = -1
	colorCorrectionEffect.Parent = Lighting
	DebrisModule:AddItem(colorCorrectionEffect, 0.08)
	local asset10 = vfxUtility.cloneAsset(
		assets,
		configuration,
		"Wind",
		aimCF() * CFrame.new(-1, -3.5, -12.84) * CFrame.Angles(3.141592653589793, 0, 3.141592653589793),
		4
	)
	vfxUtility.EmitAll(asset10, vfxUtility.Owned(instance))

	for _, v2 in asset10:QueryDescendants("Beam") do
		v2.Brightness = 1.5
	end

	tweenWindBeams(asset10, 2)
	local asset11 = vfxUtility.cloneAsset(assets, configuration, "End", humanoidRootPart.CFrame, 4)
	Ouwmit.Emit(asset11, Ouwmit.Owned(instance))
	task.spawn(function()
		for i = 1, 4 do
			local asset12 = vfxUtility.cloneAsset(
				assets,
				configuration,
				"GroundImpactEmit",
				v * CFrame.new(0, 0, i * -9),
				4
			)
			vfxUtility.EmitAll(asset12, vfxUtility.Owned(instance))
			asset12.Size *= i
			task.wait(0.1)
		end
	end)
	task.wait(0.25)

	if not findFolder(instance) or clone.Parent == nil then
		return
	end

	track:AdjustSpeed(0)
	task.wait(0.2)

	if not findFolder(instance) or clone.Parent == nil then
		return
	end

	local clone3 = assets.Attachments.IceHighlight:Clone()
	clone3.FillTransparency = 1
	clone3.Parent = clone
	TweenService:Create(clone3, TweenInfo.new(0.5), {
		FillTransparency = 0.1
	}):Play()
	task.wait(0.5)

	if not findFolder(instance) or clone.Parent == nil then
		return
	end

	local asset12 = vfxUtility.cloneAsset(assets, configuration, "Hit", clone:GetPivot(), 5)
	vfxUtility.EmitAll(asset12, vfxUtility.Owned(instance))
	fadeOutBuddha(clone)
end