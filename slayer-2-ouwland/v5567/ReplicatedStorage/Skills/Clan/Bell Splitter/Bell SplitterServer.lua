local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Checker = require(CAM.Global.Checker)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Config = require(script.Parent.Config)
local BellSplitterServer = {
	Id = {}
}
local v = {
	"Swing_1",
	"Swing_2",
	"Swing_3",
	"Swing_4",
	"Swing_5",
	"Swing_6",
	"Swing_7"
}

local function playPhase(animator, animator2, animation, animation2, flag: boolean?)
	local track = animator:LoadAnimation(animation)
	track.Looped = flag == true
	track:Play()
	DebrisModule:AddItem(track, Config.CUTSCENE)
	local track2

	if animator2 ~= nil then
		track2 = animator2:LoadAnimation(animation2)
		track2.Looped = flag == true
		track2:Play()
		DebrisModule:AddItem(track2, Config.CUTSCENE)
	end

	return track, track2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPhase(object, object2)
	if object then
		object:Stop()
	end

	if object2 then
		object2:Stop()
	end
end

local v2 = {
	"JumpCaster",
	"JumpTarget",
	"ClashLoopCaster",
	"ClashLoopTarget",
	"ClashEndCaster",
	"ClashEndTarget"
}

local function warmClips(animator)
	for _, childName in v2 do
		local child = script:FindFirstChild(childName)

		if child ~= nil then
			animator:LoadAnimation(child):Destroy()
		end
	end
end

function BellSplitterServer.Hold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(humanoidRootPart, "BellSplitterVFX", character, "Start")
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator ~= nil then
		task.spawn(warmClips, animator)
	end
end

function BellSplitterServer.UnHold(player, _: Vector3?, p)
	local v3

	if p == nil then
		v3 = false
	else
		v3 = p.countered == true
	end

	local character = player and player.Character

	if not v3 and character ~= nil then
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder ~= nil then
			Utility.AddTimedValue(
				getvaluesfolder,
				"skillsdisabled",
				Config.WHIFF_LOCK,
				"StringValue",
				Config.WHIFF_LOCKED_SKILLS
			):SetAttribute(
				"_AttackLock",
				true
			)
			Utility.AddValue(getvaluesfolder, "combatdisabled", Config.WHIFF_LOCK)
		end
	end

	BellSplitterServer.Cancel(player)
end

