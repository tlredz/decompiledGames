local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local clone = script.SlashFail:Clone()
	clone:PivotTo(cFrame)
	clone.Parent = workspace.Debree
	local clone2 = script.PS2trainingBOULDCUTfail:Clone()
	clone2.Parent = clone.PrimaryPart
	clone2:Play()
	DebrisModule:AddItem(clone, 5)
	task.wait(0.5)
	Cam_Shaker(cFrame.Position, "activate_shake")
	Ouwmit.Emit(clone.Slash, Ouwmit.Owned(instance))
	task.wait(0.065)
	local raycastResult = workspace:Raycast(
		cFrame.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	Ouwmit.Emit(
		clone.SlashHit,
		Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
	)
end