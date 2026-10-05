local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local DebrisModule = require(CAM.DebrisModule)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local DevouringRushServer = {
	Id = {}
}
local attacker = script.Attacker
local target = script.Target
local camera = script.Camera

-- equivalent calls inferred from this helper; original call sites unknown
local function fanOffset(p: number)
	if p <= 1 then
		return 0
	end

	local v2 = math.ceil((p - 1) / 2)
	return (p % 2 == 0 and 1 or -1) * v2 * Config.CARRY_SPREAD
end

local function releaseAll(state)
	for _, v2 in state.carried or {} do
		for _, v3 in v2 do
			if v3.Parent ~= nil then
				v3:Destroy()
			end
		end
	end

	state.carried = {}
end

function DevouringRushServer.Hold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	releaseAll(state)
	local v2 = DevouringRushServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Start")
	local count = 0

	local function carry(instance, humanoidRootPart2, p)
		if state.carried[instance] ~= nil then
			return
		end

		for _, v3 in CollectionService:GetTagged("OuwWeld") do
			if v3.Value == humanoidRootPart2 then
				v3:Destroy()
			end
		end

		Utility.ClearMovers(humanoidRootPart2)
		count += 1
		local createOuwWeld = Utility.CreateOuwWeld
		local v5 = fanOffset(count) -- equivalent call inferred; original call site unknown
		local ouwWeld = createOuwWeld(
			humanoidRootPart,
			humanoidRootPart2,
			CFrame.new(v5, 0, Config.CARRY_FORWARD),
			Config.CARRY_DURATION
		)

		if ouwWeld == nil then
			return
		end

		Combat_Util.Cancel(script, p)
		state.carried[instance] = {
			ouwWeld,
			Utility.AddValue(p, "pause_gameplay", Config.CARRY_DURATION),
			Utility.AddValue(p, "NR", Config.CARRY_DURATION),
			Utility.AddValue(p, "NOMouvementlines", Config.CARRY_DURATION),
			Utility.AddValue(p, "iframe", Config.CARRY_DURATION, "StringValue", character.Name)
		}
		EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Capture", instance)
	end

	local now = os.clock()
	task.spawn(function()
		for _, v3 in Config.SLASH_TIMES do
			local v4 = now + Config.LOOP_START + v3 - os.clock()

			if v4 > 0 then
				task.wait(v4)
			end

			if DevouringRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
				break
			end

			local v5 = nil

			for k in state.carried do
				if not (k.Parent ~= nil and Checker.check_victim(script, character, k) == true) then
					continue
				end

				Combat_Util.Damage(script, character, k, {
					Base = Config.SLASH_DAMAGE,
					Skill = script.Parent.Name
				})
				v5 = v5 or k
				local humanoid = k:FindFirstChildOfClass("Humanoid")

				if humanoid ~= nil then
					Combat_presets.PlayReactAnim(humanoid, nil, Config.SLASH_REACT_SPEED)
				end
			end

			if v5 ~= nil then
				ImpactSounds.Play(character, script.Parent.Name, v5)
			end
		end
	end)
	local nowsByInstance = {}
	local v3 = {}
	task.wait(Config.STARTUP)

	if DevouringRushServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Rush")

	while DevouringRushServer.Id[player.UserId] == v2 and humanoidRootPart.Parent ~= nil do
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -Config.CATCH_OFFSET),
			hitboxSize = Config.CATCH_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if p2 == "Perfect" then
					if v3[instance] then
						return
					end

					v3[instance] = true
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					local now2 = os.clock()

					if now2 - (nowsByInstance[instance] or -1e999) < Config.BLOCK_INTERVAL then
						return
					end

					nowsByInstance[instance] = now2

					if Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK) == true then
						local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 ~= nil then
							carry(instance, humanoidRootPart2, p)
						end
					end
				else
					if p2 ~= true then
						return
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 == nil then
						return
					end

					carry(instance, humanoidRootPart2, p)
				end
			end
		})
		task.wait(Config.CATCH_INTERVAL)
	end
end

function DevouringRushServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		releaseAll(state)
		return
	end

	if next(state.carried or {}) == nil then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Cancel")
		return
	end

	local v2 = DevouringRushServer.Id[player.UserId]
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CUTSCENE_DURATION)
		Utility.AddValue(getvaluesfolder, "NR", Config.CUTSCENE_DURATION)
		Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.CUTSCENE_DURATION)
		Utility.AddValue(getvaluesfolder, "iframe", Config.CUTSCENE_DURATION)
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local _, v3 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 2, 0),
		createVector(-0, -25, -0),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil then
		local v4 = humanoid == nil and 2 or humanoid.HipHeight
		position = raycastResult.Position + Vector3.new(0, v4 + humanoidRootPart.Size.Y / 2, 0)
	end

	local v4 = CFrame.new(position) * CFrame.Angles(0, v3, 0)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp ~= nil then
		air_combo_bp:Destroy()
	end

	for k, v5 in state.carried do
		local v6 = v5[1]

		if v6 ~= nil and v6.Parent ~= nil then
			v6:Destroy()
		end

		local humanoidRootPart2 = k:FindFirstChild("HumanoidRootPart")
		local air_combo_bp2 = humanoidRootPart2 and humanoidRootPart2:FindFirstChild("air_combo_bp")

		if air_combo_bp2 ~= nil then
			air_combo_bp2:Destroy()
		end
	end

	task.wait()

	if DevouringRushServer.Id[player.UserId] ~= v2 or (character.Parent == nil or humanoidRootPart.Parent == nil) then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	Utility.lock(humanoidRootPart, v4, Config.CUTSCENE_DURATION)
	local v5 = {}

	for k in state.carried do
		local humanoidRootPart2 = k:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 == nil then
			continue
		end

		humanoidRootPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart2.AssemblyAngularVelocity = createVector(0, 0, 0)
		local getvaluesfolder2 = Utility.getvaluesfolder(k)

		if getvaluesfolder2 ~= nil then
			table.insert(v5, Utility.AddValue(getvaluesfolder2, "skill_stand_still", Config.HIT_AT))
		end

		table.insert(v5, Utility.lock(humanoidRootPart2, v4, Config.HIT_AT))
	end

	local v6 = {}
	local tracks = {}
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator ~= nil then
		animator:LoadAnimation(attacker):Play()
	end

	local clone = script.CameraRig:Clone()
	clone.Name = `{player.Name}_DevouringRush_cameraRig`
	clone.RootPart.CameraWeld.Part0 = humanoidRootPart
	clone.Parent = workspace.Debree
	clone.AnimationController.Animator:LoadAnimation(camera):Play()
	DebrisModule:AddItem(clone, Config.CAMERA_DURATION)
	state.cameraRig = clone
	Cutscene_camera_handler.Regular(player, clone.Bone)

	for k in state.carried do
		table.insert(v6, k)
		local Players = game:GetService("Players")
		local playerFromCharacter = Players:GetPlayerFromCharacter(k)

		if playerFromCharacter ~= nil then
			Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
		end

		local humanoid2 = k:FindFirstChildOfClass("Humanoid")
		local animator2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")

		if not (humanoid2 ~= nil and animator2 ~= nil) then
			continue
		end

		Combat_presets.stop_extra_anims(humanoid2)
		local track = animator2:LoadAnimation(target)
		track:Play()
		track.TimePosition = Config.CLIP_SKIP
		table.insert(tracks, track)
	end

	local v7 = { character }

	for _, v8 in v6 do
		table.insert(v7, v8)
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Cutscene", v4, clone.Name, clone, v7)
	task.wait(Config.HIT_AT)

	if DevouringRushServer.Id[player.UserId] ~= v2 then
		return
	end

	for _, v8 in tracks do
		v8:Stop()
	end

	for _, v8 in v5 do
		if v8.Parent ~= nil then
			v8:Destroy()
		end
	end

	releaseAll(state)
	task.wait()

	if DevouringRushServer.Id[player.UserId] ~= v2 or (character.Parent == nil or humanoidRootPart.Parent == nil) then
		return
	end

	local v8 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v9 = not (v8.Magnitude > 0.01) and createVector(0, 0, 1) or v8.Unit

	for _, v10 in v6 do
		if not (v10.Parent ~= nil and Checker.check_victim(script, character, v10) == true) then
			continue
		end

		local humanoidRootPart2 = v10:FindFirstChild("HumanoidRootPart")
		local getvaluesfolder2 = Utility.getvaluesfolder(v10)

		if not (humanoidRootPart2 ~= nil and getvaluesfolder2 ~= nil) then
			continue
		end

		Combat_Util.Damage(script, character, v10, {
			Base = Config.HIT_DAMAGE,
			Skill = script.Parent.Name
		})
		Combat_Util.AddStun(script, character, getvaluesfolder2, Config.HIT_STUN)
		Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.HIT_RAGDOLL)
		Combat_Util.Knockback(
			script,
			character,
			humanoidRootPart2,
			v9 * Config.HIT_KNOCKBACK + Vector3.new(0, Config.HIT_KNOCKUP, 0),
			0.2
		)
	end
end

function DevouringRushServer.Cancel(player, _: Vector3?, state)
	releaseAll(state)

	if state.cameraRig ~= nil then
		state.cameraRig:Destroy()
		state.cameraRig = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Devouring Rush VFX", character, "Cancel")
	end

	if state.CleanIt then
		state.CleanIt:Clean()
	end
end

return DevouringRushServer