local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local Combat_Util = require(SAM.Services.Combat_Util)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local SpinningThrowServer = {
	Id = {}
}

local function fireProjectile(player, character, humanoidRootPart, p: number, p2: string)
	local NONVARIANT_STUN = nil
	local SHOT_DAMAGE, SHOT_STUN, SHOT_KNOCKBACK, v2

	if p2 == "Shot" then
		SHOT_DAMAGE = Config.SHOT_DAMAGE
		SHOT_STUN = Config.SHOT_STUN
		SHOT_KNOCKBACK = Config.SHOT_KNOCKBACK
		v2 = 1
	else
		if p2 == "Final" then
			SHOT_DAMAGE = Config.FINAL_DAMAGE
		else
			SHOT_DAMAGE = Config.NONVARIANT_DAMAGE
		end

		SHOT_STUN = Config.NONVARIANT_STUN
		SHOT_KNOCKBACK = Config.NONVARIANT_KNOCKBACK
		NONVARIANT_STUN = Config.NONVARIANT_STUN
		v2 = 3
	end

	local position = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.AIM_RANGE) or (humanoidRootPart.CFrame * CFrame.new(
		0,
		0,
		-1
	)).Position
	local target = ProjectileHoming.Pick({
		Script = script,
		Caster = character,
		Origin = humanoidRootPart.Position,
		Aim = position,
		Range = Config.AIM_RANGE,
		Radius = Config.SPHERECAST_RADIUS,
		Downcast = Config.DOWNCAST,
		Select = true
	})

	if target == nil then
		position = Utility.SnapAimToTarget({
			Caster = character,
			Aim = position,
			Radius = Config.AIM_SNAP_RADIUS,
			ParamsName = `{player.Name}-{script.Parent.Name}-aimsnap`,
			Checker = Checker
		})
	else
		local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 ~= nil then
			position = humanoidRootPart2.Position
		end
	end

	local unit = (position - humanoidRootPart.Position).Unit
	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	local formatted = `{player.Name} SpinningThrow {p}`
	local flag = false
	local projectile = ProjectileModeler.new({
		Name = formatted,
		Size = Config.PROJECTILE_SIZE,
		CFrame = cFrame,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.PROJECTILE_SPEED
		},
		Rotator = {
			Responsiveness = 75,
			CFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + unit)
		}
	}, function(position2: Vector3?, vector2: Vector3?, p3)
		if flag then
			return true
		end

		flag = true
		local humanoidRootPart2 = nil
		local v6

		if p3 then
			v6 = Utility.find_character_from_descendant(p3)

			if v6 then
				humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
			end
		end

		if humanoidRootPart2 then
			position2 = humanoidRootPart2.Position
		end

		local toAllInRange = EffectsEvent.ToAllInRange

		if humanoidRootPart2 then
			vector2 = nil
		end

		toAllInRange(humanoidRootPart, "Spinning Throw VFX", character, "Impact", position2, vector2, p2, unit, p)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position2),
			hitboxSize = Config.PROJECTILE_AOE_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			targets = v6 and { v6 } or nil,
			hitDetected = function(instance, p4, p5)
				local humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")

				if p5 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p5 == "Blocking" then
					Combat_Util.Block(script, character, instance, 1)
				elseif p5 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = SHOT_DAMAGE,
						Skill = Config.SKILL_NAME
					})
					Combat_Util.AddStun(script, character, p4, SHOT_STUN)

					if NONVARIANT_STUN then
						Combat_Util.RagDoll(script, character, p4, NONVARIANT_STUN)
					end

					local v11

					if v2 == 3 then
						v11 = (humanoidRootPart3.Position - humanoidRootPart.Position).Unit + createVector(0, 1, 0)
					else
						v11 = (humanoidRootPart3.Position - humanoidRootPart.Position).Unit
					end

					Combat_Util.Knockback(script, character, humanoidRootPart3, v11 * SHOT_KNOCKBACK, 0.2)

					if p2 == "NonVariant" then
						local v12 = Utility.AddValue(p4, Config.NONVARIANT_SLOW_VALUE, Config.NONVARIANT_SLOW_DURATION)
						v12:AddTag(StatTypes.ValueStatTag)
						v12:SetAttribute(
							StatTypes.StatToAttribute("Movement Speed Factor"),
							Config.NONVARIANT_SLOW_FACTOR
						)
					end

					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart3, -1)
				end
			end
		})
		return true
	end, Config.PROJECTILE_DURATION, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
	projectile.Instance:SetNetworkOwner(player)
	projectile.Instance.Transparency = 1

	if target ~= nil then
		ProjectileHoming.Track({
			Projectile = projectile,
			Target = target,
			Speed = Config.PROJECTILE_SPEED,
			Tick = Config.TRACK_TICK,
			Rotate = true,
			ShouldStop = function()
				return flag
			end
		})
	end

	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Spinning Throw VFX",
		character,
		"Projectile",
		formatted,
		unit,
		projectile.Instance,
		p,
		p2 == "NonVariant"
	)
