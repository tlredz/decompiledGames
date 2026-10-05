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

	if p == "Swing" then
		vfxUtility.PlaySound(sounds, "PS2clanskillsHEADBUTTinitswing", humanoidRootPart, true)
		return
	elseif p == "Connect" then
		vfxUtility.PlaySound(sounds, "PS2clanskillsHEADBUTTconnect", humanoidRootPart, true)
		return
	end

	local clone = script.HeadBut:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(humanoidRootPart.CFrame)
	DebrisModule:AddItem(clone, 3)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.5,
		SustainTime = 0.1,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.3, 0.3, 0.3),
		PositionInfluence = createVector(1, 1, 1)
	})
end