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
local Combat_presets = require(global.Combat_presets)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local DebrisModule = require(CAM.DebrisModule)
local ProjectileModeler = require(global.ProjectileModeler)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local RaycastHelper = require(global.RaycastHelper)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local CharGrabPosCorrector = require(global.Subsets.Gameplay.CharGrabPosCorrector)
local Config = require(script.Parent.Config)
local IdatenTyphoonServer = {
	Id = {}
}
local v2 = math.max(Config.V1_CUTSCENE_DURATION, Config.V2_PROJECTILE_LIFETIME + Config.V2_CUTSCENE_DURATION) + 1

local function lock(part, cFrame: CFrame, p: number?, childName: string?)
	part:PivotTo(cFrame)
	local clone = childName and workspace.Debree:FindFirstChild(childName)

	if not clone then
		clone = script.Parent.Parent.Parent.LOCK:Clone()
		clone.Name = childName or "LOCK"
		clone.Parent = workspace.Debree
		clone.Transparency = 1
	end

	clone:PivotTo(cFrame)

	if p then
		DebrisModule:AddItem(clone, p)
	end

	clone.Weld.Part1 = part
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCutsceneHandles(p)
	if not p.cutsceneHandles then
		return
	end

	local cutsceneHandles = p.cutsceneHandles

	if cutsceneHandles.casterLock then
		cutsceneHandles.casterLock:Destroy()
	end

	if cutsceneHandles.casterMover then
		cutsceneHandles.casterMover:Destroy()
	end

	if cutsceneHandles.casterAnim then
		cutsceneHandles.casterAnim:Stop()
		cutsceneHandles.casterAnim:Destroy()
	end

	for _, v3 in cutsceneHandles.casterDebris do
		if v3 then
			v3:Destroy()
		end
	end

	for _, victim in cutsceneHandles.victims do
		if victim.lock then
			victim.lock:Destroy()
		end

		if victim.anim then
			victim.anim:Stop()
			victim.anim:Destroy()
		end

		for _, v3 in victim.debris do
			if v3 then
				v3:Destroy()
			end
		end
	end

	p.cutsceneHandles = nil
end

local function runCloseCutscene(player, character, humanoidRootPart, state, list)
	local V1_CUTSCENE_DURATION = Config.V1_CUTSCENE_DURATION
	local cFrame = humanoidRootPart.CFrame
	local casterLock = lock(humanoidRootPart, cFrame, V1_CUTSCENE_DURATION + 0.5, `{player.Name}_IdatenTyphoon_caster`)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v4

	if getvaluesfolder then
		v4 = Utility.AddValue(getvaluesfolder, "pause_gameplay", V1_CUTSCENE_DURATION) or nil
	end

	local v5

	if getvaluesfolder then
		v5 = Utility.AddValue(getvaluesfolder, "iframe", V1_CUTSCENE_DURATION) or nil
	end

	local v6

	if getvaluesfolder then
		v6 = Utility.AddValue(getvaluesfolder, "noragdoll", V1_CUTSCENE_DURATION) or nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local track

	if animator then
		track = animator:LoadAnimation(script.CloseVariantTarget)
		track:Play()
		CharGrabPosCorrector.Do(character, track, V1_CUTSCENE_DURATION, character)
	end

	local clone = script.CameraRig:Clone()
	clone.Name = `{player.Name}_IdatenTyphoon_cameraRig`
	clone.Parent = workspace.Debree
	clone:PivotTo(cFrame)
	clone.RootPart.Weld.Part0 = humanoidRootPart
	DebrisModule:AddItem(clone, V1_CUTSCENE_DURATION + 0.5)
	clone.AnimationController:FindFirstChildOfClass("Animator"):LoadAnimation(script.CameraAnim):Play()
	local models = { character }

	for _, v7 in list do
		table.insert(models, v7.model)
	end

	Cutscene_camera_handler.Regular(player, clone.Bone)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Idaten TyphoonVFX",
		character,
		"Cutscene",
		"Close",
		clone.Name,
		clone,
		list[1] and list[1].model,
		models
	)
	local victims = {}

	for _, v8 in ipairs(list) do
		local lock2 = lock(v8.root, cFrame, V1_CUTSCENE_DURATION + 0.5, `{v8.model.Name}_IdatenTyphoon_victim`)
		local v10 = Utility.AddValue(v8.values, "pause_gameplay", V1_CUTSCENE_DURATION)
		local v11 = Utility.AddValue(v8.values, "iframe", V1_CUTSCENE_DURATION)

		if v11 and getvaluesfolder then
			v11.Value = getvaluesfolder.Name
		end

		local v12 = Utility.AddValue(v8.values, "noragdoll", V1_CUTSCENE_DURATION)
		local humanoid2 = v8.model:FindFirstChildOfClass("Humanoid")
		local animator2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")
		local track2

		if animator2 then
			track2 = animator2:LoadAnimation(script.CloseVariantVictim)
			track2:Play()
			CharGrabPosCorrector.Do(v8.model, track2, V1_CUTSCENE_DURATION, character)
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(v8.model)

		if playerFromCharacter then
			Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
		end

		table.insert(victims, {
			lock = lock2,
			debris = { v10, v11, v12 },
			anim = track2
		})
	end

	state.cutsceneHandles = {
		casterLock = casterLock,
		casterDebris = {
			v4,
			v5,
			v6,
			clone
		},
		casterAnim = track,
		victims = victims
	}

	for _, v8 in ipairs(list) do
		local v9 = v8

		local function dmg(base: number)
			if not (state.cutsceneHandles ~= nil and Checker.check_victim(script, character, v9.model, {
				iframe = true
			}) ~= nil) then
				return
			end

			Combat_Util.Damage(script, character, v9.model, {
				Base = base,
				Skill = script.Parent.Name
			})
		end

		for _, duration in Config.V1_STRIKE_TIMES do
			task.delay(duration, dmg, Config.V1_STRIKE_DAMAGE)
		end

		local dmg2 = dmg
		task.delay(Config.V1_CLIMAX_TIME, function()
			for i = 1, Config.V1_CLIMAX_HIT_COUNT do
				dmg2(Config.V1_CLIMAX_HIT_DAMAGE)

				if i < Config.V1_CLIMAX_HIT_COUNT then
					task.wait(Config.V1_CLIMAX_HIT_INTERVAL)
				end
			end
		end)
		task.delay(Config.V1_ENDING_TIME, dmg, Config.V1_ENDING_DAMAGE)
	end

	task.delay(V1_CUTSCENE_DURATION, function()
		destroyCutsceneHandles(state)

		for _, v8 in ipairs(list) do
			if not (v8.values and v8.values.Parent and Checker.check_victim(script, character, v8.model, {
				iframe = true
			}) ~= nil) then
				continue
			end

			Combat_Util.RagDoll(script, character, v8.values, Config.V1_ENDING_RAGDOLL_DURATION)
			Combat_Util.AddStun(script, character, v8.values, Config.V1_ENDING_STUN_DURATION)
		end
	end)
