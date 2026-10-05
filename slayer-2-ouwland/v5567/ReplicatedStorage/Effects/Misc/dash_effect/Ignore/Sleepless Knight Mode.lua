local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(game.ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	FadeInTime = 0,
	Frequency = 0.14,
	Amplitude = 0.6,
	SustainTime = 0,
	FadeOutTime = 0.45,
	RotationInfluence = createVector(0.14, 0.14, 0.14),
	PositionInfluence = createVector(0.6, 0.6, 0.6)
}
return function(instance, vector2: Vector3, flag: boolean?)
	if instance == nil or vector2 == nil then
		return
	end

	local airDash = flag and script:FindFirstChild("AirDash") or script:FindFirstChild("Dash")

	if airDash == nil then
		return
	end

	Cam_Shaker(instance.Position, v)
	local character

	if Players.LocalPlayer ~= nil then
		character = Players.LocalPlayer.Character or nil
	end

	local colorCorrection = script:FindFirstChild("ColorCorrection")

	if colorCorrection ~= nil and character ~= nil and instance.Parent == character then
		local clone = colorCorrection:Clone()
		clone.Parent = workspace.CurrentCamera
		TweenService:Create(clone, tweenInfo, {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
		DebrisModule:AddItem(clone, 0.25)
	end

	local clone = airDash:Clone()
	clone.Parent = workspace.Debree
	local cframe = CFrame.lookAt(instance.Position, instance.Position + vector2)

	if clone:IsA("Model") then
		clone:PivotTo(cframe)
	elseif clone:IsA("BasePart") then
		clone.CFrame = cframe
	end

	DebrisModule:AddItem(clone, 3)
	local raycastResult = workspace:Raycast(
		instance.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
	clone.Root.Sound:Play()
	return true
end