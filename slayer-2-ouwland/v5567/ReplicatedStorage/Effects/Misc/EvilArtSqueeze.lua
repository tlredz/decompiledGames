local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {
	{
		Name = "Squeeze",
		At = 0.4,
		Shake = "tinyshake_preset",
		Sound = "PS2demonORBSQUEEZEsqueeze"
	},
	{
		Name = "Break",
		At = 0.9166666666666666,
		Shake = "activate_shake",
		Sound = "PS2demonORBSQUEEZEbreak"
	}
}
local v2 = {}

local function cancel(instance)
	local v3 = v2[instance]
	v2[instance] = nil

	for _, v4 in v3 or {} do
		task.cancel(v4)
	end
end

return function(instance, p: string?)
	if p == "Cancel" then
		cancel(instance)
		return
	end

	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	cancel(instance)
	local threads = {}
	v2[instance] = threads

	for _, v3 in v do
		local child = script:FindFirstChild(v3.Name)

		if child == nil then
			continue
		end

		local v4 = child
		local v5 = v3
		table.insert(threads, task.delay(v3.At, function()
			if humanoidRootPart.Parent == nil then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			local v6

			if raycastResult ~= nil then
				v6 = vfxUtility.GetDustColorSettings(raycastResult.Instance)
			end

			local clone = v4:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Debree
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, v6))
			DebrisModule:AddItem(clone, 4)
			Cam_Shaker(humanoidRootPart.Position, v5.Shake)
			local child2 = script:FindFirstChild(v5.Sound)

			if child2 ~= nil then
				local clone2 = child2:Clone()
				clone2.Parent = humanoidRootPart
				clone2:Play()
				DebrisModule:AddItem(clone2, 0)
			end
		end))
	end
end