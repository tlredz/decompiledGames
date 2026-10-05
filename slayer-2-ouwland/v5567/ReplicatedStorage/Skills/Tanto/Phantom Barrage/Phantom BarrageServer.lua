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
local PhantomBarrageServer = {
	Id = {}
}
local name = script.Parent.Name

function PhantomBarrageServer.Hold(player, vector: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = PhantomBarrageServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3, v4 = ManuelCancel.new(player, Config.END_AT + 0.5)
	v3:Connect(function()
		PhantomBarrageServer.Id[player.UserId] = -1
		PhantomBarrageServer.Cancel(player, vector, p)
	end)
	cleanIt:Add(v4)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.END_AT))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "WalkSpeed", Config.END_AT, "NumberValue", Config.WALK_SPEED))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.END_AT))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Phantom Barrage VFX", character, "Start", humanoidRootPart.CFrame)
	task.wait(Config.BARRAGE_AT)

	if PhantomBarrageServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Phantom Barrage VFX", character, "Barrage", humanoidRootPart.CFrame)
	task.delay(Config.BARRAGE_TIMESCALE_AT - Config.BARRAGE_AT, function()
		if PhantomBarrageServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(
			humanoidRootPart,
			"Phantom Barrage VFX",
			character,
			"BarrageTimeScale",
			humanoidRootPart.CFrame
		)
	end)
	local v5 = (Config.FINISHER_AT - Config.BARRAGE_AT) / Config.BARRAGE_HIT_COUNT

	for _ = 1, Config.BARRAGE_HIT_COUNT do
		if PhantomBarrageServer.Id[player.UserId] ~= v2 then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.HITBOX_OFFSET,
			hitboxSize = Config.HITBOX_SIZE,
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
					EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				end
			end
		})
		task.wait(v5)
	end

	if PhantomBarrageServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Phantom Barrage VFX", character, "End", humanoidRootPart.CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
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
				Combat_Util.Block(script, character, instance, Config.FINISHER_BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINISHER_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p2, Config.FINISHER_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.FINISHER_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					humanoidRootPart.CFrame.LookVector * Config.FINISHER_KNOCKBACK + Vector3.new(
						0,
						Config.FINISHER_UPWARD,
						0
					),
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
			end
		end
	})
	task.wait(Config.END_AT - Config.FINISHER_AT)

	if PhantomBarrageServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function PhantomBarrageServer.UnHold(_, _: Vector3?, _) end

function PhantomBarrageServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Phantom Barrage VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return PhantomBarrageServer