game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local ArcsOfJusticeServer = {
	Id = {}
}

function ArcsOfJusticeServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2 = ArcsOfJusticeServer.Id[player.UserId]
	p.startClock = os.clock()
	task.delay(Config.HOLD_STARTUP, function()
		if ArcsOfJusticeServer.Id[player.UserId] == v2 then
			EffectsEvent.ToAllInRange(player, "Arcs Of JustiveVFX", character, "Start")
		end

		while ArcsOfJusticeServer.Id[player.UserId] == v2 do
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = rootPart.CFrame,
				hitboxSize = Config.TICK_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3)
					if instance then
						local humanoid = instance:FindFirstChild("Humanoid")
						local rootPart2 = humanoid.RootPart

						if p3 == "Blocking" then
							Combat_Util.Block(script, character, instance, Config.TICK_BLOCK_BREAK)
							Combat_Util.Knockback(
								script,
								character,
								rootPart2,
								rootPart.CFrame.lookVector * Config.TICK_BLOCK_KNOCKBACK,
								0.2
							)
						elseif p3 == "Perfect" then
							Combat_Util.Perfect(script, character, instance)
						elseif p3 == true then
							local v3 = rootPart.CFrame.LookVector * Config.TICK_KNOCKBACK + vector.create(
								0,
								Config.TICK_KNOCKUP,
								0
							)
							EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
							Combat_Util.AddStun(script, character, p2, Config.TICK_STUN)
							Combat_Util.Damage(script, character, instance, {
								Base = Config.TICK_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_Util.Knockback(script, character, rootPart2, v3, Config.TICK_KNOCKBACK_DURATION)
							Combat_presets.PlayReactAnim(humanoid)
						end
					end
				end
			})
			task.wait(Config.TICK_INTERVAL)
		end
	end)
end

local CharGrabPosCorrector = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local Cutscene_camera_handler = require(ServerStorage.SAM.Game_Play.Cutscene_camera_handler)

function ArcsOfJusticeServer.UnHold(player, vector2: Vector3, p)
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local _ = os.clock() - p.startClock
	local v2 = ArcsOfJusticeServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1.5)
	v3:Connect(function()
		v2 = -1
		ArcsOfJusticeServer.Cancel(player, vector2, p)
	end)
	local cFrame = nil
	local count = 0
	local clone = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		After = function()
			if count == 0 then
				EffectsEvent.ToAllInRange(player, "Arcs Of JustiveVFX", character, "Cancel")
			end
		end,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3, _)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid2.RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.GRAB_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					count += 1

					if count == 1 then
						cFrame = rootPart.CFrame
						clone = script.CamReAdd:Clone()
						clone:PivotTo(cFrame)
						clone.Parent = workspace.Debree
						clone.H.RootWeld.Part0 = rootPart
						DebrisModule:AddItem(clone, Config.GRAB_DURATION)
						clone.AnimationController.Animator:LoadAnimation(script.StoneUltCamera):Play()
						EffectsEvent.ToAllInRange(player, "Arcs Of JustiveVFX", character, "Cutscene", instance)
						Utility.lock(rootPart, cFrame, Config.GRAB_DURATION)
						humanoid.Animator:LoadAnimation(script.StoneUltPlayer):Play()
						Cutscene_camera_handler.Regular(player, clone.Cam)
						Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_DURATION)
						Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_DURATION)
					end

					local animator = humanoid2:FindFirstChild("Animator")
					local track

					if animator then
						track = animator:LoadAnimation(script.StoneUltVictim)
						track:Play()
					end

					local v5 = Utility.AddValue(p2, "noragdoll", Config.GRAB_DURATION)
					local v6 = Utility.lock(rootPart2, cFrame, Config.VICTIM_LOCK_DURATION)
					CharGrabPosCorrector.Do(instance, track, Config.CORRECTOR_DURATION, character)
					local v7 = Utility.AddValue(p2, "pause_gameplay", Config.GRAB_DURATION)
					local v8 = Utility.AddValue(p2, "iframe", Config.GRAB_DURATION, "StringValue", player.Name)
					local v9 = Utility.AddValue(p2, "InvisibleItem", Config.GRAB_DURATION, "StringValue", "all")

					if CAM ~= nil then
						local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

						if playerFromCharacter ~= nil then
							Cutscene_camera_handler.Regular(playerFromCharacter, clone.Cam)
						end
					end

					task.delay(Config.HIT1_AT, function()
						if v2 ~= ArcsOfJusticeServer.Id[player.UserId] or instance == nil or instance.Parent == nil or humanoid2 == nil or humanoid2.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT1_DAMAGE,
							Skill = script.Parent.Name
						})
						task.wait(Config.HIT2_AT - Config.HIT1_AT)

						if v2 ~= ArcsOfJusticeServer.Id[player.UserId] or instance == nil or instance.Parent == nil or humanoid2 == nil or humanoid2.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT2_DAMAGE,
							Skill = script.Parent.Name
						})
						task.wait(Config.HIT3_AT - Config.HIT2_AT)

						if v2 ~= ArcsOfJusticeServer.Id[player.UserId] or instance == nil or instance.Parent == nil or humanoid2 == nil or humanoid2.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT3_DAMAGE,
							Skill = script.Parent.Name
						})
						task.wait(Config.FINISHER_AT - Config.HIT3_AT)

						if v2 ~= ArcsOfJusticeServer.Id[player.UserId] or instance == nil or instance.Parent == nil or humanoid2 == nil or humanoid2.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						local v10 = cFrame.lookVector * Config.FINISHER_KNOCKBACK + vector.create(
							0,
							Config.FINISHER_KNOCKUP,
							0
						)

						if v6 ~= nil then
							v6:Destroy()
							v6 = nil
						end

						if v9 ~= nil then
							v9:Destroy()
							v9 = nil
						end

						if v7 ~= nil then
							v7:Destroy()
							v7 = nil
						end

						if v8 ~= nil then
							v8:Destroy()
							v8 = nil
						end

						if v5 ~= nil then
							v5:Destroy()
							v5 = nil
						end

						Combat_Util.AddStun(script, character, p2, Config.FINISHER_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.FINISHER_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.RagDoll(script, character, p2, Config.FINISHER_RAGDOLL)
						Combat_Util.Knockback(script, character, rootPart2, v10, Config.FINISHER_KNOCKBACK_DURATION)
					end)
				end
			end
		end
	})
	v4()
end

function ArcsOfJusticeServer.Cancel(player, _: Vector3, _)
	if player.Character == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "Arcs Of JustiveVFX", player.Character, "Cancel")
end

return ArcsOfJusticeServer