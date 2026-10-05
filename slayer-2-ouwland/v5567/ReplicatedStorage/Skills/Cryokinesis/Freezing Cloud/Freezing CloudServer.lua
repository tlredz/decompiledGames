local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Checker = require(CAM.Global.Checker)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local FreezingCloudServer = {
	Id = {}
}

local function stripCloak(character)
	if character == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder == nil then
		return
	end

	for _, stringValue in getvaluesfolder:GetChildren() do
		if not (stringValue.Name == "Transparent" and stringValue:IsA("StringValue") and stringValue.Value == script.Parent.Name) then
			continue
		end

		stringValue:Destroy()
	end
end

function FreezingCloudServer.Hold(player, _: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = FreezingCloudServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(humanoidRootPart, "Freezing Cloud VFX", character, "Startup")
	task.wait(Config.STARTUP_TO_DASH)

	if FreezingCloudServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"Transparent",
		Config.MAX_DASH_DURATION,
		"StringValue",
		script.Parent.Name
	))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.MAX_DASH_DURATION))
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	p.probeVictim = nil

	while FreezingCloudServer.Id[player.UserId] == v2 do
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = humanoidRootPart.CFrame * CFrame.new(Config.FRONT_STOP_OFFSET),
			BoxSize = Config.FRONT_STOP_SIZE
		})

		if singlePartHitbox then
			p.probeVictim = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		else
			task.wait(0.1)
		end
	end

	stripCloak(character)
end

function FreezingCloudServer.UnHold(player, _: Vector3, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	stripCloak(character)
	local v2 = FreezingCloudServer.Id[player.UserId]
	rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.2))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", 1.2))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", 1.2))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 1.2))
	local v3, v4 = ManuelCancel.new(player, 2)
	v3:Connect(function()
		FreezingCloudServer.Id[player.UserId] = -1
		FreezingCloudServer.Cancel(player, nil, state)
	end)
	local flag = false
	local count = 0
	local v5 = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.RESOLVE_HITBOX_OFFSET,
		hitboxSize = Config.RESOLVE_HITBOX_SIZE,
		targets = state.probeVictim,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid2.RootPart

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == true or p2 == "Blocking" then
				flag = true

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, 4)
					return
				end

				count += 1
				local v6 = rootPart.CFrame * Config.RESOLVE_HITBOX_OFFSET
				cleanIt:Add(Utility.AddValue(p, "iframe", Config.GRAB_VICTIM_DURATION, "StringValue", character.Name))
				cleanIt:Add(Utility.AddValue(p, "pause_gameplay", Config.GRAB_VICTIM_DURATION))
				cleanIt:Add(Utility.AddValue(p, "skill_stand_still", Config.GRAB_VICTIM_DURATION))
				cleanIt:Add(Utility.lock(rootPart2, v6, Config.GRAB_VICTIM_DURATION))
				humanoid2:FindFirstChild("Animator"):LoadAnimation(script.FreezingCloudVictim):Play()

				if count == 1 then
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_VICTIM_DURATION))
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_VICTIM_DURATION))
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.GRAB_VICTIM_DURATION))
					cleanIt:Add(Utility.lock(rootPart, v6, Config.GRAB_VICTIM_DURATION))
					v5 = v6
					animator:LoadAnimation(script.FreezingCloudUser):Play()
				end

				local v7 = count == 1
				task.delay(Config.GRAB_VICTIM_DURATION, function()
					if v7 then
						cleanIt:Clean()
					end

					task.wait()

					if v2 ~= FreezingCloudServer.Id[player.UserId] then
						return
					end

					if Checker.check_victim(script, character, instance) ~= nil then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT_DAMAGE * 5,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
						Combat_Util.RagDoll(script, character, p, Config.RAGDOLL_DURATION)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							v5.LookVector * Config.HIT_KNOCKBACK + createVector(0, 8, 0),
							0.2
						)
					end
				end)
			end
		end
	})

	if FreezingCloudServer.Id[player.UserId] ~= v2 then
		return
	end

	if flag then
		EffectsEvent.ToAllInRange(rootPart, "Freezing Cloud VFX", character, "Hit")
		return
	end

	local v6 = rootPart.CFrame * CFrame.new(0, 0, -15)
	EffectsEvent.ToAllInRange(rootPart, "Freezing Cloud VFX", character, "Clone", v6)
	task.wait(1)

	if FreezingCloudServer.Id[player.UserId] ~= v2 then
		return
	end

	local v7 = 0
	local instances = {}

	for i = 1, 4 do
		if FreezingCloudServer.Id[player.UserId] ~= v2 then
			break
		end

		local hitboxSize = createVector(25, 17.5, 12.5) * (i / 5 + 1)
		local v9 = v7 + hitboxSize.Z / 2
		local hitboxCFrame = v6 * CFrame.new(0, 0, -v9)
		v7 = v9 + hitboxSize.Z / 2
		local v11 = i
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = hitboxSize,
			targets = instances,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart2 = humanoid2.RootPart

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, 3)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						rootPart.CFrame.LookVector * Config.HIT_KNOCKBACK + createVector(0, 8, 0),
						0.2
					)
				elseif p2 == true then
					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT_DAMAGE,
						Skill = script.Parent.Name
					})

					if v11 == 4 then
						Combat_Util.RagDoll(script, character, p, Config.RAGDOLL_DURATION)
						Combat_Util.AddStun(script, character, p, Config.RAGDOLL_DURATION)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							rootPart.CFrame.LookVector * Config.FREEZE_KNOCKBACK + createVector(0, 8, 0),
							0.5
						)
					else
						Combat_presets.PlayReactAnim(humanoid2)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							rootPart.CFrame.LookVector * 32.5 + createVector(0, 10, 0),
							1
						)
						Combat_Util.AddStun(script, character, p, Config.HIT_STUN)
					end
				end
			end
		})
		task.wait(0.08)
	end

	task.wait(Config.MISS_RECOVERY)
	v4()
	cleanIt:Clean()
end

function FreezingCloudServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	stripCloak(character)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Freezing Cloud VFX", character, "Cancel")
	end
end

return FreezingCloudServer