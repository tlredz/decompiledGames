local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local WaterWheelServer = {
	Id = {}
}

function WaterWheelServer.Hold(player, _: Vector3, p)
	local character = player.Character

	if not character then
		return
	end

	local child = character.HumanoidRootPart:FindFirstChild((`{script.Parent.Name}-fromserver`))

	if child ~= nil then
		child:Destroy()
	end

	local v2 = WaterWheelServer.Id[player.UserId]
	p.startClock = os.clock()
	EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "Startup")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")
	local v3 = {}

	local function carry(instance, rootPart, p2)
		if v3[instance] ~= nil then
			return
		end

		local ouwWeld = Utility.CreateOuwWeld(
			humanoidRootPart,
			rootPart,
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

	local function fn(instance, p2, p3)
		if instance then
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart

			if p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SLASH_BLOCK_BREAK)
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					humanoidRootPart.CFrame.lookVector * Config.SLASH_BLOCK_KNOCKBACK,
					0.2
				)
			elseif p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true then
				Combat_Util.AddStun(script, character, p2, Config.SLASH_STUN, true)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SLASH_DAMAGE,
					Skill = script.Parent.Name
				})
				carry(instance, rootPart, p2)
				Combat_presets.PlayReactAnim(humanoid)
			end
		end
	end

	local function fn2(instance, p2, p3)
		if instance then
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart

			if p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.WHEEL_BLOCK_BREAK)
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					humanoidRootPart.CFrame.lookVector * Config.WHEEL_BLOCK_KNOCKBACK,
					0.2
				)
			elseif p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true then
				Combat_Util.AddStun(script, character, p2, Config.WHEEL_STUN, true)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.WHEEL_DAMAGE,
					Skill = script.Parent.Name
				})
				carry(instance, rootPart, p2)
				Combat_presets.PlayReactAnim(humanoid, nil, 2)
			end
		end
	end

	local function fn3(instance, p2, p3)
		if instance then
			local rootPart = instance:FindFirstChild("Humanoid").RootPart

			if p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.MIDDLE_BLOCK_BREAK)
			elseif p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true then
				local v4 = humanoidRootPart.CFrame.LookVector * Config.MIDDLE_KNOCKBACK + vector.create(
					0,
					Config.MIDDLE_KNOCKUP,
					0
				)
				Combat_Util.AddStun(script, character, p2, Config.MIDDLE_STUN, true)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.MIDDLE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(script, character, rootPart, v4, 0.3)
				Combat_Util.RagDoll(script:GetDescendants(), character, p2, Config.MIDDLE_RAGDOLL)
			end
		end
	end

	task.delay(Config.HOLD_DURATION, function()
		if WaterWheelServer.Id[player.UserId] ~= v2 then
			return
		end

		task.wait(Config.SLASH_1_AT)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
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
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "CreateSlash", "RightSlash", 0.3, 1)
		task.wait(Config.SLASH_2_DELAY)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
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
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "CreateSlash", "RightSlash", 0.2, 2)
		task.wait(Config.SLASH_3_DELAY)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
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
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "CreateSlash", "LeftSlash", 0.2, 1)
		task.wait(Config.SLASH_4_DELAY)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
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
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "CreateSlash", "RightSlash", 0.2, 2)
		task.wait(Config.WHEEL_DELAY)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		task.spawn(function()
			local lastTime = os.clock()

			while humanoidRootPart:IsDescendantOf(workspace) and v2 == WaterWheelServer.Id[player.UserId] and os.clock() - lastTime < Config.WHEEL_DUR do
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = humanoidRootPart.CFrame,
					hitboxSize = Config.WHEEL_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					hitDetected = fn2,
					After = function(p2, list)
						if p2 then
							ImpactSounds.Play(character, script.Parent.Name, list[1])
						end
					end
				})
				task.wait(Config.WHEEL_TICK_INTERVAL)
			end
		end)
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "Wheel")
		task.wait(Config.MIDDLE_DELAY)

		if v2 ~= WaterWheelServer.Id[player.UserId] then
			return
		end

		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "MiddleSlash", 6)
		local targets = releaseCarried()
		local createHitbox = Utility.CreateHitbox
		local v5 = {
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.MIDDLE_HITBOX_OFFSET,
			hitboxSize = Config.MIDDLE_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			hitDetected = 0,
			After = 0
		}

		if not (#targets > 0) then
			targets = nil
		end

		v5.targets = targets
		v5.checker = Checker
		v5.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		}
		v5.hitDetected = fn3

		function v5.After(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end

		createHitbox(v5)

		if p.pause_gameplay then
			p.pause_gameplay:Destroy()
			p.pause_gameplay = nil
		end
	end)
end

function WaterWheelServer.UnHold(_, _: Vector3?, p)
	p.releaseClock = os.clock()

	if p.ReleaseCarried ~= nil then
		p.ReleaseCarried()
	end
end

