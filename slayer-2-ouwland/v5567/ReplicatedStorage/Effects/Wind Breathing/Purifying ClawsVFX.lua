local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local v = { "PS2windGENERALinitiate", "PS2windPURIFYINGCLAWslash1", "PS2windPURIFYINGCLAWslash2" }

local function emitSlash(humanoidRootPart, raycastResult: RaycastResult?)
	local clone = script.Slash:Clone()
	clone:PivotTo(humanoidRootPart.CFrame)

	if raycastResult ~= nil then
		local ground = clone["1"].Ground

		for _, v2 in { ground, clone.Root } do
			for _, child in v2:GetChildren() do
				if not ((child:IsA("WeldConstraint") or child:IsA("Weld")) and (child.Part0 == ground or child.Part1 == ground)) then
					continue
				end

				child:Destroy()
			end
		end

		ground.Anchored = true
		local worldPosition = raycastResult.Position + createVector(0, 0.5, 0)
		ground.CFrame = CFrame.new(worldPosition) * ground.CFrame.Rotation
		local dustRaycast = clone["1"]["1"].DustRaycast
		dustRaycast.Parent = ground
		dustRaycast.WorldPosition = worldPosition
	end

	clone.Parent = workspace.Debree
	Ouwmit.Emit(
		clone,
		Ouwmit.Owned(humanoidRootPart, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
	)
	DebrisModule:AddItem(clone, 4)
end

return function(instance, p: string, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		for _, childName in v do
			local sound = humanoidRootPart:FindFirstChild(childName)

			if sound and sound:IsA("Sound") then
				sound:Destroy()
			end
		end
	elseif p == "Start" then
		vfxUtility.PlaySound(script.Parent, "PS2windGENERALinitiate", humanoidRootPart, true)
		local clone = script.Startup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 3)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -11,
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Release" then
		vfxUtility.PlaySound(script.Sound, "PS2windPURIFYINGCLAWslash1", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 1,
			SustainTime = 0.1,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -11,
			RaycastHelper.Crater
		)
		emitSlash(humanoidRootPart, raycastResult)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			local clone = script.GroundImpact:Clone()
			clone:PivotTo(CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)) * humanoidRootPart.CFrame.Rotation)
			clone.Parent = workspace.Debree
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance)))
			DebrisModule:AddItem(clone, 4)
		end
	elseif p == "Switch" then
		vfxUtility.PlaySound(script.Sound, "PS2windPURIFYINGCLAWslash2", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
	elseif p == "SwitchRelease" then
		emitSlash(
			humanoidRootPart,
			workspace:Raycast(humanoidRootPart.Position, humanoidRootPart.CFrame.upVector * -11, RaycastHelper.Crater)
		)
		local _, v2 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
		local v3 = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v2, 0)
		local position = (v3 * CFrame.new(0, 0, -4.5)).Position
		local raycastResult2 = workspace:Raycast(position, createVector(-0, -25, -0), RaycastHelper.Crater)

		if raycastResult2 ~= nil and raycastResult2.Instance ~= nil then
			local clone = script.GroundImpact:Clone()
			clone:PivotTo(CFrame.new(raycastResult2.Position + createVector(0, 0.5, 0)) * v3.Rotation)
			clone.Parent = workspace.Debree
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance)))
			DebrisModule:AddItem(clone, 4)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 1.35,
			SustainTime = 0.1,
			FadeOutTime = 0.65,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
	end
end