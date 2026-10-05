local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterHandler)
local currentCamera = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local v = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.5,
	SustainTime = 0.1,
	FadeOutTime = 0.4,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(0.5, 0.5, 0.5)
}
local TweenService = game:GetService("TweenService")

local function fn(value: number?)
	local v2 = value or 0.3
	local clone = script.FlameColorCorrection:Clone()
	clone.Parent = currentCamera
	TweenService:Create(clone, TweenInfo.new(v2), {
		TintColor = Color3.new(1, 1, 1),
		Contrast = 0
	}):Play()
	DebrisModule:AddItem(clone, v2)
end

local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(parent, p: string, cframe: CFrame?)
	if parent == nil then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position)

	if v2 >= 200 then
		return
	end

	if p == "Start" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Start"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local cFrame = humanoidRootPart.CFrame
		local clone = script.FlameStartup:Clone()
		clone.Parent = configuration
		clone:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -10, RaycastHelper.Crater)
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
		local clone2 = script.Sounds.PS2flameCHARGEcharge:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		local clone3 = script.Highlight:Clone()
		clone3.Parent = parent
		task.wait(0.25)

		if clone3 ~= nil then
			DebrisModule:AddItem(clone3, 1)
			TweenService:Create(clone3, TweenInfo.new(1), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end
	elseif p == "Release" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Release"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		Cam_Shaker(humanoidRootPart.Position, v)
		local clone = script.Launch:Clone()
		clone.Parent = configuration
		clone:PivotTo(cframe * CFrame.Angles(-1.5707963267948966, 0, 0))
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		local clone2 = script.Sounds.PS2flameCHARGEdashDASH:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
	elseif p == "Slash" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Slash"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		Cam_Shaker(humanoidRootPart.Position, v)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.SlashEmit:Clone()
		clone.Parent = configuration
		clone:PivotTo(cFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0))
		local clone2 = script.UnknowingFire:Clone()
		clone2.Parent = configuration
		clone2:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone2, Ouwmit.Owned(parent))
		local clone3 = script.Sounds.PS2flameCHARGEdashSUCCESS:Clone()
		clone3.Parent = clone.Startup
		clone3:Play()

		if v2 <= 60 or parent == game.Players.LocalPlayer.Character then
			fn(0.55)
		end

		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -10, RaycastHelper.Crater)
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
	elseif p == "UpSlash1" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"UpSlash1"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		Cam_Shaker(humanoidRootPart.Position, v)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.SlashEmit2:Clone()
		clone.Parent = configuration
		clone:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		local clone2 = script.Sounds.UnknowingFireUpdraftSlash1:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		local clone3 = script.UnknowingFire2:Clone()
		clone3.Parent = configuration
		clone3:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone3, Ouwmit.Owned(parent))

		if v2 <= 60 or parent == game.Players.LocalPlayer.Character then
			fn()
		end

		local clone4 = script.Highlight:Clone()
		clone4.Parent = parent
		task.wait(0.91)
		TweenService:Create(clone4, TweenInfo.new(0.4), {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
		DebrisModule:AddItem(clone4, 0.4)
	elseif p == "UpSlash2" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"UpSlash2"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		Cam_Shaker(humanoidRootPart.Position, v)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.SlashEmit3:Clone()
		clone.Parent = configuration
		clone:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		local clone2 = script.Sounds.UnknowingFireUpdraftSlash1:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		local clone3 = script.UnknowingFire2:Clone()
		clone3.Parent = configuration
		clone3:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone3, Ouwmit.Owned(parent))

		if v2 <= 60 or parent == game.Players.LocalPlayer.Character then
			fn()
		end
	end
end