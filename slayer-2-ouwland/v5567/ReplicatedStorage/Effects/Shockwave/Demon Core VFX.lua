local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local TokenKit = require(CAM.Client.Modules.Effects.Token.TokenKit)
local debree = workspace.Debree
local v = CFrame.new(0.302, -1.158, -4.283) * CFrame.Angles(0, 1.5707963267948966, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-DemonCore`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-DemonCore`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 5.829259259259259)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(parent)
	return (debree:FindFirstChild((`{parent.Name}-DemonCore`)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDustSettingsFromRay(raycastResult: RaycastResult?)
	if raycastResult then
		return vfxUtility.GetDustColorSettings(raycastResult.Instance)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDustSettingsAtPosition(position: Vector3)
	return getDustSettingsFromRay(workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	))
end

local function attachHandEffect(parent, childName: string, childName2: string, name: string)
	local child = script.Assets.Attachments:FindFirstChild(childName2)

	if not child then
		return nil
	end

	local child2 = parent:FindFirstChild(childName)

	if not child2 then
		return nil
	end

	local child3 = child2:FindFirstChild(name)

	if child3 then
		vfxUtility.EnableAll(child3, false)
		DebrisModule:AddItem(child3, 1)
	end

	local clone = child:Clone()
	clone.Name = name
	clone.Parent = child2
	vfxUtility.EnableAll(clone, true, vfxUtility.Owned(parent))
	DebrisModule:AddItem(clone, 5.829259259259259)
	return clone
end

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function clearHandEffects(parent)
	local leftHand = parent:FindFirstChild("LeftHand")
	local demonCoreLeftHandEff = leftHand and leftHand:FindFirstChild("DemonCoreLeftHandEff")

	if demonCoreLeftHandEff then
		local pointLight = demonCoreLeftHandEff:FindFirstChild("PointLight")

		if pointLight then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 0
			}):Play()
		end

		vfxUtility.EnableAll(demonCoreLeftHandEff, false)
		DebrisModule:AddItem(demonCoreLeftHandEff, 1)
	end

	local rightHand = parent:FindFirstChild("RightHand")
	local demonCoreRightHandEff = rightHand and rightHand:FindFirstChild("DemonCoreRightHandEff")

	if demonCoreRightHandEff then
		local pointLight = demonCoreRightHandEff:FindFirstChild("PointLight")

		if pointLight then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 0
			}):Play()
		end

		vfxUtility.EnableAll(demonCoreRightHandEff, false)
		DebrisModule:AddItem(demonCoreRightHandEff, 1)
	end
end

local function spawnFinishBurst(humanoidRootPart, p)
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.1,
		Amplitude = 0.1,
		SustainTime = 0.3,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	})
	local asset = vfxUtility.cloneAsset(
		script.Assets,
		p,
		"Intensitylines",
		humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0),
		0.2
	)
	vfxUtility.EmitAll(asset, vfxUtility.Owned(humanoidRootPart))
	task.delay(0.1, function()
		local dustSettingsAtPosition = getDustSettingsAtPosition(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local asset2 = vfxUtility.cloneAsset(
			script.Assets,
			p,
			"Vanish",
			humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0),
			1
		)
		vfxUtility.EmitAll(asset2, vfxUtility.Owned(humanoidRootPart, dustSettingsAtPosition))
	end)
end

local function spawnRapidPunches(instance, humanoidRootPart, vector2: Vector3)
	local asset = vfxUtility.cloneAsset(script.Assets, instance.Parent, "Barrage", humanoidRootPart.CFrame, 1.5)
	local primaryPart = asset.PrimaryPart
	Ouwmit.Emit(asset, Ouwmit.Owned(humanoidRootPart, getDustSettingsAtPosition(humanoidRootPart.Position)))
	vfxUtility.WeldConstraint(humanoidRootPart, primaryPart)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)
	local v2 = vector3.Magnitude <= 0.01 and createVector(0, 0, 1) or vector3.Unit

	for _ = 1, 16 do
		if instance.Parent == nil or instance:GetAttribute("BarrageActive") ~= true then
			break
		end

		local v3 = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v2) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		)
		local v4 = math.rad((math.random(-30, 30)))
		local cframe = CFrame.Angles(v4, v4, 0)
		local cframe2 = CFrame.new(4, math.random(-2, 2), math.random(-2, 2))
		local v5 = v3 * cframe * cframe2
		local asset2 = vfxUtility.cloneAsset(script.Assets, instance, "RapidPunch", v5, 2.57)

		if asset2:IsA("Model") then
			asset2:ScaleTo(math.random(10, 12.5) / 10)
		end

		Ouwmit.Emit(asset2, Ouwmit.Owned(humanoidRootPart))

		if asset2.PrimaryPart then
			TweenService:Create(
				asset2.PrimaryPart,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					CFrame = asset2.PrimaryPart.CFrame * CFrame.new(math.random(1, 3), 0, 0)
				}
			):Play()
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.1,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.05728395061728394)
	end
