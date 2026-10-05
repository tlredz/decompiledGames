local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local FlashingWillowServer = {
	Id = {}
}

function FlashingWillowServer.Hold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 4)
	cleanIt:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
	local v2 = FlashingWillowServer.Id[player.UserId]
	state.released = false
	task.delay(Config.TAP_THRESHOLD, function()
		if FlashingWillowServer.Id[player.UserId] ~= v2 or state.released or (rootPart == nil or rootPart.Parent == nil) then
			return
		end

		state.airHold = Combat_Util.Add_air_combo_bp(rootPart, nil, Config.UPDRAFT_HEIGHT, nil, Config.UPDRAFT_DURATION)
		cleanIt:Add(state.airHold)
	end)
	EffectsEvent.ToAllInRange(rootPart, "Flashing Willow Ground VFX", character, "Start", rootPart.CFrame)
end

function FlashingWillowServer.UnHold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	state.released = true
	local v2 = FlashingWillowServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local RELEASE_DELAY = Config.RELEASE_DELAY
	local v3, v4 = ManuelCancel.new(player, 1.6)
	v3:Connect(function()
		FlashingWillowServer.Id[player.UserId] = -1
		FlashingWillowServer.Cancel(player, vector2, state)
	end)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", RELEASE_DELAY)
	Utility.AddValue(getvaluesfolder, "NR", RELEASE_DELAY)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", RELEASE_DELAY)

	if state.airHold then
		cleanIt:Remove(state.airHold)
		state.airHold:Destroy()
		state.airHold = nil
	end

	local _, hitboxCFrame = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)

	if hitboxCFrame == nil then
		return
	end

	local position = hitboxCFrame.Position + Vector3.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0)
	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	cleanIt:Add(attachment)
	DebrisModule:AddItem(attachment, Config.RELEASE_DELAY)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = createVector(20000, 20000, 20000)
	alignPosition.Responsiveness = 45
	alignPosition.Attachment0 = attachment
	alignPosition.Parent = attachment
	alignPosition.Position = position
	cleanIt:Add(alignPosition)
	DebrisModule:AddItem(alignPosition, Config.RELEASE_DELAY)
	attachment.Parent = humanoidRootPart
	cleanIt:Add(function()
		if humanoidRootPart then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	task.wait(0.25)

	if FlashingWillowServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Flashing Willow Ground VFX", character, "Pulse", hitboxCFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.PULSE_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid2 and humanoid2.RootPart

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return true
			end

			if p2 == "Blocking" and not Combat_Util.Block(script, character, instance, Config.PULSE_BLOCK_BREAK) then
				return
			end

			Combat_Util.Knockback(script, character, rootPart, createVector(0, 5, 0), 0.75)
			EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", rootPart, -1)
			Combat_Util.Damage(script, character, instance, {
				Base = Config.PULSE_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script, character, p, Config.PULSE_STUN)
			Combat_presets.PlayReactAnim(humanoid2, nil, 0.5)
		end
	})
	task.wait(0.6)

	if FlashingWillowServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Flashing Willow Ground VFX", character, "PulseFinal", hitboxCFrame)

	for i = 1, 4 do
		if FlashingWillowServer.Id[player.UserId] ~= v2 then
			return
		end

		local v7 = i
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = Config.PULSE_FINISH_HITBOX_SIZE * (i / 16 + 1),
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2 and humanoid2.RootPart

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				if p2 == "Blocking" and not Combat_Util.Block(
					script,
					character,
					instance,
					Config.PULSE_FINISH_BLOCK_BREAK
				) then
					return
				end

				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", rootPart, -1)
				Combat_Util.AddStun(script, character, p, Config.PULSE_FINISH_STUN)
				local unit = (rootPart.Position - humanoidRootPart.Position).Unit

				if v7 == 4 then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.PULSE_FINISH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, unit * Config.PULSE_FINISH_KNOCKBACK, 0.2)
					Combat_Util.RagDoll(script, character, p, Config.PULSE_FINISH_STUN)
				else
					Combat_presets.PlayReactAnim(humanoid2)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.PULSE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, unit * 2 + createVector(0, 0.1, 0), 0.2)
				end
			end
		})
		task.wait(0.18)
	end

	if v2 ~= FlashingWillowServer.Id[player.UserId] then
		return
	end

	v4()
	cleanIt:Clean()
end

function FlashingWillowServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	EffectsEvent.ToAllInRange(player, "Flashing Willow Ground VFX", player.Character, "Cancel")
	cleanIt:Clean()
end

return FlashingWillowServer