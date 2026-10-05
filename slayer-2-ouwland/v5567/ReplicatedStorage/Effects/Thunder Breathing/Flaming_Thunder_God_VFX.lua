local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local localPlayer = Players.LocalPlayer
local assets = script:FindFirstChild("Assets")
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
local ImpactFrames = require(CAM.Client.Modules.Effects.ImpactFrames)
require(modules.Effects.BoatTween)
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera

local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local function LTN()
	local clone = script.Assets.ColorCorrection:Clone()
	clone.Parent = workspace.Camera
	TweenService:Create(clone, tweenInfo, {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play()
	DebrisModule:AddItem(clone, 0.2)
end

return function(parent, p, parents)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local leftFoot = parent:FindFirstChild("LeftFoot")
	local rightFoot = parent:FindFirstChild("RightFoot")

	if not humanoidRootPart or not leftFoot or not rightFoot or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		local clone = script.Assets.FlamingStartup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0))
		clone.Parent = workspace.Debree
		local clone2 = script.Assets.YellowHighlight:Clone()
		DebrisModule:AddItem(clone2, 1)
		clone2.Parent = parent
		TweenService:Create(clone2, TweenInfo.new(0.4), {
			FillColor = Color3.fromRGB(30, 59, 250),
			OutlineColor = Color3.fromRGB(249, 243, 129),
			FillTransparency = 1.563,
			OutlineTransparency = 0
		}):Play()
		task.delay(0.4, function()
			if clone2 ~= nil and clone2.Parent ~= nil then
				TweenService:Create(clone2, TweenInfo.new(0.3), {
					FillColor = script.Assets.YellowHighlight.FillColor,
					OutlineColor = script.Assets.YellowHighlight.OutlineColor,
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
			end
		end)
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2thunderbreathTCaFstart", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -30,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local _ = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 1, 0)
			color = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 2,
			Count = 6,
			ScaleMult = 0.5,
			Radius = 6
		})
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Attempt" then
		local clone = script.Assets.MissEmit:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0))
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2flyingthundergodFAILwithlessimpact", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -30,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local _ = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 1, 0)
			color = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 2,
			Count = 6,
			ScaleMult = 0.65,
			Radius = 8
		})
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")

		if parent == game.Players.LocalPlayer.Character or vector.magnitude(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position) < 30 then
			LTN()
		end
	elseif p == "Cutscene" then
		table.insert(parents, parent)
		local index = localPlayer.Character and table.find(parents or {}, localPlayer.Character)
		local playSound = vfxUtility.PlaySound
		local v3

		if index then
			v3 = workspace.CurrentCamera or humanoidRootPart
		else
			v3 = humanoidRootPart
		end

		playSound(sounds, "PS2thunderbreathULT", v3, true)
		local clone = assets.FlamingThundergod:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = debree
		vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))
		DebrisModule:AddItem(clone, 8)

		for _, beam in clone:GetDescendants() do
			if not (beam:IsA("Beam") and beam:GetAttribute("EmitDuration") and beam:GetAttribute("EmitDuration") ~= 0) then
				continue
			end

			if beam:GetAttribute("EmitDelay") and beam:GetAttribute("EmitDelay") ~= 0 then
				local v4 = beam
				task.delay(beam:GetAttribute("EmitDelay"), function()
					v4.Enabled = true
					task.delay(v4:GetAttribute("EmitDuration"), function()
						if v4 == nil then
							return
						end

						v4.Enabled = false
					end)
				end)
			else
				beam.Enabled = true
				local v4 = beam
				task.delay(beam:GetAttribute("EmitDuration"), function()
					if v4 == nil then
						return
					end

					v4.Enabled = false
				end)
			end
		end

		for _, parent2 in { rightFoot, leftFoot } do
			local clone2 = assets.Part.Trail:Clone()
			clone2.Parent = parent2
			DebrisModule:AddItem(clone2, 9.5)

			for _, trail in clone2:GetDescendants() do
				if not (trail:IsA("Trail") and trail:GetAttribute("EmitDelay") and trail:GetAttribute("EmitDelay") ~= 0) then
					continue
				end

				local v5 = trail
				task.delay(trail:GetAttribute("EmitDelay"), function()
					v5.Enabled = true
					task.delay(v5:GetAttribute("EmitDuration"), function()
						if v5 == nil then
							return
						end

						v5.Enabled = false
					end)
				end)
			end
		end

		if index then
			local cFrame = humanoidRootPart.CFrame
			local position = cFrame.Position
			task.delay(0.32, function()
				Cam_Shaker(position, "activate_shake")
				task.wait(0.69)
				LTN()
				task.wait(0.10000000000000009)
				LTN()
				task.wait(0.05)
				LTN()
				task.wait(0.05)
				task.wait(1.6099999999999999)
				OuwCraters.Scales({
					Center = cFrame * CFrame.new(0, 0, 3),
					Duration = 2,
					Count = 6,
					ScaleMult = 1,
					Radius = 6
				})
				Cam_Shaker(position, {
					FadeInTime = 0,
					Frequency = 0.15,
					Amplitude = 0.3,
					SustainTime = 1.2,
					FadeOutTime = 0.5,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
				task.wait(1.7399999999999998)
				OuwCraters.Scales({
					Center = cFrame * CFrame.new(0, 0, 3),
					Duration = 2,
					Count = 6,
					ScaleMult = 1,
					Radius = 7
				})
				Cam_Shaker(position, {
					FadeInTime = 0,
					Frequency = 0.15,
					Amplitude = 0.6,
					SustainTime = 0.3,
					FadeOutTime = 0.5,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
				task.wait(0.1900000000000004)
				Cam_Shaker(position, "activate_shake")
				LTN()
				task.wait(0.8599999999999994)
				Cam_Shaker(position, "Medium_tiny_shake_preset")
			end)
			task.delay(5.8, function()
				ImpactFrames.PlaySet({
					FrameRate = 0.022222222222222223,
					FramesSetName = "Flaming_Thunder_God"
				})
			end)
		end
	end
end