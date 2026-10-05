local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local cframe = CFrame.new(0.3, 0, -0.2)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local kickGround = script:FindFirstChild("KickGround")

	if kickGround ~= nil then
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = kickGround:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame * cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		vfxUtility.PlaySound(script, "PS2enhancedhearing", clone.HumanoidRootPart, true)
		DebrisModule:AddItem(clone, 3)
	end

	Cam_Shaker(humanoidRootPart.Position, "activate_shake")
end