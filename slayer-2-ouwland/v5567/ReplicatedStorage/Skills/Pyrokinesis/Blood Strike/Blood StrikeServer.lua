local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local script2 = script
local BloodStrikeServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		p.stage = "Hold"
		p.touched = false
		local character = player.Character
		local rootPart = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(rootPart, "Blood Strike VFX", character, "Start")
		task.wait(Config.STARTUP_DUR)

		if p.stage ~= "Hold" then
			return
		end

		EffectsEvent.ToAllInRange(rootPart, "Blood Strike VFX", character, "Dash")
		local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`

		while p.stage == "Hold" do
			local singlePartHitbox = Utility.SinglePartHitbox({
				Caster = character,
				ParamsName = formatted,
				Origin = rootPart.CFrame * Config.HITBOX_OFFSET,
				BoxSize = Config.HITBOX_SIZE
			})
			local captured = singlePartHitbox and Utility.find_character_from_descendant(singlePartHitbox)

			if captured and captured ~= character then
				p.captured = captured
				EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
				break
			else
				task.wait(0.1)
			end
		end
	end
}

function BloodStrikeServer.UnHold(player, vector: Vector3, state)
	state.stage = "Release"
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2, _ = ManuelCancel.new(player, Config.RELEASE_CANCEL_WINDOW)
	v2:Connect(function()
		BloodStrikeServer.Cancel(player, vector, state)
	end)
	Combat_Util.Add_air_combo_bp(rootPart, nil, 0, nil, Config.RELEASE_LOCK_DUR)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.RELEASE_LOCK_DUR)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DUR)
	Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DUR)
	local touched = state.touched
	local captured = state.captured
	state.captured = nil

	if not touched then
		EffectsEvent.ToAllInRange(rootPart, "Blood Strike VFX", character, "Release")
	end

	local function fn(instance, p, p2)
		if state.stage == "Cancel" then
			return
		end

		if p2 == "Perfect" then
			Combat_Util.Perfect(script2, character, instance)
		elseif p2 == "Blocking" then
			Combat_Util.Block(script2, character, instance, Config.HIT1_BLOCK_BREAK)
		elseif p2 == true then
			Combat_Util.Damage(script2, character, instance, {
				Base = Config.DAMAGE * 0.4,
				Skill = script.Parent.Name
			})
			Combat_Util.Add_Strict_Stun(script2, character, p, Config.STUN + 0.5)
			local v3 = rootPart.CFrame.LookVector * Config.HIT1_KNOCKBACK
			Combat_Util.RagDoll(script, instance, p, Config.STUN + 0.5)
			Combat_Util.Knockback(
				script,
				character,
				instance:FindFirstChild("HumanoidRootPart"),
				Vector3.new(v3.X, 0.01, v3.Z),
				Config.STUN + 0.5
			)
		end
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		targets = captured and { captured } or nil,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
	task.delay(Config.HIT2_AT, function()
		if state.stage == "Cancel" then
			return
		end

		if not touched then
			EffectsEvent.ToAllInRange(rootPart, "Blood Strike VFX", character, "Impact2")
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.HITBOX_OFFSET,
			hitboxSize = Config.HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if state.stage == "Cancel" then
					return
				end

				if p2 == "Perfect" then
					return
				elseif p2 == "Blocking" then
					Combat_Util.Block(script2, character, instance, Config.HIT2_BLOCK_BREAK)
					return
				end

				Combat_Util.Damage(script2, character, instance, {
					Base = Config.DAMAGE * 0.6,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script2, character, p, Config.STUN)
				Combat_Util.Knockback(
					script2,
					character,
					instance.PrimaryPart,
					rootPart.CFrame.LookVector * Config.KNOCKBACK,
					0.15
				)
			end
		})
	end)
	state.touched = true
end

function BloodStrikeServer.Cancel(player, _: Vector3, p)
	p.stage = "Cancel"
	EffectsEvent.ToAllInRange(player, "Blood Strike VFX", player.Character, "Cancel")
end

return BloodStrikeServer