end

function SpinningThrowServer.Hold(player, _: Vector3?, state)
	local maid = cleanit.new()
	state.CleanIt = maid
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	state.holdStart = os.clock()
	state.holdActive = true
	state.barrageStarted = false
	state.barrageComplete = false
	state.cancelled = false
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 10))
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.AIM_RANGE)
	maid:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Spinning Throw VFX", character, "Start", "LeftHand")
	task.delay(Config.HOLD_THRESHOLD, function()
		if not state.holdActive or state.cancelled or state.barrageStarted then
			return
		end

		state.barrageStarted = true
		state.barrageStartTime = os.clock()
		local character2 = player.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (character2 and humanoidRootPart2) then
			return
		end

		local v2, _ = ManuelCancel.new(player, Config.BARRAGE_DURATION)
		v2:Connect(function()
			SpinningThrowServer.Id[player.UserId] = -1
			SpinningThrowServer.Cancel(player, nil, state)
		end)
		local BARRAGE_THROW_GAPS = Config.BARRAGE_THROW_GAPS

		for i = 1, #BARRAGE_THROW_GAPS - 1 do
			task.wait(BARRAGE_THROW_GAPS[i] - Config.HAND_BALL_LEAD)

			if state.cancelled then
				return
			end

			local v3 = i % 2 == 1 and "RightHand" or "LeftHand"
			EffectsEvent.ToAllInRange(humanoidRootPart2, "Spinning Throw VFX", character2, "HandBall", v3, i)
			task.wait(Config.HAND_BALL_LEAD)

			if state.cancelled then
				return
			else
				fireProjectile(player, character2, humanoidRootPart2, i, "Shot")
			end
		end

		task.wait(BARRAGE_THROW_GAPS[#BARRAGE_THROW_GAPS])

		if state.cancelled then
			return
		end

		fireProjectile(player, character2, humanoidRootPart2, #BARRAGE_THROW_GAPS, "Final")
		state.barrageComplete = true
		local cleanIt = state.CleanIt

		if cleanIt then
			cleanIt:Clean()
		end
	end)
end

function SpinningThrowServer.UnHold(player, vector2: Vector3?, state)
	local v2 = SpinningThrowServer.Id[player.UserId]
	local v3 = os.clock() - (state.holdStart or 0)

	if state.barrageStarted or Config.HOLD_THRESHOLD <= v3 then
		while not state.barrageStarted do
			task.wait()

			if state.cancelled then
				return
			end
		end

		state.holdActive = false

		if state.barrageComplete then
			return
		end

		local v4 = os.clock() - (state.barrageStartTime or 0)
		local v5 = Config.BARRAGE_MIN_HOLD - v4

		if v5 > 0 then
			task.wait(v5)

			if state.barrageComplete then
				return
			end
		end

		SpinningThrowServer.Id[player.UserId] = -1
		SpinningThrowServer.Cancel(player, vector2, state)
	else
		state.holdActive = false
		local cleanIt = state.CleanIt or cleanit.new()
		state.CleanIt = cleanIt
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local v4, v5 = ManuelCancel.new(player, Config.SINGULAR_THROW_TIME)
		v4:Connect(function()
			SpinningThrowServer.Id[player.UserId] = -1
			SpinningThrowServer.Cancel(player, vector2, state)
		end)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spinning Throw VFX", character, "DashStart")
		task.wait(Config.SINGULAR_THROW_TIME)

		if SpinningThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		fireProjectile(player, character, humanoidRootPart, 1, "NonVariant")

		if SpinningThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		v5()
		cleanIt:Clean()
	end
end

function SpinningThrowServer.Cancel(player, _: Vector3?, p)
	p.cancelled = true
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spinning Throw VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return SpinningThrowServer