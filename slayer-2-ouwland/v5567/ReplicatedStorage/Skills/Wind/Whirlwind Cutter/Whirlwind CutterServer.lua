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
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local ServerClientPortal = require(global.ServerClientPortal)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local RaycastHelper = require(global.RaycastHelper)
local Config = require(script.Parent.Config)
local WhirlwindCutterServer = {
	Id = {}
}
local v2 = Config.HOLD_MAX_DURATION + Config.FINISHER_LOCK_DURATION + 1

-- equivalent calls inferred from this helper; original call sites unknown
local function dropTransparent(state)
	if state.transparentValue then
		state.transparentValue:Destroy()
		state.transparentValue = nil
	end
end

local function startHoldLoop(player, character, humanoidRootPart, state, p: number)
	state.capturedVictims = {}
	state.captureCount = 0
	state.holdActive = true
	state.holdStartedAt = os.clock()
	state.transparentValue = nil

	function state.releaseCaptives()
		for k, capturedVictim in state.capturedVictims do
			if capturedVictim.weld then
				capturedVictim.weld:Destroy()
			end

			for _, v3 in capturedVictim.debris do
				if v3 then
					v3:Destroy()
				end
			end

			state.capturedVictims[k] = nil
		end
	end

	task.delay(Config.HOLD_TRANSPARENT_DELAY, function()
		if not (state.holdActive and p == WhirlwindCutterServer.Id[player.UserId]) then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder then
			state.transparentValue = Utility.AddValue(getvaluesfolder, "Transparent", Config.HOLD_MAX_DURATION + 1)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Hold")
	end)

	local function captureVictim(instance, rootPart, valuesFolder)
		if not state.holdActive or state.capturedVictims[instance] then
			return
		end

		local captureCount = state.captureCount
		state.captureCount = captureCount + 1
		local v3 = (captureCount % 2 == 0 and 1 or -1) * math.floor((captureCount + 1) / 2) * Config.WELD_STRIDE
		local ouwWeld = Utility.CreateOuwWeld(humanoidRootPart, rootPart, CFrame.new(v3, 0, Config.WELD_FORWARD))
		local v4 = Utility.AddValue(valuesFolder, "pause_gameplay", Config.HOLD_STRICT_STUN_TOPUP)
		local v5 = Utility.AddValue(valuesFolder, "noragdoll", Config.HOLD_STRICT_STUN_TOPUP)
		local add_Strict_Stun = Combat_Util.Add_Strict_Stun(
			script,
			character,
			valuesFolder,
			Config.HOLD_STRICT_STUN_TOPUP
		)
		local v6 = Utility.AddValue(
			valuesFolder,
			"iframe",
			Config.HOLD_STRICT_STUN_TOPUP,
			"StringValue",
			character.Name
		)
		local v7 = Utility.AddValue(valuesFolder, "NOMouvementlines", Config.HOLD_MAX_DURATION + 1)
		Combat_Util.Damage(script, character, instance, {
			Base = Config.HOLD_INITIAL_DAMAGE,
			Skill = script.Parent.Name
		})
		state.capturedVictims[instance] = {
			weld = ouwWeld,
			root = rootPart,
			valuesFolder = valuesFolder,
			debris = {
				v4,
				v5,
				add_Strict_Stun,
				v6,
				v7
			}
		}
	end

	task.spawn(function()
		local now = os.clock()
		local v3 = now + Config.HOLD_TRANSPARENT_DELAY
		local v4 = now + Config.HOLD_TRANSPARENT_DELAY + Config.HOLD_TICK_INTERVAL

		while state.holdActive and p == WhirlwindCutterServer.Id[player.UserId] do
			local now2 = os.clock()

			if now2 - state.holdStartedAt >= Config.HOLD_MAX_DURATION or not (character.Parent and humanoidRootPart.Parent) then
				break
			end

			if v3 <= now2 then
				v3 = now2 + Config.HOLD_RESCAN_INTERVAL
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = humanoidRootPart.CFrame * Config.HOLD_HITBOX_OFFSET,
					hitboxSize = Config.HOLD_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_WC_Capture"
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
							Combat_Util.Block(script, character, instance, Config.HOLD_BLOCK_BREAK)
						elseif p3 == true then
							captureVictim(instance, rootPart, valuesFolder)
						end
					end
				})
			end

			if v4 <= now2 then
				v4 = now2 + Config.HOLD_TICK_INTERVAL

				for k, capturedVictim in state.capturedVictims do
					if k.Parent and capturedVictim.root and capturedVictim.root.Parent and Checker.check_victim(
						script,
						character,
						k
					) ~= nil then
						Combat_Util.Damage(script, character, k, {
							Base = Config.HOLD_TICK_DAMAGE,
							Skill = script.Parent.Name
						})
					else
						if capturedVictim.weld then
							capturedVictim.weld:Destroy()
						end

						for _, v5 in capturedVictim.debris do
							if v5 then
								v5:Destroy()
							end
						end

						state.capturedVictims[k] = nil
					end
				end
			end

			task.wait()
		end
	end)
