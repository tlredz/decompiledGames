local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Config = require(script.Parent.Config)
local DunkServer = {
	Id = {},
	Hold = function(player, _: Vector3?, p)
		local maid = cleanit.new()
		p.CleanIt = maid
		maid:Clean()
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 8)
		maid:Add(function()
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end)
		p.holding = true
		maid:Add(function()
			p.holding = false
		end)
		p.lock = ProjectileHoming.HoldLock({
			Pick = {
				Script = script,
				Caster = character,
				Origin = humanoidRootPart.Position,
				Range = Config.AIM_RANGE,
				Radius = Config.AIM_PICK_RADIUS,
				Downcast = Config.AIM_DOWNCAST,
				Select = true
			},
			Origin = function()
				return humanoidRootPart.Position
			end,
			Aim = function()
				return Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.AIM_RANGE)
			end,
			While = function()
				return p.holding == true and humanoidRootPart.Parent ~= nil
			end
		})
		EffectsEvent.ToAllInRange(humanoidRootPart, "Dunk VFX", character, "Start")
	end
}

function DunkServer.UnHold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	local v2 = DunkServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	cleanIt:Add(ManuelCancel.new(player, Config.RELEASE_DURATION):Connect(function()
		DunkServer.Id[player.UserId] = -1
		DunkServer.Cancel(player, vector2, state)
	end))
	cleanIt:Add(Combat_Util.Add_air_combo_bp(
		humanoidRootPart,
		humanoidRootPart,
		Config.UPDRAFT_HEIGHT,
		nil,
		Config.UPDRAFT_DURATION
	))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Dunk VFX", character, "Updraft")
	task.wait(Config.HIT_TIMING)

	if DunkServer.Id[player.UserId] ~= v2 then
		return
	end

	local position = humanoidRootPart.Position
	local aim = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.AIM_RANGE, vector2) or position + humanoidRootPart.CFrame.LookVector * Config.AIM_RANGE
	Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	local maximizeRayServer, v4 = RaycastHelper.MaximizeRayServer(character, position, aim, Config.AIM_RANGE, true, 2)

	if not v4 then
		maximizeRayServer, v4 = RaycastHelper.MaximizeRayServer(
			character,
			position,
			aim,
			Config.AIM_RANGE,
			true,
			2,
			Config.AIM_DOWNCAST,
			nil,
			RaycastHelper.Crater
		)
	end

	local vector3

	if v4 then
		local v5 = position.Y + Config.UPDRAFT_HEIGHT
		vector3 = Vector3.new(maximizeRayServer.X, math.min(maximizeRayServer.Y, v5), maximizeRayServer.Z)
	else
		vector3 = aim
		v4 = createVector(0, 1, 0)
	end

	local lock = state.lock
	local target

	if lock == nil then
		target = nil
	else
		target = lock:Target()
	end

	state.holding = false

	if target == nil then
		target = ProjectileHoming.Pick({
			Script = script,
			Caster = character,
			Origin = position,
			Aim = aim,
			Range = Config.AIM_RANGE,
			Radius = Config.AIM_PICK_RADIUS,
			Downcast = Config.AIM_DOWNCAST,
			Select = true
		})
	end

	if target == nil then
		vector3 = Utility.SnapAimToTarget({
			Caster = character,
			Aim = vector3,
			Radius = Config.AIM_SNAP_RADIUS,
			ParamsName = `{player.Name}-{script.Parent.Name}-aimsnap`,
			Checker = Checker
		})
	else
		local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 ~= nil then
			vector3 = humanoidRootPart2.Position
			v4 = createVector(0, 1, 0)
		end
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0.302, -1.158, -4.283)
	local unit = (vector3 - cFrame.Position).Unit
	local formatted = `{player.Name} DunkBall`
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
	}, function(vector4: Vector3?, vector5: Vector3?, p)
		if flag then
			return true
		end

		flag = true
		local v8 = vector4 or vector3

		if typeof(vector5) ~= "Vector3" then
			vector5 = v4
		end

		local function zoneCentre()
			if target ~= nil and Checker.check_can_select(script, character, target) then
				local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 ~= nil then
					return humanoidRootPart2.Position
				end
			end

			return v8
		end

		local position2

		if target == nil or not Checker.check_can_select(script, character, target) then
			position2 = v8
		else
			local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				position2 = v8
			else
				position2 = humanoidRootPart2.Position
			end
		end

		local v9

		if p then
			v9 = Utility.find_character_from_descendant(p)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Dunk VFX", character, "Impact", v8, vector5)
		local instances = {}
		local createHitbox = Utility.CreateHitbox
		local v10 = {
			caster = character,
			hitboxCFrame = CFrame.new(position2),
			hitboxSize = Config.IMPACT_HITBOX_SIZE,
			checker = Checker,
			targets = 0,
			hitPriorityHandler = 0,
			hitDetected = 0
		}
		local targets = {}

		if v9 ~= nil then
			table.insert(targets, v9)
		end

		if target ~= nil and target.Parent ~= nil and target ~= v9 then
			table.insert(targets, target)
		end

		if not (#targets > 0) then
			targets = nil
		end

		v10.targets = targets
		v10.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_2"
		}

		function v10.hitDetected(instance, p2, p3)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, 1)
			elseif p3 == true then
				if table.find(instances, instance) == nil then
					table.insert(instances, instance)
				end

				Combat_Util.Damage(script, character, instance, {
					Base = Config.IMPACT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.IMPACT_STUN)
				Combat_Util.Knockback(script, character, humanoidRootPart2, createVector(0, 3, 0), 1)
				Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.4)
			end
		end

		createHitbox(v10)
		task.delay(Config.EXPLOSION_DELAY, function()
			local position3

			if target == nil or not Checker.check_can_select(script, character, target) then
				position3 = v8
			else
				local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					position3 = v8
				else
					position3 = humanoidRootPart2.Position
				end
			end

			local v12 = {}

			local function explode(p2, p3, humanoidRootPart2)
				v12[p2] = true
				Combat_Util.Damage(script, character, p2, {
					Base = Config.EXPLOSION_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p3, Config.EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p3, Config.EXPLOSION_STUN)
				local v13 = (humanoidRootPart2.Position - position3) * createVector(1, 0, 1)
				local v14 = not (v13.Magnitude > 0.05) and createVector(0, 1, 0) or v13.Unit
				Combat_Util.Knockback(script, character, humanoidRootPart2, v14 * Config.EXPLOSION_KNOCKBACK, 0.3)
			end

			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = CFrame.new(position3),
				hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_3"
				},
				hitDetected = function(instance, p2, p3)
					if v12[instance] then
						return
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, 1)
					elseif p3 == true then
						explode(instance, p2, humanoidRootPart2)
					end
				end
			})
			local clone = table.clone(instances)

			if target ~= nil and target.Parent ~= nil and table.find(clone, target) == nil and target:FindFirstChild("HumanoidRootPart") ~= nil then
				table.insert(clone, target)
			end

			for _, v13 in clone do
				if v12[v13] then
					continue
				end

				local humanoidRootPart2 = v13:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					continue
				end

				local check_victim = Checker.check_victim(script, character, v13)
				v12[v13] = true

				if check_victim == "Blocking" or check_victim == "Perfect" then
					Combat_Util.Block(script, character, v13, 1)
				elseif check_victim == true then
					explode(v13, Utility.getvaluesfolder(v13), humanoidRootPart2)
				end
			end
		end)
		return true
	end, Config.PROJECTILE_DURATION, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater, true)
	projectile.Instance:SetNetworkOwner(player)

	if target ~= nil then
		ProjectileHoming.Track({
			Projectile = projectile,
			Target = target,
			Speed = Config.PROJECTILE_SPEED,
			Tick = Config.TRACK_TICK,
			Rotate = true,
			ShouldStop = function()
				return flag or DunkServer.Id[player.UserId] ~= v2
			end
		})
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Dunk VFX", character, "Slam", vector3, projectile.Instance, formatted)
	task.wait(Config.RELEASE_DURATION - Config.HIT_TIMING)

	if DunkServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function DunkServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Dunk VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return DunkServer