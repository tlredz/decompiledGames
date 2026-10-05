local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ImpactFrames = require(CAM.Client.Modules.Effects.ImpactFrames)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local localPlayer = Players.LocalPlayer
local debree = workspace.Debree
local cframe = CFrame.new(0, 0, 0)
local cframe2 = CFrame.new(0, 0, 0)
local v = CFrame.new(0.184, -1, 2.939) * CFrame.Angles(-3.141592653589793, 0, -3.141592653589793)
local cframe3 = CFrame.new(0.364, -1, -3.131)
local v2 = CFrame.new(0.479, -2.826, -1.696) * CFrame.Angles(-3.141592653589793, 0, -3.141592653589793)
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-AnnihilationType`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-AnnihilationType`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 20)
	return configuration
end

local function releaseFolder(instance)
	local child = debree:FindFirstChild((`{instance.Name}-AnnihilationType`))

	if child == nil or child.Parent == nil then
		return
	end

	child.Name = "--"
	local childRemovedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sweep()
		if child.Parent == nil then
			if childRemovedConnection ~= nil then
				childRemovedConnection:Disconnect()
			end
		else
			if #child:GetChildren() > 0 then
				return
			end

			if childRemovedConnection ~= nil then
				childRemovedConnection:Disconnect()
			end

			child:Destroy()
		end
	end

	childRemovedConnection = child.ChildRemoved:Connect(sweep)
	sweep() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return (debree:FindFirstChild((`{instance.Name}-AnnihilationType`)))
end

local function clearAttachments(instance)
	local v4 = v3[instance]

	if not v4 then
		return
	end

	for _, v5 in v4 do
		if not v5 then
			continue
		end

		vfxUtility.ToggleWithColor(v5, false)
		DebrisModule:AddItem(v5, 1)
	end

	v3[instance] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blurEffect(p: number)
	local blurEffect2 = Instance.new("BlurEffect")
	blurEffect2.Size = 5
	blurEffect2.Parent = Lighting
	DebrisModule:AddItem(blurEffect2, p)
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

local function impactWithFlicker(parent, framesSetName: string, frameRate: number)
	local _, v4 = ImpactFrames.GetSet(framesSetName)
	local v5 = v4 and #v4 or 0
	ImpactFrames.PlaySet({
		FrameRate = frameRate,
		FramesSetName = framesSetName
	})

	if v5 > 0 then
		task.wait(frameRate * v5)
	end

	local highlight = assets:FindFirstChild("Highlight")
	local clone = highlight and highlight:Clone()

	if clone then
		clone.Parent = parent
	end

	flickerColorCorrection()

	if clone then
		clone:Destroy()
	end
end

