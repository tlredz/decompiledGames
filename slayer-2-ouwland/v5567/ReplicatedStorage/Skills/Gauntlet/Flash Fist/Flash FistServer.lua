local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local FlashFistServer = {
	Id = {}
}
local name = script.Parent.Name

function FlashFistServer.Hold(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	p.holdStart = os.clock()
	EffectsEvent.ToAllInRange(humanoidRootPart, "GauntletInit", character)
end

function FlashFistServer.UnHold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = FlashFistServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = math.max(0, Config.HOLD_PAUSE - (os.clock() - (state.holdStart or 0)))
	local v4, v5 = ManuelCancel.new(player, v3 + Config.END_AT + 0.5)
	v4:Connect(function()
		FlashFistServer.Id[player.UserId] = -1
		FlashFistServer.Cancel(player, vector2, state)
	end)
	cleanIt:Add(v5)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v3 + Config.END_AT))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", (v3 + Config.END_AT) * Config.IFRAME_SHARE))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "WalkSpeed", v3 + Config.END_AT, "NumberValue", Config.WALK_SPEED))
	task.wait(v3 + Config.PUNCH_AT)

	if FlashFistServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Flash Fist VFX", character, "FlashFist", humanoidRootPart.CFrame)
	local v6 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.PUNCH_HITBOX_OFFSET,
		hitboxSize = Config.PUNCH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, values, p2)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.PUNCH_BLOCK_BREAK)
			elseif p2 == true then
				table.insert(v6, {
					model = instance,
					root = humanoidRootPart2,
					values = values
				})
				local lookVector = humanoidRootPart.CFrame.LookVector
				Combat_Util.Damage(script, character, instance, {
					Base = Config.PUNCH_DAMAGE,
					Skill = name
				})
				Combat_Util.Add_Strict_Stun(script, character, values, Config.PUNCH_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(lookVector.X, 0.01, lookVector.Z),
					Config.PUNCH_STUN
				)
				Combat_presets.PlayReactAnim(humanoid, nil, nil)
			end
		end
	})

	if #v6 == 0 then
		task.wait(Config.END_AT - Config.PUNCH_AT)

		if FlashFistServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	else
		local v7 = Config.END_AT - Config.PUNCH_AT
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", v7))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", v7))
		task.wait(Config.BARRAGE_AT - Config.PUNCH_AT)

		if FlashFistServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Flash Fist VFX", character, "Barrage", humanoidRootPart.CFrame)
		local BARRAGE_INTERVAL = Config.BARRAGE_INTERVAL

		for i = 1, Config.BARRAGE_HIT_COUNT do
			if FlashFistServer.Id[player.UserId] ~= v2 then
				return
			end

			local v8 = i == Config.BARRAGE_HIT_COUNT

			for _, v9 in v6 do
				local humanoid = v9.model:FindFirstChild("Humanoid")

				if not (humanoid ~= nil and v9.root.Parent ~= nil) then
					continue
				end

				Combat_Util.Damage(script, character, v9.model, {
					Base = Config.BARRAGE_DAMAGE,
					Skill = name
				})
				Combat_presets.PlayReactAnim(humanoid, nil, nil)

				if v8 then
					Combat_Util.AddStun(script, character, v9.values, Config.BARRAGE_FINAL_STUN, true)
					Combat_Util.RagDoll(script, character, v9.values, Config.BARRAGE_FINAL_STUN)
					Combat_Util.Knockback(
						script,
						character,
						v9.root,
						humanoidRootPart.CFrame.LookVector * Config.BARRAGE_KNOCKBACK + Vector3.new(
							0,
							Config.BARRAGE_KNOCKUP,
							0
						),
						0.3
					)
				else
					Combat_Util.AddStun(script, character, v9.values, Config.BARRAGE_STUN, true)
					Combat_Util.Knockback(
						script,
						character,
						v9.root,
						humanoidRootPart.CFrame.LookVector * 3 + createVector(0, 1, 0),
						BARRAGE_INTERVAL
					)
				end
			end

			task.wait(BARRAGE_INTERVAL)
		end

		if FlashFistServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	end
end

function FlashFistServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Flash Fist VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return FlashFistServer