local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local HeadbuttServer = {}
HeadbuttServer.Id = {}

function HeadbuttServer.Hold(player, _, p)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK)
	p.cancelled = false
	local v2, v3 = ManuelCancel.new(player, Config.HIT_AT)
	v2:Connect(function()
		p.cancelled = true
		v3()
	end)

	if Config.SWING_SFX_AT > 0 then
		task.wait(Config.SWING_SFX_AT)

		if p.cancelled or humanoidRootPart.Parent == nil then
			v3()
			return false
		end
	end

	EffectsEvent.ToAllInRange(player, "HeadbuttVFX", character, "Swing")
	task.wait(Config.HIT_AT - Config.SWING_SFX_AT)

	if p.cancelled or humanoidRootPart.Parent == nil then
		v3()
		return false
	end

	EffectsEvent.ToAllInRange(player, "HeadbuttVFX", character)
	local v4 = false
	local cFrame = humanoidRootPart.CFrame
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not v4 then
				v4 = true
				EffectsEvent.ToAllInRange(player, "HeadbuttVFX", character, "Connect")
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.IMPACT_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.IMPACT_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					cFrame.LookVector * Config.KNOCKBACK,
					Config.KNOCKBACK_DURATION
				)
			end
		end
	})
	v3()
	task.wait(Config.LOCK - Config.HIT_AT)
	return true
end

function HeadbuttServer.Cancel(player, _, p)
	if p then
		p.cancelled = true
	end

	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return HeadbuttServer