local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local PartBox = require(CAM.Global.PartBox)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local FleshMonsterServer = {
	Id = {}
}
local v2 = {
	{
		delay = Config.FIRST_HIT_DELAY,
		duration = Config.FIRST_HIT_DURATION,
		size = Config.ATTACK1_HITBOX_SIZE,
		offset = Config.ATTACK1_OFFSET,
		damage = Config.ATTACK1_DAMAGE,
		stun = Config.ATTACK1_STUN,
		knockback = Config.ATTACK1_KNOCKBACK,
		vfxState = "Hit1"
	},
	{
		delay = Config.SECOND_HIT_DELAY,
		duration = Config.SECOND_HIT_DURATION,
		size = Config.ATTACK2_HITBOX_SIZE,
		offset = Config.ATTACK2_OFFSET,
		damage = Config.ATTACK2_DAMAGE,
		stun = Config.ATTACK2_STUN,
		knockback = Config.ATTACK2_KNOCKBACK,
		vfxState = "Hit2"
	},
	{
		delay = Config.LAST_HIT_DELAY,
		duration = Config.LAST_HIT_DURATION,
		size = Config.ATTACK3_HITBOX_SIZE,
		offset = Config.ATTACK3_OFFSET,
		damage = Config.ATTACK3_DAMAGE,
		stun = Config.ATTACK3_STUN,
		knockback = Config.ATTACK3_KNOCKBACK,
		ragdoll = Config.ATTACK3_STUN,
		blockBreak = Config.ATTACK3_BLOCK_BREAK,
		vfxState = "Hit3"
	}
}

function FleshMonsterServer.Hold(player, _: Vector3?, p)
	local maid = cleanit.new()
	p.CleanIt = maid
	p.hitIndex = 0
	p.hitTargets = {}
	p.ended = false
	maid:Add(function()
		p.ended = true
	end)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local cFrame = humanoidRootPart.CFrame
	local v3 = Config.TRANSFORM_DURATION + Config.LAST_HIT_DURATION + 2
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.STARTUP_DURATION))
	maid:Add(Utility.AddValue(getvaluesfolder, "skillsdisabled", v3, "StringValue", Config.LOCKED_SKILLS))
	maid:Add(Utility.AddValue(getvaluesfolder, "combatdisabled", v3))
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", v3))
	maid:Add(Utility.AddValue(getvaluesfolder, "Transparent", v3))
	maid:Add(Utility.AddValue(getvaluesfolder, "HighlightOthers", v3))
	maid:Add(Utility.AddValue(getvaluesfolder, "iframe", v3))
	EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, "Spawn", cFrame)
end

function FleshMonsterServer.UnHold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	cleanIt:Add(ManuelCancel.new(player, Config.TRANSFORM_DURATION):Connect(function()
		FleshMonsterServer.Id[player.UserId] = -1
		FleshMonsterServer.Cancel(player, vector2, state)
	end))
	state.transformStart = os.clock()
	cleanIt:Add(Skill_Switch_Adder.Add(player, script.Parent.Name, Config.TRANSFORM_DURATION))
	local v3 = {}

	local function applySlow(p, p2, check_victim)
		if p2 == nil or check_victim ~= true and check_victim ~= "Blocking" then
			return
		end

		local v4 = v3[p]

		if v4 ~= nil and v4.Parent ~= nil then
			return
		end

		local v5 = Utility.AddValue(p2, Config.AOE_SLOW_VALUE)
		v5:AddTag(StatTypes.ValueStatTag)
		v5:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.AOE_SLOW_FACTOR)
		v3[p] = v5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeSlow(k)
		local v4 = v3[k]

		if v4 ~= nil then
			v4:Destroy()
			v3[k] = nil
		end
	end

	local v4 = PartBox.new({
		Shape = "Ball",
		Center = humanoidRootPart.CFrame * Config.AOE_OFFSET,
		Size = Config.AOE_BALL_SIZE,
		MaxDuration = Config.TRANSFORM_DURATION + 1,
		caster = character,
		checker = Checker,
		hitDetected = applySlow
	})

	if v4 ~= nil then
		v4.Left:Connect(removeSlow)
		cleanIt:Add(v4)
		cleanIt:Add(function()
			for k in v3 do
				removeSlow(k) -- equivalent call inferred; original call site unknown
			end
		end)
		task.spawn(function()
			local lastTime = os.clock()

			while os.clock() - lastTime < Config.TRANSFORM_DURATION do
				if state.ended or humanoidRootPart.Parent == nil then
					break
				end

				for _, v5 in v4:Inside() do
					local check_victim = Checker.check_victim(script, character, v5)

					if check_victim == "Blocking" or check_victim == "Perfect" then
						Combat_Util.Block(script, character, v5, Config.AOE_TICK_BLOCK_BREAK)
					elseif check_victim == true then
						Combat_Util.Damage(script, character, v5, {
							Base = Config.AOE_TICK_DAMAGE,
							Skill = script.Parent.Name
						})
					end

					applySlow(v5, Utility.getvaluesfolder(v5), check_victim)
				end

				task.wait(Config.AOE_TICK_INTERVAL)
			end
		end)
	end

	task.delay(Config.TRANSFORM_DURATION, function()
		if state.ended or state.hitPlaying then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, "Exit")
		task.wait(1)

		if state.ended then
			return
		end

		cleanIt:Clean()
	end)