end

local function playFinal(_, character, cframe: CFrame, _, _: number, targets)
	local lookVector = cframe.LookVector
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe * Config.HOLD_HITBOX_OFFSET,
		hitboxSize = Config.FINAL_HIT_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_WC_Final"
		},
		targets = targets,
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
				Combat_Util.Block(script, character, instance, Config.FINAL_HIT_BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINAL_HIT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, p2, Config.FINAL_HIT_STUN)
				Combat_Util.AddStun(script, character, p2, Config.FINAL_HIT_STUN)
				Combat_Util.Add_Strict_Stun(script, character, p2, Config.FINAL_HIT_STRICT_STUN, true)
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					lookVector * Config.FINAL_HIT_KNOCKBACK + vector.create(0, Config.FINAL_HIT_KNOCKUP, 0),
					Config.FINAL_HIT_KNOCKBACK_DURATION
				)
			end
		end
	})
end

function WhirlwindCutterServer.Hold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Start")
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder then
		p2.skillPauseValue = Utility.AddValue(
			getvaluesfolder,
			"pause_gameplay",
			Config.HOLD_MAX_DURATION + Config.FINISHER_LOCK_DURATION + 1
		)
	end

	local v3 = WhirlwindCutterServer.Id[player.UserId]
	local v4, signaldestroy = ManuelCancel.new(player, v2 + 0.5, nil, script.Parent.Name)
	p2.signaldestroy = signaldestroy
	v4:Connect(function()
		v3 = -1
		WhirlwindCutterServer.Cancel(player, p, p2)
		signaldestroy()
	end)
	startHoldLoop(player, character, humanoidRootPart, p2, v3)
end

