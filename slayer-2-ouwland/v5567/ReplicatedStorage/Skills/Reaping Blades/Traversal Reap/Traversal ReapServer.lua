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
local TraversalReapServer = {
	Id = {}
}
local name = script.Parent.Name

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
local function releaseCaptives(p)
	if not p.capturedVictims then
		return
	end

	for k, capturedVictim in p.capturedVictims do
		releaseEntry(capturedVictim)
		p.capturedVictims[k] = nil
	end
end

local function startHoldLoop(player, character, humanoidRootPart, state, p: number)
	state.capturedVictims = {}
	state.captureCount = 0
	state.holdActive = true
	state.holdStartedAt = os.clock()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function liveCFrame()
		local _, v2 = Server_Mouse_Pos.Aim(character, name, 15)
		return v2 or humanoidRootPart.CFrame
	end

	local function holdCaptive(p2)
		return {
			Utility.AddValue(p2, "pause_gameplay", Config.HOLD_STRICT_STUN_TOPUP),
			Utility.AddValue(p2, "noragdoll", Config.HOLD_STRICT_STUN_TOPUP),
			Combat_Util.Add_Strict_Stun(script, character, p2, Config.HOLD_STRICT_STUN_TOPUP),
			Utility.AddValue(p2, "iframe", Config.HOLD_STRICT_STUN_TOPUP, "StringValue", character.Name)
		}
	end

	local function captureVictim(instance, rootPart, valuesFolder)
		if not state.holdActive or state.capturedVictims[instance] then
			return
		end

		local captureCount = state.captureCount
		state.captureCount = captureCount + 1
		local v2 = (captureCount % 2 == 0 and 1 or -1) * math.floor((captureCount + 1) / 2) * Config.WELD_STRIDE
		local ouwWeld = Utility.CreateOuwWeld(humanoidRootPart, rootPart, CFrame.new(v2, 0, Config.WELD_FORWARD))
		Combat_Util.Damage(script, character, instance, {
			Base = Config.HOLD_INITIAL_DAMAGE,
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
			debris = holdCaptive(valuesFolder)
		}
	end

	task.spawn(function()
		local now = os.clock()
		local v2 = now + Config.HOLD_TICK_INTERVAL

		while state.holdActive and not state.cancelled and p == TraversalReapServer.Id[player.UserId] do
			local now2 = os.clock()

			if now2 - state.holdStartedAt >= Config.MAX_DURATION or not (character.Parent and humanoidRootPart.Parent) then
				break
			end

			local v3 = liveCFrame() -- equivalent call inferred; original call site unknown
			state.lastDashLook = v3.LookVector

			if now <= now2 then
				now = now2 + Config.HOLD_RESCAN_INTERVAL
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = v3 * Config.HOLD_HITBOX_OFFSET,
					hitboxSize = Config.HOLD_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_TR_Capture"
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

			if v2 <= now2 then
				v2 = now2 + Config.HOLD_TICK_INTERVAL

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
						local humanoid = k:FindFirstChild("Humanoid")

						if humanoid then
							Combat_presets.PlayReactAnim(humanoid)
						end

						for _, v4 in capturedVictim.debris do
							if v4 and v4.Parent then
								v4:Destroy()
							end
						end

						capturedVictim.debris = holdCaptive(capturedVictim.valuesFolder)
					else
						releaseEntry(capturedVictim)
						state.capturedVictims[k] = nil
					end
				end
			end

			task.wait()
		end

		Server_Mouse_Pos.Delete_Pos_Part(character, name)

		if state.holdActive and not state.cancelled and p == TraversalReapServer.Id[player.UserId] then
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
		end
	end)
end

function TraversalReapServer.Hold(player, p, p2)
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

	p2.cancelled = false
	EffectsEvent.ToAllInRange(player, "Traversal Reap_effs", character, "Initiate")
	local v2 = TraversalReapServer.Id[player.UserId]
	local v3, signaldestroy = ManuelCancel.new(player, Config.MAX_DURATION + 0.5)
	p2.signaldestroy = signaldestroy
	v3:Connect(function()
		v2 = -1
		TraversalReapServer.Cancel(player, p, p2)
		signaldestroy()
	end)
	Server_Mouse_Pos.Create_Pos_Part(character, name, Config.MAX_DURATION + 1, humanoidRootPart.Position)
	task.wait(Config.STARTUP)

	if p2.cancelled or v2 ~= TraversalReapServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
		signaldestroy()
	else
		EffectsEvent.ToAllInRange(player, "Traversal Reap_effs", character, "Start")
		startHoldLoop(player, character, humanoidRootPart, p2, v2)
	end
end

function TraversalReapServer.UnHold(player, _, state)
	if not player then
		return
	end

	state.holdActive = false
	local character = player.Character

	if not character then
		return
	end

	Server_Mouse_Pos.Delete_Pos_Part(character, name)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		EffectsEvent.ToAllInRange(player, "Traversal Reap_effs", character, "End")
	end

	if state.cancelled or not humanoidRootPart then
		releaseCaptives(state) -- equivalent call inferred; original call site unknown

		if state.signaldestroy then
			state.signaldestroy()
			state.signaldestroy = nil
		end
	else
		local v2 = TraversalReapServer.Id[player.UserId]
		local v3 = {}

		if state.capturedVictims then
			for k in state.capturedVictims do
				table.insert(v3, k)
			end
		end

		releaseCaptives(state) -- equivalent call inferred; original call site unknown
		task.wait()

		if v2 == TraversalReapServer.Id[player.UserId] and character.Parent and humanoidRootPart.Parent then
			local lastDashLook = state.lastDashLook or humanoidRootPart.CFrame.LookVector
			local vector2 = Vector3.new(lastDashLook.X, 0, lastDashLook.Z)
			local unit = vector2.Magnitude > 0 and vector2.Unit or createVector(0, 0, -1)

			for _, v4 in v3 do
				if not v4.Parent then
					continue
				end

				local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					continue
				end

				local getvaluesfolder = Utility.getvaluesfolder(v4)

				if not (getvaluesfolder and Checker.check_victim(script, character, v4) ~= nil) then
					continue
				end

				Combat_Util.Damage(script, character, v4, {
					Base = Config.FINAL_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, getvaluesfolder, Config.FINAL_STUN)
				Combat_Util.RagDoll(script, character, getvaluesfolder, Config.FINAL_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.FINAL_KNOCKBACK + Vector3.new(0, Config.FINAL_KNOCK_UP, 0),
					0.15
				)
				local humanoid = v4:FindFirstChild("Humanoid")

				if humanoid then
					Combat_presets.PlayReactAnim(humanoid)
				end
			end

			if state.signaldestroy then
				state.signaldestroy()
				state.signaldestroy = nil
			end
		elseif state.signaldestroy then
			state.signaldestroy()
			state.signaldestroy = nil
		end
	end
end

function TraversalReapServer.Cancel(player, _, p)
	if not player then
		return
	end

	if p then
		p.cancelled = true
		p.holdActive = false
		releaseCaptives(p) -- equivalent call inferred; original call site unknown

		if p.signaldestroy then
			p.signaldestroy()
			p.signaldestroy = nil
		end
	end

	local character = player.Character

	if character then
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
		EffectsEvent.ToAllInRange(player, "Traversal Reap_effs", character, "Cancel")
	end
end

return TraversalReapServer