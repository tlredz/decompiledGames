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
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local Config = require(script.Parent.Config)
local SpiralingShotServer = {
	Id = {},
	Hold = function(player, _: Vector3?, p)
		local maid = cleanit.new()
		p.CleanIt = maid
		maid:Clean()
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local getvaluesfolder = Utility.getvaluesfolder(character)
		maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LAUNCH_DELAY + 0.3))
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.LAUNCH_DELAY + 2)
		maid:Add(function()
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end)
		task.delay(Config.STARTUP_DELAY, function()
			if not p.CleanIt then
				return
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "Spiraling Shot VFX", character, "Startup")
		end)
	end
}

function SpiralingShotServer.UnHold(player, position: Vector3?, state)
	local v2 = SpiralingShotServer.Id[player.UserId]
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	cleanIt:Add(ManuelCancel.new(player, Config.PROJECTILE_LIFETIME + Config.HIT_VFX_DELAY + 2):Connect(function()
		SpiralingShotServer.Id[player.UserId] = -1
		SpiralingShotServer.Cancel(player, position, state)
	end))
	local v3 = Server_Mouse_Pos.Find(character, script.Parent.Name)

	if v3 then
		local defaultPos = v3:GetAttribute("DefaultPos")

		if defaultPos == nil or (v3.Position - defaultPos).Magnitude > 1 then
			position = v3.Position
		end
	end

	local clamped = Server_Mouse_Pos.Clamp(character, position, Config.AIM_RANGE)
	local target = ProjectileHoming.Pick({
		Script = script,
		Caster = character,
		Origin = humanoidRootPart.Position,
		Aim = clamped,
		Range = Config.AIM_RANGE,
		Radius = Config.SPHERECAST_RADIUS,
		Downcast = Config.DOWNCAST
	})
	local unit

	if clamped then
		local v5 = clamped - humanoidRootPart.Position

		if v5.Magnitude > 0.01 then
			unit = v5.Unit
		else
			unit = humanoidRootPart.CFrame.LookVector
		end
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local v5 = humanoidRootPart.Position + unit * 2
	local cframe = CFrame.lookAt(v5, v5 + unit)
	local find_character_from_descendants = {}
	local formatted = `Touched for {script.Parent.Name} from {player.Name} {v2}`
	local v6 = nil
	local flag = false
	local v7 = false
	local formatted2 = `{player.Name} SpiralingShot`
	local projectile = nil
	projectile = ProjectileModeler.new({
		Name = formatted2,
		Size = Config.PROJECTILE_SIZE,
		CFrame = cframe,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.PROJECTILE_SPEED
		}
	}, function(_, _, p)
		if SpiralingShotServer.Id[player.UserId] ~= v2 then
			return true
		end

		if p == nil then
			return false
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p)

		if find_character_from_descendant == nil or table.find(
			find_character_from_descendants,
			find_character_from_descendant
		) then
			return false
		end

		local getvaluesfolder = Utility.getvaluesfolder(find_character_from_descendant)

		if not Combat_Util.CheckCanTouch(getvaluesfolder, formatted) then
			return false
		end

		local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

		if check_victim ~= nil then
			v7 = true
		end

		if check_victim == "Perfect" then
			Combat_Util.SetTouchCooldown(getvaluesfolder, formatted, Config.PROJECTILE_LIFETIME + 1)
			Combat_Util.Perfect(script, character, find_character_from_descendant)
			return false
		elseif check_victim == "Blocking" then
			Combat_Util.SetTouchCooldown(getvaluesfolder, formatted, Config.PROJECTILE_LIFETIME + 1)
			Combat_Util.Block(script, character, find_character_from_descendant, Config.BLOCK_BREAK)
			return false
		else
			if check_victim ~= true then
				return false
			end

			local humanoidRootPart2 = find_character_from_descendant:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				return false
			end

			table.insert(find_character_from_descendants, find_character_from_descendant)

			if v6 == nil then
				v6 = humanoidRootPart2
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(find_character_from_descendant)
			local v9 = Config.GRAB_WINDOW + Config.HIT_VFX_DELAY + 0.5
			cleanIt:Add(Utility.AddValue(getvaluesfolder2, "NR", v9))
			cleanIt:Add(Utility.AddValue(getvaluesfolder2, "pause_gameplay", v9))
			Combat_Util.Cancel(script, getvaluesfolder2)
			local instance = projectile and projectile.Instance

			if instance == nil then
				return false
			end

			local count = #find_character_from_descendants
			local v10 = ((count - 1) % 2 == 0 and 1 or -1) * math.floor(count / 2) * Config.GRAB_OFFSET_STRIDE
			cleanIt:Add(Utility.CreateOuwWeld(instance, humanoidRootPart2, CFrame.new(v10, 0, 2), v9))
			EffectsEvent.ToAllInRange(
				humanoidRootPart,
				"Spiraling Shot VFX",
				character,
				"Hit",
				humanoidRootPart2.CFrame
			)

			if flag then
				return false
			end

			flag = true

			if projectile.thread then
				task.cancel(projectile.thread)
				projectile.thread = nil
			end

			task.delay(Config.GRAB_WINDOW, function()
				if SpiralingShotServer.Id[player.UserId] ~= v2 then
					return
				end

				local instance2 = projectile and projectile.Instance
				local mover = instance2 and instance2.Parent and instance2:FindFirstChild("Mover")

				if mover then
					local vectorVelocity = mover.VectorVelocity
					local v11

					if vectorVelocity.Magnitude > 0.01 then
						v11 = vectorVelocity.Unit
					else
						v11 = unit
					end

					mover.VectorVelocity = (v11 * 0.3 + createVector(0, 1, 0)).Unit * 40
				end

				EffectsEvent.ToAllInRange(humanoidRootPart, "Spiraling Shot VFX", character, "Arc", formatted2)
				task.delay(Config.HIT_VFX_DELAY, function()
					local instance3 = projectile and projectile.Instance
					local v11

					if instance3 then
						v11 = projectile:Position()
					end

					if v11 ~= nil then
						instance3.CFrame = instance3.CFrame.Rotation + v11
					end

					state.explosionPos = v11 or v6 and v6.Position or humanoidRootPart.Position

					if projectile and projectile.Destroy then
						projectile:Destroy()
					end
				end)
			end)
			return false
		end
	end, Config.PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.Humanoids, character)

	if projectile.Instance then
		projectile.Instance:SetNetworkOwner(player)
	end

	cleanIt:Add(projectile)

	if target ~= nil then
		ProjectileHoming.Track({
			Projectile = projectile,
			Target = target,
			Speed = Config.PROJECTILE_SPEED,
			Tick = Config.TRACK_TICK,
			ShouldStop = function()
				return flag or v7 or SpiralingShotServer.Id[player.UserId] ~= v2
			end
		})
	end

	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Spiraling Shot VFX",
		character,
		"Projectile",
		formatted2,
		projectile.Instance
	)
	projectile.Destroying:Wait()

	if SpiralingShotServer.Id[player.UserId] ~= v2 then
		return
	end

	if #find_character_from_descendants == 0 then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spiraling Shot VFX", character, "BallFXStop", formatted2)
		cleanIt:Clean()
	else
		local cframe2 = CFrame.new(state.explosionPos or v6.Position)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spiraling Shot VFX", character, "Explode", cframe2)
		task.wait(0.2)

		if SpiralingShotServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
		local createHitbox = Utility.CreateHitbox
		local v9 = {
			caster = character,
			hitboxCFrame = cframe2,
			hitboxSize = Config.EXPLOSION_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			targets = 0,
			hitDetected = 0
		}

		if not (#find_character_from_descendants > 0) then
			find_character_from_descendants = nil
		end

		v9.targets = find_character_from_descendants

		function v9.hitDetected(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.EXPLOSION_BLOCK_BREAK)
				return
			end

			Combat_Util.Damage(script, character, instance, {
				Base = Config.DAMAGE,
				Skill = Config.SKILL_NAME
			})
			Combat_Util.AddStun(script, character, p, Config.STUN)
			Combat_Util.RagDoll(script, character, p, Config.RAGDOLL_DURATION)
			task.defer(function()
				local unit2 = (humanoidRootPart2.Position - cframe2.Position).Unit
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					(unit2 + createVector(0, 0.3, 0)) * Config.KNOCKBACK,
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end)
		end

		createHitbox(v9)
	end
end

function SpiralingShotServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spiraling Shot VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return SpiralingShotServer