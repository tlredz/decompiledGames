local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local token = modules.Effects.Token
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
require(modules.Effects.BoatTween)
local BezierCurve = require(token.BezierCurve)
local TokenUtility = require(token.TokenUtility)
local TokenKit = require(token.TokenKit)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
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

local _ = {
	CFrame.new(0.3939208984375, 0, -6.660888671875),
	CFrame.new(0.022705078125, 0, -17.94342041015625),
	CFrame.new(0.35882568359375, 0, -35.28997802734375)
}
local v3 = {
	CFrame.fromEulerAnglesYXZ(-0, -1.5707963705062866, 0),
	CFrame.fromEulerAnglesYXZ(-0, -1.5707963705062866, 0),
	CFrame.fromEulerAnglesYXZ(-0, -1.5707963705062866, 0)
}
return function(instance, p: string, p2, p3, p4)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Blood_Tiles_Effects", instance.Name)
	local child = debree:FindFirstChild(name)

	if p == "Cancel" or not ((humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250) then
		if (child == nil or child.Parent == nil) and p ~= "Start" then
			return
		end

		if p == "Start" then
			if child ~= nil then
				child:Destroy()
			end

			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = debree
			DebrisModule:AddItem(folder, 5)
			local rightHand = instance:FindFirstChild("RightHand")

			if rightHand == nil then
				return
			end

			local clone = assets.HandInirial:Clone()
			clone.Parent = folder
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
					clone2.Parent = folder
					createBezier(rightHand, clone2)
					task.wait(0.01)
				end
			end)
			task.wait(0.1)
			local clone2 = assets.FireHand:Clone()
			clone2.Parent = folder
			clone2:PivotTo(rightHand.CFrame)
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
			local weld = Instance.new("Weld")
			weld.Part0 = rightHand
			weld.Part1 = clone2
			weld.Parent = rightHand

			while clone2:IsDescendantOf(folder) and clone2.Name ~= "--" do
				task.wait(0.06666666666666667)
			end

			vfxUtility.EnableAll(clone2, false)
		elseif p == "Release" then
			local fireHand = child:FindFirstChild("FireHand")

			if fireHand then
				fireHand.Name = "--"
				DebrisModule:AddItem(fireHand, 2)
			end

			if child == nil or not child:IsDescendantOf(debree) then
				return
			end

			local function createCrater(p5: number)
				local clone = assets[`NezGroundCrater{p5}`]:Clone()
				clone.Parent = child
				clone.CFrame = p3 and CFrame.new(p3.Position, p3.Position + p3.Normal) * v3[p5] * CFrame.Angles(
					0,
					0,
					1.5707963267948966
				) or p4
				vfxUtility.PlaySound(sounds, "PS2bloodCHAINEXPLexpl" .. p2, clone, true)
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone, 6)
				TweenService:Create(clone.PointLightAtt.PointLight, TweenInfo.new(1), {
					Brightness = 0
				}):Play()
				return clone
			end

			if p2 == 1 then
				local crater = createCrater(1)
				Cam_Shaker(crater.Position, {
					FadeInTime = 0,
					Frequency = 0.1,
					Amplitude = 0.5,
					SustainTime = 0.1,
					FadeOutTime = 0.3,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 5,
					Count = 5,
					ScaleMult = 0.4,
					OffsetMargin = 4
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 8,
					Count = 7,
					ScaleMult = 0.7,
					OffsetMargin = 7
				})
				task.spawn(function()
					TokenKit.GroundRocks({
						CF = crater.CFrame,
						InnerRadius = 5,
						OuterRadius = 10,
						Velocity = {
							Min = 5,
							Max = 10
						},
						Size = {
							Min = 0.4,
							Max = 0.6
						},
						RayParams = RaycastHelper.Crater
					})
				end)
			elseif p2 == 2 then
				if child == nil or not child:IsDescendantOf(debree) then
					return
				end

				local crater = createCrater(2)
				Cam_Shaker(crater.Position, {
					FadeInTime = 0,
					Frequency = 0.1,
					Amplitude = 0.5,
					SustainTime = 0.1,
					FadeOutTime = 0.3,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 11,
					Count = 8,
					ScaleMult = 0.9,
					OffsetMargin = 4
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 12,
					Count = 12,
					ScaleMult = 1.1,
					OffsetMargin = 7
				})
				TweenService:Create(crater.PointLightAtt.PointLight, TweenInfo.new(1), {
					Brightness = 0
				}):Play()
				task.spawn(function()
					TokenKit.GroundRocks({
						CF = crater.CFrame,
						InnerRadius = 8,
						OuterRadius = 13,
						Velocity = {
							Min = 10,
							Max = 20
						},
						Size = {
							Min = 1,
							Max = 2
						},
						RayParams = RaycastHelper.Crater
					})
				end)
			elseif p2 == 3 then
				if child == nil or not child:IsDescendantOf(debree) then
					return
				end

				local crater = createCrater(3)
				Cam_Shaker(crater.Position, {
					FadeInTime = 0,
					Frequency = 0.1,
					Amplitude = 1,
					SustainTime = 0.2,
					FadeOutTime = 0.5,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 19,
					Count = 15,
					ScaleMult = 0.9,
					OffsetMargin = 4
				})
				OuwCraters.Scales({
					Center = crater,
					Radius = 22,
					Count = 18,
					ScaleMult = 1.1,
					OffsetMargin = 7
				})
				TweenService:Create(crater.PointLightAtt.PointLight, TweenInfo.new(1), {
					Brightness = 0
				}):Play()
				task.spawn(function()
					TokenKit.GroundRocks({
						CF = crater.CFrame,
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
			end
		elseif p == "Cancel" then
			local release = humanoidRootPart:FindFirstChild("Release")

			if release and release.ClassName == "Sound" then
				release:Destroy()
			end

			child:Destroy()
		end
	else
		local release = humanoidRootPart:FindFirstChild("Release")

		if release and release.ClassName == "Sound" then
			release:Destroy()
		end

		if child ~= nil then
			child:Destroy()
		end
	end
end