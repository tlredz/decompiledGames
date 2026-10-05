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
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local FaceBreakerServer = {
	Id = {},
	Cleaners = {}
}
local faceBreakerGrab = script.FaceBreakerGrab
local faceBreakerVictim = script.FaceBreakerVictim

function FaceBreakerServer.Hold(player, _: Vector3?, p)
	local cleaner = FaceBreakerServer.Cleaners[player.UserId]

	if cleaner then
		cleaner:Clean()
	end

	local maid = cleanit.new()
	FaceBreakerServer.Cleaners[player.UserId] = maid
	p.CleanIt = maid
	local v2 = FaceBreakerServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_DASH_DURATION))
	maid:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.MAX_DASH_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Face Breaker VFX", character, "Start", humanoidRootPart.CFrame)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	task.wait(Config.STARTUP)

	if FaceBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	p.probeVictim = nil
	local flag = false

	while FaceBreakerServer.Id[player.UserId] == v2 and player.Parent ~= nil and humanoidRootPart.Parent ~= nil do
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
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
		end

		task.wait(0.05)
	end
end

function FaceBreakerServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	FaceBreakerServer.Cleaners[player.UserId] = cleanIt
	cleanIt:Clean()
	local v2 = FaceBreakerServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3, v4 = ManuelCancel.new(player, Config.GRAB_TOTAL + 0.5)
	v3:Connect(function()
		FaceBreakerServer.Id[player.UserId] = -1
		FaceBreakerServer.Cancel(player, nil, state)
	end)
	cleanIt:Add(v4)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_TOTAL))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.GRAB_TOTAL))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_TOTAL))
	local cFrame = humanoidRootPart.CFrame
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local animator2 = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		targets = state.probeVictim,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if v5 ~= nil then
				return
			end

			local humanoid2 = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid2 == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.GRAB_BLOCK_BREAK)
			elseif p2 == true then
				v5 = instance
				v6 = p
				v7 = humanoidRootPart2
				animator2 = humanoid2:FindFirstChild("Animator")
			end
		end
	})

	if v5 == nil then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Face Breaker VFX", character, "Cancel")
		cleanIt:Clean()
	else
		local v8 = v5
		local v9 = v6
		local v10 = v7
		local grabPin = RaycastHelper.ResolveGrabPin(humanoidRootPart.Position, cFrame, Config.GRAB_WALL_CLEARANCE)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Face Breaker VFX", character, "Grab", v8, grabPin)
		cleanIt:Add(Utility.lock(humanoidRootPart, grabPin, Config.GRAB_TOTAL))
		local track = animator:LoadAnimation(faceBreakerGrab)
		cleanIt:Add(track)
		track:Play()
		Combat_Util.Cancel(script, v9)
		cleanIt:Add(Utility.AddValue(v9, "iframe", Config.SLAM_AT, "StringValue", character.Name))
		cleanIt:Add(Utility.AddValue(v9, "pause_gameplay", Config.SLAM_AT))
		cleanIt:Add(Utility.AddValue(v9, "skill_stand_still", Config.SLAM_AT))
		cleanIt:Add(Utility.AddValue(v9, "NR", Config.SLAM_AT))
		cleanIt:Add(Utility.lock(v10, grabPin * Config.GRAB_VICTIM_OFFSET, Config.SLAM_AT - 0.05))

		if animator2 and animator2.Parent ~= nil and v8.Parent ~= nil then
			local track2 = animator2:LoadAnimation(faceBreakerVictim)
			cleanIt:Add(track2)
			track2:Play()
			CharGrabPosCorrector.Do(v8, track2, Config.SLAM_AT + 0.05, character)
		end

		Combat_Util.Damage(script, character, v8, {
			Base = Config.GRAB_DAMAGE,
			Skill = script.Parent.Name
		})
		task.wait(Config.SLAM_AT)

		if FaceBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Face Breaker VFX", character, "Slam", v8, humanoidRootPart.CFrame)
		task.wait()

		if FaceBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		if v8.Parent ~= nil and v10.Parent ~= nil then
			local check_victim = Checker.check_victim(script, character, v8)

			if check_victim == true then
				Combat_Util.Damage(script, character, v8, {
					Base = Config.SLAM_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, v9, Config.SLAM_STUN)
				Combat_Util.RagDoll(script, character, v9, Config.SLAM_STUN)
				Combat_Util.Knockback(script, character, v10, Vector3.new(0, -Config.SLAM_KNOCKDOWN, 0), 0.2)
			elseif check_victim == "Blocking" then
				Combat_Util.Block(script, character, v8, Config.SLAM_BLOCK_BREAK)
			end
		end

		task.wait(Config.GRAB_TOTAL - Config.SLAM_AT)

		if FaceBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		cleanIt:Clean()
	end
end

function FaceBreakerServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	FaceBreakerServer.Cleaners[player.UserId] = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Face Breaker VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return FaceBreakerServer