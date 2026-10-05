local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script.Sounds
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)

local function destroyFolder(p)
	local formatted = `{p.Name}-OrdainedFleshVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		child:SetAttribute("Cancelled", true)
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-OrdainedFleshVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 15)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-OrdainedFleshVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

return function(instance, p: string, p2, position, part)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder then
			folder:SetAttribute("BeamFired", true)
			folder.Name = "--"
			task.delay(1.1, function()
				if folder.Parent then
					folder:SetAttribute("Cancelled", true)
					vfxUtility.EnableAll(folder, false)
					DebrisModule:AddItem(folder, 1.3)
				end
			end)
		end
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Startup" then
			destroyFolder(instance)
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-OrdainedFleshVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 15)
			local asset = vfxUtility.cloneAsset(assets, configuration, "Startup", humanoidRootPart.CFrame, 4)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(
					instance,
					raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
				)
			)
			vfxUtility.PlaySound(sounds, "PS2dreamORDAINEDFLESHinit", humanoidRootPart, true)
			task.spawn(function()
				task.wait(0.4)
				local parent = configuration
				local v2

				if parent.Parent == nil then
					v2 = false
				else
					v2 = not parent:GetAttribute("Cancelled")
				end

				if not v2 or asset.Parent == nil then
					return
				end

				asset:PivotTo(humanoidRootPart.CFrame)
			end)

			if p2 == nil then
				return
			end

			local asset2 = vfxUtility.cloneAsset(
				assets,
				configuration,
				"FlowerSpawn",
				p2 * CFrame.Angles(-1.5707963267948966, 0, 0),
				8
			)

			if asset2 == nil then
				return
			end

			local raycastResult2 = workspace:Raycast(
				p2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			local part2 = Instance.new("Part")
			part2.Size = createVector(0.1, 0.1, 0.1)
			part2.Transparency = 1
			part2.Anchored = true
			part2.CanCollide = false
			part2.CFrame = CFrame.new(p2.Position)
			part2.Parent = configuration
			local v2 = vfxUtility.PlaySound(sounds, "PS2dreamORDAINEDFLESHspawn", part2, true)

			if v2 then
				DebrisModule:AddItem(part2, v2.TimeLength + 0.2)
			end

			Cam_Shaker(p2.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			local flowerRig = asset2["Flower Rig"]
			local animator = flowerRig.AnimationController.Animator
			animator:LoadAnimation(assets.OrdainedFleshFlowerStartup):Play()
			vfxUtility.EmitAll(asset2.Emithis, vfxUtility.Owned(instance, v))
			vfxUtility.EmitAll(asset2.MainAura, vfxUtility.Owned(instance, v))
			task.wait(1.67)
			local v3

			if configuration.Parent == nil then
				v3 = false
			else
				v3 = not configuration:GetAttribute("Cancelled")
			end

			if not v3 then
				return
			end

			local track = animator:LoadAnimation(assets.OrdainedFleshFlowerLoop)
			track:Play()
			local begin = flowerRig:FindFirstChild("begin", true)
			vfxUtility.EmitAll(begin, vfxUtility.Owned(instance))
			local flag = false

			local function releaseFlower()
				if flag then
					return
				end

				flag = true

				if not flowerRig.Parent then
					return
				end

				track:Stop()
				animator:LoadAnimation(assets.OrdainedFleshFlowerRelease):Play()
				task.wait(1)

				if flowerRig.Parent then
					asset2:Destroy()
				end
			end

			local beamFiredChangedConnection = configuration:GetAttributeChangedSignal("BeamFired"):Once(function()
				releaseFlower()
			end)
			task.wait(5)

			if not flag then
				if beamFiredChangedConnection.Connected then
					beamFiredChangedConnection:Disconnect()
				end

				releaseFlower()
			end
		elseif p == "ShootStart" then
			vfxUtility.PlaySound(sounds, "PS2dreamORDAINEDFLESHshootstart", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.15,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
		elseif p == "FlowerProjectile" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			local flowerSpawn = folder:FindFirstChild("FlowerSpawn")

			if flowerSpawn == nil then
				return
			end

			local flowerRig = flowerSpawn:FindFirstChild("Flower Rig")

			if not (flowerRig ~= nil and p2 and position) then
				return
			end

			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = flowerSpawn:GetPivot()
			cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
				flowerSpawn:PivotTo(cFrameValue.Value)
			end)
			local pivot = flowerSpawn:GetPivot()
			local upVector = pivot.UpVector
			local vector2 = position - pivot.Position
			local v = vector2 - upVector * vector2:Dot(upVector)

			if v.Magnitude > 0.01 then
				pivot = CFrame.lookAt(pivot.Position, pivot.Position + v, upVector)
			end

			local tween = TweenService:Create(
				cFrameValue,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Value = pivot
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				cFrameValue:Destroy()
			end)

			if typeof(part) ~= "Instance" then
				part = nil
			end

			if not (part and part:IsA("BasePart")) then
				part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(p2, 0.5)
			end

			if not (part and part:IsA("BasePart")) then
				return
			end

			local clone = assets.Orb:Clone()
			clone.CFrame = part.CFrame
			clone.Parent = part
			vfxUtility.WeldConstraint(part, clone)
			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
			vfxUtility.PlaySound(sounds, "PS2dreamORDAINEDFLESHshoot", part, true)
			local shootatt = flowerRig:FindFirstChild("shootatt", true)
			vfxUtility.EmitAll(shootatt, vfxUtility.Owned(instance))
			part.Destroying:Once(function()
				Ouwmit.Enable(clone, false)
				task.wait(1)
				clone:Destroy()
			end)
		elseif p == "BeamFire" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil or (p2 == nil or position == nil) then
				return
			end

			local asset = vfxUtility.cloneAsset(assets, folder, "beamthing", CFrame.lookAt(p2, position), 3)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
			local part2 = Instance.new("Part")
			part2.Size = createVector(0.1, 0.1, 0.1)
			part2.Transparency = 1
			part2.Anchored = true
			part2.CanCollide = false
			part2.CFrame = CFrame.new(p2)
			part2.Parent = folder
			local v = vfxUtility.PlaySound(sounds, "PS2dreamORDAINEDFLESHbeam", part2, true)

			if v then
				DebrisModule:AddItem(part2, v.TimeLength + 0.2)
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.3,
				SustainTime = 0.2,
				FadeOutTime = 0.25,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			local mainEnd = asset.MainBeam.End.MainEnd
			local v2 = (mainEnd.Position - position).Magnitude / 333.33333333333337
			TweenService:Create(mainEnd, TweenInfo.new(v2, Enum.EasingStyle.Linear), {
				Position = position
			}):Play()
		elseif p == "BeamImpact" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			folder:SetAttribute("BeamFired", true)

			if p2 == nil then
				return
			end

			local raycastResult = workspace:Raycast(
				p2 + createVector(0, 2, 0),
				createVector(0, -10, 0),
				RaycastHelper.Crater
			)
			local v = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal
			local v2 = CFrame.lookAt(p2, p2 + v) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local asset = vfxUtility.cloneAsset(assets, folder, "ExplosionRemix", v2, 5)
			local emitAll = vfxUtility.EmitAll
			local owned = vfxUtility.Owned
			local v3

			if raycastResult then
				v3 = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			end

			emitAll(asset, owned(instance, v3))

			if raycastResult then
				local cframe = CFrame.new(raycastResult.Position)
				task.delay(0.1, function()
					OuwCraters.Scales({
						Center = cframe,
						Radius = 8.4,
						Count = 5,
						ScaleMult = 0.72,
						OffsetMargin = 3
					})
				end)
				task.delay(0.3, function()
					OuwCraters.Scales({
						Center = cframe,
						Radius = 24,
						Count = 7,
						ScaleMult = 1.5,
						OffsetMargin = 8
					})
				end)
			end

			Cam_Shaker(p2, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			task.wait(0.5)
			local v4

			if folder.Parent == nil then
				v4 = false
			else
				v4 = not folder:GetAttribute("Cancelled")
			end

			if not v4 then
				return
			end

			Cam_Shaker(p2, "Medium_tiny_shake_preset")
			local beamthing = folder:FindFirstChild("beamthing")

			if beamthing then
				vfxUtility.DisableAll(beamthing)
			end

			local explosion = asset:FindFirstChild("Explosion")

			if explosion then
				explosion:Destroy()
			end

			Ouwmit.Enable(asset, false)
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 5
			blurEffect.Parent = Lighting
			DebrisModule:AddItem(blurEffect, 0.3)
			local colorCorrection = Lighting:FindFirstChild("ColorCorrection")

			if colorCorrection then
				colorCorrection.Enabled = false
				local clone = assets.ColorCorrection1:Clone()
				clone.Enabled = true
				clone.Parent = Lighting
				task.wait(0.03333333333333333)
				clone:Destroy()
				local clone2 = assets.ColorCorrection2:Clone()
				clone2.Enabled = true
				clone2.Parent = Lighting
				task.wait(0.03333333333333333)
				clone2:Destroy()
				colorCorrection.Enabled = true
			end
		end
	end
end