local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local token = modules.Effects.Token
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(CAM.DebrisModule)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local RaycastHelper = require(CAM.Global.RaycastHelper)
require(modules.Effects.BoatTween)
require(token.BezierCurve)
require(token.TokenUtility)
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
return function(folder, p: string, p2)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart") or folder.PrimaryPart
	folder:FindFirstChild("UpperTorso")

	if p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Heel_Bash_Effects", folder.Name)
	local parent = debree:FindFirstChild(name)

	if p == "Start" then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 10)
		local clone = assets.SkillInitialFX:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(folder))
		DebrisModule:AddItem(clone, 6)
		vfxUtility.PlaySound(sounds, "Attempt", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.075,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
	elseif parent == nil then
		return
	end

	if p == "Teleport" then
		local clone = assets.TeleportLines:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(folder))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(sounds, "Teleport", humanoidRootPart, true)
		local descendants = folder:GetDescendants()

		for _, part in descendants do
			if not ((part:IsA("MeshPart") or part:IsA("Part")) and part.Transparency == 0) then
				continue
			end

			part.Transparency = 1
			local v3 = part
			task.delay(0.1, function()
				v3.Transparency = 0
			end)
		end

		task.delay(0.1, function()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
			vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(folder))
		end)
	elseif p == "Punch" then
		local clone = assets.Impact2:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.2056884765625, -0.15644621849060059, -3.944091796875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			1.5707963705062866
		))
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(folder))
		DebrisModule:AddItem(clone, 6)
		TweenService:Create(clone.Impact2.SurfaceLight, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone.Impact2.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		Cam_Shaker(clone.Impact2.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Kick" then
		local rightFoot = folder:FindFirstChild("RightFoot")
		task.delay(0.2, function()
			local clone = assets.FireRFoot:Clone()
			clone:PivotTo(rightFoot.CFrame)
			clone.Anchored = false
			clone.Parent = parent
			local weld = Instance.new("Weld")
			weld.Part0 = rightFoot
			weld.Part1 = clone
			weld.Parent = rightFoot
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(folder))
			DebrisModule:AddItem(clone, 4)
			local clone2 = assets.HandInirial:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Parent = parent
			vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(folder))
			DebrisModule:AddItem(clone2, 6)
			task.wait(0.5)
			vfxUtility.EnableAll(clone, false)
		end)
	elseif p == "Slam" then
		local v3 = CFrame.new(p2 or humanoidRootPart.Position - Vector2.new(0, 2.5, 0)) * humanoidRootPart.CFrame.Rotation
		local clone = assets.NezGroundCrater3:Clone()
		clone.CFrame = v3 * CFrame.new(0, -1.5, 0)
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(folder))
		DebrisModule:AddItem(clone, 6)
		OuwCraters.Scales({
			Center = humanoidRootPart,
			Radius = 10,
			Count = 15,
			ScaleMult = 1.3,
			OffsetMargin = 4
		})
		OuwCraters.Scales({
			Center = humanoidRootPart,
			Radius = 19,
			Count = 15,
			ScaleMult = 0.9,
			OffsetMargin = 4
		})
		OuwCraters.Scales({
			Center = humanoidRootPart,
			Radius = 22,
			Count = 18,
			ScaleMult = 1.1,
			OffsetMargin = 7
		})
		task.spawn(function()
			TokenKit.GroundRocks({
				CF = clone.CFrame,
				InnerRadius = 19,
				OuterRadius = 21,
				Velocity = {
					Min = 20,
					Max = 40
				},
				Size = {
					Min = 1,
					Max = 3
				},
				RayParams = RaycastHelper.Crater
			})
		end)
		TweenService:Create(clone.PointLightAtt.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		Cam_Shaker(v3.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 1.1,
			SustainTime = 0.2,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end