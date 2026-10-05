local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(script.Parent.Config)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Server_Mouse_Pos = require(ServerStorage.SAM.Services.Server_Mouse_Pos)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ExecutionScytherServer = {
	Id = {}
}
local name = script.Parent.Name

-- equivalent calls inferred from this helper; original call sites unknown
local function baseCFrame(p, p2)
	local _, v2 = Server_Mouse_Pos.Aim(p, name, 15)
	return v2 or p2.CFrame
end

local function holdCaptive(p, p2, p3: number)
	return {
		Utility.AddValue(p2, "pause_gameplay", p3),
		Utility.AddValue(p2, "noragdoll", p3),
		Combat_Util.Add_Strict_Stun(script, p, p2, p3)
	}
end

local function releaseEntry(capturedVictim)
	if not capturedVictim then
		return
	end

	if capturedVictim.weld and capturedVictim.weld.Parent then
		capturedVictim.weld:Destroy()
	end

	capturedVictim.weld = nil

	if capturedVictim.debris then
		for _, v2 in capturedVictim.debris do
			if v2 and v2.Parent then
				v2:Destroy()
			end
		end

		capturedVictim.debris = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDrain(p)
	if p.drainValue and p.drainValue.Parent then
		p.drainValue:Destroy()
	end

	p.drainValue = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseCaptives(p)
	if not p.capturedVictims then
		return
	end

	for k, capturedVictim in p.capturedVictims do
		releaseEntry(capturedVictim)
		p.capturedVictims[k] = nil
	end
end

local function aoeHit(character, cframe: CFrame, SLAM_HITBOX_SIZE: Vector3, p: string, SLAM_BLOCK_BREAK: number, targets, fn)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe,
		hitboxSize = SLAM_HITBOX_SIZE,
		checker = Checker,
		targets = targets,
		hitPriorityHandler = {
			callback = v.Exists,
			data = p
		},
		hitDetected = function(instance, p3, p4)
			if not instance then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if not rootPart then
				return
			end

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, SLAM_BLOCK_BREAK)
			elseif p4 == true then
				fn(instance, p3, rootPart)
			end
		end
	})
end

local function startRunLoop(player, character, humanoidRootPart, state, p: number)
	state.capturedVictims = {}
	state.captureCount = 0
	state.runActive = true
	state.runStartedAt = os.clock()
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local stamina = getvaluesfolder and getvaluesfolder:FindFirstChild("Stamina")

	if getvaluesfolder then
		state.drainValue = Utility.AddValue(
			getvaluesfolder,
			"Stamina Drain Rate",
			Config.MAX_DURATION,
			"NumberValue",
			Config.STAMINA_DRAIN_RATE
		)
	end

	local function captureVictim(instance, rootPart, valuesFolder)
		if not state.runActive or state.capturedVictims[instance] then
			return
		end

		local captureCount = state.captureCount
		state.captureCount = captureCount + 1
		local v2 = (captureCount % 2 == 0 and 1 or -1) * math.floor((captureCount + 1) / 2) * Config.WELD_STRIDE
		local v3 = Config.MAX_DURATION + Config.SLAM_AT + 1
		local ouwWeld = Utility.CreateOuwWeld(humanoidRootPart, rootPart, CFrame.new(v2, 0, Config.WELD_FORWARD), v3)
		state.caught = true
		Combat_Util.Damage(script, character, instance, {
			Base = Config.RUN_INITIAL_DAMAGE,
			Skill = script.Parent.Name
		})
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid)
		end

		state.capturedVictims[instance] = {
			root = rootPart,
			valuesFolder = valuesFolder,
			weld = ouwWeld,
			debris = holdCaptive(character, valuesFolder, v3)
		}
	end

	task.spawn(function()
		local now = os.clock()
		local v2 = now + Config.RUN_TICK_INTERVAL

		while state.runActive and not state.cancelled and p == ExecutionScytherServer.Id[player.UserId] do
			local now2 = os.clock()

			if now2 - state.runStartedAt >= Config.MAX_DURATION or not character.Parent or not humanoidRootPart.Parent or stamina and stamina.Value <= 0 then
				break
			end

			local v5 = baseCFrame(character, humanoidRootPart) -- equivalent call inferred; original call site unknown
			state.lastRunLook = v5.LookVector

			if now <= now2 then
				now = now2 + Config.RUN_RESCAN_INTERVAL
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = v5 * Config.RUN_HITBOX_OFFSET,
					hitboxSize = Config.RUN_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					hitDetected = function(instance, valuesFolder, p3)
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
							Combat_Util.Block(script, character, instance, Config.RUN_BLOCK_BREAK)
						elseif p3 == true then
							EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", rootPart, -1)
							captureVictim(instance, rootPart, valuesFolder)
						end
					end
				})
			end

			if v2 <= now2 then
				v2 = now2 + Config.RUN_TICK_INTERVAL

				for k, capturedVictim in state.capturedVictims do
					if k.Parent and capturedVictim.root and capturedVictim.root.Parent and Checker.check_victim(
						script,
						character,
						k
					) ~= nil then
						Combat_Util.Damage(script, character, k, {
							Base = Config.RUN_TICK_DAMAGE,
							Skill = script.Parent.Name
						})
						EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", k.HumanoidRootPart, -1)
						local humanoid = k:FindFirstChild("Humanoid")

						if humanoid then
							Combat_presets.PlayReactAnim(humanoid)
						end
					else
						releaseEntry(capturedVictim)
						state.capturedVictims[k] = nil
					end
				end
			end

			task.wait()
		end

		if state.runActive and not state.cancelled and p == ExecutionScytherServer.Id[player.UserId] then
			stopDrain(state) -- equivalent call inferred; original call site unknown
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
		end
	end)
