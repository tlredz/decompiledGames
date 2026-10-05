local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {
	[5] = true,
	[7] = true
}
return function(instance, p: number?, flag: boolean?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	if flag == true and p == 1 then
		task.wait(0.065)

		if humanoidRootPart.Parent == nil then
			return
		end
	end

	Cam_Shaker(humanoidRootPart.Position, v[p] and "tinyshake_preset" or "punch_shake")
	local asset = vfxUtility.cloneAsset(
		script.Swings,
		workspace.Debree,
		flag and p == 1 and "Runm" or "m" .. p,
		humanoidRootPart.CFrame,
		3
	)
	local clone = script.Swing:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 1.5)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(asset, Ouwmit.Owned(instance, v2))
end