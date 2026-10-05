local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local debree = workspace.Debree

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-ExplosiveFury`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-ExplosiveFury`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 9.275)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(p)
	return (debree:FindFirstChild((`{p.Name}-ExplosiveFury`)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDustSettingsAtPosition(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)

	if raycastResult then
		return vfxUtility.GetDustColorSettings(raycastResult.Instance)
	end

	return nil
end

local function clearDashEffect(instance)
	local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

	if not folder then
		return
	end

	folder:SetAttribute("DashActive", false)
	local dashEffect = folder:FindFirstChild("DashEffect")

	if dashEffect then
		local value = dashEffect.Value

		if value then
			vfxUtility.EnableAll(value, false)
			DebrisModule:AddItem(value, 1)
		end

		dashEffect:Destroy()
	end

	local dashLoopSound = folder:FindFirstChild("DashLoopSound")

	if dashLoopSound then
		local value = dashLoopSound.Value

		if value and value:IsA("Sound") then
			value:Stop()
			DebrisModule:AddItem(value, 1)
		end

		dashLoopSound:Destroy()
	end
end

return function(instance, p: string, lookVector, p2)
	if not instance then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-ExplosiveFury`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 9.275)
		DebrisModule:AddItem(configuration, 9.275)
		local dustSettingsAtPosition = getDustSettingsAtPosition(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local asset = vfxUtility.cloneAsset(script.Assets, configuration, "SkillInitialFX", humanoidRootPart.CFrame, 3)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, dustSettingsAtPosition))
		vfxUtility.PlaySound(script.Sounds, "ExplosiveFuryStart", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		configuration:SetAttribute("DashActive", true)
		task.wait(0.75)

		if configuration:GetAttribute("DashActive") ~= true then
			return
		end

		vfxUtility.PlaySound(script.Sounds, "ExplosiveFuryLunge", humanoidRootPart, true)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local attachments = script.Assets:FindFirstChild("Attachments")
		local dashAttach = attachments and attachments:FindFirstChild("DashAttach") or script.Assets:FindFirstChild("DashAttach")

		if not dashAttach then
			return
		end

		local clone = dashAttach:Clone()
		clone.Parent = humanoidRootPart
		vfxUtility.ToggleWithColor(clone, true, v.Color, nil, instance)
		DebrisModule:AddItem(clone, 8)
		local v2 = configuration:FindFirstChild("DashEffect")

		if v2 == nil then
			v2 = Instance.new("ObjectValue")
			v2.Name = "DashEffect"
			v2.Parent = configuration
		end

		if v2.Value then
			vfxUtility.EnableAll(v2.Value, false)
			DebrisModule:AddItem(v2.Value, 1)
		end

		v2.Value = clone
		local v3 = vfxUtility.PlaySound(script.Sounds, "ExplosiveFuryDashLoop", humanoidRootPart)

		if v3 then
			local v4 = configuration:FindFirstChild("DashLoopSound")

			if v4 == nil then
				v4 = Instance.new("ObjectValue")
				v4.Name = "DashLoopSound"
				v4.Parent = configuration
			end

			if v4.Value and v4.Value:IsA("Sound") then
				v4.Value:Stop()
				DebrisModule:AddItem(v4.Value, 1)
			end

			v4.Value = v3
		end
	elseif p == "Fury" then
		clearDashEffect(instance)
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not folder then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			folder = Instance.new("Configuration")
			folder.Name = `{instance.Name}-ExplosiveFury`
			folder.Parent = debree
			DebrisModule:AddItem(folder, 9.275)
		end

		folder:SetAttribute("FuryActive", true)
		local asset = vfxUtility.cloneAsset(script.Assets, folder, "Barrage", humanoidRootPart.CFrame, 1.5)
		Ouwmit.Emit(asset, Ouwmit.Owned(instance, getDustSettingsAtPosition(humanoidRootPart.Position)))
		vfxUtility.WeldConstraint(humanoidRootPart, asset.PrimaryPart)
		vfxUtility.PlaySound(script.Sounds, "ExplosiveFuryBarrage", humanoidRootPart, true)
	elseif p == "Wave" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not folder or folder:GetAttribute("FuryActive") ~= true then
			return
		end

		if typeof(lookVector) ~= "Vector3" then
			lookVector = humanoidRootPart.CFrame.LookVector
		end

		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector2.Magnitude <= 0.01 then
			local lookVector2 = humanoidRootPart.CFrame.LookVector
			vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)
		end

		local v = vector2.Magnitude <= 0.01 and createVector(0, 0, 1) or vector2.Unit
		local v2 = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		)
		local v3 = math.rad((math.random(-15, 15)))
		local cframe = CFrame.Angles(0, v3, 0)
		local cframe2 = CFrame.new(2, math.random(-3, 3), math.random(-1, 1))
		local v4 = v2 * cframe * cframe2
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v5 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local asset = vfxUtility.cloneAsset(script.Assets, folder, "RapidPunch", v4, 2)
		asset:ScaleTo(math.random(10, 13.5) / 10)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
		Ouwmit.Emit(asset, Ouwmit.Owned(instance, v5))
		TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = asset.PrimaryPart.CFrame * CFrame.new(math.random(1, 3), 0, 0)
		}):Play()
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.1,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		if p2 == true then
			local asset2 = vfxUtility.cloneAsset(script.Assets, folder, "Ending", humanoidRootPart.CFrame, 4)
			Ouwmit.Emit(asset2, Ouwmit.Owned(instance, getDustSettingsAtPosition(humanoidRootPart.Position)))
			vfxUtility.PlaySound(script.Sounds, "ExplosiveFuryFinalHit", humanoidRootPart, true)
		end

		task.wait(0.3)

		if asset and asset.Parent then
			vfxUtility.EnableAll(asset, false)
		end
	elseif p == "Cancel" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder then
			folder:SetAttribute("FuryActive", false)
			clearDashEffect(instance)

			for _, child in folder:GetChildren() do
				child:Destroy()
			end

			DebrisModule:AddItem(folder, 1)
		end
	end
end