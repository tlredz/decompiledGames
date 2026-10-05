local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(global.Checker)
local Utility = require(global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Skill_Switch_Adder = require(global.Subsets.Gameplay.Skill_Switch_Adder)
local RaycastHelper = require(global.RaycastHelper)
local Config = require(script.Parent.Config)
local PurifyingClawsServer = {
	Id = {},
	Hold = function(player, _, _)
		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Purifying ClawsVFX", character, "Start")
	end
}

function PurifyingClawsServer.UnHold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = PurifyingClawsServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.HITBOX_DELAY + 0.5)
	v3:Connect(function()
		v2 = -1
		PurifyingClawsServer.Cancel(player, p, p2)
		v4()
	end)
	task.wait(Config.HITBOX_DELAY)

	if v2 ~= PurifyingClawsServer.Id[player.UserId] then
		v4()
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Purifying ClawsVFX", character, "Release")
	p2.Targets = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			if not instance then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if not rootPart then
				return
			end

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p3, Config.STUN)
				Combat_Util.RagDoll(script, character, p3, Config.STUN)
				local lookVector = humanoidRootPart.CFrame.LookVector
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					lookVector * Config.KNOCKBACK,
					Config.KNOCKBACK_DURATION
				)
				table.insert(p2.Targets, instance)
			end
		end,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})

	if #p2.Targets > 0 then
		Skill_Switch_Adder.Add(player, script.Parent.Name, Config.SWITCH_WINDOW)
	end

	v4()
end

function PurifyingClawsServer.Switch(player, p, state)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local targets = state.Targets or {}
	local v2 = nil
	local v3 = nil
	local position2 = nil

	for _, target in ipairs(targets) do
		if not (target and target.Parent) then
			continue
		end

		local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 and Checker.check_victim(script, character, target) ~= nil) then
			continue
		end

		local v6 = humanoidRootPart2.Position - humanoidRootPart.Position
		local vector = Vector3.new(v6.X, 0, v6.Z)
		local v7

		if vector.Magnitude > 0.0001 then
			v7 = vector.Unit
		else
			v7 = humanoidRootPart.CFrame.LookVector
		end

		local v8 = humanoidRootPart2.Position - v7 * Config.SWITCH_BACK_OFFSET + Vector3.new(
			0,
			Config.SWITCH_HEIGHT_OFFSET,
			0
		)
		local position = humanoidRootPart.Position
		local v9 = v8 - position

		if workspace:Raycast(position, v9, RaycastHelper.Crater) then
			continue
		end

		position2 = v8
		v3 = humanoidRootPart2
		v2 = target
		break
	end

	if not (v2 and v3 and position2) then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Purifying ClawsVFX", character, "Switch")
	local v6 = PurifyingClawsServer.Id[player.UserId]
	local v7, v8 = ManuelCancel.new(player, Config.SWITCH_DURATION + 0.5)
	v7:Connect(function()
		v6 = -1
		PurifyingClawsServer.Cancel(player, p, state)
		v8()
	end)
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		state.pauseValue = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SWITCH_DURATION + 0.3)
		state.nrValue = Utility.AddValue(getvaluesfolder, "NR", Config.SWITCH_DURATION + 0.3)
		state.noMovementLinesValue = Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.SWITCH_DURATION + 0.3)
	end

	local function clearLocks()
		local pauseValue = state.pauseValue

		if pauseValue ~= nil then
			if pauseValue.Parent ~= nil then
				pauseValue:Destroy()
			end

			state.pauseValue = nil
		end

		local nrValue = state.nrValue

		if nrValue ~= nil then
			if nrValue.Parent ~= nil then
				nrValue:Destroy()
			end

			state.nrValue = nil
		end

		local noMovementLinesValue = state.noMovementLinesValue

		if noMovementLinesValue ~= nil then
			if noMovementLinesValue.Parent ~= nil then
				noMovementLinesValue:Destroy()
			end

			state.noMovementLinesValue = nil
		end
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local cframe = CFrame.lookAt(position2, v3.Position + Vector3.new(0, Config.SWITCH_HEIGHT_OFFSET, 0))
	character:PivotTo(cframe)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator then
		animator:LoadAnimation(script.Switch):Play()
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "purifying_claws_switch_lock"
	attachment.Parent = humanoidRootPart
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.Position = position2
	alignPosition.MaxForce = 10000000
	alignPosition.Responsiveness = 100
	alignPosition.Parent = attachment
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.CFrame = cframe
	alignOrientation.MaxTorque = 1000000
	alignOrientation.Responsiveness = 100
	alignOrientation.Parent = attachment
	state.switchLock = attachment
	task.wait(Config.SWITCH_HITBOX_DELAY - Config.SWITCH_VFX_LEAD)

	if v6 == PurifyingClawsServer.Id[player.UserId] then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Purifying ClawsVFX", character, "SwitchRelease")
		task.wait(Config.SWITCH_VFX_LEAD)

		if v6 == PurifyingClawsServer.Id[player.UserId] then
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = humanoidRootPart.CFrame * Config.SWITCH_HITBOX_OFFSET,
				hitboxSize = Config.SWITCH_HITBOX_SIZE,
				targets = { v2 },
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_2"
				},
				hitDetected = function(instance, p2, p3)
					if not instance then
						return
					end

					local humanoid2 = instance:FindFirstChild("Humanoid")
					local rootPart = humanoid2 and humanoid2.RootPart

					if not rootPart then
						return
					end

					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.SWITCH_BLOCK_BREAK)
					elseif p3 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.STUN)
						Combat_Util.RagDoll(script, character, p2, Config.STUN)
						local lookVector = humanoidRootPart.CFrame.LookVector
						Combat_Util.Knockback(
							script,
							character,
							rootPart,
							lookVector * Config.KNOCKBACK,
							Config.KNOCKBACK_DURATION
						)
					end
				end,
				After = function(p2, list)
					if p2 then
						ImpactSounds.Play(character, script.Parent.Name, list[1])
					end
				end
			})
			task.wait(Config.SWITCH_DURATION - Config.SWITCH_HITBOX_DELAY)

			if v6 == PurifyingClawsServer.Id[player.UserId] then
				if state.switchLock and state.switchLock.Parent then
					state.switchLock:Destroy()
				end

				state.switchLock = nil
				clearLocks()
				state.Targets = nil
				v8()
			else
				v8()
				clearLocks()
				state.Targets = nil
			end
		else
			v8()
			clearLocks()
			state.Targets = nil
		end
	else
		v8()
		clearLocks()
		state.Targets = nil
	end
end

function PurifyingClawsServer.Cancel(player, _, state)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Purifying ClawsVFX", character, "Cancel")
	end

	if state and state.switchLock then
		if state.switchLock.Parent then
			state.switchLock:Destroy()
		end

		state.switchLock = nil
	end

	if state and state.pauseValue ~= nil then
		if state.pauseValue.Parent ~= nil then
			state.pauseValue:Destroy()
		end

		state.pauseValue = nil
	end

	if state and state.nrValue ~= nil then
		if state.nrValue.Parent ~= nil then
			state.nrValue:Destroy()
		end

		state.nrValue = nil
	end

	if state and state.noMovementLinesValue ~= nil then
		if state.noMovementLinesValue.Parent ~= nil then
			state.noMovementLinesValue:Destroy()
		end

		state.noMovementLinesValue = nil
	end

	if state then
		state.Targets = nil
	end
end

return PurifyingClawsServer