local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local ScytherVortexServer = {
	Id = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function tickDamageForDuration(DURATION: number)
	local v2 = math.floor(DURATION / Config.CAPTURE_TICK_INTERVAL)

	if v2 <= 0 then
		return 0
	end

	return (math.max(0, (Config.TOTAL_DAMAGE - Config.CAPTURE_INITIAL_DAMAGE - Config.BURST_DAMAGE) / v2))
end

local function runStaticCyclone(player, character, position: Vector3, state, p: number)
	local name = player.Name .. "ScytherVortex_captured--"
	local child = character:FindFirstChild(name)

	if child then
		child:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = character
	state.capturedFolder = folder
	state.capturedDebris = {}
	state.victimPauseValues = {}
	state.victimIframeValues = {}
	state.victimNoRagdollValues = {}
	state.victimLinesValues = {}
	local flag = false
	local base = tickDamageForDuration(Config.DURATION) -- equivalent call inferred; original call site unknown

	local function finishCyclone(flag2: boolean)
		if flag then
			return
		end

		flag = true

		if flag2 and character.Parent then
			EffectsEvent.ToAllInRange(player, "Scyther Vortex_effs", character, "End")
		end

		if flag2 and folder.Parent then
			for _, child2 in folder:GetChildren() do
				local value = child2.Value

				if not (value and value.Parent) then
					continue
				end

				local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")
				local getvaluesfolder = Utility.getvaluesfolder(value)

				if not (humanoidRootPart and getvaluesfolder) then
					continue
				end

				local ALP = humanoidRootPart:FindFirstChild("ALP")

				if ALP then
					ALP:Destroy()
				end

				local victimPauseValue = state.victimPauseValues[value]

				if victimPauseValue and victimPauseValue.Parent then
					victimPauseValue:Destroy()
				end

				state.victimPauseValues[value] = nil
				local victimIframeValue = state.victimIframeValues[value]

				if victimIframeValue and victimIframeValue.Parent then
					victimIframeValue:Destroy()
				end

				state.victimIframeValues[value] = nil
				local victimNoRagdollValue = state.victimNoRagdollValues[value]
				local victimLinesValue = state.victimLinesValues[value]

				if victimNoRagdollValue and victimNoRagdollValue.Parent then
					victimNoRagdollValue:Destroy()
				end

				if victimLinesValue and victimLinesValue.Parent then
					victimLinesValue:Destroy()
				end

				state.victimNoRagdollValues[value] = nil
				state.victimLinesValues[value] = nil
				Combat_Util.Damage(script, character, value, {
					Base = Config.BURST_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, getvaluesfolder, Config.BURST_STUN)
				Combat_Util.AddStun(script, character, getvaluesfolder, Config.BURST_STUN)
				local v4 = humanoidRootPart.Position - position
				local vector2 = Vector3.new(v4.X, 0, v4.Z)
				local v5 = not (vector2.Magnitude > 0.001) and createVector(0, 0, -1) or vector2.Unit
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart,
					v5 * Config.BURST_KNOCKBACK + Vector3.new(0, Config.BURST_KNOCKUP, 0),
					0.15
				)
			end
		end

		for _, victimPauseValue in state.victimPauseValues do
			if victimPauseValue and victimPauseValue.Parent then
				victimPauseValue:Destroy()
			end
		end

		state.victimPauseValues = nil

		for _, victimIframeValue in state.victimIframeValues do
			if victimIframeValue and victimIframeValue.Parent then
				victimIframeValue:Destroy()
			end
		end

		state.victimIframeValues = nil

		for _, victimNoRagdollValue in state.victimNoRagdollValues do
			if victimNoRagdollValue and victimNoRagdollValue.Parent then
				victimNoRagdollValue:Destroy()
			end
		end

		for _, victimLinesValue in state.victimLinesValues do
			if victimLinesValue and victimLinesValue.Parent then
				victimLinesValue:Destroy()
			end
		end

		state.victimNoRagdollValues = nil
		state.victimLinesValues = nil

		for _, v4 in state.capturedDebris do
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end

		state.capturedDebris = nil

		if folder.Parent then
			folder.Name = "--"
			DebrisModule:AddItem(folder, 0.5)
		end

		state.capturedFolder = nil
	end

	local function captureVictim(instance, rootPart, p2)
		if flag then
			return
		end

		for _, child2 in folder:GetChildren() do
			if child2.Value == instance then
				return
			end
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = instance.Name
		objectValue.Value = instance
		objectValue.Parent = folder
		local attachment = Instance.new("Attachment")
		attachment.Name = "ALP"
		attachment.Parent = rootPart
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "P"
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.MaxForce = 200000
		alignPosition.Responsiveness = 100
		local _, v4 = Utility.SafeLookAt(position, rootPart.Position, CFrame.new(position)):ToOrientation()
		alignPosition.Position = position + CFrame.Angles(0, v4, 0) * Config.SPIN_OFFSET
		alignPosition.Parent = attachment
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Rot"
		numberValue.Value = v4
		numberValue.Parent = attachment
		local add_Strict_Stun = Combat_Util.Add_Strict_Stun(script, character, p2, Config.CAPTURE_STRICT_STUN)
		local v5 = Utility.AddValue(p2, "pause_gameplay", Config.CAPTURE_STRICT_STUN)
		local v6 = Utility.AddValue(p2, "iframe", Config.CAPTURE_STRICT_STUN)
		local v7 = Utility.AddValue(p2, "noragdoll", Config.CAPTURE_STRICT_STUN)
		local v8 = Utility.AddValue(p2, "NOMouvementlines", Config.CAPTURE_STRICT_STUN)
		Combat_Util.Damage(script, character, instance, {
			Base = Config.CAPTURE_INITIAL_DAMAGE,
			Skill = script.Parent.Name
		})
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid)
		end

		table.insert(state.capturedDebris, attachment)

		if add_Strict_Stun then
			table.insert(state.capturedDebris, add_Strict_Stun)
		end

		state.victimPauseValues[instance] = v5
		state.victimIframeValues[instance] = v6
		state.victimNoRagdollValues[instance] = v7
		state.victimLinesValues[instance] = v8

		if Players:GetPlayerFromCharacter(instance) == nil then
			pcall(function()
				rootPart:SetNetworkOwner(player)
			end)
		end
	end

	local function acquire()
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position) * Config.HITBOX_OFFSET,
			hitboxSize = Config.TORNADO_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_SV_Capture"
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
					Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
				elseif p3 == true then
					captureVictim(instance, rootPart, p2)
				end
			end
		})
	end

	task.spawn(function()
		local now = os.clock()
		local v4 = now + Config.CAPTURE_TICK_INTERVAL
		local v5 = now + Config.DURATION

		while p == ScytherVortexServer.Id[player.UserId] and not flag do
			local now2 = os.clock()

			if v5 <= now2 or not character.Parent then
				break
			end

			if now <= now2 then
				now = now2 + Config.RESCAN_INTERVAL
				acquire()
			end

			local v6 = v4 <= now2

			if v6 then
				v4 = now2 + Config.CAPTURE_TICK_INTERVAL
			end

			for _, v7 in state.capturedDebris do
				if not (v7.Name == "ALP" and v7.Parent) then
					continue
				end

				local rot = v7:FindFirstChild("Rot")
				local P = v7:FindFirstChild("P")

				if not (rot and P) then
					continue
				end

				local v8 = rot.Value + Config.SPIN_INCREMENT
				rot.Value = v8
				P.Position = position + Vector3.new(0, v8 * Config.SPIN_RISE_RATE, 0) + CFrame.Angles(0, -v8, 0) * Config.SPIN_OFFSET
			end

			if v6 and folder.Parent then
				for _, child2 in folder:GetChildren() do
					local value = child2.Value

					if value and value.Parent and Checker.check_victim(script, character, value, {
						iframe = true
					}) ~= nil then
						Combat_Util.Damage(script, character, value, {
							Base = base,
							Skill = script.Parent.Name
						})
						local humanoid = value:FindFirstChild("Humanoid")

						if humanoid then
							Combat_presets.PlayReactAnim(humanoid)
						end
					else
						child2:Destroy()

						if value then
							local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")
							local ALP = humanoidRootPart and humanoidRootPart:FindFirstChild("ALP")

							if ALP then
								ALP:Destroy()
							end

							local v7 = state.victimPauseValues and state.victimPauseValues[value]

							if v7 and v7.Parent then
								v7:Destroy()
							end

							if state.victimPauseValues then
								state.victimPauseValues[value] = nil
							end

							local v8 = state.victimIframeValues and state.victimIframeValues[value]

							if v8 and v8.Parent then
								v8:Destroy()
							end

							if state.victimIframeValues then
								state.victimIframeValues[value] = nil
							end

							local v9 = state.victimNoRagdollValues and state.victimNoRagdollValues[value]
							local v10 = state.victimLinesValues and state.victimLinesValues[value]

							if v9 and v9.Parent then
								v9:Destroy()
							end

							if v10 and v10.Parent then
								v10:Destroy()
							end

							if state.victimNoRagdollValues then
								state.victimNoRagdollValues[value] = nil
							end

							if state.victimLinesValues then
								state.victimLinesValues[value] = nil
							end
						end
					end
				end
			end

			task.wait()
		end

		if not flag then
			finishCyclone(true)
		end
	end)