function WaterWheelServer.UnHoldAfterClient(player, p, _, p2, state)
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = (state.releaseClock or 1e999) - (state.startClock or 0)

	if p2 ~= 2 or not (v2 < Config.HOLD_DURATION + 0.25) then
		EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "Cancel")
		return
	end

	local v3, _ = ManuelCancel.new(player, Config.TAP_START_AT + Config.TAP_FINISH_DELAY)
	local v4 = WaterWheelServer.Id[player.UserId]
	v3:Connect(function()
		v4 = -1
		WaterWheelServer.Cancel(player, p, state)
	end)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "pause_gameplay"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.TAP_LOCK_DURATION)
	state.pause_gameplay = boolValue

	local function fn(instance, p3, p4)
		if instance then
			local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

			if p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.TAP_FINISH_BLOCK_BREAK)
			elseif p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == true then
				local v5 = rootPart.CFrame.LookVector * Config.TAP_FINISH_KNOCKBACK + vector.create(
					0,
					Config.TAP_FINISH_KNOCKUP,
					0
				)
				Combat_Util.AddStun(script, character, p3, Config.TAP_FINISH_STUN, true)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.TAP_FINISH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(script, character, rootPart2, v5, 0.3)
				Combat_Util.RagDoll(script:GetDescendants(), character, p3, Config.TAP_FINISH_RAGDOLL)
			end
		end
	end

	task.wait(Config.TAP_START_AT)

	if v4 ~= WaterWheelServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "Water Wheel VFX", character, "Tap")
	local part = Instance.new("Part")
	part.Size = Config.TAP_CATCH_SIZE
	part.Anchored = false
	part.CanCollide = false
	part.Transparency = 1
	part.Massless = true
	part.CanQuery = false
	part.Parent = workspace.Debree
	DebrisModule:AddItem(part, Config.TAP_LOCK_DURATION)
	local find_character_from_descendants = {}
	local v5 = false
	part.Touched:Connect(function(otherPart)
		if vector.magnitude(otherPart.Position - part.Position) > (vector.magnitude(part.Size) + vector.magnitude(otherPart.Size)) / 2 + 75 then
			return
		end

		if otherPart:IsDescendantOf(workspace.Humanoids) then
			local find_character_from_descendant = Utility.find_character_from_descendant(otherPart)

			if find_character_from_descendant ~= nil then
				local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

				if check_victim ~= nil and table.find(find_character_from_descendants, find_character_from_descendant) == nil then
					table.insert(find_character_from_descendants, find_character_from_descendant)
					local primaryPart = find_character_from_descendant.PrimaryPart

					if check_victim == true then
						if not v5 then
							v5 = true
							ImpactSounds.Play(character, script.Parent.Name, find_character_from_descendant)
						end
					elseif check_victim == "Blocking" then
						Combat_Util.Knockback(
							script,
							character,
							primaryPart,
							rootPart.CFrame.lookVector * Config.TAP_HIT_BLOCK_KNOCKBACK,
							0.2
						)
						Combat_Util.Block(
							script,
							character,
							find_character_from_descendant,
							Config.TAP_BARRAGE_BLOCK_BREAK
						)
					elseif check_victim == "Perfect" then
						Combat_Util.Perfect(script, character, find_character_from_descendant)
					end
				end
			end
		end
	end)
	local weld = Instance.new("Weld", part)
	weld.Part0 = rootPart
	weld.Part1 = part
	state.Part = part
	local v6 = Config.TAP_FINISH_DELAY / Config.TAP_BARRAGE_HIT_COUNT
	task.spawn(function()
		for _ = 1, Config.TAP_BARRAGE_HIT_COUNT do
			if v4 ~= WaterWheelServer.Id[player.UserId] then
				break
			end

			for _, v7 in ipairs(find_character_from_descendants) do
				if v7.Parent == nil then
					continue
				end

				local humanoidRootPart = v7:FindFirstChild("HumanoidRootPart")
				local humanoid = v7:FindFirstChild("Humanoid")

				if not (humanoidRootPart ~= nil and humanoid ~= nil) then
					continue
				end

				local check_victim = Checker.check_victim(script, character, v7)
				local getvaluesfolder2 = Utility.getvaluesfolder(v7)

				if check_victim == "Blocking" then
					Combat_Util.Block(script, character, v7, Config.TAP_BARRAGE_BLOCK_BREAK)
				elseif check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v7)
				elseif check_victim == true then
					Combat_Util.Damage(script, character, v7, {
						Base = Config.TAP_BARRAGE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, getvaluesfolder2, Config.TAP_BARRAGE_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart,
						vector.create(0, Config.TAP_BARRAGE_KNOCKUP, 0),
						v6
					)
					Combat_presets.PlayReactAnim(humanoid)
					EffectsEvent.ToAllInRange(character, "Normal_Sword_Slash_Effect", humanoidRootPart, -1)
				end
			end

			task.wait(v6)
		end
	end)
	task.wait(Config.TAP_FINISH_DELAY)

	if v4 ~= WaterWheelServer.Id[player.UserId] then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.TAP_FINISH_HITBOX_OFFSET,
		hitboxSize = Config.TAP_FINISH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		targets = find_character_from_descendants,
		hitDetected = fn,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})

	if state.pause_gameplay then
		state.pause_gameplay:Destroy()
		state.pause_gameplay = nil
	end

	if state.Part ~= nil then
		state.Part:Destroy()
		state.Part = nil
	end
end

function WaterWheelServer.Cancel(player, _: Vector3, state)
	if state ~= nil and state.ReleaseCarried ~= nil then
		state.ReleaseCarried()
		state.ReleaseCarried = nil
	end

	local _ = player.Character

	if state.pause_gameplay then
		state.pause_gameplay:Destroy()
		state.pause_gameplay = nil
	end

	if state.Part ~= nil then
		state.Part:Destroy()
		state.Part = nil
	end

	EffectsEvent.ToAllInRange(player, "Water Wheel VFX", player.Character, "Cancel")
end

return WaterWheelServer