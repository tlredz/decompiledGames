local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local PointBlankServer = {
	Id = {}
}

function PointBlankServer.Hold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = PointBlankServer.Id[player.UserId]
	local character = player.Character
	local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_AT + Config.MISS_TAIL)
	Utility.AddValue(getvaluesfolder, "WalkSpeed", Config.GRAB_AT + Config.MISS_TAIL, "NumberValue", Config.WALK_SPEED)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Point Blank VFX", character, "Start", humanoidRootPart.CFrame)
	task.wait(Config.GRAB_AT)

	if PointBlankServer.Id[player.UserId] ~= v2 then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	EffectsEvent.ToAllInRange(humanoidRootPart, "Point Blank VFX", character, "Grab", cFrame)
	local v3 = {}
	local v4 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, values, p2)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.GRAB_BLOCK_BREAK)
			elseif p2 == true and not v4[instance] then
				v4[instance] = true
				table.insert(v3, {
					model = instance,
					values = values,
					root = humanoidRootPart2,
					animator = humanoid:FindFirstChild("Animator"),
					lowerTorso = instance:FindFirstChild("LowerTorso")
				})
			end
		end
	})

	if #v3 == 0 then
		EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
		return
	end

	state.GrabStarted = true
	local grabPin = RaycastHelper.ResolveGrabPin(humanoidRootPart.Position, cFrame, Config.GRAB_WALL_CLEARANCE)
	local v5 = grabPin * Config.GRAB_VICTIM_OFFSET
	EffectsEvent.ToAllInRange(humanoidRootPart, "Point Blank VFX", character, "Slam", grabPin, v5)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 2.3333333333333335))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", 2.3333333333333335))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 2.3333333333333335))
	cleanIt:Add(Utility.lock(humanoidRootPart, grabPin, 2.3333333333333335))
	local maid = cleanIt:Extend()

	for _, v6 in v3 do
		maid:Add(Utility.AddValue(v6.values, "iframe", 2.3333333333333335, "StringValue", character.Name))
		maid:Add(Utility.AddValue(v6.values, "pause_gameplay", 2.3333333333333335))
		maid:Add(Utility.AddValue(v6.values, "skill_stand_still", 2.3333333333333335))
		maid:Add(Utility.AddValue(v6.values, "NR", 2.3333333333333335))
		maid:Add(Utility.AddValue(v6.values, "noragdoll", 2.3333333333333335))
		maid:Add(Utility.lock(v6.root, v5, 2.2333333333333334))

		if not (v6.animator and v6.animator.Parent ~= nil and v6.model.Parent ~= nil) then
			continue
		end

		local track = v6.animator:LoadAnimation(script.PointBlankGrabVictim)
		maid:Add(track)
		track:Play()
		CharGrabPosCorrector.Do(v6.model, track, 2.3333333333333335, character)
	end

	local track = animator:LoadAnimation(script.PointBlankGrabFollowup)
	cleanIt:Add(track)
	track:Play()
	task.wait(0.6)

	if state.GrabStarted ~= true then
		return
	end

	for _, v6 in v3 do
		local check_victim = Checker.check_victim(script, character, v6.model)

		if check_victim == nil then
			continue
		end

		if check_victim == true then
			Combat_Util.Damage(script, character, v6.model, {
				Base = Config.SLAM_DAMAGE,
				Skill = script.Parent.Name
			})
		else
			Combat_Util.Block(script, character, v6.model, Config.SLAM_BLOCK_BREAK)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", v6.root, -1)
	end

	task.wait(1.7333333333333334)

	if state.GrabStarted ~= true then
		return
	end

	maid:Clean()
	task.wait()

	if state.GrabStarted ~= true then
		return
	end

	for _, v6 in v3 do
		local check_victim = Checker.check_victim(script, character, v6.model)

		if check_victim == nil then
			continue
		end

		if check_victim == true then
			Combat_Util.Damage(script, character, v6.model, {
				Base = Config.BLAST_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script, character, v6.values, Config.BLAST_STUN)
			Combat_Util.RagDoll(script, character, v6.values, Config.BLAST_STUN)
			Combat_Util.Knockback(
				script,
				character,
				v6.root,
				grabPin.LookVector * Config.BLAST_FORWARD + Vector3.new(0, -Config.BLAST_DOWNWARD, 0),
				0.2
			)
		else
			Combat_Util.Block(script, character, v6.model, Config.BLAST_BLOCK_BREAK)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", v6.root, -1)
	end

	task.wait(0.6666666666666666)

	if state.GrabStarted ~= true then
		return
	end

	cleanIt:Clean()
end

function PointBlankServer.UnHold(p, vector: Vector3?, p2)
	if p2.GrabStarted ~= true then
		PointBlankServer.Cancel(p, vector, p2)
	end
end

function PointBlankServer.Cancel(player, _: Vector3?, p)
	p.GrabStarted = nil
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Point Blank VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return PointBlankServer