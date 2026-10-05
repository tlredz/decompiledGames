local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local _ = script
local VolcanicConquestServer = {
	Id = {}
}

function VolcanicConquestServer.Hold(player, _: Vector3, _)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2 = VolcanicConquestServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "Start")
	task.wait(Config.SLICE1_AT)

	if VolcanicConquestServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "StoneConquestVFX", player.Character, "Slice1")
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLICE1_HITBOX_OFFSET,
		hitboxSize = Config.SLICE1_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if instance then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid.RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.HIT_BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.lookVector * Config.HIT_BLOCK_KNOCKBACK,
						0.2
					)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					local v3 = rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + vector.create(
						0,
						Config.HIT_KNOCKUP,
						0
					)
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
					Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v3, Config.HIT_KNOCKBACK_DURATION)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.SLICE2_AT - Config.SLICE1_AT)

	if VolcanicConquestServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "StoneConquestVFX", player.Character, "Slice2")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLICE2_HITBOX_OFFSET,
		hitboxSize = Config.SLICE2_HITBOX_SIZE,
		targets = instances,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if instance then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid.RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.HIT_BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.lookVector * Config.HIT_BLOCK_KNOCKBACK,
						0.2
					)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					local v3 = rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + vector.create(
						0,
						Config.HIT_KNOCKUP,
						0
					)
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
					Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v3, Config.HIT_KNOCKBACK_DURATION)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.SPIN_AT - Config.SLICE2_AT)

	if VolcanicConquestServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "StoneConquestVFX", player.Character, "Spin")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SPIN_HITBOX_OFFSET,
		hitboxSize = Config.SPIN_HITBOX_SIZE,
		targets = instances,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if instance then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid.RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.HIT_BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.lookVector * Config.HIT_BLOCK_KNOCKBACK,
						0.2
					)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					local v3 = rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + vector.create(
						0,
						Config.HIT_KNOCKUP,
						0
					)
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
					Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v3, Config.HIT_KNOCKBACK_DURATION)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.SLICE3_AT - Config.SPIN_AT)

	if VolcanicConquestServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "StoneConquestVFX", player.Character, "Slice3")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLICE3_HITBOX_OFFSET,
		hitboxSize = Config.SLICE3_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		targets = instances,
		hitDetected = function(instance, p, p2)
			if instance then
				local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.HIT_BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.lookVector * Config.HIT_BLOCK_KNOCKBACK,
						0.2
					)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					local v3 = rootPart.CFrame.LookVector * Config.FINAL_KNOCKBACK
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
					Combat_Util.AddStun(script, character, p, Config.FINAL_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINAL_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v3, Config.FINAL_KNOCKBACK_DURATION)
					Combat_Util.RagDoll(script, character, p, Config.FINAL_RAGDOLL)
				end
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
end

function VolcanicConquestServer.UnHold(_, _: Vector3, _) end

function VolcanicConquestServer.Cancel(_, _: Vector3, _) end

return VolcanicConquestServer