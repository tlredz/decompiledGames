game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Utility = require(CAM.Global.Utility)
local Checker = require(CAM.Global.Checker)
local Combat_Util = require(SAM.Services.Combat_Util)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Config = require(script.Parent.Config)
local ChaoticAfterglowServer = {
	Id = {}
}

function ChaoticAfterglowServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ChaoticAfterglowServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Chaotic Afterglow VFX", character, "Start", humanoidRootPart.CFrame)

	for _, v3 in {
		"pause_gameplay",
		"NR",
		"skill_stand_still",
		"iframe"
	} do
		cleanIt:Add(Utility.AddValue(getvaluesfolder, v3, Config.AFTERGLOW_CAST_LOCK))
	end

	task.wait(0.8)

	if v2 ~= ChaoticAfterglowServer.Id[player.UserId] then
		return
	end

	vfxUtility.PlaySound(script, "PS2akazaULTIMATE2explo", humanoidRootPart)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Chaotic Afterglow VFX", character, "Pulse", humanoidRootPart.CFrame)
	local position = humanoidRootPart.Position
	local count = 0

	while v2 == ChaoticAfterglowServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil do
		count += 1
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position.X, humanoidRootPart.Position.Y, position.Z) * humanoidRootPart.CFrame.Rotation,
			hitboxSize = Config.AFTERGLOW_HITBOX_SIZE * (math.max(count - 4, 1) / 15 + 1),
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid.RootPart

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" and not Combat_Util.Block(
					script,
					character,
					instance,
					Config.AFTERGLOW_TICK_BLOCK_BREAK
				) then
					return
				end

				local unit = (rootPart.Position - humanoidRootPart.Position).Unit
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					unit * Config.AFTERGLOW_TICK_KNOCKBACK + vector.create(0, Config.AFTERGLOW_TICK_UPWARD, 0),
					0.3
				)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.AFTERGLOW_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.AFTERGLOW_FINAL_STUN)
				Combat_presets.PlayReactAnim(humanoid)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", rootPart, -1)
			end
		})
		task.wait(0.2)
	end
end

function ChaoticAfterglowServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = ChaoticAfterglowServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)

	for _, v3 in {
		"pause_gameplay",
		"NR",
		"skill_stand_still",
		"iframe"
	} do
		cleanIt:Add(Utility.AddValue(getvaluesfolder, v3, Config.AFTERGLOW_FINISH_LOCK))
	end

	local v3, v4 = ManuelCancel.new(player, 0.93)
	v3:Connect(function()
		ChaoticAfterglowServer.Id[player.UserId] = -1
		ChaoticAfterglowServer.Cancel(player, vector2, p)
	end)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Chaotic Afterglow VFX",
		character,
		"PulseFinal",
		humanoidRootPart.CFrame
	)
	task.wait(0.4)

	if ChaoticAfterglowServer.Id[player.UserId] ~= v2 then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame,
		hitboxSize = Config.AFTERGLOW_FINAL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			local rootPart = instance:FindFirstChild("Humanoid").RootPart

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" and not Combat_Util.Block(
				script,
				character,
				instance,
				Config.AFTERGLOW_FINAL_BLOCK_BREAK
			) then
				return
			end

			Combat_Util.Damage(script, character, instance, {
				Base = Config.AFTERGLOW_FINAL_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script, character, p2, Config.AFTERGLOW_STUN)
			EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", rootPart, -1)
			Combat_Util.RagDoll(script, character, p2, Config.AFTERGLOW_FINAL_STUN)
			local unit = (rootPart.Position - humanoidRootPart.Position).Unit
			Combat_Util.Knockback(
				script,
				character,
				rootPart,
				unit * Config.AFTERGLOW_FINAL_KNOCKBACK + vector.create(0, Config.AFTERGLOW_FINAL_UPWARD, 0),
				0.45
			)
		end
	})
	v4()
	cleanIt:Clean()
end

function ChaoticAfterglowServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	EffectsEvent.ToAllInRange(player, "Chaotic Afterglow VFX", player.Character, "Cancel")
	cleanIt:Clean()
end

return ChaoticAfterglowServer