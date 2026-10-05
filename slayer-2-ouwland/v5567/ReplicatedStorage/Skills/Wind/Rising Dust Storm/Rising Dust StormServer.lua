local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local Checker = require(global.Checker)
local Utility = require(global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local ProjectileModeler = require(global.ProjectileModeler)
local PartBox = require(global.PartBox)
local DebrisModule = require(CAM.DebrisModule)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local RisingDustStormServer = {
	Id = {}
}
local v2 = Config.PRE_RELEASE_DELAY + math.max(Config.V1_SEQUENCE_DURATION, Config.V2_SEQUENCE_DURATION) + 1

-- equivalent calls inferred from this helper; original call sites unknown
local function tickDamageForDuration(p: number, V1_TICK_INTERVAL: number?)
	local v3 = math.floor(p / (V1_TICK_INTERVAL or Config.CAPTURE_TICK_INTERVAL))

	if v3 <= 0 then
		return 0
	end

	return (math.max(0, (Config.TOTAL_DAMAGE - Config.CAPTURE_INITIAL_DAMAGE - Config.BURST_DAMAGE) / v3))
end

local function hasNearbyOpponent(character, humanoidRootPart)
	return Utility.SinglePartHitbox({
		Caster = character,
		ParamsName = `{character.Name}-{script.Parent.Name}-variantcheck`,
		Origin = humanoidRootPart.CFrame,
		BoxSize = Config.VARIANT_CHECK_SIZE
	}) ~= nil
end

local function runCaptureCyclone(player)
	local plr = player.plr
	local character = player.Character
	local skill_Data = player.Skill_Data
	local folder = Instance.new("Folder")
	folder.Name = `{plr.Name}RisingDustStorm_captured_{math.random(1, 9999)}--`
	folder.Parent = character
	DebrisModule:AddItem(folder, Config.CAPTURE_STRICT_STUN + 5)
	skill_Data.capturedFolder = folder
	skill_Data.capturedDebris = {}
	skill_Data.victimPauseValues = {}
	skill_Data.victimIframeValues = {}
	skill_Data.victimNoRagdollValues = {}
	skill_Data.victimLinesValues = {}
	skill_Data.cycloneFinish = nil
	local flag = false
	local v3 = nil

	local function finishCyclone(flag2: boolean, vector2: Vector3?)
		if flag then
			return
		end

		flag = true
		local v4 = vector2 or player.getCenter() or v3

		if v4 == nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			v4 = not humanoidRootPart and createVector(0, 0, 0) or humanoidRootPart.Position
		end

		if flag2 and folder.Parent then
			for _, child in folder:GetChildren() do
				local value = child.Value

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

				local victimPauseValue = skill_Data.victimPauseValues[value]

				if victimPauseValue then
					victimPauseValue:Destroy()
				end

				skill_Data.victimPauseValues[value] = nil
				local victimIframeValue = skill_Data.victimIframeValues[value]

				if victimIframeValue then
					victimIframeValue:Destroy()
				end

				skill_Data.victimIframeValues[value] = nil
				local victimNoRagdollValue = skill_Data.victimNoRagdollValues[value]
				local victimLinesValue = skill_Data.victimLinesValues[value]

				if victimNoRagdollValue then
					victimNoRagdollValue:Destroy()
				end

				if victimLinesValue then
					victimLinesValue:Destroy()
				end

				skill_Data.victimNoRagdollValues[value] = nil
				skill_Data.victimLinesValues[value] = nil
				Combat_Util.Damage(script, character, value, {
					Base = Config.BURST_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, getvaluesfolder, Config.BURST_STUN)
				Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder, Config.BURST_STUN)
				local v5 = humanoidRootPart.Position - v4
				local v6 = not (v5.Magnitude > 0.001) and createVector(0, 0, -1) or v5.Unit
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart,
					v6 * (player.burstKnockback or Config.BURST_KNOCKBACK),
					0.125
				)
			end
		end

		for _, victimPauseValue in skill_Data.victimPauseValues do
			victimPauseValue:Destroy()
		end

		skill_Data.victimPauseValues = nil

		for _, victimIframeValue in skill_Data.victimIframeValues do
			victimIframeValue:Destroy()
		end

		skill_Data.victimIframeValues = nil

		for _, victimNoRagdollValue in skill_Data.victimNoRagdollValues do
			victimNoRagdollValue:Destroy()
		end

		for _, victimLinesValue in skill_Data.victimLinesValues do
			victimLinesValue:Destroy()
		end

		skill_Data.victimNoRagdollValues = nil
		skill_Data.victimLinesValues = nil

		for _, v5 in skill_Data.capturedDebris do
			v5:Destroy()
		end

		skill_Data.capturedDebris = nil

		if folder.Parent then
			folder.Name = "--"
			DebrisModule:AddItem(folder, 0.5)
		end

		skill_Data.capturedFolder = nil

		if skill_Data.projectile and skill_Data.projectile.IsActive then
			skill_Data.projectile:Destroy()
		end

		skill_Data.projectile = nil
		player.signaldestroy()
		player.clearPause()
		skill_Data.cycloneFinish = nil
	end

	function skill_Data.cycloneFinish()
		finishCyclone(false)
	end

	local function captureVictim(instance, parent, p)
		if flag then
			return
		end

		for _, child in folder:GetChildren() do
			if child.Value == instance then
				return
			end
		end

		local center = player.getCenter()

		if center == nil then
			return
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = instance.Name
		objectValue.Value = instance
		objectValue.Parent = folder
		local attachment = Instance.new("Attachment")
		attachment.Name = "ALP"
		attachment.Parent = parent
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "P"
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.MaxForce = 200000
		alignPosition.Responsiveness = 100
		local _, v4 = Utility.SafeLookAt(center, parent.Position, CFrame.new(center)):ToOrientation()
		local v5 = v4 - 0.7853981633974483
		alignPosition.Position = center + CFrame.Angles(0, v5, 0) * (player.spinOffset or Config.SPIN_OFFSET)
		alignPosition.Parent = attachment
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Rot"
		numberValue.Value = v5
		numberValue.Parent = attachment
		local add_Strict_Stun = Combat_Util.Add_Strict_Stun(script, character, p, Config.CAPTURE_STRICT_STUN)
		local v6 = Utility.AddValue(p, "pause_gameplay", Config.CAPTURE_STRICT_STUN)
		local v7 = Utility.AddValue(p, "iframe", Config.CAPTURE_STRICT_STUN)
		local v8 = Utility.AddValue(p, "noragdoll", Config.CAPTURE_STRICT_STUN)
		local v9 = Utility.AddValue(p, "NOMouvementlines", Config.CAPTURE_STRICT_STUN)
		Combat_Util.Damage(script, character, instance, {
			Base = Config.CAPTURE_INITIAL_DAMAGE,
			Skill = script.Parent.Name
		})
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid)
		end

		table.insert(skill_Data.capturedDebris, attachment)

		if add_Strict_Stun then
			table.insert(skill_Data.capturedDebris, add_Strict_Stun)
		end

		skill_Data.victimPauseValues[instance] = v6
		skill_Data.victimIframeValues[instance] = v7
		skill_Data.victimNoRagdollValues[instance] = v8
		skill_Data.victimLinesValues[instance] = v9

		if Players:GetPlayerFromCharacter(instance) == nil then
			pcall(function()
				parent:SetNetworkOwner(player.plr)
			end)
		end
	end

	task.spawn(function()
		local now = os.clock()
		local tickInterval = player.tickInterval or Config.CAPTURE_TICK_INTERVAL
		local v4 = now + tickInterval
		local v5 = not (player.acquire and player.acquisitionInterval) and 1e999 or now
		local v6

		if player.spinDuration then
			v6 = now + player.spinDuration
		else
			v6 = 1e999
		end

		while player.current_id == RisingDustStormServer.Id[plr.UserId] and not flag do
			local center = player.getCenter()

			if center == nil then
				break
			end

			v3 = center
			local now2 = os.clock()

			if v6 <= now2 then
				break
			end

			if player.acquire and v5 <= now2 then
				v5 = now2 + player.acquisitionInterval
				player.acquire(captureVictim)
			end

			local v7 = v4 <= now2

			if v7 then
				v4 = now2 + tickInterval
			end

			for _, v8 in skill_Data.capturedDebris do
				if not (v8.Name == "ALP" and v8.Parent) then
					continue
				end

				local rot = v8:FindFirstChild("Rot")
				local P = v8:FindFirstChild("P")
				local v9 = rot.Value + (player.spinIncrement or Config.SPIN_INCREMENT)
				rot.Value = v9
				P.Position = center + Vector3.new(0, v9 * (player.spinRiseRate or Config.SPIN_RISE_RATE), 0) + CFrame.Angles(
					0,
					-v9,
					0
				) * (player.spinOffset or Config.SPIN_OFFSET)
			end

			if v7 and folder.Parent then
				for _, child in folder:GetChildren() do
					local value = child.Value

					if value and value.Parent and Checker.check_victim(script, character, value, {
						iframe = true
					}) ~= nil then
						Combat_Util.Damage(script, character, value, {
							Base = player.tickDamage or 0,
							Skill = script.Parent.Name
						})
						local humanoid = value:FindFirstChild("Humanoid")

						if humanoid then
							Combat_presets.PlayReactAnim(humanoid)
						end
					else
						child:Destroy()

						if value then
							local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")
							local ALP = humanoidRootPart and humanoidRootPart:FindFirstChild("ALP")

							if ALP then
								ALP:Destroy()
							end

							local victimPauseValue = skill_Data.victimPauseValues[value]

							if victimPauseValue then
								victimPauseValue:Destroy()
							end

							skill_Data.victimPauseValues[value] = nil
							local victimIframeValue = skill_Data.victimIframeValues[value]

							if victimIframeValue then
								victimIframeValue:Destroy()
							end

							skill_Data.victimIframeValues[value] = nil
							local victimNoRagdollValue = skill_Data.victimNoRagdollValues[value]
							local victimLinesValue = skill_Data.victimLinesValues[value]

							if victimNoRagdollValue then
								victimNoRagdollValue:Destroy()
							end

							if victimLinesValue then
								victimLinesValue:Destroy()
							end

							skill_Data.victimNoRagdollValues[value] = nil
							skill_Data.victimLinesValues[value] = nil
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
	return {
		captureVictim = captureVictim,
		finishCyclone = finishCyclone,
		capturedFolder = folder,
		isActive = function()
			return not flag
		end
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropV1Box(p)
	local v1Box = p.v1Box
	p.v1Box = nil

	if v1Box ~= nil and v1Box.Part ~= nil then
		v1Box:Destroy()
	end
end

local function plantCaster(p, parent, p2, p3: number)
	local v3 = {}
	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder ~= nil then
		for _, v4 in { "skill_stand_still", "NR", "pause_gameplay" } do
			table.insert(v3, Utility.AddValue(getvaluesfolder, v4, p3))
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "risingduststorm_plant"
	attachment.Parent = parent
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(10000, 10000, 10000)
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	table.insert(v3, attachment)
	DebrisModule:AddItem(attachment, p3)
	parent.AssemblyLinearVelocity = createVector(0, 0, 0)
	local flag = false
	local release

	release = function()
		if flag then
			return
		end

		flag = true

		for _, v4 in v3 do
			if v4.Parent ~= nil then
				v4:Destroy()
			end
		end

		if p2.v1Release == release then
			p2.v1Release = nil
		end
	end

	p2.v1Release = release
	return release
end

local function runVariantOne(player, character, humanoidRootPart, state, current_id: number, callback, clearPause)
	local cFrame = humanoidRootPart.CFrame
	local position = cFrame.Position
	local v3 = plantCaster(character, humanoidRootPart, state, Config.V1_CASTER_FREE_AT + 0.1)
	task.wait(Config.V1_CYCLONE_START)

	if state.v1Release ~= v3 or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	local spinDuration = Config.V1_SPIN_DURATION - Config.V1_CYCLONE_START
	local v7 = runCaptureCyclone({
		plr = player,
		Character = character,
		Skill_Data = state,
		current_id = current_id,
		signaldestroy = function() end,
		clearPause = clearPause,
		getCenter = function()
			return position
		end,
		spinDuration = spinDuration,
		burstKnockback = Config.V1_BURST_KNOCKBACK,
		tickInterval = Config.V1_TICK_INTERVAL,
		tickDamage = tickDamageForDuration(spinDuration, Config.V1_TICK_INTERVAL)
	})
	state.v1Box = PartBox.new({
		Shape = "Cylinder",
		Center = cFrame * Config.V1_AOE_OFFSET,
		Size = Config.V1_AOE_SIZE,
		MaxDuration = spinDuration + 1,
		caster = character,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_RDS_Capture"
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
				Combat_Util.Block(script, character, instance, Config.CAPTURE_BLOCK_BREAK)
			elseif p3 == true then
				v7.captureVictim(instance, rootPart, p2)
			end
		end
	})
	task.wait(Config.V1_SECOND_SLASH_START - Config.V1_CYCLONE_START)

	if state.v1Release ~= v3 or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Rising Dust StormVFX", character, "SlashAOEDisperse")
	task.wait(Config.V1_SPIN_DURATION - Config.V1_SECOND_SLASH_START)
	dropV1Box(state) -- equivalent call inferred; original call site unknown

	if state.v1Release ~= v3 or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	task.wait(Config.V1_CASTER_FREE_AT - Config.V1_SPIN_DURATION)

	if state.v1Release ~= v3 or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	v3()
	callback()
end

local function runVariantTwo(player, character, humanoidRootPart, p, state, current_id: number, callback, clearPause)
	local v3 = (p or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.V2_PROJECTILE_RANGE) - humanoidRootPart.Position
	local vector2 = Vector3.new(v3.X, 0, v3.Z)
	local unit

	if vector2.Magnitude > 0.001 then
		unit = vector2.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local cFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit) * Config.V2_SPAWN_OFFSET
	local v5 = nil
	local projectile2 = ProjectileModeler.new({
		Name = `{player.Name} Rising Dust Storm`,
		Size = Config.V2_PROJECTILE_SIZE,
		Massless = true,
		CanCollide = false,
		Transparency = 1,
		CFrame = cFrame,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.V2_PROJECTILE_SPEED
		},
		Rotator = {
			CFrame = cFrame
		}
	}, function(_, _, p3)
		if v5 == nil then
			return false
		end

		if not (v5.isActive() and current_id == RisingDustStormServer.Id[player.UserId] and p3 ~= nil) then
			return true
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p3)

		if find_character_from_descendant == nil or find_character_from_descendant == character or v5.capturedFolder:FindFirstChild(find_character_from_descendant.Name) then
			return false
		end

		local getvaluesfolder = Utility.getvaluesfolder(find_character_from_descendant)
		local formatted = `Touched for {script.Parent.Name} from {player.Name}`

		if not Combat_Util.CheckCanTouch(getvaluesfolder, formatted) then
			return false
		end

		Combat_Util.SetTouchCooldown(getvaluesfolder, formatted)
		local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

		if check_victim == nil then
			return false
		elseif check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, find_character_from_descendant)
			return false
		elseif check_victim == "Blocking" then
			Combat_Util.Block(script, character, find_character_from_descendant, Config.CAPTURE_BLOCK_BREAK)
			return false
		end

		local humanoid = find_character_from_descendant:FindFirstChild("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if rootPart and getvaluesfolder then
			v5.captureVictim(find_character_from_descendant, rootPart, getvaluesfolder)
		end

		return false
	end, Config.V2_PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, nil, true)
	pcall(function()
		projectile2.Instance:SetNetworkOwner(player)
	end)
	state.projectile = projectile2
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Rising Dust StormVFX",
		character,
		"SlashTornadoProjectile",
		false,
		Config.V2_VFX_OFFSET
	)
	local v2Token = {}
	state.v2Token = v2Token
	v5 = runCaptureCyclone({
		plr = player,
		Character = character,
		Skill_Data = state,
		current_id = current_id,
		signaldestroy = function() end,
		clearPause = clearPause,
		getCenter = function()
			local projectile = state.projectile
			local v10

			if projectile and projectile.Instance then
				v10 = projectile:Position()
			end

			if v10 == nil then
				return nil
			end

			return v10 + Config.V2_VFX_OFFSET.Position
		end,
		spinDuration = Config.V2_SPIN_DURATION,
		spinIncrement = Config.V2_SPIN_INCREMENT,
		spinRiseRate = Config.V2_SPIN_RISE_RATE,
		spinOffset = Config.V2_SPIN_OFFSET,
		tickDamage = tickDamageForDuration(Config.V2_SPIN_DURATION)
	})
	task.wait(Config.V2_SPIN_DURATION)

	if state.v2Token ~= v2Token or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	if state.farTrack then
		state.farTrack:Stop()
		state.farTrack = nil
	end

	local animator = character:FindFirstChild("Animator", true)
	local disperse = script.Parent:FindFirstChild("Disperse")

	if animator and disperse then
		local track = animator:LoadAnimation(disperse)
		track:Play()
		state.disperseTrack = track
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Rising Dust StormVFX", character, "SlashTornadoDisperse")
	task.wait(Config.V2_DISPERSE_DURATION)

	if state.v2Token ~= v2Token or current_id ~= RisingDustStormServer.Id[player.UserId] then
		return
	end

	state.disperseTrack = nil
	state.v2Token = nil
	callback()
