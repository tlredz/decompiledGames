local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TwinHarmonyServer = {
	Id = {}
}
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
local v = {}
local v2 = {}
local v3 = {}

function TwinHarmonyServer.Hold(player, _)
	if not player then
		return
	end

	local v4 = TwinHarmonyServer.Id[player.UserId]
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	v[player.UserId] = Utility.AddValue(getvaluesfolder, "NR", Config.NR_DURATION)
	v3[player.UserId] = Utility.AddValue(
		getvaluesfolder,
		"WalkSpeed",
		Config.NR_DURATION,
		"NumberValue",
		Config.WALK_SPEED
	)

	local function cleanup()
		if v[player.UserId] then
			v[player.UserId]:Destroy()
			v[player.UserId] = nil
		end

		if v2[player.UserId] then
			v2[player.UserId]:Destroy()
			v2[player.UserId] = nil
		end

		if v3[player.UserId] then
			v3[player.UserId]:Destroy()
			v3[player.UserId] = nil
		end
	end

	local function stillValid()
		return v4 == TwinHarmonyServer.Id[player.UserId] and character.Parent ~= nil and humanoidRootPart.Parent ~= nil
	end

	task.wait(Config.STARTUP)
	local v5

	if v4 == TwinHarmonyServer.Id[player.UserId] and character.Parent ~= nil then
		v5 = humanoidRootPart.Parent ~= nil
	else
		v5 = false
	end

	if not v5 then
		cleanup()
		return
	end

	EffectsEvent.ToAllInRange(player, "TwinHarmony_effs", character, "Start")
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "Transparent"
	stringValue.Value = name
	stringValue.Parent = getvaluesfolder
	DebrisModule:AddItem(stringValue, Config.INVIS_DURATION)
	v2[player.UserId] = stringValue
	task.wait(Config.SPIN_AT)
	local v6

	if v4 == TwinHarmonyServer.Id[player.UserId] and character.Parent ~= nil then
		v6 = humanoidRootPart.Parent ~= nil
	else
		v6 = false
	end

	if not v6 then
		cleanup()
		return
	end

	local total = 0

	while total < Config.BLITZ_DURATION do
		local v7

		if v4 == TwinHarmonyServer.Id[player.UserId] and character.Parent ~= nil then
			v7 = humanoidRootPart.Parent ~= nil
		else
			v7 = false
		end

		if not v7 then
			break
		end

		total += task.wait(Config.BLITZ_INTERVAL)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame,
			hitboxSize = Config.BLITZ_HITBOX_SIZE,
			checker = Checker,
			hitDetected = function(instance, p, p2)
				if instance == character or not instance:FindFirstChild("Humanoid") then
					return false
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					return false
				end

				if p2 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.BLITZ_DAMAGE,
						Skill = name
					})
					Combat_Util.AddStun(script, character, p, Config.BLITZ_STUN)
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
					Combat_presets.PlayReactAnim((instance:FindFirstChild("Humanoid")))
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BLITZ_BLOCK_BREAK)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				end

				return false
			end
		})
	end

	local v7

	if v4 == TwinHarmonyServer.Id[player.UserId] and character.Parent ~= nil then
		v7 = humanoidRootPart.Parent ~= nil
	else
		v7 = false
	end

	if not v7 then
		cleanup()
		return
	end

	EffectsEvent.ToAllInRange(player, "TwinHarmony_effs", character, "BurstHit")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame,
		hitboxSize = Config.BURST_HITBOX_SIZE,
		checker = Checker,
		hitDetected = function(instance, p, p2)
			if instance == character or not instance:FindFirstChild("Humanoid") then
				return false
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return false
			end

			if p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BURST_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p, Config.BURST_STUN)
				Combat_Util.RagDoll(script, character, p, Config.BURST_STUN)
				local v8 = humanoidRootPart.CFrame.LookVector * Config.BURST_KNOCKBACK
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(v8.X, Config.BURST_KNOCKUP, v8.Z),
					Config.BURST_KNOCK_DURATION
				)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BURST_BLOCK_BREAK)
			elseif p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			end

			return false
		end
	})
	cleanup()
end

function TwinHarmonyServer.UnHold(_, _) end

function TwinHarmonyServer.Cancel(player)
	if not player then
		return
	end

	TwinHarmonyServer.Id[player.UserId] = nil

	if v[player.UserId] then
		v[player.UserId]:Destroy()
		v[player.UserId] = nil
	end

	if v2[player.UserId] then
		v2[player.UserId]:Destroy()
		v2[player.UserId] = nil
	end

	if v3[player.UserId] then
		v3[player.UserId]:Destroy()
		v3[player.UserId] = nil
	end

	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "TwinHarmony_effs", character, "Cancel")
	end
end

return TwinHarmonyServer