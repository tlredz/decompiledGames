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
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local _ = script
local ReapingSlashesServer = {}
ReapingSlashesServer.Id = {}

function ReapingSlashesServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	task.wait(Config.SLASHES_FIRST_AT)

	if p.Cancelled then
		return
	end

	EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "AirVariant1st", 1)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLASHES_HITBOX_OFFSET,
		hitboxSize = Config.SLASHES_HITBOX_SIZE,
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
					Combat_Util.Block(script, character, instance, Config.SLASHES_BLOCK_BREAK)
					local v2 = rootPart.CFrame.LookVector * Config.SLASHES_BLOCK_KNOCKBACK
					Combat_Util.Knockback(script, character, rootPart2, v2, Config.SLASHES_BLOCK_KNOCKBACK_TIME)
				else
					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
						return true
					end

					if p3 == true then
						local v2 = rootPart.CFrame.LookVector * Config.SLASH1_KNOCKBACK
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
						Combat_Util.AddStun(script, character, p2, Config.SLASH1_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.SLASH1_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							vector.create(v2.X, v2.Y == 0 and 0.1 or v2.Y, v2.Z),
							Config.SLASH1_KNOCKBACK_TIME
						)
						Combat_presets.PlayReactAnim(humanoid)
					end
				end
			end
		end
	})
	task.wait(Config.SLASHES_SECOND_AT)

	if p.Cancelled then
		return
	end

	EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "AirVariant1st", 2)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.SLASHES_HITBOX_OFFSET,
		hitboxSize = Config.SLASHES_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if instance then
				local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SLASHES_BLOCK_BREAK)
					local v2 = rootPart.CFrame.LookVector * Config.SLASHES_BLOCK_KNOCKBACK
					Combat_Util.Knockback(script, character, rootPart2, v2, Config.SLASHES_BLOCK_KNOCKBACK_TIME)
				else
					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
						return true
					end

					if p3 == true then
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart2, -1)
						Combat_Util.AddStun(script, character, p2, Config.SLASH2_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.SLASH2_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.RagDoll(script, character, p2, Config.SLASH2_RAGDOLL)
					end
				end
			end
		end
	})
end

function ReapingSlashesServer.UnHold(_, _: Vector3, _) end

function ReapingSlashesServer.Cancel(_, _: Vector3, p)
	p.Cancelled = true
end

return ReapingSlashesServer