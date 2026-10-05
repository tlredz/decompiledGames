local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerStorage2 = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local CharGrabPosCorrector = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local ServerClientPortal = require(ReplicatedStorage2.CAM.Global.ServerClientPortal)
local SonidoSurgeServer = {
	Id = {}
}

function SonidoSurgeServer.Hold(player, _: Vector3, p)
	local character = player.Character
	p.Held = nil
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", character, "Start")
	local v2 = SonidoSurgeServer.Id[player.UserId]
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`

	while v2 == SonidoSurgeServer.Id[player.UserId] do
		local cFrame = rootPart.CFrame
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * Config.SCAN_HITBOX_OFFSET,
			BoxSize = Config.SCAN_HITBOX_SIZE
		})

		if singlePartHitbox then
			p.Held = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		else
			task.wait(0.1)
		end
	end
end

local ManuelCancel = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Cutscene_camera_handler = require(ServerStorage2.SAM.Game_Play.Cutscene_camera_handler)

function SonidoSurgeServer.UnHold(player, _: Vector3, p)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local track = nil
	local v2 = Utility.AddValue(getvaluesfolder, "pause_gameplay", 5)
	local v3 = SonidoSurgeServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, 2)
	v4:Connect(function()
		SonidoSurgeServer.Id[player.UserId] = -1
		SonidoSurgeServer.Cancel(player)

		if track ~= nil then
			track:Stop()
			track = nil
		end
	end)
	local instances = {}
	local v6 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.CATCH_HITBOX_OFFSET,
		hitboxSize = Config.CATCH_HITBOX_SIZE,
		targets = p.Held,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2.RootPart

				if p3 == "Perfect" then
					v6[instance] = true
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					v6[instance] = true
					Combat_Util.Block(script, character, instance, Config.CATCH_BLOCK_BREAK)
					local v7 = humanoidRootPart.CFrame.LookVector * Config.CATCH_BLOCK_KNOCKBACK
					Combat_Util.Knockback(script, character, rootPart, v7, Config.CATCH_BLOCK_KNOCKBACK_TIME)
				elseif p3 == true then
					if #instances == 0 then
						EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", character, "StartAttack", instance)
					end

					table.insert(instances, instance)
					local v7 = humanoidRootPart.CFrame.LookVector * Config.CATCH_KNOCKBACK + vector.create(
						0,
						Config.CATCH_KNOCKUP,
						0
					)
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
					Combat_Util.Add_Strict_Stun(script, character, p2, Config.CATCH_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.CATCH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(
						script,
						character,
						rootPart,
						vector.create(v7.X, v7.Y == 0 and 0.1 or v7.Y, v7.Z),
						Config.CATCH_KNOCKBACK_TIME
					)
					Combat_presets.PlayReactAnim(humanoid2, nil, 0.6)
				end
			end
		end
	})

	if #instances == 0 then
		DebrisModule:AddItem(v2, Config.MISS_RECOVER_TIME)
		EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", character, "Cancel")
	else
		Utility.AddValue(getvaluesfolder, "NR", Config.ULT_STARTUP_LOCK)
		track = humanoid.Animator:LoadAnimation(script.UltStartup)
		track:Play()
		DebrisModule:AddItem(v2, Config.ULT_STARTUP_LOCK)
		ServerClientPortal.ToClient(player, script.Parent.Name, Config.ULT_STARTUP_LOCK)
		EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", character, "DashHit")
		task.wait(Config.ULT_GRAB_AT)
		v5()

		if v3 ~= SonidoSurgeServer.Id[player.UserId] then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local instances2 = {}
		local v7 = nil
		local clone = nil

		local function fn(instance, p2, p3, _)
			if v6[instance] then
				return
			end

			if instance then
				local rootPart = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.ULT_BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart,
						vector.normalize(cFrame.Position - rootPart.Position) * -Config.ULT_BLOCK_KNOCKBACK,
						Config.ULT_BLOCK_KNOCKBACK_TIME
					)
				elseif p3 == true then
					table.insert(instances2, instance)

					for _, v8 in ipairs({ "pause_gameplay", "iframe" }) do
						if v8 == "iframe" then
							Utility.AddValue(p2, "iframe", Config.ULT_ANIM_DURATION, "StringValue", character.Name)
						else
							Utility.AddValue(p2, v8, Config.ULT_ANIM_DURATION)
						end
					end

					local v8 = Utility.lock(rootPart, cFrame, Config.ULT_ANIM_DURATION)

					if clone == nil and #instances2 == 1 then
						v7 = instance
						clone = script.CamModel:Clone()
						clone.RW.Part0 = humanoidRootPart
						clone.Parent = workspace.Debree
						clone.AnimationController:LoadAnimation(script.Cam):Play()
						DebrisModule:AddItem(clone, Config.ULT_SLAM_AT - 0.05)
						Cutscene_camera_handler.Regular(player, clone.CamPart)
					end

					if clone ~= nil then
						local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

						if playerFromCharacter ~= nil then
							Cutscene_camera_handler.Regular(playerFromCharacter, clone.CamPart)
						end
					end

					local animator = instance:FindFirstChild("Humanoid"):FindFirstChild("Animator")
					local track2

					if animator then
						track2 = animator:LoadAnimation(script.Victim)
						track2:Play()
						CharGrabPosCorrector.Do(instance, track2, Config.ULT_SLAM_AT - 0.05, character)
					else
						track2 = nil
					end

					task.delay(Config.ULT_SLAM_AT, function()
						if Checker.check_victim(script, character, instance) == nil then
							return
						end

						if v8 ~= nil and v8.Parent ~= nil then
							v8:Destroy()
						end

						if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.ULT_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.ULT_STUN, true)
						Combat_Util.RagDoll(script, character, p2, Config.ULT_RAGDOLL)
						track2:Stop()
						local v9 = humanoidRootPart.CFrame.LookVector * Config.ULT_KNOCKBACK + vector.create(
							0,
							Config.ULT_KNOCKUP,
							0
						)
						Combat_Util.Knockback(script, character, rootPart, v9, Config.ULT_KNOCKBACK_TIME)
					end)

					if #instances2 == 1 then
						local animator2 = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
						Utility.lock(humanoidRootPart, cFrame, Config.ULT_ANIM_DURATION)

						if animator2 then
							local track3 = animator2:LoadAnimation(script.User)
							track3:Play(0)
							CharGrabPosCorrector.Do(character, track3, Config.ULT_ANIM_DURATION, character)
						end

						Utility.AddValue(
							getvaluesfolder,
							"camsubject",
							Config.ULT_ANIM_DURATION,
							"ObjectValue",
							character:FindFirstChild("UpperTorso")
						)

						for _, v9 in ipairs({ "pause_gameplay", "iframe" }) do
							Utility.AddValue(getvaluesfolder, v9, Config.ULT_ANIM_DURATION)
						end
					end
				end
			end
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.ULT_HITBOX_OFFSET,
			hitboxSize = Config.ULT_HITBOX_SIZE,
			targets = instances,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			After = function()
				if #instances2 > 0 then
					EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", character, "StartCinema", v7, instances2)
				end
			end,
			hitDetected = fn
		})
	end
end

function SonidoSurgeServer.Cancel(player)
	EffectsEvent.ToAllInRange(player, "Sonido SurgeVFX", player.Character, "Cancel")
end

return SonidoSurgeServer