end

function ExecutionScytherServer.Hold(player, _, p)
	if not player then
		return
	end

	p.cancelled = false
	p.runActive = true
	p.caught = false
	p.capturedVictims = {}
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = ExecutionScytherServer.Id[player.UserId]
	Server_Mouse_Pos.Create_Pos_Part(character, name, Config.MAX_DURATION + 4, humanoidRootPart.Position)
	task.wait(Config.STARTUP)

	if p.cancelled or v2 ~= ExecutionScytherServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		releaseCaptives(p) -- equivalent call inferred; original call site unknown
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
	else
		EffectsEvent.ToAllInRange(player, "Execution Scyther_effs", character, "Startup")
		startRunLoop(player, character, humanoidRootPart, p, v2)
	end
end

function ExecutionScytherServer.UnHold(player, p, state)
	if not player then
		return
	end

	state.runActive = false
	stopDrain(state) -- equivalent call inferred; original call site unknown
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		state.cancelled = false
		local v2 = ExecutionScytherServer.Id[player.UserId]
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder then
			state.pauseValue = Utility.AddValue(
				getvaluesfolder,
				"pause_gameplay",
				Config.SECOND_AOE_AT + Config.FINISHER_ENDLAG + 0.5
			)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearPause()
			if state.pauseValue and state.pauseValue.Parent then
				state.pauseValue:Destroy()
			end

			state.pauseValue = nil
		end

		local v3, signaldestroy = ManuelCancel.new(player, Config.SECOND_AOE_AT + Config.FINISHER_ENDLAG + 1)
		state.signaldestroy = signaldestroy
		v3:Connect(function()
			v2 = -1
			ExecutionScytherServer.Cancel(player, p, state)
			signaldestroy()
		end)

		local function stillValid()
			local v5 = not state.cancelled

			if v5 then
				if v2 == ExecutionScytherServer.Id[player.UserId] then
					return humanoidRootPart.Parent ~= nil
				else
					return false
				end
			end

			return v5
		end

		local function bail()
			releaseCaptives(state) -- equivalent call inferred; original call site unknown
			Server_Mouse_Pos.Delete_Pos_Part(character, name)
			clearPause() -- equivalent call inferred; original call site unknown
			signaldestroy()
		end

		EffectsEvent.ToOthersInRange(player, "Execution Scyther_effs", character, "Hit")
		local now = os.clock()
		task.wait(Config.AIR_TICK_DELAY)
		local v5 = not state.cancelled

		if v5 then
			if v2 == ExecutionScytherServer.Id[player.UserId] then
				v5 = humanoidRootPart.Parent ~= nil
			else
				v5 = false
			end
		end

		if v5 then
			for _, capturedVictim in state.capturedVictims do
				if capturedVictim.weld and capturedVictim.weld.Parent then
					capturedVictim.weld:Destroy()
				end

				capturedVictim.weld = nil
			end

			local v6 = os.clock() + Config.AIR_TICK_DURATION

			while true do
				local v7 = not state.cancelled

				if v7 then
					if v2 == ExecutionScytherServer.Id[player.UserId] then
						v7 = humanoidRootPart.Parent ~= nil
					else
						v7 = false
					end
				end

				if v7 then
					for k, capturedVictim in state.capturedVictims do
						if k.Parent and capturedVictim.root and capturedVictim.root.Parent and Checker.check_victim(
							script,
							character,
							k
						) ~= nil then
							Combat_Util.Damage(script, character, k, {
								Base = Config.AIR_TICK_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_Util.AddStun(script, character, capturedVictim.valuesFolder, Config.AIR_TICK_STUN)
							Combat_Util.Knockback(
								script,
								character,
								capturedVictim.root,
								Vector3.new(0, Config.AIR_TICK_KNOCKUP, 0),
								Config.AIR_TICK_KNOCK_DURATION
							)
							local humanoid = k:FindFirstChild("Humanoid")

							if humanoid then
								Combat_presets.PlayReactAnim(humanoid)
							end
						else
							releaseEntry(capturedVictim)
							state.capturedVictims[k] = nil
						end
					end

					local v8 = v6 - os.clock()

					if v8 <= 0 then
						local v9 = not state.cancelled

						if v9 then
							if v2 == ExecutionScytherServer.Id[player.UserId] then
								v9 = humanoidRootPart.Parent ~= nil
							else
								v9 = false
							end
						end

						if v9 then
							local v10 = now + Config.SLAM_AT - os.clock()

							if v10 > 0 then
								task.wait(v10)
							end

							local v11 = not state.cancelled

							if v11 then
								if v2 == ExecutionScytherServer.Id[player.UserId] then
									v11 = humanoidRootPart.Parent ~= nil
								else
									v11 = false
								end
							end

							if v11 then
								local targets = {}

								for k in state.capturedVictims do
									table.insert(targets, k)
								end

								releaseCaptives(state) -- equivalent call inferred; original call site unknown
								task.wait()
								local v13 = not state.cancelled

								if v13 then
									if v2 == ExecutionScytherServer.Id[player.UserId] then
										v13 = humanoidRootPart.Parent ~= nil
									else
										v13 = false
									end
								end

								if v13 then
									EffectsEvent.ToAllInRange(player, "Execution Scyther_effs", character, "Slam")
									local v14 = baseCFrame(character, humanoidRootPart) -- equivalent call inferred; original call site unknown
									local vector2 = Vector3.new(v14.LookVector.X, 0, v14.LookVector.Z)
									local unit = vector2.Magnitude > 0.001 and vector2.Unit or v14.LookVector
									local raycastResult = workspace:Raycast(
										v14.Position + createVector(0, 5, 0),
										createVector(-0, -60, -0),
										RaycastHelper.Crater
									)
									local position = raycastResult and raycastResult.Position or v14.Position
									aoeHit(
										character,
										CFrame.lookAt(position, position + unit) * Config.SLAM_HITBOX_OFFSET,
										Config.SLAM_HITBOX_SIZE,
										"Choosing_2",
										Config.SLAM_BLOCK_BREAK,
										targets,
										function(p2, p3, p4)
											Combat_Util.Damage(script, character, p2, {
												Base = Config.SLAM_DAMAGE,
												Skill = script.Parent.Name
											})
											Combat_Util.AddStun(script, character, p3, Config.SLAM_STUN)
											Combat_Util.RagDoll(script, character, p3, Config.SLAM_STUN)
											local v16 = unit * Config.SLAM_KNOCKBACK
											Combat_Util.Knockback(
												script,
												character,
												p4,
												Vector3.new(v16.X, Config.SLAM_KNOCKUP, v16.Z),
												0.3
											)
										end
									)
									task.wait(Config.SECOND_AOE_AT - Config.SLAM_AT)
									local v16 = not state.cancelled

									if v16 then
										if v2 == ExecutionScytherServer.Id[player.UserId] then
											v16 = humanoidRootPart.Parent ~= nil
										else
											v16 = false
										end
									end

									if v16 then
										EffectsEvent.ToAllInRange(player, "Execution Scyther_effs", character, "Cross")
										task.wait(Config.FINISHER_ENDLAG)
									end

									releaseCaptives(state) -- equivalent call inferred; original call site unknown
									Server_Mouse_Pos.Delete_Pos_Part(character, name)
									clearPause() -- equivalent call inferred; original call site unknown
									signaldestroy()
									return
								end
							end

							releaseCaptives(state) -- equivalent call inferred; original call site unknown
							Server_Mouse_Pos.Delete_Pos_Part(character, name)
							clearPause() -- equivalent call inferred; original call site unknown
							signaldestroy()
							return
						end
					else
						task.wait((math.min(Config.AIR_TICK_INTERVAL, v8)))
						continue
					end
				end

				releaseCaptives(state) -- equivalent call inferred; original call site unknown
				Server_Mouse_Pos.Delete_Pos_Part(character, name)
				clearPause() -- equivalent call inferred; original call site unknown
				signaldestroy()
				return
			end
		else
			releaseCaptives(state) -- equivalent call inferred; original call site unknown
			Server_Mouse_Pos.Delete_Pos_Part(character, name)
			clearPause() -- equivalent call inferred; original call site unknown
			signaldestroy()
		end
	else
		releaseCaptives(state) -- equivalent call inferred; original call site unknown
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
	end
end

function ExecutionScytherServer.Cancel(player, _, state)
	if not player then
		return
	end

	if state then
		state.cancelled = true
		state.runActive = false
		stopDrain(state) -- equivalent call inferred; original call site unknown
		releaseCaptives(state) -- equivalent call inferred; original call site unknown

		if state.pauseValue and state.pauseValue.Parent then
			state.pauseValue:Destroy()
		end

		state.pauseValue = nil

		if state.signaldestroy then
			state.signaldestroy()
			state.signaldestroy = nil
		end
	end

	local character = player.Character

	if character then
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
		EffectsEvent.ToAllInRange(player, "Execution Scyther_effs", character, "Cancel")
	end
end

return ExecutionScytherServer