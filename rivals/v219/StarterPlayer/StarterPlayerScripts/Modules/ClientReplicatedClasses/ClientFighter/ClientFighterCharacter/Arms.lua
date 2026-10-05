local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = { "RightShoulderBallSocket", "RightElbowBallSocket", "RightWristBallSocket" }
local v2 = { "LeftShoulderBallSocket", "LeftElbowBallSocket", "LeftWristBallSocket" }
local Arms = {}
Arms.__index = Arms

function Arms.new(clientFighterCharacter)
	local self = setmetatable({}, Arms)
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._right_hand_ik_control = Instance.new("IKControl")
	self._left_hand_ik_control = Instance.new("IKControl")
	self._ik_control_target_item = nil
	self._ik_arms_disable_hash = 0
	self._arm_ball_socket_constraints = {}
	self:_Init()
	return self
end

function Arms:SetIKControlTargetItem(ik_control_target_item)
	if ik_control_target_item == self._ik_control_target_item then
		return
	end

	self._ik_control_target_item = ik_control_target_item
	self._right_hand_ik_control.Enabled = false
	self._left_hand_ik_control.Enabled = false
	local _right_hand_ik_control = self._right_hand_ik_control
	local target

	if self._ik_control_target_item and not self._ik_control_target_item.ViewModel.RightArmIKControlDisabled then
		target = self._ik_control_target_item.ViewModel.Model.RightArm.HandAttachment or nil
	end

	_right_hand_ik_control.Target = target
	local _left_hand_ik_control = self._left_hand_ik_control
	local target2

	if self._ik_control_target_item and not self._ik_control_target_item.ViewModel.LeftArmIKControlDisabled then
		target2 = self._ik_control_target_item.ViewModel.Model.LeftArm.HandAttachment or nil
	end

	_left_hand_ik_control.Target = target2
	self:_UpdateArmBallSocketConstraints()
	self:Update(0, nil)
end

function Arms:DisableIKArms(p, p2, p3)
	self._ik_arms_disable_hash += 1
	local _ik_arms_disable_hash = self._ik_arms_disable_hash

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set(weight)
		if not p2 then
			self._right_hand_ik_control.Weight = weight
		end

		if not p3 then
			self._left_hand_ik_control.Weight = weight
		end
	end

	if not (p >= 1e999) then
		task.spawn(function()
			local lastTime = tick()

			while tick() < lastTime + p do
				if _ik_arms_disable_hash ~= self._ik_arms_disable_hash then
					return
				end

				set(math.clamp((tick() - lastTime) / p, 0, 1) ^ 4) -- equivalent call inferred; original call site unknown
				RunService.RenderStepped:Wait()
			end

			set(1) -- equivalent call inferred; original call site unknown
		end)
		return
	end

	set(0) -- equivalent call inferred; original call site unknown
end

function Arms:Update(_, p)
	if p and not p.IsAlive or self.ClientFighterCharacter:IsHidden() then
		return
	end

	local v3 = self._ik_control_target_item and (self._ik_control_target_item.ViewModel.Model.HumanoidRootPart.Position - self.ClientFighterCharacter.RootPart.Position).Magnitude < 16
	self._right_hand_ik_control.Enabled = self._right_hand_ik_control.Target and v3
	self._left_hand_ik_control.Enabled = self._left_hand_ik_control.Target and v3
	self:_UpdateArmBallSocketConstraints()
end

function Arms:Destroy()
	self._destroyed = true
	self._ik_control_target_item = nil
	self._ik_arms_disable_hash += 1
	self._right_hand_ik_control:Destroy()
	self._left_hand_ik_control:Destroy()
end

function Arms:_UpdateArmBallSocketConstraints()
	for k, _arm_ball_socket_constraint in pairs(self._arm_ball_socket_constraints) do
		k.Enabled = not _arm_ball_socket_constraint.Enabled
	end
end

function Arms:_SetupAsync()
	self.ClientFighterCharacter:WaitUntilIsInWorld()

	if self._destroyed then
		return
	end

	self._right_hand_ik_control.Name = "RightHandIKControl"
	self._right_hand_ik_control.EndEffector = self.ClientFighterCharacter.Model:WaitForChild("RightHand")
	self._right_hand_ik_control.ChainRoot = self.ClientFighterCharacter.Model:WaitForChild("RightUpperArm")
	self._right_hand_ik_control.SmoothTime = 0
	self._right_hand_ik_control.Enabled = false
	self._right_hand_ik_control.Parent = self.ClientFighterCharacter.Humanoid
	self._left_hand_ik_control.Name = "LeftHandIKControl"
	self._left_hand_ik_control.EndEffector = self.ClientFighterCharacter.Model:WaitForChild("LeftHand")
	self._left_hand_ik_control.ChainRoot = self.ClientFighterCharacter.Model:WaitForChild("LeftUpperArm")
	self._left_hand_ik_control.SmoothTime = 0
	self._left_hand_ik_control.Enabled = false
	self._left_hand_ik_control.Parent = self.ClientFighterCharacter.Humanoid

	for _, list in pairs({
		{ v, self._right_hand_ik_control },
		{ v2, self._left_hand_ik_control }
	}) do
		local v3, v4 = table.unpack(list)

		for _, v5 in pairs(v3) do
			local v6 = Utility:WaitForChildRecursive(self.ClientFighterCharacter.Model, v5)
			self._arm_ball_socket_constraints[v6] = v4
		end
	end

	self:Update(0, nil)
	self:_UpdateArmBallSocketConstraints()
end

function Arms:_Init()
	self.ClientFighterCharacter.EmoteStatusChanged:Connect(function()
		if self.ClientFighterCharacter:IsEmoting() then
			self:DisableIKArms(1e999)
		else
			self:DisableIKArms(0)
		end
	end)
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.EquippedItemChanged:Connect(function()
		self:Update(nil, nil)
	end))
	task.defer(self._SetupAsync, self)
end

return Arms