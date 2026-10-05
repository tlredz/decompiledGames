local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local BuckShotServer = {
	Id = {}
}

function BuckShotServer.Hold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = BuckShotServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_DASH_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.MAX_DASH_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Start", humanoidRootPart.CFrame)
	task.wait(0.26666666666666666)

	if BuckShotServer.Id[player.UserId] ~= v2 then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Shot", humanoidRootPart.CFrame)
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	state.contact = nil
	state.probeVictim = nil

	while BuckShotServer.Id[player.UserId] == v2 do
		local v3 = not state.contact and Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = humanoidRootPart.CFrame * Config.FRONT_STOP_OFFSET,
			BoxSize = Config.FRONT_STOP_SIZE
		})

		if v3 then
			state.contact = true
			state.probeVictim = Utility.find_character_from_descendant(v3)
			ServerClientPortal.ToClient(player, script.Parent.Name, "Hit")
		end

		if state.contact then
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
		end

		task.wait(0.05)
	end
end

function BuckShotServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = BuckShotServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if state.contact then
		local v3, v4 = ManuelCancel.new(player, 1.8)
		v3:Connect(function()
			BuckShotServer.Id[player.UserId] = -1
			BuckShotServer.Cancel(player, nil, state)
		end)
		cleanIt:Add(v4)
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.3))
		local instances = {}
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.KICK_HITBOX_OFFSET,
			hitboxSize = Config.KICK_HITBOX_SIZE,
			targets = state.probeVictim,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid2 == nil or humanoidRootPart2 == nil then
					return
				end

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.KICK_BLOCK_BREAK)
				elseif p2 == true then
					table.insert(instances, instance)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.KICK_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Add_Strict_Stun(script, character, p, Config.KICK_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						Vector3.new(0, Config.KICK_UPWARD, 0),
						Config.KICK_STUN
					)
					Combat_presets.PlayReactAnim(humanoid2, nil, nil)
					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
				end
			end
		})
		task.wait(0.18333333333333332)

		if BuckShotServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Kick", humanoidRootPart.CFrame)
		task.wait(0.5666666666666667)

		if BuckShotServer.Id[player.UserId] ~= v2 then
			return
		end

		local SLAM_UPWARD

		if humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil then
			SLAM_UPWARD = -Config.SLAM_DOWNWARD
		else
			SLAM_UPWARD = Config.SLAM_UPWARD
		end

		local v5 = humanoidRootPart.CFrame * Config.SLAM_HITBOX_OFFSET
		EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Slam", humanoidRootPart.CFrame, v5)

		for _, v6 in instances do
			local humanoid2 = v6:FindFirstChild("Humanoid")
			local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")

			if not (humanoid2 ~= nil and humanoidRootPart2 ~= nil) then
				continue
			end

			local check_victim = Checker.check_victim(script, character, v6)

			if check_victim == nil then
				continue
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(v6)

			if check_victim == true then
				local air_combo_bp = humanoidRootPart2:FindFirstChild("air_combo_bp")

				if air_combo_bp then
					air_combo_bp:Destroy()
				end

				local unit = ((humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Unit
				Combat_Util.Damage(script, character, v6, {
					Base = Config.SLAM_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SLAM_STUN, true)
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLAM_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.SLAM_KNOCKBACK + Vector3.new(0, SLAM_UPWARD, 0),
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			else
				Combat_Util.Block(script, character, v6, Config.SLAM_BLOCK_BREAK)
			end
		end

		task.wait(0.55)

		if BuckShotServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	else
		ServerClientPortal.ToClient(player, script.Parent.Name, "Miss")
		EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Cancel")
	end
end

function BuckShotServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Buck Shot VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return BuckShotServer