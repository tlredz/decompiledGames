game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
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
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local UpperSmashServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		local character = player.Character
		local _ = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "Start", "InitSound2")
		p.startClock = os.clock()
	end
}

function UpperSmashServer.UnHold(player, vector2: Vector3, p)
	local character = player.Character
	Utility.getvaluesfolder(character)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local _ = os.clock() - p.startClock
	local v2 = UpperSmashServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		UpperSmashServer.Cancel(player, vector2, p)
	end)
	task.wait(Config.THROW_AT)

	if UpperSmashServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Upper SmashVFX", character, "Throw")
	task.wait(Config.EXPLODE_DELAY)

	if UpperSmashServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Upper SmashVFX", character, "Explode")
	local hitboxCFrame = rootPart.CFrame * Config.EXPLODE_HITBOX_OFFSET
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.EXPLODE_HITBOX_SIZE,
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
					Combat_Util.Block(script, character, instance, Config.EXPLODE_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					table.insert(instances, instance)
					local v6 = rootPart.CFrame.LookVector * Config.EXPLODE_KNOCKBACK + vector.create(
						0,
						Config.EXPLODE_KNOCKUP,
						0
					)
					Combat_Util.AddStun(script, character, p2, Config.EXPLODE_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.EXPLODE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v6, Config.EXPLODE_KNOCKBACK_DURATION)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		end,
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.LAUNCH_DELAY)

	if UpperSmashServer.Id[player.UserId] ~= v2 then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.LAUNCH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		targets = instances,
		hitDetected = function(instance, p2, p3)
			if instance then
				local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.LAUNCH_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					local v6 = vector.normalize(rootPart2.Position - hitboxCFrame.Position) * Config.LAUNCH_KNOCKBACK + vector.create(
						0,
						Config.LAUNCH_KNOCKUP,
						0
					)
					Combat_Util.AddStun(script, character, p2, Config.LAUNCH_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.LAUNCH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v6, Config.LAUNCH_KNOCKBACK_DURATION)
					Combat_Util.RagDoll(script, character, p2, Config.LAUNCH_RAGDOLL)
				end
			end
		end,
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	v4()
end

function UpperSmashServer.Cancel(_, _: Vector3, _) end

return UpperSmashServer