local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Checker = require(CAM.Global.Checker)
local CombatBalance = require(CAM.Global.CombatBalance)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local DebrisModule = require(CAM.DebrisModule)
local PartBox = require(CAM.Global.PartBox)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local BodhisattvaServer = {
	Id = {}
}

function BodhisattvaServer.Hold(player, _: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local cFrame = humanoidRootPart.CFrame
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ANIMATION_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.ANIMATION_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.ANIMATION_DURATION))
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local attachment = Instance.new("Attachment")
	attachment.Parent = humanoidRootPart
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.MaxAxesForce = createVector(100000, 100000, 100000)
	alignPosition.Responsiveness = 200
	alignPosition.Position = cFrame.Position
	alignPosition.Parent = humanoidRootPart
	cleanIt:Add(alignPosition)
	cleanIt:Add(attachment)
	DebrisModule:AddItem(alignPosition, Config.ANIMATION_DURATION + 1)
	DebrisModule:AddItem(attachment, Config.ANIMATION_DURATION + 1)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "HighlightOthers", Config.ANIMATION_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.ANIMATION_DURATION))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function aimCF()
		local _, v2 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
		return CFrame.new(cFrame.Position) * CFrame.Angles(0, v2, 0)
	end

	local v2 = BodhisattvaServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(humanoidRootPart, "Bodhisattva VFX", character, "IceStatue", cFrame)
	task.wait(Config.UPDRAFT_TIME)

	if BodhisattvaServer.Id[player.UserId] ~= v2 then
		return
	end

	local instances = {}
	cleanIt:Add(PartBox.new({
		Shape = "Cylinder",
		Center = aimCF() * CFrame.new(0, 0, -Config.UPDRAFT_ZONE_FORWARD),
		Size = Config.UPDRAFT_ZONE_SIZE,
		MaxDuration = Config.IMPACT_TIME_2 - Config.UPDRAFT_TIME,
		caster = character,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				local block = Combat_Util.Block
				local script2 = script
				local v5

				if CombatBalance.IsPvP(character, instance) then
					v5 = Config.BLOCK_DAMAGE
				else
					v5 = Config.PVE_BLOCK_BREAK
				end

				block(script2, character, instance, v5)
			elseif p3 == true then
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if table.find(instances, instance) == nil then
					table.insert(instances, instance)
				end

				Combat_Util.Damage(script, character, instance, {
					Base = Config.UPDRAFT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(0, Config.UPDRAFT_KNOCKBACK, 0),
					1.5
				)
				Combat_Util.AddStun(script, character, p2, 1.5)
				Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
			end
		end
	}))
	task.wait(Config.IMPACT_TIME_1 - Config.UPDRAFT_TIME)

	if BodhisattvaServer.Id[player.UserId] ~= v2 then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = aimCF() * CFrame.new(0, 0, -26),
		hitboxSize = Config.IMPACT_HITBOX_SIZE,
		checker = Checker,
		targets = instances,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				local block = Combat_Util.Block
				local script2 = script
				local v6

				if CombatBalance.IsPvP(character, instance) then
					v6 = Config.BLOCK_DAMAGE
				else
					v6 = Config.PVE_BLOCK_BREAK
				end

				block(script2, character, instance, v6)
			elseif p3 == true then
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if table.find(instances, instance) == nil then
					table.insert(instances, instance)
				end

				Combat_Util.Damage(script, character, instance, {
					Base = Config.FIRST_IMPACT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(0, Config.UPDRAFT_KNOCKBACK, 0),
					1.5
				)
				Combat_Util.AddStun(script, character, p2, 1.5)
				Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
			end
		end
	})
	local IMPACT_TIME_1 = Config.IMPACT_TIME_1
	task.wait(Config.IMPACT_TIME_2 - IMPACT_TIME_1)

	if BodhisattvaServer.Id[player.UserId] ~= v2 then
		return
	end

	local v5 = aimCF() -- equivalent call inferred; original call site unknown
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v5 * CFrame.new(0, 0, -26),
		hitboxSize = Config.IMPACT_HITBOX_SIZE,
		checker = Checker,
		targets = instances,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, 6)
			elseif p3 == true then
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SECOND_IMPACT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v5.LookVector * 55 + createVector(0, 15, 0),
					0.3
				)
				Combat_Util.RagDoll(script, character, p2, Config.IMPACT_RAGDOLL)
				Combat_Util.AddStun(script, character, p2, Config.IMPACT_RAGDOLL)
			end
		end
	})
	task.wait(Config.ANIMATION_DURATION - Config.IMPACT_TIME_2)
	cleanIt:Clean()
end

function BodhisattvaServer.UnHold(_, _: Vector3, _) end

function BodhisattvaServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Bodhisattva VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return BodhisattvaServer