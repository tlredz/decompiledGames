local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(global.Checker)
local Utility = require(global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local MountainWindServer = {
	Id = {},
	Hold = function(player, _, _)
		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Mountain WindVFX", character, "Start")
	end
}

function MountainWindServer.UnHold(player, p, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = MountainWindServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		state.pauseValue = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SEQUENCE_LOCK_DURATION)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearPause()
		local pauseValue = state.pauseValue

		if pauseValue ~= nil then
			if pauseValue.Parent ~= nil then
				pauseValue:Destroy()
			end

			state.pauseValue = nil
		end
	end

	local v3, v4 = ManuelCancel.new(player, 4)
	v3:Connect(function()
		v2 = -1
		MountainWindServer.Cancel(player, p, state)
		v4()
	end)
	task.wait(Config.PRE_HITBOX_DELAY)

	if v2 == MountainWindServer.Id[player.UserId] then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Mountain WindVFX", character, "Up", humanoidRootPart.CFrame)
		local v5 = nil
		local instances = {}
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.CATCH_HITBOX_OFFSET,
			hitboxSize = Config.CATCH_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				if not instance then
					return
				end

				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid and humanoid.RootPart

				if not rootPart then
					return
				end

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.CATCH_BLOCK_BREAK)
				elseif p3 == true then
					Combat_Util.Add_air_combo_bp(rootPart, humanoidRootPart)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.CATCH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Add_Strict_Stun(script, character, p2, Config.CATCH_STUN, true)

					if humanoid then
						Combat_presets.PlayReactAnim(humanoid)
					end

					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					if v5 == nil then
						v5 = instance
						Combat_Util.Add_air_combo_bp(humanoidRootPart, humanoidRootPart)
					end
				end
			end,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})

		if v5 ~= nil then
			task.wait(Config.POST_CATCH_WAIT_BEFORE_ANIM)

			if v2 == MountainWindServer.Id[player.UserId] then
				EffectsEvent.ToAllInRange(humanoidRootPart, "Mountain WindVFX", character, "PreSlash")
				local humanoid = character:FindFirstChild("Humanoid")
				local animator = humanoid and humanoid:FindFirstChild("Animator")

				if animator then
					state.downslamTrack = animator:LoadAnimation(script.Downslam)
					state.downslamTrack:Play(nil, nil, Config.DOWNSLAM_ANIM_SPEED)
				end

				task.wait(Config.POST_CATCH_WAIT_AFTER_ANIM)

				if v2 == MountainWindServer.Id[player.UserId] then
					local position = (humanoidRootPart.CFrame * Config.SLAM_OFFSET).Position
					local unit = (position - humanoidRootPart.Position).Unit
					local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit)
					local cframe2 = CFrame.lookAt(position, position + unit)
					EffectsEvent.ToAllInRange(humanoidRootPart, "Mountain WindVFX", character, "Slash", cframe, cframe2)
					local hitboxCFrame = cframe * CFrame.new(0, 0, -Config.RELEASE_HITBOX_LENGTH / 2)
					Utility.CreateHitbox({
						caster = character,
						hitboxCFrame = hitboxCFrame,
						hitboxSize = Vector3.new(
							Config.RELEASE_HITBOX_WIDTH,
							Config.RELEASE_HITBOX_HEIGHT,
							Config.RELEASE_HITBOX_LENGTH
						),
						checker = Checker,
						targets = instances,
						hitPriorityHandler = {
							callback = v.Exists,
							data = "Choosing_2"
						},
						hitDetected = function(instance, p2, p3)
							if not instance then
								return
							end

							local humanoid2 = instance:FindFirstChild("Humanoid")

							if not (humanoid2 and humanoid2.RootPart) then
								return
							end

							if p3 == "Perfect" then
								Combat_Util.Perfect(script, character, instance)
							elseif p3 == "Blocking" then
								Combat_Util.Block(script, character, instance, Config.SLAM_BLOCK_BREAK)
							elseif p3 == true then
								Combat_Util.Damage(script, character, instance, {
									Base = Config.SLAM_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_Util.AddStun(script, character, p2, Config.SLAM_STUN)
								local air_combo_slam = Combat_Util.Air_combo_slam(
									character,
									instance,
									humanoidRootPart.CFrame,
									Config.SLAM_OFFSET,
									true
								)

								if instance == v5 and air_combo_slam then
									EffectsEvent.ToAllInRange(
										air_combo_slam,
										"Mountain WindVFX",
										character,
										"Impact",
										air_combo_slam
									)
								end
							end
						end,
						After = function(p2, list)
							if p2 then
								ImpactSounds.Play(character, script.Parent.Name, list[1])
							end
						end
					})
					v4()
					clearPause() -- equivalent call inferred; original call site unknown
					return
				end
			end
		end

		v4()
		clearPause() -- equivalent call inferred; original call site unknown
	else
		v4()
		clearPause() -- equivalent call inferred; original call site unknown
	end
end

function MountainWindServer.Cancel(player, _, state)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if state and state.downslamTrack then
		state.downslamTrack:Stop()
		state.downslamTrack:Destroy()
		state.downslamTrack = nil
	end

	if state and state.pauseValue ~= nil then
		if state.pauseValue.Parent ~= nil then
			state.pauseValue:Destroy()
		end

		state.pauseValue = nil
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return MountainWindServer