end

return function(parent, p: string, position, normal, instance, vector2: Vector3?, part)
	local WAIT_INTERVAL = 0.2
	local DISTANCE_EPSILON = 0.01

	if not parent then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		clearHandEffects(parent)
		destroyFolder(parent) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{parent.Name}-DemonCore`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 5.829259259259259)
		configuration:SetAttribute("BarrageActive", false)
		vfxUtility.PlaySound(script.Sounds, "DemonCoreJump", humanoidRootPart, true)
		local asset = vfxUtility.cloneAsset(
			script.Assets,
			configuration,
			"JumpEff",
			humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
			2
		)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(parent, getDustSettingsAtPosition(humanoidRootPart.Position)))
		attachHandEffect(parent, "LeftHand", "LeftHandEff", "DemonCoreLeftHandEff")
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "WaveLong" then
		local folder = findFolder(parent) -- equivalent call inferred; original call site unknown

		if not folder then
			destroyFolder(parent) -- equivalent call inferred; original call site unknown
			folder = Instance.new("Configuration")
			folder.Name = `{parent.Name}-DemonCore`
			folder.Parent = debree
			DebrisModule:AddItem(folder, 5.829259259259259)
		end

		local asset = vfxUtility.cloneAsset(script.Assets, folder, "Shoot", humanoidRootPart.CFrame * v, 1.5)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
		vfxUtility.PlaySound(script.Sounds, "DemonCoreProjectileShoot", humanoidRootPart, true)
		clearHandEffects(parent)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		if typeof(part) ~= "Instance" then
			part = nil
		end

		if not (part and part:IsA("BasePart")) then
			part = (debree:FindFirstChild("Projectiles") or debree):WaitForChild(normal, 0.35)
		end

		if part then
			local asset2 = vfxUtility.cloneAsset(script.Assets, folder, "Projectile", part.CFrame, 3)
			vfxUtility.WeldConstraint(part, asset2)
			vfxUtility.EmitAll(asset2, vfxUtility.Owned(parent))
			part.AncestryChanged:Once(function()
				asset2:Destroy()
			end)
		end

		task.wait(2)

		if not (folder.Parent ~= nil and folder:GetAttribute("BarrageActive") ~= true) then
			return
		end

		clearHandEffects(parent)
	elseif p == "Impact" then
		local folder = findFolder(parent) -- equivalent call inferred; original call site unknown

		if not folder then
			destroyFolder(parent) -- equivalent call inferred; original call site unknown
			folder = Instance.new("Configuration")
			folder.Name = `{parent.Name}-DemonCore`
			folder.Parent = debree
			DebrisModule:AddItem(folder, 5.829259259259259)
		end

		local cframe = CFrame.new(position)
		local v3 = cframe.Position + createVector(0, 5, 0)
		local v4

		if normal and normal.Magnitude > 0.001 then
			local unit = normal.Unit
			v3 = cframe.Position + unit * 6
			v4 = unit * -16
		else
			v4 = createVector(-0, -20, -0)
		end

		local raycastResult = workspace:Raycast(v3, v4, RaycastHelper.Crater)
		local asset = vfxUtility.cloneAsset(script.Assets, folder, "GroundImpact", cframe, 3)
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = cframe.Position
		end

		if not normal then
			if raycastResult then
				normal = raycastResult.Normal or nil
			else
				normal = nil
			end
		end

		if normal and normal.Magnitude > 0.001 then
			local unit = normal.Unit
			local v5 = CFrame.new(position2, position2 - unit) * CFrame.Angles(1.5707963267948966, 0, 0)
			asset:PivotTo(v5)
			local cFrame = asset.CFrame
			cframe = v5 + unit * math.min(
				math.abs((unit:Dot(cFrame.RightVector))) * asset.Size.X * 0.5 + math.abs((unit:Dot(cFrame.UpVector))) * asset.Size.Y * 0.5 + math.abs((unit:Dot(cFrame.LookVector))) * asset.Size.Z * 0.5,
				0.1
			)
		end

		asset:PivotTo(cframe)
		local ground = not raycastResult and asset:FindFirstChild("Ground")

		if ground then
			ground:Destroy()
		end

		vfxUtility.EmitAll(asset, vfxUtility.Owned(parent, getDustSettingsFromRay(raycastResult)))
		vfxUtility.PlaySound(script.Sounds, "DemonCoreProjectileHit", asset, true)
		OuwCraters.Scales({
			Center = cframe,
			Radius = 12,
			Count = 8,
			ScaleMult = 0.9,
			OffsetMargin = 4
		})
		OuwCraters.Scales({
			Center = cframe,
			Radius = 18,
			Count = 12,
			ScaleMult = 1.1,
			OffsetMargin = 7
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = cframe,
			InnerRadius = 10,
			OuterRadius = 30,
			Velocity = {
				Min = 10,
				Max = 30
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.15)

		if not (folder.Parent ~= nil and folder:GetAttribute("BarrageActive") ~= true) then
			return
		end

		clearHandEffects(parent)
	elseif p == "Finish" then
		local folder = findFolder(parent) -- equivalent call inferred; original call site unknown

		if not folder then
			destroyFolder(parent) -- equivalent call inferred; original call site unknown
			folder = Instance.new("Configuration")
			folder.Name = `{parent.Name}-DemonCore`
			folder.Parent = debree
			DebrisModule:AddItem(folder, 5.829259259259259)
		end

		if normal == false then
			folder:SetAttribute("BarrageActive", false)
			clearHandEffects(parent)
		else
			folder:SetAttribute("BarrageActive", true)
			local v3

			if vector2 and typeof(vector2) == "Vector3" and vector2.Magnitude > DISTANCE_EPSILON then
				local vector3 = Vector3.new(vector2.X, 0, vector2.Z)
				v3 = vector3.Magnitude <= DISTANCE_EPSILON and createVector(0, 0, 1) or vector3.Unit
			else
				if instance and instance.Parent then
					position = instance.Position
				elseif typeof(position) ~= "Vector3" then
					position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
				end

				local v4 = position - humanoidRootPart.Position
				local vector3 = Vector3.new(v4.X, 0, v4.Z)

				if vector3.Magnitude <= DISTANCE_EPSILON then
					local lookVector = humanoidRootPart.CFrame.LookVector
					vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
				end

				v3 = vector3.Magnitude <= DISTANCE_EPSILON and createVector(0, 0, 1) or vector3.Unit
			end

			attachHandEffect(parent, "RightHand", "LeftHandEff", "DemonCoreRightHandEff")
			spawnFinishBurst(humanoidRootPart, folder)
			local clone = script.Assets.Attachments.IceHighlight:Clone()
			clone.Parent = parent
			TweenService:Create(clone, TweenInfo.new(0.1), {
				FillTransparency = 0.1
			}):Play()
			DebrisModule:AddItem(clone, 0.1)
			task.delay(0.4, function()
				if folder.Parent == nil then
					return
				end

				spawnRapidPunches(folder, humanoidRootPart, v3)
			end)
			task.delay(1.5703703703703704, function()
				if folder.Parent == nil then
					return
				end

				clearHandEffects(parent)
				task.wait(0.9996296296296294)

				if folder.Parent == nil then
					return
				end

				folder:SetAttribute("BarrageActive", false)
				clearHandEffects(parent)
			end)
			task.wait(0.1)

			if folder.Parent == nil then
				return
			end

			vfxUtility.PlaySound(script.Sounds, "DemonCoreBarrageStart", humanoidRootPart, true)
			task.wait(WAIT_INTERVAL)

			if folder.Parent == nil then
				return
			end

			spawnFinishBurst(humanoidRootPart, folder)
			task.wait(WAIT_INTERVAL)

			if folder.Parent == nil then
				return
			end

			vfxUtility.PlaySound(script.Sounds, "DemonCoreBarrage", humanoidRootPart, true)
			task.wait(0.8)

			if folder.Parent == nil then
				return
			end

			local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v3)
			local asset = vfxUtility.cloneAsset(script.Assets, folder, "Shoot", cframe * v, 1.5)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.1,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			task.wait(WAIT_INTERVAL)

			if folder.Parent == nil then
				return
			end

			local asset2 = vfxUtility.cloneAsset(script.Assets, folder, "Ending", humanoidRootPart.CFrame, 5)
			Ouwmit.Emit(asset2, Ouwmit.Owned(parent, getDustSettingsAtPosition(humanoidRootPart.Position)))
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.15,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			local position2 = humanoidRootPart.Position + v3 * 50
			local asset3 = vfxUtility.cloneAsset(
				script.Assets,
				folder,
				"Projectile",
				CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v3),
				0.25
			)
			vfxUtility.EmitAll(asset3, vfxUtility.Owned(parent))
			TweenService:Create(asset3, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			task.delay(0.25, function()
				if asset3.Parent == nil then
					return
				end

				vfxUtility.EnableAll(asset3, false)
			end)
		end
	elseif p == "Cancel" then
		local folder = findFolder(parent) -- equivalent call inferred; original call site unknown

		if folder then
			folder:SetAttribute("BarrageActive", false)

			for _, child in folder:GetChildren() do
				child:Destroy()
			end

			DebrisModule:AddItem(folder, 1)
		end

		clearHandEffects(parent)
	end
end