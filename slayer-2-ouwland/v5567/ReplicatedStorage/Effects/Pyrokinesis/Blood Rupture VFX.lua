local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage2.CAM.Client.Modules.Effects.Craters.OuwCraters)
local CraterEffects = require(modules.Effects.Craters.CraterEffects)
local ImpactFrames = require(modules.Effects.ImpactFrames)
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = {
	{
		SlashOffset = CFrame.new(-2.48, -0.75, -26.28) * CFrame.fromEulerAnglesYXZ(-0.41, 1.89, 0.52),
		HitOffset = CFrame.new(0.02, -2.5, -28.6) * CFrame.fromEulerAnglesYXZ(-0, -1.57, 0),
		WindOffset = CFrame.new(-0.04, -2.89, -28.11) * CFrame.fromEulerAnglesYXZ(-0, -1.57, 0)
	},
	{
		SlashOffset = CFrame.new(1.57, -1.37, -26.11) * CFrame.fromEulerAnglesYXZ(-0.24, -2.18, -0.61),
		HitOffset = CFrame.new(0.02, -2.505007028579712, -28.60369873046875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		),
		WindOffset = CFrame.new(-0.0425412654876709, -2.8950772285461426, -28.118410110473633) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		)
	},
	{
		SlashOffset = CFrame.new(-1.3021240234375, -0.22738003730773926, -26.65362548828125) * CFrame.fromEulerAnglesYXZ(
			-0.44045478105545044,
			1.9469565153121948,
			0.5047235488891602
		),
		HitOffset = CFrame.new(0.0234375, -2.505007028579712, -28.60369873046875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		),
		WindOffset = CFrame.new(-0.0425412654876709, -2.8950772285461426, -28.118410110473633) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		)
	},
	{
		SlashOffset = CFrame.new(0.58966064453125, -0.547738790512085, -25.675201416015625) * CFrame.fromEulerAnglesYXZ(
			-0.14927302300930023,
			-2.0481066703796387,
			-0.6423813104629517
		),
		HitOffset = CFrame.new(0.0234375, -2.505007028579712, -28.60369873046875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		),
		WindOffset = CFrame.new(0.33966684341430664, -2.447082996368408, -27.004589080810547) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.480425238609314,
			0
		)
	},
	{
		SlashOffset = CFrame.new(-0.40532398223876953, 1.1341500282287598, -23.777034759521484) * CFrame.fromEulerAnglesYXZ(
			-0.1217319667339325,
			2.8925249576568604,
			0.10485552996397018
		),
		HitOffset = CFrame.new(0.0234375, -2.505007028579712, -28.60369873046875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		),
		WindOffset = CFrame.new(-0.0425412654876709, -2.8950772285461426, -28.118410110473633) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		)
	}
}

local function ParticlePull(clone, leftFoot, duration: number, value: number?)
	for _, child in clone:GetChildren() do
		child.Parent = leftFoot
		child.Enabled = true
		local v2 = child
		task.delay(duration, function()
			v2.Enabled = false
			DebrisModule:AddItem(v2, value or 2)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.5)
end

local function callSlashEffect(p, parent, p2: number)
	local clone = assets.NezukoSlash1:Clone()
	clone.Parent = parent
	clone:PivotTo(p.CFrame * v[p2].SlashOffset)
	vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(p))
	DebrisModule:AddItem(clone, 3)
	task.wait(0.1)
	local clone2 = assets.Hit:Clone()
	clone2.Parent = parent
	clone2.CFrame = p.CFrame * v[p2].HitOffset
	vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(p))
	DebrisModule:AddItem(clone2, 6)
	local clone3 = assets.GroundWind:Clone()
	clone3.Parent = parent
	clone3.CFrame = p.CFrame * v[p2].WindOffset
	DebrisModule:AddItem(clone3, 2)
	TweenService:Create(clone3.Decal, TweenInfo.new(1), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(1), {
		Orientation = createVector(0, 230, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.5), {
		Size = createVector(9.276, 0.07, 9.306)
	}):Play()
	TweenService:Create(clone3.Mesh, TweenInfo.new(0.5), {
		Scale = createVector(4.216, 0.268, 4.23)
	}):Play()

	if p2 == 4 then
		local clone4 = assets.CamerDust2:Clone()
		clone4.Parent = parent
		clone4.CFrame = p.CFrame * CFrame.new(0.33966684341430664, -2.447082996368408, -27.004589080810547) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.480425238609314,
			0
		)
		vfxUtility.EmitAll(clone4:GetDescendants(), vfxUtility.Owned(p))
		DebrisModule:AddItem(clone4, 6)
	elseif p2 == 5 then
		BlurEffect() -- equivalent call inferred; original call site unknown
	end
