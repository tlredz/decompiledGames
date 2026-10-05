local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance, p, _, _)
	local child = script:FindFirstChild("M" .. p)

	if child ~= nil then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		local v = "PS2yetiSWINGS" .. p
		vfxUtility.PlaySound(script.Sounds, v, humanoidRootPart, true)

		if p == 3 then
			local clone = script.PreM:Clone()
			clone.Parent = workspace.Debree
			DebrisModule:AddItem(clone, 3)
			clone:PivotTo(humanoidRootPart.CFrame)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			task.wait(0.1)
		end

		local clone = child:Clone()
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 3)

		if p == 3 then
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.16,
				Amplitude = 1,
				SustainTime = 0.05,
				FadeOutTime = 1,
				RotationInfluence = createVector(0.35, 0.35, 0.35),
				PositionInfluence = createVector(1, 1, 1)
			})
		else
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.16,
				Amplitude = 0.5,
				SustainTime = 0.05,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.35, 0.35, 0.35),
				PositionInfluence = createVector(1, 1, 1)
			})
		end

		clone:PivotTo(humanoidRootPart.CFrame)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local dustRaycast = (raycastResult == nil or raycastResult.Instance == nil) and clone:FindFirstChild(
			"DustRaycast",
			true
		)

		if dustRaycast then
			dustRaycast:Destroy()
		end

		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
	end
end