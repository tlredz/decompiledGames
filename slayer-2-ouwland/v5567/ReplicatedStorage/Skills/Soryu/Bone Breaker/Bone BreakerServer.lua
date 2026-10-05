local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_Util = require(SAM.Services.Combat_Util)
local Checker = require(CAM.Global.Checker)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local DebrisModule = require(CAM.DebrisModule)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local SkillStorage = require(ServerStorage2.SAM.Utility.SkillStorage)
local BoneBreakerServer = {
	Id = {}
}
local boneBreakerUser = script.BoneBreakerUser
local boneBreakerVictim = script.BoneBreakerVictim

function BoneBreakerServer.Hold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = BoneBreakerServer.Id[player.UserId]
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Bone Breaker VFX", character, "Start", humanoidRootPart.CFrame)
	task.wait(Config.SWEEP_AT)

	if BoneBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local counterTarget = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p, _, p2)
			if counterTarget == nil and p2 == true then
				counterTarget = p
			end
		end
	})

	if counterTarget then
		local getID = SkillStorage.GetID(player, script.Parent.Name)
		getID.CounterTarget = counterTarget
		EffectsEvent.ToClient(
			player,
			"force_skill_actions_server",
			script.Parent.Name,
			"Counter",
			nil,
			true,
			counterTarget
		)
	end
end

function BoneBreakerServer.UnHold(p)
	BoneBreakerServer.Cancel(p)
end

function BoneBreakerServer.Counter(player, _: Vector3?, instance, _)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoid2 = instance and instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid2 and humanoid2.RootPart
	local animator2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")

	if animator == nil or humanoidRootPart == nil or rootPart == nil or animator2 == nil then
		return
	end

	if not Checker.check_victim(script, character, instance) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local v2 = (rootPart.Position - humanoidRootPart.Position) * createVector(1, 0, 1)

	if v2.Magnitude < 0.01 then
		v2 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	end

	local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v2.Unit)
	local grabPin = RaycastHelper.ResolveGrabPin(humanoidRootPart.Position, cframe, Config.GRAB_WALL_CLEARANCE)
	humanoidRootPart.CFrame = grabPin
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.THROW_AT)
	Utility.AddValue(getvaluesfolder, "NR", Config.THROW_AT)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.THROW_AT)
	Utility.AddValue(getvaluesfolder, "iframe", Config.THROW_AT)
	Utility.lock(humanoidRootPart, grabPin, Config.THROW_AT)
	Combat_Util.Cancel(script, getvaluesfolder2, true)
	Utility.AddValue(getvaluesfolder2, "iframe", Config.THROW_AT, "StringValue", character.Name)
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.THROW_AT)
	Utility.AddValue(getvaluesfolder2, "skill_stand_still", Config.THROW_AT)
	Utility.AddValue(getvaluesfolder2, "NR", Config.THROW_AT)
	Utility.lock(rootPart, grabPin * Config.GRAB_VICTIM_OFFSET, Config.THROW_AT - 0.05)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Bone Breaker VFX", character, "Grab", instance, grabPin)
	local track = animator:LoadAnimation(boneBreakerUser)
	track:Play()
	DebrisModule:AddItem(track, Config.THROW_AT)
	local track2 = animator2:LoadAnimation(boneBreakerVictim)
	track2:Play()
	DebrisModule:AddItem(track2, Config.THROW_AT)
	CharGrabPosCorrector.Do(instance, track2, Config.THROW_AT + 0.05, character)
	task.wait(Config.SNAP_AT)

	if instance.Parent == nil or rootPart.Parent == nil then
		return
	end

	local check_victim = Checker.check_victim(script, character, instance)

	if check_victim == true then
		Combat_Util.Damage(script, character, instance, {
			Base = Config.SNAP_DAMAGE,
			Skill = script.Parent.Name
		})
	elseif check_victim == "Blocking" then
		Combat_Util.Block(script, character, instance, Config.SNAP_BLOCK_BREAK)
	end

	task.wait(Config.THROW_AT - Config.SNAP_AT)

	if instance.Parent == nil or rootPart.Parent == nil then
		return
	end

	task.wait()

	if instance.Parent == nil or rootPart.Parent == nil then
		return
	end

	local check_victim2 = Checker.check_victim(script, character, instance)

	if check_victim2 == true then
		Combat_Util.Damage(script, character, instance, {
			Base = Config.SLAM_DAMAGE,
			Skill = script.Parent.Name
		})
		Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SLAM_STUN)
		Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLAM_STUN)
		Combat_Util.Knockback(script, character, rootPart, -grabPin.LookVector * Config.SLAM_KNOCKBACK, 0.2)
	elseif check_victim2 == "Blocking" then
		Combat_Util.Block(script, character, instance, Config.SLAM_BLOCK_BREAK)
	end
end

function BoneBreakerServer.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Bone Breaker VFX", character, "Cancel")
	end
end

return BoneBreakerServer