end

return function(instance, p, instance2, p2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	local v2 = { instance, instance2 }
	local name = string.format("%s Blood_Rupture_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if p == "Start" then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 15)
		local clone = assets.StartEffect:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.02,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		vfxUtility.PlaySound(sounds, "Start", humanoidRootPart, true)
	elseif parent == nil then
		return
	end

	if p == "Movement" then
		local clone = assets.Dash:Clone()
		clone.Parent = parent
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		vfxUtility.PlaySound(sounds, "Dash", humanoidRootPart, true)
		local clone2 = assets.MovementThingy:Clone()
		clone2.Parent = parent
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0.51, -1.39, 6.63)
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 6)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone2
		weld.Parent = humanoidRootPart
		weld.C0 = CFrame.new(0.51, -1.39, -0.63)
		DebrisModule:AddItem(weld, 6)
	elseif p == "MovementStop" then
		local movementThingy = parent:WaitForChild("MovementThingy", 2)

		if movementThingy then
			movementThingy.Parent = parent.Parent

			for _, beam in movementThingy:GetDescendants() do
				if beam:IsA("Beam") and beam.Brightness == 1 then
					TweenService:Create(beam, TweenInfo.new(0.1), {
						Brightness = 0
					}):Play()
				end
			end

			task.wait(0.1)
			vfxUtility.EnableAll(movementThingy, false)
			DebrisModule:AddItem(movementThingy, 1.5)
		end
	elseif p == "Hit" then
		local clone = assets.MaceHitfr:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.27, -1.45, -1.87) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.57,
			1.56
		)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.06,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
	elseif p == "Initial" then
		local leftFoot = instance2:FindFirstChild("LeftFoot") or instance2:FindFirstChild("Left Leg") or instance2:FindFirstChild("HumanoidRootPart")

		if leftFoot ~= nil then
			ParticlePull(assets.FootDust:Clone(), leftFoot, 1.5, 0.5)
		end

		task.delay(0.3, function()
			local clone = assets.CamerDust:Clone()
			clone.Parent = parent
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0.33, -2.44, -27) * CFrame.fromEulerAnglesYXZ(
				-0,
				-1.48,
				0
			)
			vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone, 6)
			task.wait(0.5)
			local blurEffect = Instance.new("BlurEffect")
			local lighting = game.Lighting
			blurEffect.Size = 5
			blurEffect.Parent = lighting
			DebrisModule:AddItem(blurEffect, 0.9)
		end)
	elseif p == "Slashes" then
		task.spawn(function()
			local count = 0

			for _, v5 in {
				2.048,
				0.715,
				0.587,
				0.377,
				0.586
			} do
				task.wait(v5 - 0.025)
				count += 1
				task.spawn(callSlashEffect, humanoidRootPart, parent, count)
			end
		end)
	elseif p == "Stomp" then
		local clone = assets.FinalKick:Clone()
		clone.Parent = parent
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.5455322265625, -2.9995005130767822, -27.00384521484375))
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 5)
		local clone2 = assets.GroundWind:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(
			-0.0425412654876709,
			-2.8950772285461426,
			-28.118410110473633
		) * CFrame.fromEulerAnglesYXZ(-0, -1.5707963705062866, 0)
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 2)
		TweenService:Create(clone2.Decal, TweenInfo.new(1), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(1), {
			Orientation = createVector(0, 230, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.5), {
			Size = createVector(30.835, 4.039, 30.936)
		}):Play()
		TweenService:Create(clone2.Mesh, TweenInfo.new(0.5), {
			Scale = createVector(14.016, 15.467, 14.062)
		}):Play()
		local clone3 = assets.ShockGroundWind:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(
			-0.4298224449157715,
			-0.11100435256958008,
			-28.766132354736328
		) * CFrame.fromEulerAnglesYXZ(-0, 3.1415927410125732, 0)
		clone3.Parent = parent
		DebrisModule:AddItem(clone3, 3)
		TweenService:Create(clone3.Decal, TweenInfo.new(2), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(2), {
			Orientation = createVector(0, 230, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5), {
			Size = createVector(20.632, 7.579, 20.698)
		}):Play()
		TweenService:Create(clone3.Mesh, TweenInfo.new(0.5), {
			Scale = createVector(9.378, 29.02, 9.408)
		}):Play()
		OuwCraters.Scales({
			Center = clone.PrimaryPart.CFrame,
			Radius = 10,
			ScaleMult = 0.5,
			Duration = 4.5
		})
		task.spawn(function()
			CraterEffects.new("RisingRocks", clone.PrimaryPart.Position, {
				Iterations = 30,
				BlockSize = { 0.5, 1 },
				Radius = 12,
				Height = { 2, 9 },
				HoldTime = 1,
				AnimationSpeed = 0.1,
				Range = 100,
				delayTime = 0.01
			})
		end)
		TweenService:Create(clone.Crater.PointLight, TweenInfo.new(0.5), {
			Brightness = 30
		}):Play()
		task.wait(0.1)
		task.delay(0.25, function()
			if localPlayer.Character and table.find(v2, localPlayer.Character) then
				ImpactFrames.PlaySet({
					FrameRate = 0.03333333333333333,
					FramesSetName = "Pyro_Part2"
				})
			end
		end)
		BlurEffect() -- equivalent call inferred; original call site unknown
		task.wait(0.35)
		TweenService:Create(clone.Crater.BrightOne, TweenInfo.new(0.1), {
			Transparency = 0
		}):Play()
		task.spawn(function()
			local clone4 = assets.ColorCorrection1:Clone()
			clone4.Parent = Lighting
			task.wait(0.05)
			clone4:Destroy()
			local clone5 = assets.ColorCorrection2:Clone()
			clone5.Parent = Lighting
			task.wait(0.05)
			clone5:Destroy()
		end)
		BlurEffect() -- equivalent call inferred; original call site unknown
		task.spawn(function()
			Cam_Shaker(clone.PrimaryPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.4,
				SustainTime = 0.1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			OuwCraters.Scales({
				Center = clone.PrimaryPart.CFrame,
				ScaleMult = 1.5,
				Radius = 15,
				Duration = 3.5
			})

			for i = 1, 8 do
				local v5 = i
				task.spawn(function()
					TokenKit.GroundRocks({
						CF = clone.PrimaryPart.CFrame,
						InnerRadius = v5 * 5 / 2,
						OuterRadius = v5 * 10 / 2,
						Velocity = {
							Min = 10,
							Max = 60
						},
						Size = {
							Min = 2,
							Max = 4
						}
					})
					task.wait(0.1)
				end)
			end
		end)
		task.wait(3)
		TweenService:Create(clone.Crater.BrightOne, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone.Crater.notBrightOne, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	elseif p == "UltimateCamera" then
		local v5 = p2 or debree:WaitForChild(instance.Name .. "_BloodRuptureCam", 0.2)

		if v5 == nil then
			return
		end

		local clone = assets.CameraVFX:Clone()
		clone.Parent = parent
		clone:PivotTo(v5.PrimaryPart.CFrame)
		local rigidConstraint = clone.Bone.Attachment.RigidConstraint
		local camattach = clone.Bone.camattach
		DebrisModule:AddItem(clone, 6)
		camattach.Parent = v5:FindFirstChild("Bone")
		rigidConstraint.Attachment1 = camattach
		Ouwmit.Emit(clone.WindStuff1, Ouwmit.Owned(instance))
		task.delay(2, function()
			local morebgfx = assets:FindFirstChild("morebgfx")

			if morebgfx then
				local clone2 = morebgfx:Clone()
				clone2.Parent = parent
				clone2:PivotTo(humanoidRootPart.CFrame)
				DebrisModule:AddItem(clone2, 7)
				Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone2.Extras, 4.5)
			end

			local clone2 = assets.Camera_VFX:Clone()
			clone2.Parent = parent
			clone2:PivotTo(v5.PrimaryPart.CFrame)
			local rigidConstraint2 = clone2.Bone.Attachment.RigidConstraint
			local camattach2 = clone2.Bone.camattach
			DebrisModule:AddItem(clone2, 6)
			camattach2.Parent = v5:FindFirstChild("Bone")
			rigidConstraint2.Attachment1 = camattach2
			Ouwmit.Emit(clone2.CameraAuraFX, Ouwmit.Owned(instance))
			task.wait(1)
			Ouwmit.Emit(clone.FireAura, Ouwmit.Owned(instance))
		end)
	elseif p == "Cancel" then
		parent:Destroy()
	end
end