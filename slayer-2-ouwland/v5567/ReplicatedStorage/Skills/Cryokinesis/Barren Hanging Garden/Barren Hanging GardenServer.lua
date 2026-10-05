local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local Combat_Util = require(SAM.Services.Combat_Util)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local BarrenHangingGardenServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = `{player.Name}-{script.Parent.Name}-detect`,
			Origin = humanoidRootPart.CFrame * Config.CLOSE_BARRAGE_HITBOX_OFFSET,
			BoxSize = Config.CLOSE_BARRAGE_HITBOX_SIZE
		}) then
			p.branch = "Close"
			ServerClientPortal.ToClient(player, script.Parent.Name, "Close")
		else
			p.branch = "Far"
			ServerClientPortal.ToClient(player, script.Parent.Name, "Far")
		end

		EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
	end
}

function BarrenHangingGardenServer.UnHold(player, _: Vector3, state)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v = BarrenHangingGardenServer.Id[player.UserId]
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	local v2, v3 = ManuelCancel.new(player, 3)
	v2:Connect(function()
		BarrenHangingGardenServer.Id[player.UserId] = -1
		BarrenHangingGardenServer.Cancel(player, nil, state)
	end)

	if state.branch == "Far" then
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder then
			cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FAR_CAST_LOCK))
		end

		local v4 = BarrenHangingGardenServer.Id[player.UserId]
		task.wait(0.15)

		if BarrenHangingGardenServer.Id[player.UserId] ~= v4 then
			return
		end

		local lookVector = humanoidRootPart.CFrame.LookVector
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local formatted = `{player.Name} Barren Hanging Garden Projectile`
		local models = {}
		local v6 = nil
		v6 = ProjectileModeler.new({
			Name = formatted,
			Size = Config.FAR_PROJECTILE_SIZE,
			CFrame = cFrame,
			Mover = {
				MaxForce = 1000000000,
				VectorVelocity = lookVector * Config.FAR_PROJECTILE_SPEED
			}
		}, function(_, _, instance)
			if BarrenHangingGardenServer.Id[player.UserId] ~= v then
				return true
			end

			local model = instance:FindFirstAncestorOfClass("Model")

			if model == nil or table.find(models, model) then
				return false
			end

			local humanoid = model:FindFirstChild("Humanoid")
			local humanoidRootPart2 = model:FindFirstChild("HumanoidRootPart")

			if not humanoid or not humanoidRootPart2 or humanoid.Health <= 0 then
				return false
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(model)
			local formatted2 = `Touched for {script.Parent.Name} from {player.Name}`

			if not Combat_Util.CheckCanTouch(getvaluesfolder2, formatted2) then
				return false
			end

			Combat_Util.SetTouchCooldown(getvaluesfolder2, formatted2)
			local check_victim = Checker.check_victim(script, character, model)

			if check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, model)
				return true
			end

			if check_victim == "Blocking" then
				Combat_Util.Block(script, character, model, 4)
			elseif check_victim == true then
				table.insert(models, model)
				cleanIt:Add(Utility.AddValue(getvaluesfolder2, "NR", Config.FAR_PROJECTILE_DURATION))
				cleanIt:Add(Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.FAR_PROJECTILE_DURATION))
				cleanIt:Add(Utility.CreateOuwWeld(v6.Instance, humanoidRootPart2, nil, Config.FAR_PROJECTILE_DURATION))
			end

			return false
		end, Config.FAR_PROJECTILE_DURATION, ProjectileModeler.WhitelistType.Humanoids, character)
		cleanIt:Add(v6)
		v3()
		EffectsEvent.ToAllInRange(
			humanoidRootPart,
			"Barren Hanging Garden VFX",
			character,
			"Far",
			formatted,
			v6.Instance
		)
		cleanIt:Add(task.spawn(function()
			while v6.IsActive and v == BarrenHangingGardenServer.Id[player.UserId] and v6.IsActive and BarrenHangingGardenServer.Id[player.UserId] == v do
				for _, v7 in models do
					local check_victim = Checker.check_victim(script, character, v7)

					if check_victim == nil then
						continue
					end

					local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
					local getvaluesfolder2 = Utility.getvaluesfolder(v7)

					if check_victim == "Perfect" then
						Combat_Util.Perfect(script, character, v7)
					elseif check_victim == "Blocking" then
						Combat_Util.Block(script, character, v7, 2)
						Combat_Util.Knockback(
							script,
							character,
							humanoidRootPart2,
							lookVector * Config.FAR_BLOCK_KNOCKBACK + createVector(0, 5, 0),
							0.2
						)
					elseif check_victim == true then
						Combat_Util.Damage(script, character, v7, {
							Base = Config.FAR_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, getvaluesfolder2, Config.FAR_STUN, true)
					end
				end

				task.wait(Config.FAR_TICK_INTERVAL)
			end
		end))
		v6.Destroying:Wait(Config.FAR_PROJECTILE_DURATION)

		if BarrenHangingGardenServer.Id[player.UserId] ~= v then
			return
		end

		v3()
		cleanIt:Clean()
		task.defer(function()
			if BarrenHangingGardenServer.Id[player.UserId] ~= v then
				return
			end

			for _, v7 in models do
				local check_victim = Checker.check_victim(script, character, v7)

				if check_victim == nil then
					continue
				end

				local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
				local getvaluesfolder2 = Utility.getvaluesfolder(v7)

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v7)
				elseif check_victim == "Blocking" then
					Combat_Util.Block(script, character, v7, 2)
				elseif check_victim == true then
					local unit = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
					Combat_Util.Damage(script, character, v7, {
						Base = Config.FAR_EXPLOSION_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, getvaluesfolder2, Config.FAR_EXPLOSION_STUN, true)
					Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.FAR_EXPLOSION_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						unit * Config.FAR_EXPLOSION_KNOCKBACK + createVector(0, 8, 0),
						0.2,
						"remove_airbp"
					)
				end
			end
		end)
	elseif state.branch == "Close" then
		task.wait(0.07)

		if BarrenHangingGardenServer.Id[player.UserId] ~= v then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		local CLOSE_HOLD_DURATION = Config.CLOSE_HOLD_DURATION
		local instances = {}
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.CLOSE_BARRAGE_HITBOX_OFFSET,
			hitboxSize = Config.CLOSE_BARRAGE_HITBOX_SIZE,
			checker = Checker,
			hitDetected = function(instance, p, p2)
				local getvaluesfolder2 = Utility.getvaluesfolder(instance)
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, 2)
				elseif p2 == true then
					table.insert(instances, instance)
					cleanIt:Add(Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, CLOSE_HOLD_DURATION))
					cleanIt:Add(Utility.AddValue(p, "NR", CLOSE_HOLD_DURATION))
					cleanIt:Add(Utility.AddValue(p, "pause_gameplay", CLOSE_HOLD_DURATION))
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						humanoidRootPart.CFrame.LookVector * 3 + createVector(0, 1, 0),
						Config.CLOSE_HOLD_DURATION,
						"remove_airbp"
					)
				end
			end
		})
		EffectsEvent.ToAllInRange(humanoidRootPart, "Barren Hanging Garden VFX", character, "Close")

		if #instances == 0 then
			return
		end

		cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", CLOSE_HOLD_DURATION))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", CLOSE_HOLD_DURATION))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", CLOSE_HOLD_DURATION))

		for _ = 1, math.max(1, (math.round(Config.CLOSE_BARRAGE_DURATION / Config.CLOSE_BARRAGE_TICK_INTERVAL))) do
			task.wait(Config.CLOSE_BARRAGE_TICK_INTERVAL)

			if BarrenHangingGardenServer.Id[player.UserId] ~= v then
				return
			end

			for _, v4 in instances do
				if not (v4 ~= nil and v4.Parent ~= nil and Checker.check_victim(script, character, v4) ~= nil) then
					continue
				end

				Combat_Util.Damage(script, character, v4, {
					Base = Config.CLOSE_BARRAGE_DAMAGE,
					Skill = script.Parent.Name
				})
			end
		end

		if BarrenHangingGardenServer.Id[player.UserId] ~= v then
			return
		end

		for _, v4 in instances do
			if not (v4 ~= nil and v4.Parent ~= nil) then
				continue
			end

			local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				continue
			end

			local check_victim = Checker.check_victim(script, character, v4)

			if check_victim == nil then
				continue
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(v4)

			if check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, v4)
			elseif check_victim == "Blocking" then
				Combat_Util.Block(script, character, v4, Config.CLOSE_FINISH_BLOCK_BREAK)
			else
				Combat_Util.Damage(script, character, v4, {
					Base = Config.CLOSE_FINISH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.CLOSE_FINISH_STUN, true)
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.CLOSE_FINISH_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					humanoidRootPart.CFrame.LookVector * Config.CLOSE_FINISH_KNOCKBACK + createVector(0, 5, 0),
					0.2,
					"remove_airbp"
				)
			end
		end

		v3()
	end
end

function BarrenHangingGardenServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Barren Hanging Garden VFX", character, "Cancel")
	end
end

return BarrenHangingGardenServer