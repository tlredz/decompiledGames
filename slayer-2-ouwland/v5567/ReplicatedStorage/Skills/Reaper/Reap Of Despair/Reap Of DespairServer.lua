local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ReapOfDespairServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Config = require(script.Parent.Config)
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local _ = table.find
local _ = table.remove
local _ = Vector3.new
local _ = tick
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local _ = table.find
local _ = table.remove

function ReapOfDespairServer.Hold(player, _, p)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")
	p.Started = humanoidRootPart.CFrame
	EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "Start")
end

local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)

function ReapOfDespairServer.UnHold(player, p, state)
	if player.Character == nil then
		return
	end

	local v2 = ReapOfDespairServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or p == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local position = humanoidRootPart.CFrame.Position
	local maximizeRayServer, _, _, _ = RaycastHelper.MaximizeRayServer(
		character,
		position,
		p,
		Config.TELEPORT_RANGE,
		true,
		5,
		7,
		3
	)
	local unit = (maximizeRayServer - position).unit
	local transparency = Utility.AddValue(getvaluesfolder, "Transparent", 3)
	state.Transparency = transparency
	EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "Disappear", state.Started)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	local v4 = nil
	local v5, v6 = ManuelCancel.new(player, 1)
	v5:Connect(function()
		ReapOfDespairServer.Cancel(player, p, state)
		ReapOfDespairServer.Id[player.UserId] = -1
	end)
	task.delay(Config.TELEPORT_AT, function()
		boolValue:Destroy()

		if ReapOfDespairServer.Id[player.UserId] ~= v2 then
			return
		end

		transparency:Destroy()
		local cframe = CFrame.lookAlong(maximizeRayServer, unit)
		EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "ReAppear", cframe)
		local getvaluesfolder2 = Utility.getvaluesfolder(character)
		v4 = Utility.GetModelInRegion(cframe * Config.APPEAR_HITBOX_OFFSET, Config.APPEAR_HITBOX_SIZE, nil, nil)
		local targets = {}
		local flag = false

		for _, v8 in pairs(v4) do
			if ReapOfDespairServer.Id[player.UserId] ~= v2 then
				return
			end

			if not (v8 ~= character and v8:FindFirstChild("Humanoid") ~= nil) then
				continue
			end

			local humanoidRootPart2 = v8:FindFirstChild("HumanoidRootPart")
			v8:FindFirstChild("Humanoid")
			local check_victim, _ = Checker.check_victim(script, character, v8)
			local getvaluesfolder3 = Utility.getvaluesfolder(v8)

			if v.Both(getvaluesfolder3, {
				pv = getvaluesfolder2,
				name = "Choosing_1"
			}) == true then
				continue
			end

			if check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, v8)
			elseif check_victim == true or check_victim == "Blocking" then
				if check_victim == "Blocking" then
					Combat_Util.Block(script, character, v8, Config.APPEAR_BLOCK_BREAK)
				else
					Combat_Util.Damage(script, character, v8, {
						Base = Config.APPEAR_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder3, Config.APPEAR_STUN)
					table.insert(targets, v8)
					Combat_Util.Add_air_combo_bp(humanoidRootPart2, humanoidRootPart, nil, humanoidRootPart.Position)

					if not flag then
						EffectsEvent.ToAllInRange(
							player,
							"Reap Of DespairVFX",
							player.Character,
							"Air",
							humanoidRootPart2
						)
						flag = true
					end
				end
			end
		end

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "Updraft", cframe)

		if flag then
			state.pg = Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.UPDRAFT_LOCK_DURATION)
			state.nr = Utility.AddValue(getvaluesfolder2, "NR", Config.UPDRAFT_LOCK_DURATION)
			Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, nil)
			state.DespairAnim = humanoid.Animator:LoadAnimation(script.User)
			state.DespairAnim:Play()
			task.wait(Config.TICKS_START_DELAY)

			if ReapOfDespairServer.Id[player.UserId] ~= v2 then
				return
			end

			for _ = 1, Config.TICK_COUNT do
				if ReapOfDespairServer.Id[player.UserId] ~= v2 then
					return
				end

				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = humanoidRootPart.CFrame * Config.TICK_HITBOX_OFFSET,
					hitboxSize = Config.TICK_HITBOX_SIZE,
					targets = targets,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					hitDetected = function(instance, p2, p3, _)
						if instance then
							local humanoid2 = instance:FindFirstChild("Humanoid")
							local rootPart = humanoid2.RootPart

							if p3 == "Blocking" then
								Combat_Util.Block(script, character, instance, Config.TICK_BLOCK_BREAK)
							elseif p3 == "Perfect" then
								Combat_Util.Perfect(script, character, instance)
							elseif p3 == true then
								local v8 = CFrame.new(rootPart.Position).UpVector * 0.01
								EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
								Combat_Util.AddStun(script, character, p2, Config.TICK_STUN)
								Combat_Util.Damage(script, character, instance, {
									Base = Config.TICK_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_Util.Knockback(script, character, rootPart, v8, Config.TICK_KNOCKBACK_TIME)

								if humanoid2 then
									local v9 = math.random(1, 4)
									Combat_presets.PlayReactAnim(humanoid2, v9)
								end
							end
						end
					end
				})
				task.wait(Config.TICK_INTERVAL)
			end

			task.wait(Config.SLAM_DELAY)

			if ReapOfDespairServer.Id[player.UserId] ~= v2 then
				return
			end

			local v8 = false
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = humanoidRootPart.CFrame * Config.SLAM_HITBOX_OFFSET,
				hitboxSize = Config.SLAM_HITBOX_SIZE,
				targets = targets,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3, _)
					if instance then
						local _ = instance:FindFirstChild("Humanoid").RootPart

						if p3 == "Blocking" then
							Combat_Util.Block(script, character, instance, Config.SLAM_BLOCK_BREAK)
						elseif p3 == "Perfect" then
							Combat_Util.Perfect(script, character, instance)
						elseif p3 == true then
							Combat_Util.AddStun(script, character, p2, Config.SLAM_STUN)
							local air_combo_slam = Combat_Util.Air_combo_slam(character, instance, nil, nil, true)

							if not v8 then
								v8 = true
								EffectsEvent.ToAllInRange(
									player,
									"Reap Of DespairVFX",
									character,
									"Slam",
									air_combo_slam
								)
							end
						end
					end
				end
			})
			task.wait(Config.SLAM_RECOVERY)

			if ReapOfDespairServer.Id[player.UserId] == v2 then
				ReapOfDespairServer.Cancel(player, p, state)
			end
		end

		v6()
	end)
end

function ReapOfDespairServer.Cancel(player, _, state)
	if player.Character == nil then
		return
	end

	if state.pg ~= nil then
		state.pg:Destroy()
		state.pg = nil
	end

	if state.nr ~= nil then
		state.nr:Destroy()
		state.nr = nil
	end

	if state.Transparency ~= nil then
		state.Transparency:Destroy()
		state.Transparency = nil
	end

	if state.DespairAnim ~= nil then
		state.DespairAnim:Stop()
		state.DespairAnim = nil
	end
end

return ReapOfDespairServer