end

function RisingDustStormServer.Hold(player, _, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Rising Dust StormVFX", character, "Start")
	local animator = character:FindFirstChild("Animator", true)

	if animator then
		local track = animator:LoadAnimation(script.Parent.Far)
		track:Play()
		state.farTrack = track
		state.farHoldPending = true
		task.delay(Config.FAR_HOLD_PAUSE_TIME, function()
			if state.farHoldPending and state.farTrack == track and track.IsPlaying then
				track:AdjustSpeed(0)
			end
		end)
	end
end

function RisingDustStormServer.UnHold(player, p, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v3 = RisingDustStormServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		state.pauseValue = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CASTER_LOCK_DURATION)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearPause()
		if state.pauseValue then
			state.pauseValue:Destroy()
			state.pauseValue = nil
		end
	end

	local v4, v5 = ManuelCancel.new(player, v2 + 0.5)
	v4:Connect(function()
		v3 = -1
		RisingDustStormServer.Cancel(player, p, state)
		v5()
	end)
	task.wait(Config.PRE_RELEASE_DELAY)

	if v3 == RisingDustStormServer.Id[player.UserId] then
		clearPause() -- equivalent call inferred; original call site unknown
		state.farHoldPending = false
		local nearbyOpponent = hasNearbyOpponent(character, humanoidRootPart)

		if nearbyOpponent then
			if state.farTrack then
				state.farTrack:Stop()
				state.farTrack = nil
			end

			local animator = character:FindFirstChild("Animator", true)

			if animator then
				local track = animator:LoadAnimation(script.Parent.Close)
				track:Play()
				state.closeTrack = track
			end
		elseif state.farTrack then
			state.farTrack:AdjustSpeed(1)
		end

		if nearbyOpponent then
			EffectsEvent.ToAllInRange(humanoidRootPart, "Rising Dust StormVFX", character, "SlashAOE")
			runVariantOne(player, character, humanoidRootPart, state, v3, v5, clearPause)
		else
			runVariantTwo(player, character, humanoidRootPart, p, state, v3, v5, clearPause)
		end
	else
		v5()
		clearPause() -- equivalent call inferred; original call site unknown
	end
end

function RisingDustStormServer.Cancel(player, _, state)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Rising Dust StormVFX", character, "Cancel")
	end

	if state then
		state.farHoldPending = false

		if state.farTrack then
			state.farTrack:Stop()
			state.farTrack = nil
		end

		if state.closeTrack then
			state.closeTrack:Stop()
			state.closeTrack = nil
		end

		if state.disperseTrack then
			state.disperseTrack:Stop()
			state.disperseTrack = nil
		end

		if state.cycloneFinish then
			state.cycloneFinish()
		end

		if state.v1Release then
			state.v1Release()
		end

		dropV1Box(state) -- equivalent call inferred; original call site unknown
		state.v2Token = nil

		if state.pauseValue then
			state.pauseValue:Destroy()
			state.pauseValue = nil
		end
	end
end

return RisingDustStormServer