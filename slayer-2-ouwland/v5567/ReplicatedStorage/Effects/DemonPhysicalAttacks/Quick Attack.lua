local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local debree = workspace.Debree

local function emitAtRoot(childName: string, cframe: CFrame, instance)
	local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -20, 0), RaycastHelper.Crater)
	local v

	if raycastResult then
		v = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	end

	local child = script:FindFirstChild(childName)

	if child == nil then
		return raycastResult
	end

	local clone = child:Clone()
	local root = clone:FindFirstChild("Root")

	if root == nil then
		clone:PivotTo(cframe)
	else
		clone:PivotTo(cframe * root.CFrame:ToObjectSpace(clone:GetPivot()))
	end

	clone.Parent = debree
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	DebrisModule:AddItem(clone, 3)
	return raycastResult
end

return function(instance, p: string?, p2)
	local DISTANCE_THRESHOLD = 250

	if p == "Dash" then
		if typeof(p2) ~= "CFrame" or (p2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		local humanoidRootPart = instance and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)

		if humanoidRootPart then
			vfxUtility.PlaySound(script.Sounds, "PS2evilspiritDASH", humanoidRootPart, true)
		end

		Cam_Shaker(p2.Position, {
			FadeInTime = 0.05,
			Frequency = 0.25,
			Amplitude = 0.4,
			SustainTime = 0.1,
			FadeOutTime = 1,
			RotationInfluence = createVector(0.7, 0.7, 0.7),
			PositionInfluence = createVector(0.3, 0.3, 0.3)
		})
		emitAtRoot("AirEmit", p2, instance)
	elseif p == "Strike" then
		if typeof(p2) ~= "CFrame" or (p2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		Cam_Shaker(p2.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.5,
			SustainTime = 0.05,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.6, 0.6, 0.6)
		})
		emitAtRoot("StrikeEffect", p2, instance)
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		if p == "Startup" then
			emitAtRoot("StartupEffect", humanoidRootPart.CFrame, instance)
		end
	end
end