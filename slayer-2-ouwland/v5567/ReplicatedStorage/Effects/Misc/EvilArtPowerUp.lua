local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local EvilArtCores = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.EvilArtCores)
return function(instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local aura_Impact = script:FindFirstChild("Aura_Impact")

	if humanoidRootPart == nil or aura_Impact == nil then
		return
	end

	task.delay(0.5333333333333333, function()
		if humanoidRootPart.Parent == nil then
			return
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local v

		if raycastResult ~= nil then
			v = vfxUtility.GetDustColorSettings(raycastResult.Instance)
		end

		local clone = aura_Impact:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone, EvilArtCores.POWERUP_TIME + 3)
		Cam_Shaker(humanoidRootPart.Position, "medium_shake_longer_preset")
		local pS2demonPOWERUP = script:FindFirstChild("PS2demonPOWERUP")

		if pS2demonPOWERUP ~= nil then
			local clone2 = pS2demonPOWERUP:Clone()
			clone2.Parent = humanoidRootPart
			clone2:Play()
			DebrisModule:AddItem(clone2, 0)
		end
	end)
end