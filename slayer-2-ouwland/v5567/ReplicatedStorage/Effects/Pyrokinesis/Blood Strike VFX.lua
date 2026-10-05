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
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterExtension = require(modules.Effects.Craters.CraterExtension)
require(modules.Effects.BoatTween)
local BezierCurve = require(token.BezierCurve)
local TokenUtility = require(token.TokenUtility)
require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = {
	Min = {
		X = 5,
		Y = 5,
		Z = 5
	},
	Max = {
		X = 10,
		Y = 10,
		Z = 10
	}
}
local v2 = {
	Duration = 0.1,
	EasingStyle = Enum.EasingStyle.Linear,
	EasingDirection = Enum.EasingDirection.InOut,
	LookAt = true
}

local function createBezier(rightHand, clone)
	local position = clone.Position
	local position2 = rightHand.Position
	local min = v.Min
	local max = v.Max
	local v3 = TokenUtility.GetRandomNumber(min.X, max.X, true) * TokenUtility.GetRandomSign()
	local v4 = TokenUtility.GetRandomNumber(min.Y, max.Y, true) * TokenUtility.GetRandomSign()
	local v5 = TokenUtility.GetRandomNumber(min.Z, max.Z, true) * TokenUtility.GetRandomSign()
	local randomNumber = TokenUtility.GetRandomNumber(0.4, 0.6, true)
	local cframe = CFrame.Angles(CFrame.lookAt(clone.Position, position2):ToEulerAnglesXYZ())
	local v6 = CFrame.new(position:Lerp(position2, randomNumber)) * cframe * CFrame.new(v3, v4, v5)
	BezierCurve.Play(clone, { position, v6.Position, position2 }, false, v2)
	clone.Transparency = 1
	TokenUtility.DelayDestruction(0.5, clone)
end

return function(instance, p: string, instance2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Blood_Strike_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 or (parent == nil or parent.Parent == nil) and p ~= "Start" then
		return
	end

	if p == "Start" then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 5)
		local rightHand = instance:FindFirstChild("RightHand")

		if not rightHand then
			return
		end

		local clone = assets.HandInirial:Clone()
		clone.Parent = parent
		clone.CFrame = rightHand.CFrame
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "Start", humanoidRootPart, true)
		task.spawn(function()
			for _ = 1, 8 do
				local clone2 = assets.trail:Clone()
				clone2.Position = clone.Position + Vector3.new(
					math.random(-10, 10),
					math.random(-10, 10),
					math.random(-10, 10)
				)
				clone2.Parent = parent
				createBezier(rightHand, clone2)
				task.wait(0.01)
			end
		end)
		task.wait(0.1)
		local clone2 = assets.FireHand:Clone()
		clone2.Parent = parent
		clone2:PivotTo(rightHand.CFrame)
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		local weld = Instance.new("Weld")
		weld.Part0 = rightHand
		weld.Part1 = clone2
		weld.Parent = rightHand
	elseif parent == nil then
		return
	end

	if p == "Dash" then
		local clone = assets.DashnHit:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.1171875, -2.9046151638031006, 0.09063720703125)
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		CraterExtension.Ground(humanoidRootPart.Position, 7, createVector(1.5, 1.5, 2), nil, 2, false, 2)
		local clone2 = assets.RushLines:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0.078369140625, -0.3877224922180176, 1.115966796875) * CFrame.fromEulerAnglesYXZ(
			-0,
			3.1415927410125732,
			0
		)
		clone2.Parent = parent
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(humanoidRootPart, clone2)
		DebrisModule:AddItem(clone2, 1.5)
		local clone3 = assets.Finish:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.615440607070923, 2.89837646484375) * CFrame.fromEulerAnglesYXZ(
			-0,
			3.1415927410125732,
			0
		)
		clone3.Parent = parent
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 1.5)
		vfxUtility.WeldConstraint(humanoidRootPart, clone3)
	elseif p == "Release" then
		local fireHand = parent:WaitForChild("FireHand", 0.25)
		local rushLines = parent:FindFirstChild("RushLines")
		local finish = parent:FindFirstChild("Finish")

		if fireHand then
			vfxUtility.EnableAll(fireHand, false)
			DebrisModule:AddItem(fireHand, 2)
		end

		if rushLines then
			vfxUtility.EnableAll(rushLines, false)
		end

		if finish then
			vfxUtility.EnableAll(finish, false)
		end

		vfxUtility.PlaySound(sounds, "Punch", humanoidRootPart, true)
		local clone = assets.Impact:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.2056884765625, -0.15644621849060059, -3.944091796875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			1.5707963705062866
		)
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		TweenService:Create(clone.SurfaceLight, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.75,
			SustainTime = 0.1,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone2 = assets.DashnHit:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.1171875, -2.9046151638031006, 0.09063720703125)
		clone2.Parent = parent
		vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 6)
	elseif p == "Impact2" then
		local clone = assets.Impact2:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.2056884765625, -0.15644621849060059, -3.944091796875) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			1.5707963705062866
		))
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		TweenService:Create(clone.Impact2.SurfaceLight, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone.Impact2.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		Cam_Shaker(clone.Impact2.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 0.85,
			SustainTime = 0.1,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone2 = assets.DashnHit:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.1171875, -2.9046151638031006, 0.09063720703125)
		clone2.Parent = parent
		vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 6)
	elseif p == "Victim" then
		local clone = assets.VictimHit:Clone()
		clone:PivotTo(instance2:GetPivot())
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
	elseif p == "Cancel" then
		parent:Destroy()
	end
end