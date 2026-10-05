local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local DemonCoagulantServer = {
	Id = {}
}
local name = script.Parent.Name

function DemonCoagulantServer.Hold(player, vector: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if humanoidRootPart == nil or animator == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = DemonCoagulantServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.ANIM_DURATION + 0.5)
	v3:Connect(function()
		DemonCoagulantServer.Id[player.UserId] = -1
		DemonCoagulantServer.Cancel(player, vector, p)
	end)
	cleanIt:Add(v4)
	local track = animator:LoadAnimation(script.Caster)
	cleanIt:Add(track)
	track:Play()
	local cFrame = humanoidRootPart.CFrame
	local v5 = {}
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
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid2 == nil or humanoidRootPart2 == nil then
				return
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p3 == true then
				table.insert(v5, {
					model = instance,
					root = humanoidRootPart2,
					values = values,
					humanoid = humanoid2
				})
			end
		end
	})
	task.delay(Config.VFX_AT, function()
		if DemonCoagulantServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "DemonCoagulantVFX", character)
	end)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ANIM_DURATION))

	if #v5 == 0 then
		task.wait(Config.ANIM_DURATION)
	else
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.ANIM_DURATION))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.ANIM_DURATION))
		cleanIt:Add(Utility.lock(humanoidRootPart, cFrame, Config.ANIM_DURATION))

		for k, v6 in v5 do
			for _, v7 in {
				"pause_gameplay",
				"iframe",
				"skill_stand_still",
				"NR"
			} do
				cleanIt:Add(Utility.AddValue(v6.values, v7, Config.ANIM_DURATION))
			end

			local v7 = ((k - 1) % 2 == 0 and 1 or -1) * math.floor(k / 2) * Config.GRAB_OFFSET_STRIDE
			local lock = Utility.lock(v6.root, cFrame * CFrame.new(v7, 0, -Config.GRAB_FORWARD), Config.ANIM_DURATION)

			if lock then
				v6.lock = lock
				cleanIt:Add(lock)
			end

			local animator2 = v6.humanoid:FindFirstChildOfClass("Animator")

			if animator2 == nil then
				continue
			end

			local track2 = animator2:LoadAnimation(script.Target)
			cleanIt:Add(track2)
			track2:Play()
		end

		task.wait(Config.DOSE_AT)

		if DemonCoagulantServer.Id[player.UserId] ~= v2 then
			cleanIt:Clean()
			return false
		end

		for _, v6 in v5 do
			if v6.root.Parent == nil then
				continue
			end

			local v7 = Utility.AddValue(v6.values, Config.DEBUFF_VALUE, Config.DEBUFF_DURATION)
			v7:AddTag(StatTypes.ValueStatTag)
			v7:SetAttribute(StatTypes.StatToAttribute("Additional Damage Factor"), Config.DEBUFF_DAMAGE_FACTOR)
			Utility.AddValue(v6.values, Config.TICK_VALUE, Config.TICK_DURATION, "ObjectValue", character):SetAttribute(
				"Skill",
				name
			)
		end

		task.wait(Config.FLING_AT - Config.DOSE_AT)

		if DemonCoagulantServer.Id[player.UserId] ~= v2 then
			cleanIt:Clean()
			return false
		end

		for _, v6 in v5 do
			if not v6.lock then
				continue
			end

			cleanIt:Remove(v6.lock)
			v6.lock:Destroy()
			v6.lock = nil
		end

		task.wait()

		if DemonCoagulantServer.Id[player.UserId] ~= v2 then
			cleanIt:Clean()
			return false
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "DemonCoagulantVFX", character, "Connect")

		for _, v6 in v5 do
			if not (v6.root.Parent ~= nil and Checker.check_victim(script, character, v6.model, {
				iframe = true
			}) ~= nil) then
				continue
			end

			Combat_Util.Damage(script, character, v6.model, {
				Base = Config.FLING_DAMAGE,
				Skill = name
			})
			Combat_Util.AddStun(script, character, v6.values, Config.IMPACT_STUN)
			Combat_Util.RagDoll(script, character, v6.values, Config.IMPACT_STUN)
			Combat_Util.Knockback(
				script,
				character,
				v6.root,
				cFrame.LookVector * Config.KNOCKBACK + Vector3.new(0, Config.KNOCKUP, 0),
				Config.KNOCKBACK_DURATION
			)
			Combat_presets.PlayReactAnim(v6.humanoid, nil, nil)
		end

		task.wait(Config.ANIM_DURATION - Config.FLING_AT)
	end

	if DemonCoagulantServer.Id[player.UserId] ~= v2 then
		return false
	end

	cleanIt:Clean()
	return true
end

function DemonCoagulantServer.Cancel(_, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return DemonCoagulantServer