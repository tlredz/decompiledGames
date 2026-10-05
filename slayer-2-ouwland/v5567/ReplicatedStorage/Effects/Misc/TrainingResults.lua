local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local tweenInfo = TweenInfo.new(0.2)
local v = {
	FadeInTime = 0,
	Frequency = 0.15,
	Amplitude = 0.08333333333333333,
	SustainTime = 0.1,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}
return function(instance, flag: boolean)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.13333333333333333,
		SustainTime = 0.1,
		FadeOutTime = 0.4,
		RotationInfluence = createVector(0.1, 0.1, 0.1),
		PositionInfluence = createVector(0.5, 0.5, 0.5)
	})
	local pS2succes

	if flag then
		pS2succes = script.Sounds.PS2succes
		local clone = script.Success:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		TweenService:Create(clone.Root.SuccesPointlight, tweenInfo, {
			Brightness = 0,
			Range = 0
		}):Play()
		local position = humanoidRootPart.Position
		task.delay(0.3, function()
			Cam_Shaker(position, v)
		end)
	else
		pS2succes = script.Sounds.PS2failure
		local clone = script.Failure:Clone()
		clone.Parent = humanoidRootPart
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 3)
	end

	local clone = pS2succes:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 3)
end