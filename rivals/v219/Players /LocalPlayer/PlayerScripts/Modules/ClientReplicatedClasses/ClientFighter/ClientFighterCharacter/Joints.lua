local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spring = require(ReplicatedStorage.Modules.Spring)
local Joints = {}
Joints.__index = Joints

function Joints.new(clientFighterCharacter)
	local self = setmetatable({}, Joints)
	self.ClientFighterCharacter = clientFighterCharacter
	self._camera_rotation_spring = Spring.new(Vector2.zero, 1, 50)
	self._camera_lean_spring = Spring.new(0, 1, 20)
	self._waist_joint = nil
	self._waist_joint_is_motor6d = nil
	self._neck_joint = nil
	self._neck_joint_is_motor6d = nil
	self._root_joint = nil
	self._root_joint_is_motor6d = nil
	self._root_joint_origin = nil
	self:_Init()
	return self
end

function Joints:Update(_, data2)
	if not data2.IsAlive or self.ClientFighterCharacter:IsHidden() then
		return
	end

	self._camera_lean_spring.Target = data2.CameraLean
	self._camera_rotation_spring.Target = Vector2.new(
		data2.CameraRotationRaw.X > 3.141592653589793 and data2.CameraRotationRaw.X - 6.283185307179586 or data2.CameraRotationRaw.X,
		data2.CameraRotationRaw.Y > 3.141592653589793 and data2.CameraRotationRaw.Y - 6.283185307179586 or data2.CameraRotationRaw.Y
	)
	local value = self._camera_rotation_spring.Value
	local value2 = self._camera_lean_spring.Value

	if self._waist_joint then
		local v = CFrame.new(self._waist_joint.C0.Position) * CFrame.Angles(value.X * 0.25, 0, 0)
		local cframe = CFrame.new(self._waist_joint.C1.Position)

		if self._waist_joint_is_motor6d then
			self._waist_joint.C0 = v
			self._waist_joint.C1 = cframe
		else
			self._waist_joint.Attachment0.CFrame = v
			self._waist_joint.Attachment1.CFrame = cframe
		end
	end

	if self._neck_joint then
		local v = CFrame.new(self._neck_joint.C0.Position) * CFrame.Angles(value.X * 0.75, 0, 0)
		local cframe = CFrame.new(self._neck_joint.C1.Position)

		if self._neck_joint_is_motor6d then
			self._neck_joint.C0 = v
			self._neck_joint.C1 = cframe
		else
			self._neck_joint.Attachment0.CFrame = v
			self._neck_joint.Attachment1.CFrame = cframe
		end
	end

	if self._root_joint and self._root_joint_origin then
		local v = self._root_joint_origin * CFrame.new(value2 * 1.25, 0, 0) * CFrame.Angles(
			0,
			0,
			value2 * -0.3490658503988659
		)

		if self._root_joint_is_motor6d then
			self._root_joint.C0 = v
		else
			self._root_joint.Attachment0.CFrame = v
		end
	end
end

function Joints.Destroy(_) end

function Joints:_SetupAsync()
	self.ClientFighterCharacter:WaitUntilIsInWorld()
	self._waist_joint = self.ClientFighterCharacter.Model:WaitForChild("UpperTorso"):WaitForChild("Waist")
	self._waist_joint_is_motor6d = self._waist_joint:IsA("Motor6D")
	self._neck_joint = self.ClientFighterCharacter.Model:WaitForChild("Head"):WaitForChild("Neck")
	self._neck_joint_is_motor6d = self._neck_joint:IsA("Motor6D")
	self._root_joint = self.ClientFighterCharacter.Model:WaitForChild("LowerTorso"):WaitForChild("Root")
	self._root_joint_is_motor6d = self._root_joint:IsA("Motor6D")
	self._root_joint_origin = self._root_joint.C0
end

function Joints:_Init()
	task.spawn(self._SetupAsync, self)
end

return Joints