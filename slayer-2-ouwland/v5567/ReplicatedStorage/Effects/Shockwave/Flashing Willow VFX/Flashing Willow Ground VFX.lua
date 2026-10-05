local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local TokenKit = require(CAM.Client.Modules.Effects.Token.TokenKit)
local debree = workspace.Debree
local cframe = CFrame.new(-0.1, 0, -1.7)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-FlashingWillow`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-FlashingWillow`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 15)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(p)
	return (debree:FindFirstChild((`{p.Name}-FlashingWillow`)))
end

local function getDustSettingsAtPosition(position: Vector3, unit: Vector3?)
	local v = position + createVector(0, 5, 0)
	local v2

	if unit and unit.Magnitude > 0.001 then
		local unit2 = unit.Unit
		v = position + unit2 * 5
		v2 = unit2 * -20
	else
		v2 = createVector(0, -20, 0)
	end

	local raycastResult = workspace:Raycast(v, v2, RaycastHelper.Crater)

	if not raycastResult and unit and unit.Magnitude > 0.001 then
		raycastResult = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)
	end

	if raycastResult then
		return vfxUtility.GetDustColorSettings(raycastResult.Instance)
	end

	return nil
end

local function shake(vector2: Vector3, amplitude: number, value: number?, vector3: Vector3?, vector4: Vector3?)
	Cam_Shaker(vector2, {
		FadeInTime = 0,
		Frequency = 0.125,
		Amplitude = amplitude,
		SustainTime = value or 0.3,
		FadeOutTime = 0.2,
		RotationInfluence = vector3 or createVector(0.25, 0.25, 0.25),
		PositionInfluence = vector4 or createVector(1.5, 1.5, 1.5)
	})
end

local function clearAttachmentEffects(instance)
	local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

	if not folder then
		return
	end

	for _, objectValue in folder:GetChildren() do
		if not objectValue:IsA("ObjectValue") then
			continue
		end

		local value = objectValue.Value

		if value then
			vfxUtility.EnableAll(value, false)
			DebrisModule:AddItem(value, 1)
		end

		objectValue:Destroy()
	end
end

return function(instance, p: string, position, _)
	if not instance then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		clearAttachmentEffects(instance)
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-FlashingWillow`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 15)
		configuration:SetAttribute("FinisherTriggered", false)
		vfxUtility.PlaySound(script.Parent.Sounds, "PS2shockwavePOWERSLAMinitiate", humanoidRootPart, true)
		local v = humanoidRootPart.Position + createVector(0, 5, 0)
		local raycastResult = workspace:Raycast(v, createVector(0, -20, 0), RaycastHelper.Crater)
		local v2

		if raycastResult then
			v2 = vfxUtility.GetDustColorSettings(raycastResult.Instance)
		end

		local asset = vfxUtility.cloneAsset(
			script.Parent.Assets,
			configuration,
			"JumpEff",
			humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
			4
		)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v2))
		local attachments = script.Parent.Assets:FindFirstChild("Attachments")
		local leftHandEff = attachments and attachments:FindFirstChild("LeftHandEff")
		local rightHand = leftHandEff and instance:FindFirstChild("RightHand")

		if rightHand then
			local clone = leftHandEff:Clone()
			clone.Parent = rightHand
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "RightHand"
			objectValue.Parent = configuration
			objectValue.Value = clone
			DebrisModule:AddItem(clone, 8)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.1,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		task.wait(0.2)

		if configuration.Parent == nil then
			return
		end

		TokenKit.GroundRocks({
			CF = humanoidRootPart.CFrame,
			InnerRadius = 5,
			OuterRadius = 6,
			Velocity = {
				Min = 10,
				Max = 50
			},
			Size = {
				Min = 0.2,
				Max = 1
			}
		})
	elseif p == "Pulse" or p == "PulseFinal" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local v = folder:GetAttribute("FinisherTriggered") ~= true

		if v then
			folder:SetAttribute("FinisherTriggered", true)
		end

		if p == "Pulse" then
			vfxUtility.PlaySound(script.Parent.Sounds, "PS2shockwavePOWERSLAMslamexplo", humanoidRootPart, true)
		end

		local unit, cframe2, flag

		if typeof(position) == "CFrame" then
			local position2 = position.Position
			local lookVector = position.LookVector

			if lookVector.Magnitude > 0.001 then
				unit = lookVector.Unit
				cframe2 = CFrame.new(position2, position2 - unit) * CFrame.Angles(1.5707963267948966, 0, 0)
			else
				cframe2 = CFrame.new(position2)
				unit = humanoidRootPart.CFrame.UpVector
			end

			flag = true
		else
			if typeof(position) == "Vector3" then
				cframe2 = CFrame.new(position)
			else
				cframe2 = humanoidRootPart.CFrame
			end

			unit = humanoidRootPart.CFrame.UpVector
			flag = false
		end

		local v2

		if flag then
			v2 = cframe2
		else
			v2 = cframe2 * cframe
		end

		local dustSettingsAtPosition = getDustSettingsAtPosition(v2.Position, unit)
		local v3 = not (unit.Magnitude > 0.001) and createVector(0, 1, 0) or unit.Unit

		if v then
			local v4 = cframe2 + v3 * 2.5
			local asset = vfxUtility.cloneAsset(script.Parent.Assets, folder, "Hit3", v4, 7)
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, dustSettingsAtPosition))
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 5
			blurEffect.Parent = Lighting
			DebrisModule:AddItem(blurEffect, 0.3)
			Cam_Shaker(v4.Position, {
				FadeInTime = 0,
				Frequency = 0.125,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})

			for i = 1, 3 do
				task.delay((i - 1) * 0.3 + 0.5, function()
					if folder.Parent == nil then
						return
					end

					Cam_Shaker(v4.Position, {
						FadeInTime = 0,
						Frequency = 0.125,
						Amplitude = 0.2,
						SustainTime = 0.2,
						FadeOutTime = 0.2,
						RotationInfluence = createVector(0.8, 0.8, 0.8),
						PositionInfluence = createVector(3.5, 3.5, 3.5)
					})
				end)
			end

			clearAttachmentEffects(instance)
		else
			local v4 = v2 + v3 * 2.5
			OuwCraters.Scales({
				Center = v4,
				Radius = 6,
				Count = 6,
				ScaleMult = 0.8,
				OffsetMargin = 4
			})
			OuwCraters.Scales({
				Center = v4,
				Radius = 9,
				Count = 5,
				ScaleMult = 0.9,
				OffsetMargin = 5
			})
			task.spawn(TokenKit.GroundRocks, {
				CF = v4,
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
			Cam_Shaker(v4.Position, {
				FadeInTime = 0,
				Frequency = 0.125,
				Amplitude = 0.1,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.5, 1.5, 1.5)
			})
		end
	elseif p == "Cancel" then
		clearAttachmentEffects(instance)
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	end
end