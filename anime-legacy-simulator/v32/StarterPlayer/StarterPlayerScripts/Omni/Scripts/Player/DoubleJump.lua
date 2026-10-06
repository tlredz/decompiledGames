local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local assets = module.Services.ReplicatedStorage:WaitForChild("Assets")
local movement = assets:WaitForChild("Animations"):WaitForChild("Movement")
local doubleJump = assets:WaitForChild("Sounds"):WaitForChild("Movement"):WaitForChild("DoubleJump")
local doubleJump2 = movement:WaitForChild("DoubleJump")
local doubleJump3 = assets:WaitForChild("Effects"):WaitForChild("Movement"):WaitForChild("DoubleJump")
local stateChangedConnection = nil
local jumpChangedConnection = nil
local count = 0
local v = false
module:OnCharacterAdded(function(instance)
	if not instance then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not (humanoid and humanoid:FindFirstChild("Animator")) then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if jumpChangedConnection and typeof(jumpChangedConnection) == "RBXScriptConnection" then
		jumpChangedConnection:Disconnect()
		jumpChangedConnection = nil
	end

	if stateChangedConnection and typeof(stateChangedConnection) == "RBXScriptConnection" then
		stateChangedConnection:Disconnect()
		stateChangedConnection = nil
	end

	stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		local name = p.Name

		if name == "Landed" then
			count = 0
			v = true
		elseif name == "Freefall" then
			task.wait(0.2)
			v = true
		elseif name == "Jumping" then
			if instance:GetAttribute("SkillJumpBlocked") then
				return
			end

			v = false
			count += 1

			if count > 1 and not instance:GetAttribute("Mounted") then
				if not (module.Data.Settings["Low Mode"] or module.Data.Settings["Hide Effects"]) then
					local clone = doubleJump3:Clone()
					clone:PivotTo(humanoidRootPart.CFrame)
					clone.Parent = workspace.Cache
					module.Utils.Particles:Emit(clone)
					module.Services.Debris:AddItem(clone, 5)
				end

				humanoidRootPart.AssemblyLinearVelocity *= createVector(1, 0, 1)
				humanoidRootPart.AssemblyLinearVelocity += Vector3.new(0, humanoid.JumpPower * 1.5, 0)
				module.Sound:Play(doubleJump, humanoidRootPart)
				local animate = module:GetAnimate()

				if animate and not animate:HasPersistentState() then
					animate:PlayAnimation({
						Animation = doubleJump2,
						Priority = Enum.AnimationPriority.Action4
					})
				end
			end
		end
	end)
	jumpChangedConnection = humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if module.Instance:GetAttribute("Frozen") or instance:GetAttribute("SkillJumpBlocked") then
			return
		end

		if humanoid.Jump and v and count < 2 then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end)
return {}