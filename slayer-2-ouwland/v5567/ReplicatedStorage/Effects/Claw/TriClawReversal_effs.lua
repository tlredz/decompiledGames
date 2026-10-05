local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local v = {
	FadeInTime = 0,
	Frequency = 0.125,
	Amplitude = 0.15,
	SustainTime = 0.2,
	FadeOutTime = 0.2,
	RotationInfluence = createVector(0.2, 0.2, 0.2),
	PositionInfluence = createVector(2.5, 2.5, 2.5)
}
local v2 = {
	FadeInTime = 0,
	Frequency = 0.15,
	Amplitude = 0.75,
	SustainTime = 0.25,
	FadeOutTime = 0.3,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(3, 3, 3)
}
local debree = workspace.Debree
return function(instance, vector2: Vector3, p: string?)
	local primaryPart = instance.PrimaryPart

	if primaryPart == nil or (CFrame.new(primaryPart.Position, vector2).Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 or p == "Cancel" then
		return
	end

	local function emitSlash(childName: string, p2: string)
		local child = script:FindFirstChild(childName)

		if not child then
			return
		end

		local clone = child:Clone()
		clone:PivotTo(primaryPart.CFrame)
		clone.Parent = debree
		local raycastResult = workspace:Raycast(
			primaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -30, -0),
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		DebrisModule:AddItem(clone, 3)
		vfxUtility.PlaySound(script, p2, primaryPart, true)
	end

	if p == "First" then
		emitSlash("Jump", "PS2clawsTriClawReversalJUMP")
		Cam_Shaker(primaryPart.Position, v)
	elseif p == "Second" then
		emitSlash("Final_Slash", "PS2clawsTriClawReversalSLASH")
		Cam_Shaker(primaryPart.Position, v2)
	end
end