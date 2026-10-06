local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local preSimulationConnection = nil
local v = nil
local v2 = nil
local v3 = nil
local WeaponMovement = {
	Clear = function()
		if not v then
			return
		end

		local humanoid = v.Humanoid

		if humanoid.Parent then
			if v.Jumping ~= nil then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, v.Jumping)
			end

			if v.AutoRotate ~= nil and humanoid.AutoRotate == false then
				humanoid.AutoRotate = v.AutoRotate
			end
		end

		v = nil
		v2 = nil
		v3 = nil
	end
}

function WeaponMovement.Update()
	local character = module:GetCharacter()
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if v and v.Character ~= character then
		WeaponMovement.Clear()
	end

	if not (character and humanoid and humanoidRootPart) then
		return
	end

	if not v then
		v = {
			Character = character,
			Humanoid = humanoid
		}
	end

	local skillJumpBlocked = character:GetAttribute("SkillJumpBlocked")
	local skillRotationLocked = character:GetAttribute("SkillRotationLocked")
	local skillMovementLocked = character:GetAttribute("SkillMovementLocked")
	local skillSpeedMultiplier = character:GetAttribute("SkillSpeedMultiplier")
	local skillLockCFrame = character:GetAttribute("SkillLockCFrame")

	if skillJumpBlocked then
		if v.Jumping == nil then
			v.Jumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		humanoid.Jump = false
	elseif v.Jumping ~= nil then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, v.Jumping)
		v.Jumping = nil
	end

	if skillRotationLocked then
		if v.AutoRotate == nil then
			v.AutoRotate = humanoid.AutoRotate
		end

		humanoid.AutoRotate = false
	elseif v.AutoRotate ~= nil then
		humanoid.AutoRotate = v.AutoRotate
		v.AutoRotate = nil
	end

	if typeof(skillLockCFrame) == "CFrame" and not (character:GetAttribute("Anchored") or character:GetAttribute("VoidRecovering")) then
		local position

		if skillMovementLocked then
			position = skillLockCFrame.Position
		else
			position = humanoidRootPart.Position
		end

		local v4

		if skillRotationLocked then
			v4 = skillLockCFrame.Rotation
		else
			v4 = humanoidRootPart.CFrame.Rotation
		end

		humanoidRootPart.CFrame = CFrame.new(position) * v4

		if skillMovementLocked then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end

		if skillRotationLocked then
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end

	if v2 ~= skillSpeedMultiplier or v3 ~= skillMovementLocked then
		v2 = skillSpeedMultiplier
		v3 = skillMovementLocked
		module.Signal:FireSelf("Player", "Run", "Update")
	end
end

function WeaponMovement.Destroy()
	if preSimulationConnection then
		preSimulationConnection:Disconnect()
		preSimulationConnection = nil
	end

	WeaponMovement.Clear()
end

function WeaponMovement.Init()
	if preSimulationConnection then
		return
	end

	preSimulationConnection = module.Services.RunService.PreSimulation:Connect(WeaponMovement.Update)
end

return WeaponMovement