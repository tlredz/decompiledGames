local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local sounds = script:WaitForChild("Sounds")
return function(instance, p: string?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Connect" then
		vfxUtility.PlaySound(sounds, "PS2clanskillsDEMONCOAGULANTfinishpunch", humanoidRootPart, true)
		return
	end

	vfxUtility.PlaySound(sounds, "PS2clanskillsDEMONCOAGULANTfirstpunch", humanoidRootPart, true)
	local clone = script.DemonCoagulantVFX:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(humanoidRootPart.CFrame)
	DebrisModule:AddItem(clone, 3)
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(clone.Inital, Ouwmit.Owned(instance, v))
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.2,
		Amplitude = 0.2,
		SustainTime = 0.1,
		FadeOutTime = 0.6,
		RotationInfluence = createVector(0.2, 0.2, 0.2),
		PositionInfluence = createVector(1, 1, 1)
	})
	task.wait(0.3)
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.4,
		SustainTime = 0.1,
		FadeOutTime = 0.6,
		RotationInfluence = createVector(0.2, 0.2, 0.2),
		PositionInfluence = createVector(1, 1, 1)
	})
	Ouwmit.Emit(clone.Poison, Ouwmit.Owned(instance, v))
end