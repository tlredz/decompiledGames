local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)

local function groundCFrame(instance, humanoidRootPart)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local v = humanoid == nil and 3 or humanoid.HipHeight + humanoidRootPart.Size.Y / 2
	local position = humanoidRootPart.Position - Vector3.new(0, v, 0)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil then
		position = raycastResult.Position
	end

	return CFrame.new(position) * humanoidRootPart.CFrame.Rotation
end

return function(instance, childName: string)
	if instance == nil or childName == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local child = script:FindFirstChild(childName)

	if child == nil then
		return
	end

	vfxUtility.PlaySound(script, "PS2clanskillsVITALDRAW", humanoidRootPart, true)
	local clone = child:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(groundCFrame(instance, humanoidRootPart) * CFrame.Angles(0, -1.5707963267948966, 0))
	Ouwmit.Emit(clone, Ouwmit.Owned(instance))
	DebrisModule:AddItem(clone, 3)
	Cam_Shaker(humanoidRootPart.Position, "activate_shake")
end