end

local function runFarCutscene(p, instance, parent, state, list, cFrame: CFrame)
	if #list == 0 then
		return
	end

	if Checker.check_victim(script, instance, instance) == nil then
		IdatenTyphoonServer.Cancel(p, nil, state)
		return
	end

	local V2_CUTSCENE_DURATION = Config.V2_CUTSCENE_DURATION
	local v3 = list[1]
	local v4 = v3.root.Position - cFrame.Position
	local unit

	if v4.Magnitude > 0.001 then
		unit = v4.Unit
	else
		unit = cFrame.LookVector
	end

	local position = v3.root.Position + unit * Config.V2_CASTER_BEHIND_DISTANCE
	local raycastResult = workspace:Raycast(
		v3.root.Position,
		unit * Config.V2_CASTER_BEHIND_DISTANCE,
		RaycastHelper.Crater
	)

	if raycastResult then
		position = raycastResult.Position + raycastResult.Normal * 2
	end

	local vector2 = Vector3.new(unit.X, 0, unit.Z)
	local v6 = not (vector2.Magnitude > 0.001) and createVector(0, 0, -1) or vector2.Unit
	local cFrame2 = parent.CFrame
	local cframe = CFrame.lookAt(parent.Position, parent.Position + v6)
	parent.CFrame = cframe
	parent.AssemblyAngularVelocity = createVector(0, 0, 0)
	local cframe2 = CFrame.lookAt(position, position + v6)
	EffectsEvent.ToAllInRange(
		parent,
		"Idaten TyphoonVFX",
		instance,
		"Cutscene",
		"Far",
		v3.root.CFrame,
		cframe,
		cframe2,
		v3.model,
		cFrame2
	)
	local attachment = Instance.new("Attachment")
	attachment.Name = `{p.Name}_IdatenTyphoon_caster_mover`
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = createVector(20000, 20000, 20000)
	alignPosition.Responsiveness = 45
	alignPosition.Attachment0 = attachment
	alignPosition.Position = position
	alignPosition.Parent = attachment
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.CFrame = cframe
	alignOrientation.MaxTorque = 1000000
	alignOrientation.Responsiveness = 100
	alignOrientation.Parent = attachment
	attachment.Parent = parent
	DebrisModule:AddItem(attachment, V2_CUTSCENE_DURATION + 0.5)
	local getvaluesfolder = Utility.getvaluesfolder(instance)
	local v7

	if getvaluesfolder then
		v7 = Utility.AddValue(getvaluesfolder, "pause_gameplay", V2_CUTSCENE_DURATION) or nil
	end

	local v8

	if getvaluesfolder then
		v8 = Utility.AddValue(getvaluesfolder, "iframe", V2_CUTSCENE_DURATION) or nil
	end

	local v9

	if getvaluesfolder then
		v9 = Utility.AddValue(getvaluesfolder, "noragdoll", V2_CUTSCENE_DURATION) or nil
	end

	local v10

	if getvaluesfolder then
		v10 = Utility.AddValue(getvaluesfolder, "NR", V2_CUTSCENE_DURATION) or nil
	end

	local animator = instance:FindFirstChildOfClass("Humanoid") and instance:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	local track

	if animator then
		track = animator:LoadAnimation(script.FarRangeUserAnim)
		track:Play()
	end

	local victims = {}

	for _, v12 in ipairs(list) do
		local lock2 = lock(
			v12.root,
			v12.root.CFrame,
			V2_CUTSCENE_DURATION + 0.5,
			`{v12.model.Name}_IdatenTyphoon_victim`
		)
		local v14 = Utility.AddValue(v12.values, "pause_gameplay", V2_CUTSCENE_DURATION)
		local v15 = Utility.AddValue(v12.values, "iframe", V2_CUTSCENE_DURATION)

		if v15 and getvaluesfolder then
			v15.Value = getvaluesfolder.Name
		end

		local v16 = Utility.AddValue(v12.values, "noragdoll", V2_CUTSCENE_DURATION)
		local humanoid = v12.model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid, nil, 0.2)
		end

		table.insert(victims, {
			lock = lock2,
			debris = { v14, v15, v16 }
		})
	end

	state.cutsceneHandles = {
		casterMover = attachment,
		casterDebris = {
			v7,
			v8,
			v9,
			v10
		},
		casterAnim = track,
		victims = victims
	}

	for _, v12 in ipairs(list) do
		local v13 = v12
		local v14 = v12.model:FindFirstChildOfClass("Humanoid")

		local function dmg(base: number)
			if not (state.cutsceneHandles ~= nil and Checker.check_victim(script, instance, v13.model, {
				iframe = true
			}) ~= nil) then
				return
			end

			Combat_Util.Damage(script, instance, v13.model, {
				Base = base,
				Skill = script.Parent.Name
			})

			if v14 then
				Combat_presets.PlayReactAnim(v14)
			end
		end

		local dmg2 = dmg
		task.delay(Config.V2_BARRAGE_START, function()
			for i = 1, Config.V2_BARRAGE_COUNT do
				dmg2(Config.V2_BARRAGE_DAMAGE)

				if i < Config.V2_BARRAGE_COUNT then
					task.wait(Config.V2_BARRAGE_INTERVAL)
				end
			end
		end)
	end

	task.delay(Config.V2_ENDING_TIME, function()
		destroyCutsceneHandles(state)

		for _, v12 in ipairs(list) do
			if not (v12.values and v12.values.Parent and Checker.check_victim(script, instance, v12.model, {
				iframe = true
			}) ~= nil) then
				continue
			end

			Combat_Util.Damage(script, instance, v12.model, {
				Base = Config.V2_ENDING_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, instance, v12.values, Config.V2_ENDING_RAGDOLL_DURATION)
			Combat_Util.AddStun(script, instance, v12.values, Config.V2_ENDING_STUN_DURATION)
		end
	end)
end

local function runUpdraftAndProjectiles(player, character, humanoidRootPart, state, p: number)
	local cFrame = humanoidRootPart.CFrame
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder then
		state.firingPause = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.V2_FIRING_PAUSE_DURATION)
	end

	EffectsEvent.ToAllInRange(player, "Idaten TyphoonVFX", character, "Jump", cFrame)
	Combat_Util.Add_air_combo_bp(
		humanoidRootPart,
		humanoidRootPart,
		Config.UPDRAFT_HEIGHT,
		nil,
		Config.UPDRAFT_DURATION
	)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator then
		state.strikeAnim = animator:LoadAnimation(script.ThreeSlashes)
		state.strikeAnim:Play()
	end

	task.wait(Config.V2_STRIKE_PREP_DELAY)

	if not (p == IdatenTyphoonServer.Id[player.UserId] and (character.Parent and humanoidRootPart.Parent)) then
		return
	end

	local v3 = false
	local v4 = false
	local v5 = {}
	local v6 = {}
	local v7 = 0
	local v8 = false

	local function tryReleaseFiringPause()
		if not v8 or v7 > 0 then
			return
		end

		if state.firingPause then
			state.firingPause:Destroy()
			state.firingPause = nil
		end
	end

	local function abortFiring(p2)
		v4 = true

		for _, v9 in v6 do
			if v9 ~= p2 and v9.IsActive then
				v9:Destroy()
			end
		end

		if state.strikeAnim then
			state.strikeAnim:Stop()
			state.strikeAnim:Destroy()
			state.strikeAnim = nil
		end

		if state.firingPause then
			state.firingPause:Destroy()
			state.firingPause = nil
		end
	end

	local function addVictim(model, root, values)
		for _, v9 in v5 do
			if v9.model == model then
				return
			end
		end

		table.insert(v5, {
			model = model,
			root = root,
			values = values
		})
	end

	local function fireStrike(i: number)
		if v3 or v4 then
			return
		end

		local v9 = Server_Mouse_Pos.Find(character, script.Parent.Name)
		local v10 = (v9 and v9.Position or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 20) - humanoidRootPart.Position
		local unit

		if v10.Magnitude > 0.001 then
			unit = v10.Unit
		else
			unit = humanoidRootPart.CFrame.LookVector
		end

		local cFrame2 = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit) * Config.V2_PROJECTILE_SPAWN_OFFSET
		local v12 = nil
		local v13 = false
		v12 = ProjectileModeler.new({
			Name = `{player.Name} Idaten Typhoon Strike{i}`,
			Size = Config.V2_PROJECTILE_SIZE,
			Massless = false,
			CanCollide = false,
			Transparency = 1,
			CFrame = cFrame2,
			Mover = {
				MaxForce = 1000000000,
				VectorVelocity = unit * Config.V2_PROJECTILE_SPEED
			},
			Rotator = {
				CFrame = cFrame2
			},
			UseRaycast = true
		}, function(p2, _, p3)
			-- [DEDUP] synthesized from 3 duplicated terminal regions
			local function deduplicatedTail()
				if v8 and not (v7 > 0) and state.firingPause then
					state.firingPause:Destroy()
					state.firingPause = nil
				end

				return true
			end

			if v3 or v13 then
				v7 -= 1
				return deduplicatedTail()
			elseif p3 == nil then
				v7 -= 1
				return deduplicatedTail()
			else
				local find_character_from_descendant = Utility.find_character_from_descendant(p3)

				if find_character_from_descendant == character then
					return false
				end

				v13 = true
				local v14 = #v5
				local humanoidRootPart2 = find_character_from_descendant and find_character_from_descendant:FindFirstChild("HumanoidRootPart")
				local position

				if humanoidRootPart2 then
					position = humanoidRootPart2.Position
				else
					position = p2 or v12.Instance.Position
				end

				local cframe = CFrame.new(position, position + humanoidRootPart.CFrame.LookVector)
				local v15 = i == Config.V2_STRIKE_COUNT
				local flag = false
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = cframe,
					hitboxSize = Config.V2_AOE_HITBOX_SIZE,
					checker = Checker,
					targets = find_character_from_descendant and { find_character_from_descendant } or nil,
					hitPriorityHandler = {
						callback = v.Exists,
						data = `Choosing_IT_FarAOE{i}`
					},
					hitDetected = function(instance, values, p5)
						if not instance then
							return
						end

						local humanoid2 = instance:FindFirstChild("Humanoid")
						local rootPart = humanoid2 and humanoid2.RootPart

						if not rootPart then
							return
						end

						local v16 = instance == find_character_from_descendant

						if p5 == "Perfect" then
							Combat_Util.Perfect(script, character, instance)

							if v16 then
								flag = true
							end
						elseif p5 == "Blocking" then
							local block = Combat_Util.Block
							local script2 = script
							local V2_FINAL_PROJECTILE_BLOCK_BREAK

							if v15 then
								V2_FINAL_PROJECTILE_BLOCK_BREAK = Config.V2_FINAL_PROJECTILE_BLOCK_BREAK
							elseif v16 then
								V2_FINAL_PROJECTILE_BLOCK_BREAK = Config.V2_PROJECTILE_BLOCK_BREAK
							else
								V2_FINAL_PROJECTILE_BLOCK_BREAK = Config.V2_AOE_BLOCK_BREAK
							end

							block(script2, character, instance, V2_FINAL_PROJECTILE_BLOCK_BREAK)
						elseif p5 == true then
							local flag2 = true

							for _, v17 in v5 do
								if v17.model ~= instance then
									continue
								end

								flag2 = false
								break
							end

							if flag2 then
								table.insert(v5, {
									model = instance,
									root = rootPart,
									values = values
								})
							end

							local damage = Combat_Util.Damage
							local script2 = script
							local base

							if v16 then
								base = Config.V2_PROJECTILE_DAMAGE
							else
								base = Config.V2_AOE_DAMAGE
							end

							damage(script2, character, instance, {
								Base = base,
								Skill = script.Parent.Name
							})
						end
					end
				})
				local v16 = v5[v14 + 1]
				EffectsEvent.ToAllInRange(
					humanoidRootPart,
					"Idaten TyphoonVFX",
					character,
					"ProjectileExplosion",
					cframe,
					v16 and v16.model,
					i
				)

				if flag then
					abortFiring(v12)
					return true
				end

				if v15 and #v5 > 0 then
					v3 = true

					if state.strikeAnim then
						state.strikeAnim:Stop()
						state.strikeAnim:Destroy()
						state.strikeAnim = nil
					end

					for _, v17 in v6 do
						if v17 ~= v12 and v17.IsActive then
							v17:Destroy()
						end
					end

					if state.firingPause then
						state.firingPause:Destroy()
						state.firingPause = nil
					end

					runFarCutscene(player, character, humanoidRootPart, state, v5, cFrame)
				end

				v7 -= 1
				return deduplicatedTail()
			end
		end, Config.V2_PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.HumanoidsAndMap, character)
		v12.Instance:SetNetworkOwner(player)
		EffectsEvent.ToAllInRange(
			humanoidRootPart,
			"Idaten TyphoonVFX",
			character,
			"ProjectileFired",
			v12.Instance and v12.Instance.Name,
			v12.Instance,
			i
		)
		table.insert(v6, v12)
		v7 += 1
	end

	for i = 1, Config.V2_STRIKE_COUNT do
		if v3 or v4 then
			break
		end

		if p ~= IdatenTyphoonServer.Id[player.UserId] then
			return
		end

		fireStrike(i)

		if i < Config.V2_STRIKE_COUNT then
			task.wait(Config.V2_STRIKE_INTERVAL)
		end
	end

	v8 = true

	if v8 and not (v7 > 0) and state.firingPause then
		state.firingPause:Destroy()
		state.firingPause = nil
	end

	Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
