local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local ShoulderThrowServer = {
	Id = {}
}
local name = script.Parent.Name

function ShoulderThrowServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShoulderThrowServer.Id[player.UserId]
	local character = player.Character
	local animator = character.Humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.25))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "WalkSpeed", 1.25, "NumberValue", Config.WALK_SPEED))
	EffectsEvent.ToAllInRange(humanoidRootPart, "GauntletInit", character)
	task.wait(0.6833333333333333)

	if ShoulderThrowServer.Id[player.UserId] ~= v2 then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	EffectsEvent.ToAllInRange(humanoidRootPart, "Shoulder Throw VFX", character, "Grab", cFrame)
	local v3 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, values, p3)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true or p3 == "Blocking" then
				table.insert(v3, {
					model = instance,
					values = values,
					root = humanoidRootPart2,
					animator = humanoid:FindFirstChild("Animator")
				})
			end
		end
	})

	if #v3 == 0 then
		task.wait(0.5666666666666667)

		if ShoulderThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	else
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 0.5833333333333334))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", 0.5833333333333334))
		cleanIt:Add(Utility.lock(humanoidRootPart, cFrame, 0.5833333333333334))

		for _, v4 in v3 do
			cleanIt:Add(Utility.AddValue(v4.values, "iframe", 0.5833333333333334, "StringValue", character.Name))
			cleanIt:Add(Utility.AddValue(v4.values, "pause_gameplay", 0.5833333333333334))
			cleanIt:Add(Utility.AddValue(v4.values, "skill_stand_still", 0.5833333333333334))
			cleanIt:Add(Utility.AddValue(v4.values, "NR", 0.5833333333333334))
			cleanIt:Add(Utility.lock(v4.root, cFrame, 0.55))

			if not (v4.animator and v4.animator.Parent ~= nil and v4.model.Parent ~= nil) then
				continue
			end

			local track = v4.animator:LoadAnimation(script.ShoulderThrowVictim)
			cleanIt:Add(track)
			track:Play()
			CharGrabPosCorrector.Do(v4.model, track, 0.6333333333333334, character)
		end

		local track = animator:LoadAnimation(script.ShoulderThrowUser)
		cleanIt:Add(track)
		track:Play()
		task.wait(0.5833333333333334)

		if ShoulderThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Shoulder Throw VFX", character, "Throw", cFrame)
		task.wait()

		if ShoulderThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		for _, v4 in v3 do
			if Checker.check_victim(script, character, v4.model) == nil then
				continue
			end

			Combat_Util.Damage(script, character, v4.model, {
				Base = Config.SLAM_DAMAGE,
				Skill = name
			})
			Combat_Util.AddStun(script, character, v4.values, Config.SLAM_STUN)
			Combat_Util.RagDoll(script, character, v4.values, Config.RAGDOLL_DURATION)
			Combat_Util.Knockback(
				script,
				character,
				v4.root,
				cFrame.LookVector * Config.SLAM_FORWARD + Vector3.new(0, -Config.SLAM_DOWNWARD, 0),
				0.2
			)
		end

		task.wait(0.8)

		if ShoulderThrowServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	end
end

function ShoulderThrowServer.UnHold(_, _: Vector3?, _) end

function ShoulderThrowServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Shoulder Throw VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return ShoulderThrowServer