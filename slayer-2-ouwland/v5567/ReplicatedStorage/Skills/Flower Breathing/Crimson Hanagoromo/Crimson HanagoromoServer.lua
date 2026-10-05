local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local CrimsonHanagoromoServer = {
	Id = {}
}
local name = script.Parent.Name

function CrimsonHanagoromoServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = CrimsonHanagoromoServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v3 = character and Utility.getvaluesfolder(character)

	if humanoidRootPart == nil or v3 == nil then
		return
	end

	cleanIt:Add(Utility.AddValue(v3, "WalkSpeed", Config.MAX_HOLD + 1, "NumberValue", Config.WALK_SPEED))

	local function stillHeld()
		return CrimsonHanagoromoServer.Id[player.UserId] == v2 and character.Parent ~= nil and humanoidRootPart.Parent ~= nil
	end

	local v4 = cleanIt:Add(Utility.AddValue(v3, "pause_gameplay", Config.STARTUP))
	local now = os.clock()
	task.wait(Config.INVIS_AT)
	local v5

	if CrimsonHanagoromoServer.Id[player.UserId] == v2 and character.Parent ~= nil then
		v5 = humanoidRootPart.Parent ~= nil
	else
		v5 = false
	end

	if not v5 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Crimson Hanagoromo VFX", character, "Start")
	cleanIt:Add(Utility.AddValue(v3, "Transparent", Config.MAX_HOLD + 1, "StringValue", name))
	local v6 = now + Config.STARTUP - os.clock()

	if v6 > 0 then
		task.wait(v6)
	end

	local v7

	if CrimsonHanagoromoServer.Id[player.UserId] == v2 and character.Parent ~= nil then
		v7 = humanoidRootPart.Parent ~= nil
	else
		v7 = false
	end

	if not v7 then
		return
	end

	if v4.Parent ~= nil then
		v4:Destroy()
	end

	local now2 = os.clock()
	local count = 0

	while true do
		local v8

		if CrimsonHanagoromoServer.Id[player.UserId] == v2 and character.Parent ~= nil then
			v8 = humanoidRootPart.Parent ~= nil
		else
			v8 = false
		end

		if not v8 then
			break
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame,
			hitboxSize = Config.BLITZ_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					return
				end

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BLITZ_BLOCK_BREAK)
				elseif p3 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.BLITZ_DAMAGE,
						Skill = name
					})
					Combat_Util.AddStun(script, character, p2, Config.BLITZ_STUN)
					local v9 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
					local v10 = not (v9.Magnitude > 0.001) and createVector(0, 0, 1) or v9.Unit
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						v10 * Config.BLITZ_KNOCKBACK,
						Config.BLITZ_KNOCK_DURATION
					)
					Combat_presets.PlayReactAnim((instance:FindFirstChild("Humanoid")))
					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				end
			end
		})
		count += 1
		local v9 = now2 + count * Config.BLITZ_INTERVAL - os.clock()

		if v9 > 0 then
			task.wait(v9)
		end
	end
end

function CrimsonHanagoromoServer.UnHold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v2 = character and Utility.getvaluesfolder(character)

	if humanoidRootPart == nil or v2 == nil then
		return
	end

	cleanIt:Add(Utility.AddValue(v2, "pause_gameplay", Config.ENDLAG))
	cleanIt:Add(Utility.AddValue(v2, "WalkSpeed", Config.ENDLAG, "NumberValue", Config.WALK_SPEED))
	cleanIt:Add(Utility.AddValue(v2, "iframe", Config.ENDLAG))
	local v3 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v4 = not (v3.Magnitude > 0.001) and createVector(0, 0, 1) or v3.Unit
	EffectsEvent.ToAllInRange(humanoidRootPart, "Crimson Hanagoromo VFX", character, "Final", humanoidRootPart.CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame,
		hitboxSize = Config.FINAL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				return
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINAL_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p2, Config.FINAL_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.FINAL_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v4 * Config.FINAL_KNOCKBACK + Vector3.new(0, Config.FINAL_KNOCKUP, 0),
					Config.FINAL_KNOCK_DURATION
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
			end
		end
	})
end

function CrimsonHanagoromoServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Crimson Hanagoromo VFX", character, "Cancel")
	end

	if p.CleanIt then
		p.CleanIt:Clean()
	end
end

return CrimsonHanagoromoServer