end

function FleshMonsterServer.Switch(player, _: Vector3?, state)
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	local v3 = FleshMonsterServer.Id[player.UserId]
	local hitIndex = (state.hitIndex or 0) + 1
	state.hitIndex = hitIndex
	local v5 = v2[hitIndex]

	if not v5 then
		return
	end

	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	state.hitPlaying = true
	cleanIt:Add(Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", v5.duration))
	EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, v5.vfxState)
	local v6 = Config.HIT_COUNT <= hitIndex

	if v6 then
		task.wait(Config.ATTACK3_SLAM_DELAY)

		if v3 ~= FleshMonsterServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * v5.offset,
			hitboxSize = v5.size,
			checker = Checker,
			targets = {},
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if not instance then
					return
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					return
				end

				if p2 == "Blocking" or p2 == "Perfect" then
					Combat_Util.Block(script, character, instance, v5.blockBreak or 3)
				elseif p2 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.ATTACK3_SLAM_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p, Config.ATTACK3_SLAM_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						createVector(0, 1, 0) * Config.ATTACK3_SLAM_KNOCKBACK,
						1.25
					)
					Combat_presets.PlayReactAnim(
						instance:FindFirstChild("Humanoid"),
						nil,
						Config.ATTACK3_SLAM_REACT_SPEED
					)
					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
				end
			end
		})
		task.wait(v5.delay - Config.ATTACK3_SLAM_DELAY)
	else
		task.wait(v5.delay)
	end

	if v3 ~= FleshMonsterServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return
	end

	local hitTargets = state.hitTargets
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * v5.offset,
		hitboxSize = v5.size,
		checker = Checker,
		targets = hitTargets,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if not instance then
				return
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if p2 == "Blocking" or p2 == "Perfect" then
				Combat_Util.Block(script, character, instance, v5.blockBreak or 3)
			elseif p2 == true then
				if table.find(hitTargets, instance) == nil then
					table.insert(hitTargets, instance)
				end

				Combat_Util.Damage(script, character, instance, {
					Base = v5.damage,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p, v5.stun)

				if v6 then
					if v5.ragdoll then
						Combat_Util.RagDoll(script, character, p, v5.ragdoll)
					end

					local unit = (humanoidRootPart2.Position - humanoidRootPart.Position).Unit
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						(unit + createVector(0, 1, 0)) * v5.knockback,
						0.24
					)
				else
					Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
				end

				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})

	if Config.HIT_COUNT <= hitIndex then
		task.wait(v5.duration - v5.delay)

		if v3 ~= FleshMonsterServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, "Exit")
		task.wait(0.5)

		if v3 ~= FleshMonsterServer.Id[player.UserId] then
			return
		end

		cleanIt:Clean()
	else
		local v7 = Config.TRANSFORM_DURATION - (os.clock() - state.transformStart)
		local v8 = v2[hitIndex + 1]

		if v8 and v8.duration <= v7 then
			state.hitPlaying = false
			cleanIt:Add(Skill_Switch_Adder.Add(player, script.Parent.Name, v7))
		else
			task.wait(v5.duration - v5.delay)

			if v3 ~= FleshMonsterServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
				return
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, "Exit")
			task.wait(0.5)

			if v3 ~= FleshMonsterServer.Id[player.UserId] then
				return
			end

			cleanIt:Clean()
		end
	end
end

function FleshMonsterServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshMonster VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return FleshMonsterServer