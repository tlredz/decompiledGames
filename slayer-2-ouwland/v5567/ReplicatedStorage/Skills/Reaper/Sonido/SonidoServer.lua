local createVector = vector.create
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
CFrame.new(0, 3, -5)
CFrame.new(0, 7, -10)
local SonidoServer = {
	Id = {}
}

function SonidoServer.Hold(player, _: Vector3, _)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	EffectsEvent.ToAllInRange(player, "SonidoVFX", player.Character, "Start")
	local v2 = SonidoServer.Id[player.UserId]
	task.wait(Config.STARTUP_AT)

	if v2 ~= SonidoServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "SonidoVFX", player.Character, "Jump", rootPart.CFrame)
	task.wait(Config.ZIGZAG_DELAY)

	if v2 ~= SonidoServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(player, "SonidoVFX", player.Character, "ZigZag", rootPart.CFrame)

	while SonidoServer.Id[player.UserId] == v2 do
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = rootPart.CFrame,
			hitboxSize = Config.HIT_HITBOX_SIZE,
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
						Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							rootPart.CFrame.lookVector * Config.BLOCK_KNOCKBACK,
							Config.BLOCK_KNOCKBACK_TIME
						)
					elseif p2 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p2 == true then
						local v3 = rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + createVector(0, 0.01, 0)
						EffectsEvent.ToAllInRange(player, "SonidoVFX", character, "hit", rootPart2.CFrame)
						Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v3, Config.HIT_KNOCKBACK_TIME)
						Combat_presets.PlayReactAnim(humanoid)
					end
				end
			end
		})
		task.wait(Config.HIT_INTERVAL)
	end
end

function SonidoServer.UnHold(player, _: Vector3, _)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local character = player.Character
	EffectsEvent.ToAllInRange(player, "SonidoVFX", player.Character, "Cancel")

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DURATION)
	local rootPart = humanoid.RootPart
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame,
		hitboxSize = Config.HIT_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid2.RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.lookVector * Config.BLOCK_KNOCKBACK,
						Config.BLOCK_KNOCKBACK_TIME
					)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					local v2 = rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + createVector(0, 0.01, 0)
					EffectsEvent.ToAllInRange(player, "SonidoVFX", character, "hit", rootPart2.CFrame, true)
					Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart2, v2, Config.HIT_KNOCKBACK_TIME)
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end
		end
	})
end

function SonidoServer.Cancel(player, _: Vector3, _)
	EffectsEvent.ToAllInRange(player, "SonidoVFX", player.Character, "Cancel")
end

return SonidoServer