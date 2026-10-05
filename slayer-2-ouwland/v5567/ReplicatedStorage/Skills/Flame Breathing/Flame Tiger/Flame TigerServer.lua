local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local gameSettings = require(CAM.Global.gameSettings)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(Config.HEAD_ACCEL_TIME, Enum.EasingStyle.Sine)
local tweenInfo2 = TweenInfo.new(Config.HEAD_DECEL_TIME, Enum.EasingStyle.Sine)
local FlameTigerServer = {
	Id = {}
}

function FlameTigerServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	EffectsEvent.ToAllInRange(player, "Flame Tiger TapVFX", character, "Start")
	local v2 = FlameTigerServer.Id[player.UserId]
	p.startClock = os.clock()
	local v3 = {}

	local function carry(instance, rootPart2, p2)
		if v3[instance] ~= nil then
			return
		end

		local ouwWeld = Utility.CreateOuwWeld(
			rootPart,
			rootPart2,
			CFrame.new(0, 0, Config.CARRY_FORWARD),
			Config.CARRY_DURATION
		)

		if ouwWeld == nil then
			return
		end

		local v4 = Utility.AddValue(p2, "pause_gameplay", Config.CARRY_DURATION)
		local v5 = Utility.AddValue(p2, "NR", Config.CARRY_DURATION)
		Combat_Util.Cancel(script, p2)
		v3[instance] = { ouwWeld, v4, v5 }
	end

	local function releaseCarried()
		local result = {}

		for k, v4 in v3 do
			table.insert(result, k)

			for _, v5 in v4 do
				if typeof(v5) == "Instance" and v5.Parent ~= nil then
					v5:Destroy()
				end
			end

			v3[k] = nil
		end

		return result
	end

	p.ReleaseCarried = releaseCarried

	local function carried()
		local result = {}

		for k in v3 do
			table.insert(result, k)
		end

		return result
	end

	task.delay(Config.HOLD_DURATION, function()
		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		local function fn(instance, p2, p3)
			if instance then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid.RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SLASH_BLOCK_BREAK)
					local v4 = rootPart.CFrame.LookVector * Config.BLOCKED_KNOCKBACK
					Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
				else
					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
						return true
					end

					if p3 == true then
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
						Combat_Util.AddStun(script, character, p2, Config.SLASH_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.SLASH_DAMAGE,
							Skill = script.Parent.Name
						})
						carry(instance, rootPart2, p2)
						Combat_presets.PlayReactAnim(humanoid, nil, Config.SLASH_REACT_ANIM_SPEED)
					end
				end
			end
		end

		local function fn2(instance, p2, p3)
			if instance then
				local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.IMPACT_BLOCK_BREAK)
					local v4 = rootPart.CFrame.LookVector * Config.BLOCKED_KNOCKBACK
					Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
				else
					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
						return true
					end

					if p3 == true then
						local v4 = rootPart.CFrame.LookVector * Config.IMPACT_KNOCKBACK + vector.create(
							0,
							Config.IMPACT_KNOCKUP,
							0
						)
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
						Combat_Util.AddStun(script, character, p2, Config.IMPACT_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.IMPACT_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
						Combat_Util.RagDoll(script:GetDescendants(), character, p2, Config.IMPACT_RAGDOLL)
					end
				end
			end
		end

		task.wait(Config.SLASH1_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Slash", 1)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
			hitboxSize = Config.SLASH_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
		task.wait(Config.SLASH2_AT - Config.SLASH1_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Slash", 2)
		local createHitbox = Utility.CreateHitbox
		local v4 = {
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
			hitboxSize = Config.SLASH_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			hitDetected = 0,
			After = 0
		}
		local targets = {}

		for k in v3 do
			table.insert(targets, k)
		end

		v4.targets = targets
		v4.checker = Checker
		v4.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		}
		v4.hitDetected = fn

		function v4.After(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end

		createHitbox(v4)
		task.wait(Config.SLASH3_AT - Config.SLASH2_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Slash", 3)
		local createHitbox2 = Utility.CreateHitbox
		local v6 = {
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
			hitboxSize = Config.SLASH_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			hitDetected = 0,
			After = 0
		}
		local targets2 = {}

		for k in v3 do
			table.insert(targets2, k)
		end

		v6.targets = targets2
		v6.checker = Checker
		v6.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		}
		v6.hitDetected = fn

		function v6.After(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end

		createHitbox2(v6)
		task.wait(Config.SLASH4_AT - Config.SLASH3_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Slash", 4)
		local createHitbox3 = Utility.CreateHitbox
		local v8 = {
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
			hitboxSize = Config.SLASH_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			hitDetected = 0,
			After = 0
		}
		local targets3 = {}

		for k in v3 do
			table.insert(targets3, k)
		end

		v8.targets = targets3
		v8.checker = Checker
		v8.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		}
		v8.hitDetected = fn

		function v8.After(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end

		createHitbox3(v8)
		task.wait(Config.HEAD_AT - Config.SLASH4_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		local clone = script.TigerHead:Clone()
		clone.Parent = workspace.Debree
		clone.TouchPart:Destroy()
		clone.Name = `{character.Name}'s Flame Tiger Head`
		local weld = Instance.new("Weld", clone.RootPart)
		weld.Part0 = rootPart
		weld.Part1 = clone.RootPart
		weld.C1 = CFrame.Angles(0, 3.141592653589793, 0)
		clone.AnimationController.Animator:LoadAnimation(script.FinalHeadANim):Play(nil, nil, 1.95)
		DebrisModule:AddItem(clone, Config.HOLD_HEAD_LIFETIME)
		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Jump", nil, clone)
		task.wait(Config.SLAM_AT - Config.HEAD_AT)

		if FlameTigerServer.Id[player.UserId] ~= v2 then
			return
		end

		local v10 = rootPart.CFrame * Config.IMPACT_VFX_OFFSET
		EffectsEvent.ToAllInRange(player, "Flame Tiger HoldVFX", character, "Slam", nil, nil, v10)
		local targets4 = releaseCarried()

		if #targets4 > 0 then
			task.wait()

			if FlameTigerServer.Id[player.UserId] ~= v2 then
				return
			end
		end

		local createHitbox4 = Utility.CreateHitbox
		local v12 = {
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.IMPACT_HITBOX_OFFSET,
			hitboxSize = Config.IMPACT_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			TreeDestruction = true,
			hitDetected = 0,
			After = 0
		}

		if not (#targets4 > 0) then
			targets4 = nil
		end

		v12.targets = targets4
		v12.checker = Checker
		v12.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		}
		v12.hitDetected = fn2

		function v12.After(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end

		createHitbox4(v12)
	end)
end

function FlameTigerServer.UnHold(player, vector2: Vector3, state)
	local character = player.Character

	if state.ReleaseCarried ~= nil then
		state.ReleaseCarried()
	end

	if state.TouchedConnection ~= nil then
		state.TouchedConnection:Disconnect()
		state.TouchedConnection = nil
	end

	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2 = os.clock() - state.startClock
	local vector3 = vector.create(vector2.X, rootPart.Position.Y, vector2.Z)
	local safeLookAt = Utility.SafeLookAt(rootPart.Position, vector3, rootPart.CFrame)
	local v3 = FlameTigerServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, 3)
	v4:Connect(function()
		v3 = -1
		FlameTigerServer.Cancel(player, vector2, state)
	end)
	local child = workspace.Debree:FindFirstChild((`{character.Name}'s Flame Tiger Head`))

	if child ~= nil then
		child:Destroy()
	end

	if v2 < Config.HOLD_DURATION then
		task.delay(0.2, function()
			if FlameTigerServer.Id[player.UserId] ~= v3 then
				return
			end

			EffectsEvent.ToAllInRange(player, "Flame Tiger TapVFX", character, "Jump")
		end)
		local clone = script.TigerHead:Clone()
		clone:PivotTo(safeLookAt * CFrame.Angles(0, 3.141592653589793, 0))
		clone.Parent = workspace.Debree
		clone.Name = `{character.Name}'s Flame Tiger Head`
		clone.RootPart:SetNetworkOwner(player)
		local track = clone.AnimationController.Animator:LoadAnimation(script.TigerAnim)
		local attachment = Instance.new("Attachment", clone.RootPart)
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Parent = attachment
		linearVelocity.Attachment0 = attachment
		linearVelocity.MaxForce = 200000
		local v6 = {}
		local v7 = {}
		local v8 = {}
		state.TouchedConnection = clone.TouchPart.Touched:Connect(function(otherPart)
			if FlameTigerServer.Id[player.UserId] ~= v3 or (otherPart.Position - safeLookAt.Position).Magnitude > Config.TAP_HEAD_SPEED * Config.TAP_CATCH_DURATION + 25 then
				return
			end

			if otherPart:IsDescendantOf(workspace.Humanoids) then
				local find_character_from_descendant = Utility.find_character_from_descendant(otherPart)

				if find_character_from_descendant == nil or find_character_from_descendant == character or v7[find_character_from_descendant] ~= nil then
					return
				end

				local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

				if check_victim == nil then
					return
				end

				if check_victim == "Blocking" or check_victim == "Perfect" then
					local now = os.clock()
					local v9 = v8[find_character_from_descendant]

					if v9 ~= nil and now < v9 then
						return
					end

					v8[find_character_from_descendant] = now + gameSettings.default_touched_cooldown

					if check_victim == "Perfect" then
						Combat_Util.Perfect(script, character, find_character_from_descendant)
					else
						Combat_Util.Block(script, character, find_character_from_descendant, Config.CATCH_BLOCK_BREAK)
					end
				else
					v7[find_character_from_descendant] = true
					local humanoidRootPart = find_character_from_descendant:FindFirstChild("HumanoidRootPart") or find_character_from_descendant.PrimaryPart
					local ouwWeld = Utility.CreateOuwWeld(
						clone.TouchPart,
						humanoidRootPart,
						CFrame.new(0, -5, 8.5),
						1.5
					)
					local getvaluesfolder = Utility.getvaluesfolder(find_character_from_descendant)
					local v9 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.TAP_CARRY_PAUSE_GAMEPLAY)
					Combat_Util.Cancel(script, getvaluesfolder)
					table.insert(v6, { find_character_from_descendant, ouwWeld, v9 })
				end
			end
		end)
		DebrisModule:AddItem(clone.TouchPart, Config.TAP_CATCH_DURATION)
		TweenService:Create(linearVelocity, tweenInfo, {
			VectorVelocity = safeLookAt.LookVector * Config.TAP_HEAD_SPEED
		}):Play()
		track:Play(0)
		track.TimePosition = 0.45
		DebrisModule:AddItem(clone, Config.TAP_HEAD_LIFETIME)
		local v9 = Config.HOLD_DURATION - v2
		task.wait(0.35 + v9)

		if FlameTigerServer.Id[player.UserId] == v3 then
			EffectsEvent.ToAllInRange(player, "Flame Tiger TapVFX", character, "Release", clone)
		end

		task.delay(Config.HEAD_DECEL_DELAY, function()
			if linearVelocity ~= nil and linearVelocity.Parent ~= nil then
				TweenService:Create(linearVelocity, tweenInfo2, {
					VectorVelocity = createVector(0, 0, 0)
				}):Play()
			end
		end)
		task.wait(Config.TAP_BITE_DELAY)

		if state.TouchedConnection ~= nil then
			state.TouchedConnection:Disconnect()
			state.TouchedConnection = nil
		end

		if FlameTigerServer.Id[player.UserId] ~= v3 then
			return
		end

		local hitboxCFrame = safeLookAt * Config.BITE_HITBOX_OFFSET
		clone.TouchPart:Destroy()
		task.wait()
		local targets = {}

		for _, v12 in ipairs(v6) do
			v12[2]:Destroy()
			v12[3]:Destroy()
			table.insert(targets, v12[1])
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = Config.BITE_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			targets = targets,
			hitDetected = function(instance, p, p2)
				if instance then
					local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

					if p2 == "Blocking" or p2 == "Perfect" then
						Combat_Util.Block(script, character, instance, Config.BITE_BLOCK_BREAK)
					elseif p2 == true then
						if table.find(targets, instance) == nil then
							table.insert(targets, instance)
						end

						local v12 = safeLookAt.LookVector * Config.BITE_KNOCKBACK + vector.create(
							0,
							Config.BITE_KNOCKUP,
							0
						)
						Combat_Util.AddStun(script, character, p, Config.BITE_STUN, true)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.BITE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v12, Config.BITE_KNOCKBACK_DURATION)
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
					end
				end
			end
		})
		EffectsEvent.ToAllInRange(player, "Flame Tiger TapVFX", character, "Bite", hitboxCFrame)
		task.wait(Config.TAP_DIVE_DELAY)

		if FlameTigerServer.Id[player.UserId] ~= v3 then
			return
		end

		local hitboxCFrame2 = safeLookAt * Config.DIVE_HITBOX_OFFSET
		EffectsEvent.ToAllInRange(player, "Flame Tiger TapVFX", character, "Dive", hitboxCFrame2)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame2,
			hitboxSize = Config.DIVE_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			TreeDestruction = true,
			targets = targets,
			hitDetected = function(instance, p, p2)
				if instance then
					local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

					if p2 == "Blocking" or p2 == "Perfect" then
						Combat_Util.Block(script, character, instance, Config.DIVE_BLOCK_BREAK)
					elseif p2 == true then
						local v13 = safeLookAt.LookVector * Config.DIVE_KNOCKBACK + vector.create(
							0,
							Config.DIVE_KNOCKUP,
							0
						)
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
						Combat_Util.AddStun(script, character, p, Config.DIVE_STUN, true)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.DIVE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v13, 0.2)
						Combat_Util.RagDoll(script, character, p, Config.DIVE_RAGDOLL)
					end
				end
			end,
			After = function(p, list)
				if p then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
	end

	v5()
end

function FlameTigerServer.Cancel(p, _: Vector3, state)
	if state.ReleaseCarried ~= nil then
		state.ReleaseCarried()
		state.ReleaseCarried = nil
	end

	if state.TouchedConnection ~= nil then
		state.TouchedConnection:Disconnect()
		state.TouchedConnection = nil
	end

	local child = workspace.Debree:FindFirstChild((`{p.Name}'s Flame Tiger Head`))

	if child ~= nil then
		child:Destroy()
	end
end

return FlameTigerServer