function WhirlwindCutterServer.UnHold(player, p, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v3 = WhirlwindCutterServer.Id[player.UserId]

	if state.signaldestroy then
		state.signaldestroy()
	end

	local v4, signaldestroy = ManuelCancel.new(player, v2 + 0.5)
	state.signaldestroy = signaldestroy
	v4:Connect(function()
		v3 = -1
		WhirlwindCutterServer.Cancel(player, p, state)
		signaldestroy()
	end)
	state.holdActive = false
	dropTransparent(state) -- equivalent call inferred; original call site unknown
	local targets = {}

	if state.capturedVictims then
		for k in state.capturedVictims do
			table.insert(targets, k)
		end
	end

	local _, v7 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 2, 0),
		createVector(-0, -25, -0),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local v8 = not humanoid and 2 or humanoid.HipHeight
		position = raycastResult.Position + Vector3.new(0, v8 + humanoidRootPart.Size.Y / 2, 0)
	end

	local v8 = CFrame.new(position) * CFrame.Angles(0, v7, 0)

	if state.releaseCaptives then
		state.releaseCaptives()
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Release")

	if #targets == 0 then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local track, length

		if animator then
			track = animator:LoadAnimation(script.ReleaseMissed)
			track:Play()
			state.releaseTrack = track
			length = track.Length
		else
			length = 0
		end

		task.wait(Config.MISS_HITBOX_DELAY)

		if not (v3 == WhirlwindCutterServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
			return
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.MISS_HITBOX_OFFSET,
			hitboxSize = Config.MISS_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_WC_Miss"
			},
			hitDetected = function(instance, _, p2)
				if not instance then
					return
				end

				local humanoid2 = instance:FindFirstChild("Humanoid")

				if not (humanoid2 and humanoid2.RootPart) then
					return
				end

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.HOLD_BLOCK_BREAK)
				elseif p2 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.HOLD_INITIAL_DAMAGE,
						Skill = script.Parent.Name
					})
					table.insert(targets, instance)
				end
			end
		})

		if #targets == 0 then
			EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Missed")
			ServerClientPortal.ToClient(
				player,
				script.Parent.Name,
				false,
				(math.max(length - Config.MISS_HITBOX_DELAY, 0))
			)
			task.wait((math.max(length - Config.MISS_HITBOX_DELAY, 0)))

			if v3 ~= WhirlwindCutterServer.Id[player.UserId] then
				return
			end

			state.releaseTrack = nil

			if state.skillPauseValue then
				state.skillPauseValue:Destroy()
				state.skillPauseValue = nil
			end

			if state.signaldestroy then
				state.signaldestroy()
				state.signaldestroy = nil
			end

			return
		elseif track then
			track:Stop()
			track:Destroy()
			state.releaseTrack = nil
		end
	end

	ServerClientPortal.ToClient(player, script.Parent.Name, true)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	for _, v9 in targets do
		local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")
		local air_combo_bp2 = humanoidRootPart2 and humanoidRootPart2:FindFirstChild("air_combo_bp")

		if air_combo_bp2 then
			air_combo_bp2:Destroy()
		end
	end

	task.wait()

	if not (v3 == WhirlwindCutterServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
		return
	end

	local v9 = {}
	local tracks = {}
	local releaseGrab

	releaseGrab = function()
		for _, v10 in v9 do
			if v10.Parent ~= nil then
				v10:Destroy()
			end
		end

		table.clear(v9)

		for _, v10 in tracks do
			v10:Stop()
			v10:Destroy()
		end

		table.clear(tracks)

		if state.releaseGrab == releaseGrab then
			state.releaseGrab = nil
		end
	end

	state.releaseGrab = releaseGrab
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local v10 = Utility.lock(humanoidRootPart, v8, Config.FINAL_CASTER_LOCK_DURATION)
	local v11 = {}
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		for _, v12 in { "skill_stand_still", "NR", "iframe" } do
			table.insert(v11, Utility.AddValue(getvaluesfolder, v12, Config.FINAL_CASTER_LOCK_DURATION))
		end
	end

	local releaseCaster

	releaseCaster = function()
		if v10 ~= nil and v10.Parent ~= nil then
			v10:Destroy()
		end

		v10 = nil

		for _, v12 in v11 do
			if v12.Parent ~= nil then
				v12:Destroy()
			end
		end

		table.clear(v11)

		if state.releaseCaster == releaseCaster then
			state.releaseCaster = nil
		end
	end

	state.releaseCaster = releaseCaster

	for _, v12 in targets do
		if not v12.Parent then
			continue
		end

		local humanoidRootPart2 = v12:FindFirstChild("HumanoidRootPart")
		local getvaluesfolder2 = Utility.getvaluesfolder(v12)

		if not (humanoidRootPart2 and getvaluesfolder2) then
			continue
		end

		for _, v13 in {
			"pause_gameplay",
			"iframe",
			"skill_stand_still",
			"NR"
		} do
			table.insert(v9, Utility.AddValue(getvaluesfolder2, v13, Config.FINAL_GRAB_DURATION))
		end

		Combat_Util.Damage(script, character, v12, {
			Base = Config.GRAB_DAMAGE,
			Skill = script.Parent.Name
		})
		humanoidRootPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart2.AssemblyAngularVelocity = createVector(0, 0, 0)
		table.insert(v9, Utility.lock(humanoidRootPart2, v8, Config.FINAL_GRAB_DURATION))
		local humanoid = v12:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			continue
		end

		local track = animator:LoadAnimation(script.Victim)
		track:Play()
		table.insert(tracks, track)
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Grab", v8, targets)
	local now = os.clock()
	local animator = character:FindFirstChild("Animator", true)

	if animator then
		local track = animator:LoadAnimation(script.Release)
		track:Play()
		state.releaseTrack = track
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function waitUntil(p2: number)
		local v12 = now + p2 - os.clock()

		if v12 > 0 then
			task.wait(v12)
		end
	end

	waitUntil(Config.FINAL_WINDUP_DELAY) -- equivalent call inferred; original call site unknown

	if not (v3 == WhirlwindCutterServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Final")
	waitUntil(Config.FINAL_HIT_AT - 0.016666666666666666) -- equivalent call inferred; original call site unknown

	if not (v3 == WhirlwindCutterServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
		return
	end

	releaseGrab()
	waitUntil(Config.FINAL_HIT_AT) -- equivalent call inferred; original call site unknown

	if not (v3 == WhirlwindCutterServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
		return
	end

	playFinal(player, character, v8, state, v3, targets)
	waitUntil(Config.FINAL_CASTER_FREE_AT) -- equivalent call inferred; original call site unknown

	if v3 ~= WhirlwindCutterServer.Id[player.UserId] then
		return
	end

	state.releaseTrack = nil
	releaseCaster()

	if state.skillPauseValue then
		state.skillPauseValue:Destroy()
		state.skillPauseValue = nil
	end

	if state.signaldestroy then
		state.signaldestroy()
		state.signaldestroy = nil
	end
end

function WhirlwindCutterServer.Cancel(player, _, state)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Whirlwind CutterVFX", character, "Cancel")
	end

	if state then
		state.holdActive = false
		dropTransparent(state) -- equivalent call inferred; original call site unknown

		if state.releaseCaptives then
			state.releaseCaptives()
		end

		if state.releaseTrack then
			state.releaseTrack:Stop()
			state.releaseTrack:Destroy()
			state.releaseTrack = nil
		end

		if state.releaseGrab then
			state.releaseGrab()
		end

		if state.releaseCaster then
			state.releaseCaster()
		end

		if state.skillPauseValue then
			state.skillPauseValue:Destroy()
			state.skillPauseValue = nil
		end
	end
end

return WhirlwindCutterServer