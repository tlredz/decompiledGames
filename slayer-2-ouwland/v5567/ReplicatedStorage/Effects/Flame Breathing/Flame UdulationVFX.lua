local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local currentCamera = workspace.CurrentCamera
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(instance, p: string)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 then
		return
	end

	if p == "Start" then
		local clone = script.Startup:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.RootPart.PS2flameCOUNTERandslash:Play()
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.upVector * -8, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Position == nil) then
			color = raycastResult.Instance.Color
			clone.SpinningVFX.raycastdust.WorldPosition = raycastResult.Position + createVector(0, 0.15, 0)
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = "raycastdust"
		} or nil) or nil))
	elseif p == "Release" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Release"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 4)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 0.25,
			SustainTime = 0.1,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
		local clone = script.Launch:Clone()
		clone.Parent = configuration
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.RootPart.PS2flameCOUNTERflamewhoosh:Play()
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.upVector * -8, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Position == nil) then
			color = raycastResult.Instance.Color
			clone.Raycastdust.Position = raycastResult.Position + createVector(0, 0.15, 0)
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = "Raycastdust",
			ColorBlacklist = "IgnoreFireGrass"
		} or nil) or nil))
		local clone2 = script.FlameTornado:Clone()
		clone2.Parent = configuration
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -2.5)
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
	elseif p == "Counter" then
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local clone = script.CounterLaunch:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.RootPart.PS2flameCOUNTERnormalwhoosh:Play()
		DebrisModule:AddItem(clone, 2)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.upVector * -8, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Position == nil) then
			color = raycastResult.Instance.Color
			clone.SpinningVFX.raycastdust.WorldPosition = raycastResult.Position + createVector(0, 0.15, 0)
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = "raycastdust"
		} or nil) or nil))
	end
end