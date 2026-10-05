local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local script2 = script
local ArrowEruptionServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		p.stage = "Hold"
		p.clock = os.clock()
		local character = player.Character
		local getvaluesfolder = Utility.getvaluesfolder(character)
		EffectsEvent.ToAllInRange(player, "Arrow Eruption VFX", character, "Start")
		p.NR = Utility.AddValue(getvaluesfolder, "NR", Config.HOLD_NR_DUR)
	end
}

function ArrowEruptionServer.UnHold(player, vector: Vector3, state)
	state.stage = "Release"

	if os.clock() - state.clock < Config.MIN_HOLD_DUR then
		EffectsEvent.ToAllInRange(player, "Arrow Eruption VFX", player.Character, "Cancel")

		if state.NR then
			state.NR:Destroy()
		end
	else
		local character = player.Character
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local rootPart = character:FindFirstChild("Humanoid").RootPart
		local v2 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_DUR)
		local v3, v4 = ManuelCancel.new(player, Config.RELEASE_DUR, nil, script.Parent.Name)
		local v5 = false
		v3:Connect(function()
			v5 = true

			if v2 then
				v2:Destroy()
			end

			ArrowEruptionServer.Cancel(player, vector, state)
		end)
		Utility.CreateHitbox({
			caster = character,
			hitboxSize = Config.HITBOX_ONE_SIZE,
			hitboxCFrame = rootPart.CFrame * Config.HITBOX_ONE_OFFSET,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if p2 == "Perfect" then
					Combat_Util.Perfect(script2, character, instance)
					return
				elseif p2 == "Blocking" then
					Combat_Util.Block(script2, character, instance, Config.BLOCK_DAMAGE)
					return
				end

				Combat_Util.Add_Strict_Stun(script2, character, p, Config.HITBOX_ONE_STUN)
				local v6 = CFrame.lookAt(rootPart.Position, instance:GetPivot().Position).LookVector * -1
				Combat_Util.Knockback(
					script2,
					character,
					instance.PrimaryPart,
					Vector3.new(v6.X, 0.01, v6.Z),
					Config.HITBOX_ONE_PULL_DUR
				)
				Combat_Util.RagDoll(script2, character, p, Config.HITBOX_ONE_RAGDOLL)
				Combat_Util.Damage(script2, character, instance, {
					Base = Config.HITBOX_ONE_DAMAGE,
					Skill = script.Parent.Name
				})
			end
		})
		EffectsEvent.ToAllInRange(player, "Arrow Eruption VFX", character, "ArrowEruption")
		task.wait(Config.HITBOX_TWO_DELAY)

		if state.stage == "Cancel" or v5 then
			return
		end

		v4()
		Utility.CreateHitbox({
			caster = character,
			hitboxSize = Config.HITBOX_TWO_SIZE,
			hitboxCFrame = rootPart.CFrame * Config.HITBOX_TWO_OFFSET,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if p2 == "Perfect" then
					Combat_Util.Perfect(script2, character, instance)
					return
				elseif p2 == "Blocking" then
					Combat_Util.Block(script2, character, instance, Config.BLOCK_DAMAGE)
					return
				end

				Combat_Util.Damage(script2, character, instance, {
					Base = Config.HITBOX_TWO_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script2,
					character,
					instance.PrimaryPart,
					CFrame.lookAt(rootPart.Position, instance:GetPivot().Position).LookVector * Config.HITBOX_TWO_KNOCKBACK + Vector3.new(
						0,
						Config.HITBOX_TWO_KNOCKUP,
						0
					),
					0.15
				)
				Combat_Util.AddStun(script2, character, p, Config.HITBOX_TWO_STUN)
				Combat_Util.RagDoll(script2, character, p, Config.HITBOX_TWO_RAGDOLL)
			end
		})
	end
end

function ArrowEruptionServer.Cancel(player, _: Vector3, p)
	p.stage = "Cancel"
	EffectsEvent.ToAllInRange(player, "Arrow Eruption VFX", player.Character, "Cancel")
end

return ArrowEruptionServer