local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local clone = script.SoothingVoice:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(humanoidRootPart.CFrame)
	clone.Root.PS2clanskillsSOOTHINGVOICE:Play()
	DebrisModule:AddItem(clone, 3)
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.225,
		Amplitude = 0.3,
		SustainTime = 0.2,
		FadeOutTime = 1,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
end