local tweenInfo = TweenInfo.new(0.5)
return function(instance, p: string, instance2, list)
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
		configuration.Name = `{instance.Name}-AnnihilationType`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 20)
		task.spawn(flickerColorCorrection)
		blurEffect(0.3) -- equivalent call inferred; original call site unknown
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(7.5, 7.5, 7.5)
		})
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v4 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = assets.initial:Clone()
		clone.Parent = configuration
		clone:PivotTo(humanoidRootPart.CFrame * cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v4))
		DebrisModule:AddItem(clone, 5)
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			ScaleMult = 0.8,
			Count = 6,
			Radius = 10,
			OffsetMargin = 6
		})
		local clone2 = assets.ViolentBurst:Clone()
		clone2.Parent = configuration
		clone2:PivotTo(humanoidRootPart.CFrame * cframe2)
		vfxUtility.ToggleWithColor(clone2, true, v4.Color, nil, instance)
		DebrisModule:AddItem(clone2, 5)
		vfxUtility.WeldConstraint(humanoidRootPart, clone2.PrimaryPart)
		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE1start", humanoidRootPart, true)
		task.wait(0.7)

		if configuration.Parent == nil or configuration.Name == "--" then
			return
		end

		clone:PivotTo(humanoidRootPart.CFrame * cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v4))
		vfxUtility.ToggleWithColor(clone2, false)
		local v5 = {}
		v3[instance] = v5
		local clone3 = assets.Attachments.DashAttach:Clone()
		clone3.Parent = humanoidRootPart
		vfxUtility.ToggleWithColor(clone3, true, v4.Color, nil, instance)
		v5.DashAttach = clone3
		local rightHand = instance:FindFirstChild("RightHand")

		if rightHand and rightHand:IsA("BasePart") then
			local clone4 = assets.Attachments.HandTrail:Clone()
			clone4.Parent = rightHand
			vfxUtility.ToggleWithColor(clone4, true, nil, nil, instance)
			v5.HandTrailR = clone4
		end

		local leftHand = instance:FindFirstChild("LeftHand")

		if leftHand and leftHand:IsA("BasePart") then
			local clone4 = assets.Attachments.HandTrail:Clone()
			clone4.Parent = leftHand
			vfxUtility.ToggleWithColor(clone4, true, nil, nil, instance)
			v5.HandTrailL = clone4
		end

		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE1launch", humanoidRootPart, true)
		local v6 = true
		local ancestryChangedConnection = clone3.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				v6 = false
			end
		end)
		local clone4 = script.Sounds:FindFirstChild("PS2shockwaveULTrunloop"):Clone()
		clone4.Parent = humanoidRootPart
		clone4:Play()

		while v6 and configuration.Parent ~= nil and configuration.Name ~= "--" do
			task.wait()
		end

		TweenService:Create(clone4, tweenInfo, {
			Volume = 0
		}):Play()
		DebrisModule:AddItem(clone4, 0.5)
		ancestryChangedConnection:Disconnect()
	elseif p == "Cutscene" then
		clearAttachments(instance)
		local parent = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not parent then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			parent = Instance.new("Configuration")
			parent.Name = `{instance.Name}-AnnihilationType`
			parent.Parent = debree
			DebrisModule:AddItem(parent, 20)
		end

		local index = list and localPlayer.Character and table.find(list, localPlayer.Character)
		local dashAttach = humanoidRootPart:FindFirstChild("DashAttach")

		if dashAttach then
			DebrisModule:AddItem(dashAttach, 0.1)
		end

		vfxUtility.PlaySound(script.Sounds, "PS2akazaULTIMATE1impact", humanoidRootPart, true)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v5 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = assets.InitialFX:Clone()
		clone.Parent = parent
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v5))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(7.5, 7.5, 7.5)
		})

		if index then
			blurEffect(0.2) -- equivalent call inferred; original call site unknown
		end

		task.wait(0.5833333333333334)

		if parent.Parent == nil then
			return
		end

		vfxUtility.ToggleWithColor(clone.Dash, false)
		vfxUtility.ToggleWithColor(clone.Dash2, false)
		task.wait(0.75)

		if parent.Parent == nil then
			return
		end

		local clone2 = assets.PreExplosion:Clone()
		clone2.Parent = parent
		clone2:PivotTo(humanoidRootPart.CFrame * v)
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v5))
		DebrisModule:AddItem(clone2, 12)
		task.wait(0.5)

		if parent.Parent == nil then
			return
		end

		vfxUtility.ToggleWithColor(clone, false)
		DebrisModule:AddItem(clone, 2)
		task.wait(0.4166666666666667)

		if parent.Parent == nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(7.5, 7.5, 7.5)
		})
		local clone3 = assets.GroundImpact:Clone()
		clone3.Parent = parent
		clone3.CFrame = humanoidRootPart.CFrame * cframe3
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v5))
		DebrisModule:AddItem(clone3, 12)
		task.wait(0.11666666666666667)

		if parent.Parent == nil then
			return
		end

		if index then
			task.spawn(flickerColorCorrection)
		end

		task.wait(0.08333333333333333)

		if parent.Parent == nil then
			return
		end

		if index then
			blurEffect(0.2) -- equivalent call inferred; original call site unknown
		end

		local clone4 = assets.Daeath:Clone()
		clone4.Parent = parent
		clone4:PivotTo(humanoidRootPart.CFrame * v2)
		vfxUtility.ToggleWithColor(clone4, true, nil, nil, instance)
		task.spawn(function()
			for _ = 1, 20 do
				if parent.Parent == nil then
					break
				end

				clone4:ScaleTo(clone4:GetScale() + 0.1)
				local raycastResult2 = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 50, 0),
					createVector(0, -100, 0),
					RaycastHelper.Crater
				)

				if raycastResult2 then
					clone4.PrimaryPart.CFrame = CFrame.new(
						raycastResult2.Position,
						raycastResult2.Position - raycastResult2.Normal
					) * CFrame.Angles(1.5707963267948966, 0, 0)
				end

				task.wait(0.05)
			end
		end)
		local clone5 = assets.Hit3:Clone()
		clone5.Parent = parent
		clone5:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -0.45, 0))
		DebrisModule:AddItem(clone5, 12)
		Ouwmit.Emit(clone5, Ouwmit.Owned(instance, v5))

		if index then
			blurEffect(0.3) -- equivalent call inferred; original call site unknown
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "UltimateCamera" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not (folder ~= nil and (instance2 and instance2.Parent and instance2.PrimaryPart)) then
			return
		end

		local clone = assets.CameraVFX:Clone()
		clone.Parent = folder
		clone:PivotTo(instance2.PrimaryPart.CFrame)
		local rigidConstraint = clone.Bone.Attachment.RigidConstraint
		local camattach = clone.Bone.camattach
		DebrisModule:AddItem(clone, 4.5)
		camattach.Parent = instance2:FindFirstChild("Camera")
		rigidConstraint.Attachment1 = camattach
		Ouwmit.Emit(clone.WindStuff1, Ouwmit.Owned(instance))
		local sunRays = Lighting:FindFirstChild("SunRays")

		if sunRays then
			local enabled = sunRays.Enabled
			sunRays.Enabled = false
			task.delay(7.5, function()
				sunRays.Enabled = enabled
			end)
		end

		local index = list and localPlayer.Character and table.find(list, localPlayer.Character)

		if index then
			task.spawn(impactWithFlicker, instance, "AnnihilationType_Part1", 0.008333333333333333)
		end

		task.wait(0.016666666666666666)

		if folder.Parent == nil then
			return
		end

		Ouwmit.Emit(clone.DunkCameraSparks, Ouwmit.Owned(instance))
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(2), {
			FieldOfView = 70
		}):Play()
		local morebgfx = assets:FindFirstChild("morebgfx")
		local sphereBG

		if morebgfx then
			local clone2 = morebgfx:Clone()
			clone2.Parent = folder
			clone2:PivotTo(humanoidRootPart.CFrame)
			DebrisModule:AddItem(clone2, 3)
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			sphereBG = clone2:FindFirstChild("SphereBG")

			if sphereBG then
				local highlight = sphereBG:FindFirstChild("Highlight")

				if highlight then
					highlight.Enabled = false
				end
			end
		end

		task.wait(1.2833333333333334)

		if folder.Parent == nil then
			return
		end

		Ouwmit.Emit(clone.DunkCameraVertical, Ouwmit.Owned(instance))
		task.wait(0.9666666666666667)

		if folder.Parent == nil then
			return
		end

		if sphereBG then
			sphereBG:Destroy()
		end

		task.wait(0.06666666666666667)

		if folder.Parent == nil then
			return
		end

		if index then
			task.spawn(impactWithFlicker, instance, "AnnihilationType_Part2", 0.008333333333333333)
		end

		task.wait(1)

		if folder.Parent == nil then
			return
		end

		if index then
			ImpactFrames.PlaySet({
				FrameRate = 0.016666666666666666,
				FramesSetName = "AnnihilationType_Part3"
			})
		end

		releaseFolder(instance)
	elseif p == "Cancel" then
		clearAttachments(instance)
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	end
end