end

function IdatenTyphoonServer.Hold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	p2.cancelled = false
	local v3, signaldestroy = ManuelCancel.new(player, v2 + 0.5)
	p2.signaldestroy = signaldestroy
	v3:Connect(function()
		IdatenTyphoonServer.Cancel(player, p, p2)
		signaldestroy()
	end)
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, v2 + 1)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Idaten TyphoonVFX", character, "Start")
end

function IdatenTyphoonServer.UnHold(player, _, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or state and state.cancelled then
		return
	end

	local v3 = IdatenTyphoonServer.Id[player.UserId]
	local v4 = {}
	local flag = false
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.UNHOLD_HITBOX_OFFSET,
		hitboxSize = Config.UNHOLD_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_IT_UnHold"
		},
		hitDetected = function(instance, values, p2)
			if not instance then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if not rootPart then
				return
			end

			if p2 == "Perfect" then
				flag = true
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				flag = true
				Combat_Util.Block(script, character, instance, Config.UNHOLD_BLOCK_BREAK)
			elseif p2 == true then
				table.insert(v4, {
					model = instance,
					root = rootPart,
					values = values
				})
			end
		end
	})

	if #v4 > 0 then
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		runCloseCutscene(player, character, humanoidRootPart, state, v4)
	elseif flag then
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)

		if state.signaldestroy then
			state.signaldestroy()
			state.signaldestroy = nil
		end
	else
		runUpdraftAndProjectiles(player, character, humanoidRootPart, state, v3)
	end
end

function IdatenTyphoonServer.Cancel(player, _, state)
	if not player then
		return
	end

	if state then
		state.cancelled = true
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Idaten TyphoonVFX", character, "Cancel")
	end

	Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)

	if state then
		if state.strikeAnim then
			state.strikeAnim:Stop()
			state.strikeAnim:Destroy()
			state.strikeAnim = nil
		end

		destroyCutsceneHandles(state) -- equivalent call inferred; original call site unknown

		if state.firingPause then
			state.firingPause:Destroy()
			state.firingPause = nil
		end

		if state.signaldestroy then
			state.signaldestroy()
			state.signaldestroy = nil
		end
	end
end

return IdatenTyphoonServer