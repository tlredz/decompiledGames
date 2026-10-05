local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local currentCamera = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local TweenService = game:GetService("TweenService")
return function(parent, p: string, cFrame, cframe: CFrame?)
	if parent == nil then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 then
		return
	end

	if p == "Start" then
		local clone = script.FlameStartup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		clone.RootPart.PS2flameCHARGEcharge:Play()
		local cFrame2 = humanoidRootPart.CFrame
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(cFrame2.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.15,
			SustainTime = 0.2,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.08, 0.08, 0.08),
			PositionInfluence = createVector(0.3, 0.3, 0.3)
		})
		OuwCraters.Scales({
			Center = cFrame2,
			Duration = 1.4,
			Radius = 6,
			Count = 4,
			ScaleMult = 0.55,
			OffsetMargin = 3
		})
		local raycastResult = workspace:Raycast(cFrame2.Position, cFrame2.UpVector * -10, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
			clone.Startup.Position = raycastResult.Position
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Dust" },
			ColorBlacklist = { "GroundCracks", "Debree22t" }
		} or nil) or nil))
		local clone2 = script.Highlight:Clone()
		clone2.Parent = parent
		task.wait(1)

		if clone2 ~= nil then
			DebrisModule:AddItem(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(1), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end
	elseif p == "Jump" then
		local clone = script.FlameJump:Clone()
		clone:PivotTo(typeof(cFrame) == "CFrame" and cFrame or humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.22,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.35, 0.35, 0.35)
		})
	elseif p == "Release" then
		if cFrame ~= nil then
			local v = cframe or humanoidRootPart.CFrame

			for _, child in ipairs(script.Attachments.Tiger:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = cFrame.RootPart.Mouth
				DebrisModule:AddItem(clone, 3.5)
				Ouwmit.Emit(clone, Ouwmit.Owned(parent))
			end

			for _, child in ipairs(script.Attachments.Tiger2:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = cFrame.RootPart.Mouth["Bone.002"]
				DebrisModule:AddItem(clone, 3.5)
				Ouwmit.Emit(clone, Ouwmit.Owned(parent))
			end

			local clone = script.PS2flameSKILL1:Clone()
			clone.Parent = humanoidRootPart
			clone.PlaybackSpeed = 1.05
			clone:Play()
			DebrisModule:AddItem(clone, 7)
			task.wait(0.15)
			local clone2 = script.Launch:Clone()
			clone2:PivotTo(v)
			clone2.Parent = workspace.Debree
			DebrisModule:AddItem(clone2, 2)
			local raycastResult = workspace:Raycast(v.Position, v.upVector * -8, RaycastHelper.Crater)
			local color

			if not (raycastResult == nil or raycastResult.Position == nil) then
				color = raycastResult.Instance.Color
			end

			Ouwmit.Emit(clone2, Ouwmit.Owned(parent, color ~= nil and ({
				Color = color,
				ColorWhitelist = "Raycastdust",
				ColorBlacklist = "IgnoreFireGrass"
			} or nil) or nil))
			Cam_Shaker(v.Position, {
				FadeInTime = 0.01,
				Frequency = 0.25,
				Amplitude = 0.4,
				SustainTime = 0.45,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.5, 0.5, 0.5),
				PositionInfluence = createVector(0.45, 0.45, 0.45)
			})
		end
	elseif p == "Bite" then
		local clone = script.Bite:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = cFrame
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		DebrisModule:AddItem(clone, 4)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0.01,
			Frequency = 0.28,
			Amplitude = 0.9,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.14, 0.14, 0.14),
			PositionInfluence = createVector(0.55, 0.55, 0.55)
		})
		OuwCraters.Scales({
			Center = cFrame,
			Radius = 13,
			Count = 10
		})
	elseif p == "Dive" then
		local clone = script.SlamDown:Clone()
		clone.Parent = workspace.Debree
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -10, RaycastHelper.Crater)
		clone:PivotTo(cFrame * CFrame.new(0, -2.5, 0))
		local color

		if not (raycastResult == nil or raycastResult.Position == nil) then
			color = raycastResult.Instance.Color
			local cFrame2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0.35, 0)
			clone.GroundSlam.CFrame = cFrame2
		end

		clone.Part1.PS2flameSKILL1slam:Play()
		Ouwmit.Emit(clone, Ouwmit.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = "raycastdust",
			ColorBlacklist = "Ignore"
		} or nil) or nil))
		DebrisModule:AddItem(clone, 4)
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0.01,
			Frequency = 0.24,
			Amplitude = 1.3,
			SustainTime = 0.35,
			FadeOutTime = 0.25,
			RotationInfluence = createVector(0.16, 0.16, 0.16),
			PositionInfluence = createVector(0.6, 0.6, 0.6)
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = cFrame,
			InnerRadius = 7,
			OuterRadius = 25,
			Amount = 20,
			Velocity = {
				Min = 20,
				Max = 120
			},
			Size = {
				Min = 0.75,
				Max = 5
			}
		})
		OuwCraters.Scales({
			Center = cFrame,
			Duration = 1.8,
			Radius = 15,
			Count = 12,
			ScaleMult = 1.25,
			OffsetMargin = 6
		})
	end
end