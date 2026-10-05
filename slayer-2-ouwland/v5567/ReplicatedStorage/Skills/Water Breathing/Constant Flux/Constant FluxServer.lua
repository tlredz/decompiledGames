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
local CombatMode = require(CAM.Global.CombatMode)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local _ = script
local ConstantFluxServer = {
	Id = {}
}

function ConstantFluxServer.Hold(player, _: Vector3, _)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Activate")
	local v2 = ConstantFluxServer.Id[player.UserId]
	local v3 = not CombatMode.IsRanked(player) and 0 or Config.RANKED_STUN_CUT

	local function fn(instance, p, p2)
		if instance then
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid.RootPart

			if p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SLASH_BLOCK_BREAK)
				local v4 = rootPart.CFrame.LookVector * Config.SLASH_BLOCK_KNOCKBACK
				Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
			else
				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				if p2 == true then
					local v4 = rootPart.CFrame.LookVector * Config.SLASH_KNOCKBACK
					Combat_Util.AddStun(script, character, p, Config.SLASH_STUN - v3)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						vector.create(v4.X, v4.Y, v4.Z),
						Config.SLASH_KNOCKBACK_DURATION
					)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		end
	end

	local function fn2(instance, p, p2)
		if instance then
			local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

			if p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.IMPACT_BLOCK_BREAK)
				local v4 = rootPart.CFrame.LookVector * Config.IMPACT_BLOCK_KNOCKBACK
				Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
			else
				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				if p2 == true then
					local v4 = rootPart.CFrame.LookVector * Config.IMPACT_KNOCKBACK + vector.create(
						0,
						Config.IMPACT_KNOCKUP,
						0
					)
					Combat_Util.AddStun(script, character, p, Config.IMPACT_STUN - v3)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.IMPACT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v4, 0.4)
					Combat_Util.RagDoll(script:GetDescendants(), character, p, Config.IMPACT_RAGDOLL - v3)
				end
			end
		end
	end

	task.wait(Config.STARTUP_AT)

	if v2 ~= ConstantFluxServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Slash", 1)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
		hitboxSize = Config.SLASH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.SLASH_2_DELAY)

	if v2 ~= ConstantFluxServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Slash", 2)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLASH_HITBOX_OFFSET,
		hitboxSize = Config.SLASH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.IMPACT_DELAY)

	if v2 ~= ConstantFluxServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Impact")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.IMPACT_HITBOX_OFFSET,
		hitboxSize = Config.IMPACT_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn2,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.RECOVERY_DUR)

	if v2 ~= ConstantFluxServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Cancel")
end

function ConstantFluxServer.UnHold(player, _: Vector3, _)
	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Cancel")
end

function ConstantFluxServer.Cancel(player, _: Vector3, _)
	EffectsEvent.ToAllInRange(player, "Constant Flux VFX", player.Character, "Cancel")
end

return ConstantFluxServer