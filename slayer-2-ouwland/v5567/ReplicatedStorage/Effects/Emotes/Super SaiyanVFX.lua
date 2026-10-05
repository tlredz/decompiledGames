local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local pVInstance = script:FindFirstChildWhichIsA("PVInstance")

	if pVInstance == nil then
		warn((`{script.Name}: no effect (a Model or a part) is parented under the module, nothing to emit`))
		return
	end

	local clone = pVInstance:Clone()
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
	clone.Root["PS2emotesSUPERSAIYAN_(1)"]:Play()
	Cam_Shaker(humanoidRootPart.Position, {
		FadeInTime = 0,
		Frequency = 0.225,
		Amplitude = 0.25,
		SustainTime = 0.3,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	})
end