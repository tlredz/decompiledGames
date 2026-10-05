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
local ServerStorage2 = game:GetService("ServerStorage")
local Server_Mouse_Pos = require(ServerStorage2.SAM.Services.Server_Mouse_Pos)
local StormRushServer = {
	Id = {}
}
local name = script.Parent.Name

function StormRushServer.Hold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = StormRushServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	p.hovering = false
	local v3, v4 = ManuelCancel.new(player, Config.HOLD_LOCK_DURATION + 0.5)
	v3:Connect(function()
		StormRushServer.Id[player.UserId] = -1
		StormRushServer.Cancel(player, vector2, p)
	end)
	cleanIt:Add(v4)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.HOLD_LOCK_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.HOLD_LOCK_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.HOLD_LOCK_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Startup", humanoidRootPart.CFrame)
	task.wait(Config.STARTUP_AT)

	if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Barrage", humanoidRootPart.CFrame)
	local v5 = Config.BARRAGE_DUR / Config.BARRAGE_HIT_COUNT

	for _ = 1, Config.BARRAGE_HIT_COUNT do
		if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.BARRAGE_HITBOX_OFFSET,
			hitboxSize = Config.BARRAGE_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				local humanoid = instance:FindFirstChild("Humanoid")
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid == nil or humanoidRootPart2 == nil then
					return
				end

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BARRAGE_BLOCK_BREAK)
				elseif p3 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.BARRAGE_DAMAGE,
						Skill = name
					})
					Combat_Util.AddStun(script, character, p2, Config.BARRAGE_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						Vector3.new(0, Config.BARRAGE_KNOCKUP, 0),
						v5
					)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		})
		task.wait(v5)
	end

	if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	task.wait(Config.KICK_HIT_AT)

	if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Kick", humanoidRootPart.CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.KICK_HITBOX_OFFSET,
		hitboxSize = Config.KICK_HITBOX_SIZE,
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
				Combat_Util.Block(script, character, instance, Config.KICK_BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.KICK_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p2, Config.KICK_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.KICK_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					humanoidRootPart.CFrame.LookVector * Config.KICK_KNOCKBACK + Vector3.new(0, Config.KICK_UPWARD, 0),
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})
	task.wait(Config.KICK_DUR - Config.KICK_HIT_AT)

	if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	p.hovering = true
	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Jump", humanoidRootPart.CFrame)
end

function StormRushServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if state.hovering then
		state.hovering = false
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "AirDash", humanoidRootPart.CFrame)
	else
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Cancel")
		cleanIt:Clean()
	end
end

function StormRushServer.UnHoldAfterClient(player, _: Vector3?, _, p, p2)
	local cleanIt = p2.CleanIt or cleanit.new()
	p2.CleanIt = cleanIt
	local v2 = StormRushServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if typeof(p) ~= "CFrame" then
		StormRushServer.Cancel(player, nil, p2)
		return
	end

	local clamped = Server_Mouse_Pos.Clamp(character, p.Position, Config.MOUSE_RANGE + 15)

	if clamped == nil then
		StormRushServer.Cancel(player, nil, p2)
		return
	end

	local v3 = p.Rotation + clamped
	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Land", v3)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v3 * Config.LAND_HITBOX_OFFSET,
		hitboxSize = Config.LAND_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				return
			end

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.LAND_BLOCK_BREAK)
			elseif p4 == true then
				local air_combo_bp = humanoidRootPart2:FindFirstChild("air_combo_bp")

				if air_combo_bp then
					air_combo_bp:Destroy()
				end

				Combat_Util.Damage(script, character, instance, {
					Base = Config.LAND_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p3, Config.LAND_STUN)
				Combat_Util.RagDoll(script, character, p3, Config.LAND_RAGDOLL)
				local v4 = (humanoidRootPart2.Position - v3.Position) * createVector(1, 0, 1)
				local v5

				if v4.Magnitude > 0.1 then
					v5 = v4.Unit
				else
					v5 = (v3.LookVector * createVector(1, 0, 1)).Unit
				end

				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v5 * Config.LAND_KNOCKBACK + Vector3.new(0, Config.LAND_UPWARD, 0),
					0.25
				)
			end
		end
	})
	task.wait(Config.LAND_DUR)

	if StormRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function StormRushServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Rush VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return StormRushServer