end

function ScytherVortexServer.Hold(_, _, p)
	if p then
		p.released = false
	end
end

function ScytherVortexServer.UnHold(player, p, p2)
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

	local v2 = ScytherVortexServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 2)
	v3:Connect(function(...)
		v4()
		ScytherVortexServer.Id[player.UserId] = -1
		ScytherVortexServer.Cancel(player)
	end)
	p2.released = true
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder then
		p2.selfPause = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SELF_LOCK_DURATION)
	end

	local unit = nil

	if typeof(p) == "Vector3" then
		local v5 = p - humanoidRootPart.Position
		local vector2 = Vector3.new(v5.X, 0, v5.Z)

		if vector2.Magnitude > 0.001 then
			unit = vector2.Unit
		end
	end

	if not unit then
		unit = humanoidRootPart.CFrame.LookVector
		local vector2 = Vector3.new(unit.X, 0, unit.Z)

		if vector2.Magnitude > 0.001 then
			unit = vector2.Unit or unit
		end
	end

	local cframe = CFrame.lookAt(
		humanoidRootPart.Position + unit * Config.TORNADO_FORWARD,
		humanoidRootPart.Position + unit * (Config.TORNADO_FORWARD + 1)
	)
	EffectsEvent.ToAllInRange(player, "Scyther Vortex_effs", character, "Tornado", cframe)
	task.wait(Config.RELEASE_WINDUP)

	if ScytherVortexServer.Id[player.UserId] ~= v2 then
		return
	end

	runStaticCyclone(player, character, cframe.Position, p2, v2)
	task.wait(0.4875)

	if ScytherVortexServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Scyther Vortex_effs", character, "JumpBack")
end

function ScytherVortexServer.Cancel(p, _, p2)
	if not p then
		return
	end

	if p2 and p2.released then
	end
end

return ScytherVortexServer