function BellSplitterServer.Counter(player, _: Vector3?, instance, p)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid2 = instance and instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid2 and humanoid2.RootPart
	local animator2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")

	if humanoidRootPart == nil or animator == nil or rootPart == nil or not Checker.check_victim(
		script,
		character,
		instance
	) then
		return
	end

	if p ~= nil then
		p.countered = true
	end

	local v3 = BellSplitterServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)
	local rotation = humanoidRootPart.CFrame.Rotation
	local rotation2 = rootPart.CFrame.Rotation
	local position = rootPart.Position
	local v4 = (humanoidRootPart.Position - position) * createVector(1, 0, 1)
	local v5 = v4.Magnitude < 0.01 and createVector(0, 0, 1) or v4.Unit
	local cframe = CFrame.lookAt(position, position - v5)

	local function stillRunning()
		return v3 == BellSplitterServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil
	end

	if humanoid2 ~= nil then
		Combat_presets.stop_extra_anims(humanoid2, v)
	end

	local v6, v7 = playPhase(animator, animator2, script.JumpCaster, script.JumpTarget)
	local v8 = v6
	local v9 = v7
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CUTSCENE)
	Utility.AddValue(getvaluesfolder, "NR", Config.CUTSCENE)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.CUTSCENE)
	Utility.AddValue(getvaluesfolder, "iframe", Config.CUTSCENE)
	Utility.lock(humanoidRootPart, cframe, Config.LOCK_DURATION)
	Combat_Util.Cancel(script, getvaluesfolder2, true)
	Utility.AddValue(getvaluesfolder2, "iframe", Config.CUTSCENE, "StringValue", character.Name)
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.CUTSCENE)
	Utility.AddValue(getvaluesfolder2, "NR", Config.CUTSCENE)
	Utility.AddValue(getvaluesfolder2, "skill_stand_still", Config.CUTSCENE)
	Utility.lock(rootPart, cframe, Config.LOCK_DURATION)
	task.delay(Config.CUTSCENE, function()
		local v10

		if v3 == BellSplitterServer.Id[player.UserId] then
			v10 = humanoidRootPart.Parent ~= nil
		else
			v10 = false
		end

		if not v10 or instance.Parent == nil then
			return
		end

		Combat_Util.AddStun(script, character, getvaluesfolder2, Config.END_STUN)
		local v11 = Utility.AddValue(getvaluesfolder2, Config.SLOW_VALUE, Config.END_SLOW_DURATION)
		v11:AddTag(StatTypes.ValueStatTag)
		v11:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.END_SLOW_FACTOR)
		local v12 = Utility.AddValue(getvaluesfolder2, Config.FIST_DEBUFF_VALUE, Config.FIST_DEBUFF_DURATION)
		v12:AddTag(StatTypes.ValueStatTag)
		v12:SetAttribute(
			StatTypes.StatToAttribute("Additional Damage Factor"),
			(`{Config.FIST_DEBUFF_MASTERY},{-Config.M1_DAMAGE_REDUCTION}`)
		)
	end)

	local function runPhase(data)
		local v10

		if v3 == BellSplitterServer.Id[player.UserId] then
			v10 = humanoidRootPart.Parent ~= nil
		else
			v10 = false
		end

		if not v10 then
			return
		end

		local v12 = v9
		stopPhase(v8, v12) -- equivalent call inferred; original call site unknown
		v8, v9 = playPhase(animator, animator2, data.caster, data.target, data.looped)

		if data.correct ~= true then
			return
		end

		if v8 ~= nil and v8.IsPlaying then
			CharGrabPosCorrector.Do(character, v8, Config.CLASH_END_LENGTH, character, true, rotation)
		end

		if v9 ~= nil and v9.IsPlaying then
			CharGrabPosCorrector.Do(instance, v9, Config.CLASH_END_LENGTH, character, true, rotation2)
		end
	end

	local v10 = {
		{
			at = Config.LOOP_AT,
			caster = script.ClashLoopCaster,
			target = script.ClashLoopTarget,
			looped = true
		},
		{
			at = Config.END_AT,
			caster = script.ClashEndCaster,
			target = script.ClashEndTarget,
			correct = true
		}
	}
	task.delay(Config.CAM_SUBJECT_AT, function()
		local v11

		if v3 == BellSplitterServer.Id[player.UserId] then
			v11 = humanoidRootPart.Parent ~= nil
		else
			v11 = false
		end

		if not v11 then
			return
		end

		local v12 = Config.CUTSCENE - Config.CAM_SUBJECT_AT
		local head = character:FindFirstChild("Head")

		if head ~= nil then
			Utility.AddValue(getvaluesfolder, "camsubject", v12, "ObjectValue", head)
		end

		local head2 = instance:FindFirstChild("Head")

		if head2 ~= nil then
			Utility.AddValue(getvaluesfolder2, "camsubject", v12, "ObjectValue", head2)
		end
	end)

	for _, v11 in Config.VFX_BEATS do
		local v12 = v11
		task.delay(v11.at, function()
			local v13

			if v3 == BellSplitterServer.Id[player.UserId] then
				v13 = humanoidRootPart.Parent ~= nil
			else
				v13 = false
			end

			if not v13 then
				return
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "BellSplitterVFX", character, v12.state, instance, cframe)
		end)
	end

	for _, v11 in v10 do
		task.delay(v11.at, runPhase, v11)
	end
end

function BellSplitterServer.Cancel(player)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "BellSplitterVFX", character, "Cancel")
end

return BellSplitterServer