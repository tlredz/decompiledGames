local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FierySlashServer = {
	Id = {}
}
local _ = game.ReplicatedStorage.Communication
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local hit_priority_handler = require(game.ServerStorage.SAM:WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local script2 = script
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Config = require(script.Parent.Config)
local COMBO_WAITS = Config.COMBO_WAITS

function FierySlashServer.Hold(player, p, state)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local v2 = FierySlashServer.Id[player.UserId]
	task.wait(Config.STARTUP_DUR)

	if FierySlashServer.Id[player.UserId] ~= v2 then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Fiery Slash VFX", character, "StarterSlash")
	state.userValues = {}

	for _, v3 in { "skill_stand_still", "NR", "pause_gameplay" } do
		table.insert(
			state.userValues,
			Utility.AddValue(getvaluesfolder, v3, Config.CASTER_VALUES_DUR / Config.COMBO_SPEED)
		)
	end

	state.target_air_combo_stuff = {}
	state.highesti = 0
	state.vicanims = {}
	local v3 = nil

	for i = 1, 8 do
		if COMBO_WAITS[i] ~= 0 then
			task.wait(COMBO_WAITS[i] / Config.COMBO_SPEED)
		end

		if FierySlashServer.Id[player.UserId] ~= v2 then
			break
		end

		state.highesti = i
		local hitboxCFrame = humanoidRootPart.CFrame * Config.HIT_HITBOX_OFFSET
		local HIT_HITBOX_SIZE = Config.HIT_HITBOX_SIZE
		local v5 = false
		local v6 = nil
		local v7 = {}

		if i == 6 then
			if state.bp then
				state.bp:Destroy()
			end

			state.bp = Combat_Util.Add_air_combo_bp(
				humanoidRootPart,
				humanoidRootPart,
				Config.UPDRAFT_HEIGHT,
				nil,
				Config.UPDRAFT_CASTER_DUR
			)
			task.delay(0.5 / Config.COMBO_SPEED, function()
				if FierySlashServer.Id[player.UserId] == v2 then
					EffectsEvent.ToAllInRange(humanoidRootPart, "Fiery Slash VFX", character, "Kick1", v6)
				end
			end)
		else
			local instances = v7
			local v8 = i
			local v9 = hitboxCFrame
			Utility.CreateHitbox({
				caster = character,
				hitboxSize = HIT_HITBOX_SIZE,
				hitboxCFrame = hitboxCFrame,
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

					if v6 == nil then
						v6 = humanoidRootPart2
					end

					local v10 = false

					if p3 == "Perfect" then
						Combat_Util.Perfect(script2, character, instance)
						return true
					end

					if p3 == "Blocking" or p3 == true then
						Combat_Util.Block(script2, character, instance, Config.HIT_BLOCK_BREAK)
						v10 = true
					end

					v5 = true

					if v10 == true then
						table.insert(instances, instance)
						Combat_Util.Knockback(
							script,
							character,
							humanoidRootPart2,
							humanoidRootPart.CFrame.lookVector * Config.HIT_KNOCKBACK + createVector(0, 0.01, 0),
							0.5,
							"combat_knockback"
						)
						Combat_Util.AddRotation(
							script,
							character,
							humanoidRootPart2,
							Utility.SafeLookAt(
								humanoidRootPart2.Position,
								Vector3.new(
									humanoidRootPart.Position.X,
									humanoidRootPart2.Position.Y,
									humanoidRootPart.Position.Z
								),
								humanoidRootPart2.CFrame
							) * CFrame.new(0, 0, -3),
							0.35,
							50
						)

						if v8 == 5 then
							local add_air_combo_bp = Combat_Util.Add_air_combo_bp(
								humanoidRootPart2,
								humanoidRootPart,
								Config.UPDRAFT_HEIGHT,
								nil,
								Config.UPDRAFT_VICTIM_DUR
							)
							table.insert(state.target_air_combo_stuff, add_air_combo_bp)
							state.bp = Combat_Util.Add_air_combo_bp(
								humanoidRootPart,
								humanoidRootPart,
								0,
								nil,
								Config.LAUNCH_CASTER_PIN_DUR
							)
						end

						if p3 == true then
							if state.vicanims[instance] == nil then
								state.vicanims[instance] = instance.Humanoid.Animator:LoadAnimation(script.victim)
								state.vicanims[instance]:Play()
							end

							if v8 < 5 then
								Combat_Util.AddStun(script2, character, p2, Config.HIT_STUN, true)
							else
								Combat_Util.AddStun(script2, character, p2, Config.LAUNCH_STUN, false)
							end

							Combat_Util.Damage(script2, character, instance, {
								Base = Config.HIT_DAMAGE,
								Skill = script.Parent.Name
							})
						end

						if v8 == 8 then
							task.spawn(function()
								local v11 = Utility.AddValue(
									p2,
									"iframe",
									Config.TORNADO_TICKS * Config.TORNADO_TICK_INTERVAL
								)
								local TORNADO_TICKS = Config.TORNADO_TICKS

								for i2 = 1, TORNADO_TICKS do
									if i2 > 1 then
										task.wait(Config.TORNADO_TICK_INTERVAL)
									end

									if character.Parent == nil or humanoid.Health <= 0 then
										Combat_Util.Remove_air_combo_bp(humanoidRootPart2)
										break
									end

									local check_victim = Checker.check_victim(script2, character, instance, {
										iframe = true
									})

									if check_victim == nil then
										break
									end

									if check_victim == true then
										if i2 == TORNADO_TICKS then
											Combat_Util.AddStun(
												script2,
												character,
												p2,
												Config.TORNADO_FINAL_STUN,
												false
											)
											local position = v9.Position
											local position2 = humanoidRootPart2.Position
											local v12 = (position2 - Vector3.new(position.X, position2.Y, position.Z)).Unit * Config.TORNADO_FINAL_KNOCKBACK
											Combat_Util.RagDoll(script, instance, p2, Config.TORNADO_FINAL_RAGDOLL)
											Combat_Util.Knockback(
												script,
												character,
												instance:FindFirstChild("HumanoidRootPart"),
												Vector3.new(v12.X, 0.01, v12.Z),
												0.2
											)
											Combat_Util.Damage(script2, character, instance, {
												Base = Config.TORNADO_FINAL_DAMAGE,
												Skill = script.Parent.Name
											})
										else
											Combat_Util.AddStun(script2, character, p2, Config.TORNADO_TICK_STUN, false)
											Combat_Util.Damage(script2, character, instance, {
												Base = Config.TORNADO_TICK_DAMAGE,
												Skill = script.Parent.Name
											})
										end
									else
										Combat_Util.Block(script2, character, instance, Config.TORNADO_BLOCK_BREAK)
									end
								end

								v11:Destroy()
							end)
						end
					end
				end
			})

			if v5 ~= true and i >= 6 then
				FierySlashServer.Cancel(player, p, state)
				break
			end

			if i == 1 then
				state.Anim = humanoid.Animator:LoadAnimation(script.User)
				state.Anim:Play(nil, nil, Config.COMBO_SPEED)
				state.Sound = script.ComboSFX:Clone()
				state.Sound.Parent = humanoidRootPart
				v3 = vfxUtility.PlayAtComboSpeed(state.Sound, Config.COMBO_SPEED)
				DebrisModule:AddItem(state.Sound, state.Sound.TimeLength + 3)
			elseif i <= 5 and i > 1 then
				EffectsEvent.ToAllInRange(humanoidRootPart, "Fiery Slash VFX", character, "Slash" .. i - 1, v6)
			elseif i == 8 then
				EffectsEvent.ToAllInRange(humanoidRootPart, "Fiery Slash VFX", character, "Kick2", v6)

				if state.Sound then
					state.Sound.PlaybackSpeed = 1
					v3:Destroy()
				end
			end

			if i < 7 then
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart,
					humanoidRootPart.CFrame.lookVector * Config.CASTER_STEP_KNOCKBACK + createVector(0, 0.01, 0),
					0.5,
					"combat_knockback"
				)
			end

			local raycastResult = i == 8 and v5 == true and workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.UpVector * -150 + humanoidRootPart.CFrame.LookVector * -60,
				RaycastHelper.Crater
			)

			if raycastResult then
				if state.bp then
					state.bp:Destroy()
					state.bp = nil
				end

				local attachment = Instance.new("Attachment")
				attachment.Name = "air_combo_bp"
				local alignPosition = Instance.new("AlignPosition")
				alignPosition.Name = "bpv"
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
				alignPosition.MaxAxesForce = createVector(40000, 40000, 40000)
				alignPosition.Attachment0 = attachment
				alignPosition.Responsiveness = 25
				alignPosition.Parent = attachment
				alignPosition.Position = raycastResult.Position + Vector3.new(0, humanoid.HipHeight * 1.5, 0)
				attachment.Parent = humanoidRootPart
				task.wait(Config.FINISHER_DRAG_AT / Config.COMBO_SPEED)
				local v10 = humanoidRootPart.CFrame.lookVector * -Config.FINISHER_DRAG_BACK * createVector(1, 0, 1)
				local position = alignPosition.Position + v10
				local raycastResult2 = workspace:Raycast(alignPosition.Position, v10, RaycastHelper.Crater)

				if raycastResult2 then
					position = raycastResult2.Position + humanoidRootPart.CFrame.LookVector * 3 * createVector(1, 0, 1)
				end

				alignPosition.Position = position
				DebrisModule:AddItem(attachment, Config.FINISHER_PIN_DUR / Config.COMBO_SPEED)
				task.delay(0.1, function()
					if humanoidRootPart and character then
						EffectsEvent.ToAllInRange(humanoidRootPart, "Fiery Slash VFX", character, "Drag")
					end
				end)
			end

			if state ~= nil and state.vicanims ~= nil then
				for k, vicanim in pairs(state.vicanims) do
					if table.find(v7, k) ~= nil then
						continue
					end

					vicanim:Stop()
					state.vicanims[k] = nil
				end
			end
		end
	end

	EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
end

function FierySlashServer.UnHold(...)
	FierySlashServer.Cancel(...)
end

function FierySlashServer.Cancel(_, _, state)
	if state.highesti ~= 8 then
		if state.Anim then
			state.Anim:Stop()
			state.Anim = nil
		end

		if state.Sound then
			state.Sound:Stop()
			state.Sound = nil
		end

		if state.userValues then
			for _, userValue in state.userValues do
				userValue:Destroy()
			end
		end

		if state.target_air_combo_stuff ~= nil then
			for _, v2 in pairs(state.target_air_combo_stuff) do
				game.Debris:AddItem(v2, 1)
			end
		end

		if state.vicanims then
			for _, vicanim in pairs(state.vicanims) do
				vicanim:Stop()
			end
		end
	end

	if state.vicanims then
		state.vicanims = nil
	end
end

return FierySlashServer