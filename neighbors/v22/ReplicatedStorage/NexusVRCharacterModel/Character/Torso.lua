local parent = script.Parent.Parent
local NexusAppendage = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusAppendage"))
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local limb = NexusAppendage.Limb
local Torso = {}
Torso.__index = Torso
setmetatable(Torso, limb)

function Torso.new(lowerTorso, upperTorso)
	local self = setmetatable(limb.new(), Torso)
	self.LowerTorso = lowerTorso
	self.UpperTorso = upperTorso
	return self
end

function Torso.GetTorsoCFrames(object, cframe: CFrame)
	local v = cframe * object:GetAttachmentCFrame(object.UpperTorso, "NeckRigAttachment"):Inverse()
	local setting = instance:GetSetting("Appearance.MaxTorsoBend") or 0.17453292519943295
	local v2 = math.asin(cframe.LookVector.Y)
	local v3 = math.sign(v2) * math.min(math.abs(v2), setting)
	return
		v * object:GetAttachmentCFrame(object.UpperTorso, "WaistRigAttachment") * CFrame.Angles(-v3, 0, 0) * object:GetAttachmentCFrame(
			object.LowerTorso,
			"WaistRigAttachment"
		):Inverse(),
		v
end

function Torso.GetAppendageJointCFrames(object, cframe: CFrame, cframe2: CFrame)
	return {
		RightShoulder = cframe2 * object:GetAttachmentCFrame(object.UpperTorso, "RightShoulderRigAttachment"),
		LeftShoulder = cframe2 * object:GetAttachmentCFrame(object.UpperTorso, "LeftShoulderRigAttachment"),
		LeftHip = cframe * object:GetAttachmentCFrame(object.LowerTorso, "LeftHipRigAttachment"),
		RightHip = cframe * object:GetAttachmentCFrame(object.LowerTorso, "RightHipRigAttachment")
	}
end

return Torso