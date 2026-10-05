local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TriClawReversalServer = {
	Id = {}
}
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)

function TriClawReversalServer.Hold(_, _) end

function TriClawReversalServer.UnHold(player, p, p2)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local v2 = TriClawReversalServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3

	if getvaluesfolder then
		v3 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SEQUENCE_LOCK_DURATION)
	else
		v3 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearPause()
		if v3 ~= nil then
			if v3.Parent ~= nil then
				v3:Destroy()
			end

			v3 = nil
		end
	end

	local v4, v5 = ManuelCancel.new(player, Config.SEQUENCE_LOCK_DURATION, nil, "TriClaw Reversal")
	v4:Connect(function()
		v2 = -1
		TriClawReversalServer.Cancel(player, p, p2)
		v5()
	end)
	EffectsEvent.ToAllInRange(player, "TriClawReversal_effs", character, p, "First")
	local instances = {}
	task.wait(Config.SETUP_DELAY)

	if v2 == TriClawReversalServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil then
		local safeLookAt = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(p.X, humanoidRootPart.Position.Y, p.Z),
			humanoidRootPart.CFrame
		)
		local add_air_combo_bp = Combat_Util.Add_air_combo_bp(
			humanoidRootPart,
			humanoidRootPart,
			Config.AIR_COMBO_Y,
			nil,
			Config.AIR_COMBO_DURATION
		)

		if p2 then
			p2.airComboBP = add_air_combo_bp
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = safeLookAt,
			hitboxSize = Config.SETUP_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Both,
				data = {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}
			},
			hitDetected = function(instance, p3, p4)
				if not instance then
					return false
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					return false
				end

				if p4 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
				elseif p4 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p4 == true then
					table.insert(instances, instance)
					local v6 = humanoidRootPart.CFrame.RightVector * -Config.SETUP_KNOCKBACK
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SETUP_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p3, Config.SETUP_STUN)
					Combat_Util.Knockback(script, character, humanoidRootPart2, Vector3.new(v6.X, 2, v6.Z), 0.5)
				end

				return false
			end
		})
		task.wait(Config.PHASE_GAP)

		if v2 == TriClawReversalServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil then
			EffectsEvent.ToAllInRange(player, "TriClawReversal_effs", character, p, "Second")
			local hitboxCFrame = humanoidRootPart.CFrame * CFrame.Angles(-0.5235987755982988, 0, 0) * CFrame.new(
				0,
				-3.5,
				-Config.SWEEP_HITBOX_SIZE.Z / 2
			)
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = hitboxCFrame,
				hitboxSize = Config.SWEEP_HITBOX_SIZE,
				targets = instances,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Both,
					data = {
						pv = getvaluesfolder,
						name = "Choosing_1"
					}
				},
				hitDetected = function(instance, p3, p4)
					if not instance then
						return false
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						return false
					end

					if p4 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
					elseif p4 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p4 == true then
						local v7 = hitboxCFrame.LookVector * Config.SWEEP_KNOCKBACK
						EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.SWEEP_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p3, Config.IMPACT_STUN)
						Combat_Util.RagDoll(script, character, p3, Config.IMPACT_STUN)
						Combat_Util.Knockback(script, character, humanoidRootPart2, Vector3.new(v7.X, 0.5, v7.Z), 0.15)
					end

					return false
				end
			})
			task.wait(Config.POST_HIT_LOCK)
			clearPause() -- equivalent call inferred; original call site unknown
			v5()
			return
		end
	end

	clearPause() -- equivalent call inferred; original call site unknown
	v5()
end

function TriClawReversalServer.Cancel(p, _, p2)
	if p == nil then
		return
	end

	TriClawReversalServer.Id[p.UserId] = nil

	if p2 and p2.airComboBP ~= nil then
		if p2.airComboBP.Parent ~= nil then
			p2.airComboBP:Destroy()
		end

		p2.airComboBP = nil
	end
end

return TriClawReversalServer