local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local StormPiercerServer = {
	Id = {}
}
local name = script.Parent.Name

function StormPiercerServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = StormPiercerServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_DASH_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.MAX_DASH_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Startup", humanoidRootPart.CFrame)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	task.wait(Config.STARTUP_AT)

	if StormPiercerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Dash", humanoidRootPart.CFrame)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Loop", humanoidRootPart.CFrame)
	local formatted = `{player.Name}-{name}-{math.random(1, 99)}`
	p.probeVictim = nil
	local flag = false

	while StormPiercerServer.Id[player.UserId] == v2 and player.Parent ~= nil and humanoidRootPart.Parent ~= nil do
		if not flag then
			local singlePartHitbox = Utility.SinglePartHitbox({
				Caster = character,
				ParamsName = formatted,
				Origin = humanoidRootPart.CFrame * Config.FRONT_STOP_OFFSET,
				BoxSize = Config.FRONT_STOP_SIZE
			})

			if singlePartHitbox then
				p.probeVictim = Utility.find_character_from_descendant(singlePartHitbox)
				flag = true
			end
		end

		if flag then
			EffectsEvent.ToClient(player, "force_skill_actions_server", name, "UnHold", nil)
		end

		task.wait(0.05)
	end
end

function StormPiercerServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = StormPiercerServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = Config.SLAM_AT + Config.ENDLAG

	local function cancel()
		StormPiercerServer.Id[player.UserId] = -1
		StormPiercerServer.Cancel(player, nil, state)
	end

	local v4, v5 = ManuelCancel.new(player, v3 + 0.5, { "Strict_Stun", "KnockedOut" })
	v4:Connect(cancel)
	cleanIt:Add(v5)
	local v6, v7 = ManuelCancel.new(player, v3 + 0.5, nil, script.Parent.Name)
	v6:Connect(cancel)
	cleanIt:Add(v7)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v3))
	local grabPin = RaycastHelper.ResolveGrabPin(
		humanoidRootPart.Position,
		humanoidRootPart.CFrame,
		Config.GRAB_WALL_CLEARANCE
	)
	local v8 = math.max(0, Config.WELD_FORWARD - (grabPin.Position - humanoidRootPart.Position).Magnitude)
	local v9 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.CATCH_HITBOX_OFFSET,
		hitboxSize = Config.CATCH_HITBOX_SIZE,
		targets = state.probeVictim,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid2 == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.CATCH_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.CATCH_DAMAGE,
					Skill = name
				})
				Combat_Util.Add_Strict_Stun(script, character, p, Config.CATCH_STUN)
				local ouwWeld = Utility.CreateOuwWeld(
					humanoidRootPart,
					humanoidRootPart2,
					CFrame.new(0, 0, v8),
					Config.SLAM_AT + 0.5
				)

				if ouwWeld then
					cleanIt:Add(ouwWeld)
				end

				cleanIt:Add(Utility.AddValue(p, "NR", Config.SLAM_AT))
				cleanIt:Add(Utility.AddValue(p, "skill_stand_still", Config.SLAM_AT))
				table.insert(v9, {
					model = instance,
					root = humanoidRootPart2,
					weld = ouwWeld
				})
				local animator2 = humanoid2:FindFirstChild("Animator")

				if animator2 and instance.Parent ~= nil then
					local track = animator2:LoadAnimation(script.Victim)
					cleanIt:Add(track)
					track:Play()
				end
			end
		end
	})

	if #v9 == 0 then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Miss", humanoidRootPart.CFrame)
		EffectsEvent.ToClient(player, "force_skill_actions_server", name, "Cancel", nil, false)
		cleanIt:Clean()
	else
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Hit", humanoidRootPart.CFrame)
		local track = animator:LoadAnimation(script.Attacker)
		cleanIt:Add(track)
		track:Play()
		task.wait(Config.SLAM_AT)

		if StormPiercerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		for _, v10 in v9 do
			if v10.weld then
				v10.weld:Destroy()
			end
		end

		task.wait()

		if StormPiercerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		for _, v10 in v9 do
			local model = v10.model
			local root = v10.root

			if root.Parent == nil then
				continue
			end

			local check_victim = Checker.check_victim(script, character, model)

			if check_victim == nil then
				continue
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(model)

			if check_victim == true then
				local air_combo_bp = root:FindFirstChild("air_combo_bp")

				if air_combo_bp then
					air_combo_bp:Destroy()
				end

				Combat_Util.Damage(script, character, model, {
					Base = Config.SLAM_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SLAM_STUN, true)
				Combat_Util.Knockback(
					script,
					character,
					root,
					humanoidRootPart.CFrame.LookVector * Config.LAUNCH_FORWARD + Vector3.new(0, Config.LAUNCH_UPWARD, 0),
					0.25
				)
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLAM_STUN)
			else
				Combat_Util.Block(script, character, model, Config.SLAM_BLOCK_BREAK)
			end
		end

		task.wait(Config.ENDLAG)

		if StormPiercerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		cleanIt:Remove(track)
		cleanIt:Clean()
	end
end

function StormPiercerServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Storm Piercer VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return StormPiercerServer