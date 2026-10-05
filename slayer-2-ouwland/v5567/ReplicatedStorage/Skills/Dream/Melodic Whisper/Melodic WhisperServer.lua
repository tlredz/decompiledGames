local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local MelodicWhisperServer = {
	Id = {}
}

function MelodicWhisperServer.Hold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	state.cancelled = false
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = MelodicWhisperServer.Id[player.UserId]

	if Utility.SinglePartHitbox({
		Caster = character,
		ParamsName = `{player.Name}-{script.Parent.Name}-detect`,
		Origin = humanoidRootPart.CFrame,
		BoxSize = Config.DETECT_HITBOX_SIZE
	}) then
		state.branch = "Close"
		ServerClientPortal.ToClient(player, script.Parent.Name, "Close")
		EffectsEvent.ToAllInRange(humanoidRootPart, "MelodicWhisper VFX", character, "CloseHold")
	else
		state.branch = "Far"
		ServerClientPortal.ToClient(player, script.Parent.Name, "Far")
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 3)
		cleanIt:Add(function()
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end)
		cleanIt:Add(Combat_Util.Add_air_combo_bp(
			humanoidRootPart,
			nil,
			Config.UPDRAFT_HEIGHT,
			nil,
			Config.UPDRAFT_DURATION
		))
		state.farPauseValue = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FAR_PAUSE_DURATION)
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.FAR_TOTAL_ANIM_DURATION))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.FAR_TOTAL_ANIM_DURATION))
		state.farSkillLock = Utility.AddValue(
			getvaluesfolder,
			"skillsdisabled",
			Config.FAR_PAUSE_DURATION,
			"StringValue",
			"all"
		)
		EffectsEvent.ToAllInRange(humanoidRootPart, "MelodicWhisper VFX", character, "Far")
		local count = 0
		local count2 = #Config.FAR_PROJECTILE_DELAY_TIMES
		task.wait(Config.FAR_PREP_DELAY)

		if state.cancelled or v2 ~= MelodicWhisperServer.Id[player.UserId] or not humanoidRootPart.Parent then
			if state.farPauseValue then
				state.farPauseValue:Destroy()
				state.farPauseValue = nil
			end

			if state.farSkillLock then
				state.farSkillLock:Destroy()
				state.farSkillLock = nil
			end

			cleanIt:Clean()
		else
			for k, duration in Config.FAR_PROJECTILE_DELAY_TIMES do
				task.wait(duration)

				if state.cancelled or v2 ~= MelodicWhisperServer.Id[player.UserId] or not humanoidRootPart.Parent then
					break
				end

				local v3 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE) or (humanoidRootPart.CFrame * CFrame.new(
					0,
					0,
					-1
				)).Position
				local unit = (v3 - humanoidRootPart.Position).Unit
				local _, _, _, v4 = RaycastHelper.MaximizeRayServer(
					character,
					humanoidRootPart.Position,
					v3,
					Config.FAR_AIM_RANGE,
					true,
					Config.FAR_SPHERECAST_RADIUS,
					Config.FAR_DOWNCAST
				)

				if v4 == nil or Checker.check_victim(script, character, v4) == nil then
					v4 = nil
				end

				local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -4)
				local formatted = `{player.Name} MelodicWhisper Orb {k}`
				local flag = false
				local v6 = k
				local v7 = ProjectileModeler.new({
					Name = formatted,
					Size = Config.FAR_PROJECTILE_SIZE,
					CFrame = cFrame,
					Mover = {
						MaxForce = 1000000000,
						VectorVelocity = unit * Config.FAR_PROJECTILE_SPEED
					},
					Rotator = {
						Responsiveness = 75,
						CFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + unit)
					}
				}, function(position: Vector3?, vector: Vector3?, p)
					if flag then
						return true
					end

					flag = true
					local humanoidRootPart2 = nil
					local v8

					if p then
						v8 = Utility.find_character_from_descendant(p)

						if v8 then
							humanoidRootPart2 = v8:FindFirstChild("HumanoidRootPart")
						end
					end

					if humanoidRootPart2 then
						position = humanoidRootPart2.Position
					end

					if humanoidRootPart2 then
						vector = nil
					end

					EffectsEvent.ToAllInRange(
						humanoidRootPart,
						"MelodicWhisper VFX",
						character,
						"FarImpact",
						position,
						vector
					)
					Utility.CreateHitbox({
						caster = character,
						hitboxCFrame = CFrame.new(position),
						hitboxSize = Config.PROJECTILE_AOE_SIZE,
						checker = Checker,
						hitPriorityHandler = {
							callback = v.Exists,
							data = "Choosing_1"
						},
						targets = v8 and { v8 } or nil,
						hitDetected = function(instance, p2, p3)
							if p3 == "Perfect" then
								Combat_Util.Perfect(script, character, instance)
							elseif p3 == "Blocking" then
								Combat_Util.Block(script, character, instance, 2)
							elseif p3 == true then
								Combat_Util.Damage(script, character, instance, {
									Base = Config.FAR_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_Util.AddStun(script, character, p2, 0.75)

								if v6 == #Config.FAR_PROJECTILE_DELAY_TIMES then
									Combat_Util.RagDoll(script, character, p2, Config.FAR_STUN)
									local v9 = Utility.AddValue(p2, Config.FAR_SLOW_VALUE, Config.FAR_SLOW_DURATION)
									v9:AddTag(StatTypes.ValueStatTag)
									v9:SetAttribute(
										StatTypes.StatToAttribute("Movement Speed Factor"),
										Config.FAR_SLOW_FACTOR
									)
								else
									Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil)
								end
							end
						end
					})
					count += 1

					if count2 <= count then
						if state.farPauseValue then
							state.farPauseValue:Destroy()
							state.farPauseValue = nil
						end

						if state.farSkillLock then
							state.farSkillLock:Destroy()
							state.farSkillLock = nil
						end
					end

					return true
				end, Config.FAR_PROJECTILE_DURATION, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
				v7.Instance:SetNetworkOwner(player)

				if v4 ~= nil then
					local v8 = v7
					task.spawn(function()
						while v8.IsActive and not flag and not state.cancelled and v2 == MelodicWhisperServer.Id[player.UserId] do
							local instance = v8.Instance

							if instance == nil or instance.Parent == nil then
								break
							end

							local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart2 == nil or humanoidRootPart2.Parent == nil then
								break
							end

							local v9 = humanoidRootPart2.Position - instance.Position

							if v9.Magnitude > 0.1 then
								local mover = v8.Mover or instance:FindFirstChild("Mover")

								if mover ~= nil then
									mover.VectorVelocity = v9.Unit * Config.FAR_PROJECTILE_SPEED
								end
							end

							task.wait(Config.FAR_TRACK_TICK)
						end
					end)
				end

				EffectsEvent.ToAllInRange(
					humanoidRootPart,
					"MelodicWhisper VFX",
					character,
					"FarOrb",
					formatted,
					v7.Instance
				)
			end
		end
	end
end

function MelodicWhisperServer.UnHold(player, vector: Vector3?, state)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = MelodicWhisperServer.Id[player.UserId]
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt

	if state.farPauseValue then
		state.farPauseValue:Destroy()
		state.farPauseValue = nil
	end

	if state.branch == "Far" then
		task.delay(Config.FAR_MAX_TAIL_GRACE, function()
			if v2 ~= MelodicWhisperServer.Id[player.UserId] then
				return
			end

			if state.CleanIt then
				state.CleanIt:Clean()
			end
		end)
	end

	if state.branch == "Close" then
		local v3, v4 = ManuelCancel.new(player, 1.1, nil, script.Parent.Name)
		v3:Connect(function()
			v2 = -1
			MelodicWhisperServer.Cancel(player, vector, state)
			v4()
		end)
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.1))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", 1.1))
		EffectsEvent.ToAllInRange(humanoidRootPart, "MelodicWhisper VFX", character, "Close")
		task.wait(0.4)

		if v2 ~= MelodicWhisperServer.Id[player.UserId] then
			v4()
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame,
			hitboxSize = Config.CLOSE_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, 2)
				elseif p2 == true then
					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
					Combat_Util.Damage(script, character, instance, {
						Base = Config.CLOSE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p, Config.CLOSE_STUN)
					Combat_Util.RagDoll(script, character, p, Config.CLOSE_STUN)
					EffectsEvent.ToAllInRange(
						humanoidRootPart,
						"MelodicWhisper VFX",
						character,
						"CloseHit",
						humanoidRootPart2
					)
				end
			end
		})
		task.wait(0.58)

		if v2 == MelodicWhisperServer.Id[player.UserId] then
			v4()
			cleanIt:Clean()
		else
			v4()
		end
	end
end

function MelodicWhisperServer.Cancel(player, _: Vector3?, state)
	state.cancelled = true
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()

	if state.farPauseValue then
		state.farPauseValue:Destroy()
		state.farPauseValue = nil
	end

	if state.farSkillLock then
		state.farSkillLock:Destroy()
		state.farSkillLock = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "MelodicWhisper VFX", character, "Cancel")
	end
end

return MelodicWhisperServer