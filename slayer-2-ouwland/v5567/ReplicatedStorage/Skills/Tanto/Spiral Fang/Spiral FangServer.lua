local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local HitCooldown = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.HitCooldown)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local SpiralFangServer = {
	Id = {}
}
local name = script.Parent.Name

function SpiralFangServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = SpiralFangServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_DASH_DURATION + 0.5))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Spiral Fang VFX", character, "Start", humanoidRootPart.CFrame)
	local v3 = HitCooldown.new(Config.VICTIM_HIT_COOLDOWN)

	local function castDashHitbox(p2)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.DASH_HITBOX_OFFSET,
			hitboxSize = Config.DASH_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			targets = p2 and { p2 } or nil,
			hitDetected = function(instance, p3, p4)
				local humanoid = instance:FindFirstChild("Humanoid")
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid == nil or humanoidRootPart2 == nil or not v3:Take(instance) then
					return
				end

				if p4 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p4 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.DASH_BLOCK_BREAK)
				elseif p4 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.DASH_DAMAGE,
						Skill = name
					})
					Combat_Util.AddStun(script, character, p3, Config.DASH_STUN)
					Combat_presets.PlayReactAnim(humanoid)
					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						humanoidRootPart.CFrame.LookVector * Config.DASH_KNOCKBACK + Vector3.new(
							0,
							Config.DASH_UPWARD,
							0
						),
						Config.VICTIM_HIT_COOLDOWN
					)
				end
			end
		})
	end

	local formatted = `{player.Name}-{name}-{math.random(1, 99)}`
	local flag = false
	local v4 = nil

	while SpiralFangServer.Id[player.UserId] == v2 do
		if not flag then
			local singlePartHitbox = Utility.SinglePartHitbox({
				Caster = character,
				ParamsName = formatted,
				Origin = humanoidRootPart.CFrame * Config.CONTACT_CHECK_OFFSET,
				BoxSize = Config.CONTACT_CHECK_SIZE
			})
			local v5 = singlePartHitbox and Utility.find_character_from_descendant(singlePartHitbox)

			if v5 and v5 ~= character then
				v4 = v5
				flag = true
			end
		end

		if flag then
			castDashHitbox(v4)
			v4 = nil
		end

		task.wait(Config.DASH_HIT_INTERVAL)
	end
end

function SpiralFangServer.UnHold(p, vector: Vector3?, p2)
	SpiralFangServer.Cancel(p, vector, p2)
end

function SpiralFangServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Spiral Fang VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt

	if cleanIt then
		cleanIt:Clean()
	end
end

return SpiralFangServer