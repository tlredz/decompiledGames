local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage2:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local ImpactSounds = require(ServerStorage.SAM.Utility.ImpactSounds)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local ResoundingSlashesServer = {
	Id = {}
}

function ResoundingSlashesServer.Hold(player, _, p)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	EffectsEvent.ToAllInRange(character, "Resounding SlashesVFX", character, "Start")
	p.Clock = os.clock()
	local v2 = ResoundingSlashesServer.Id[player.UserId]

	local function fn(instance, p2, p3)
		if instance then
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart

			if p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.LOOP_BLOCK_BREAK)
			elseif p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true then
				local v3 = humanoidRootPart.CFrame.UpVector * 0.01
				Combat_Util.AddStun(script, character, p2, 1)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.LOOP_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(script, character, rootPart, v3, 0.15)

				if humanoid then
					Combat_presets.PlayReactAnim(humanoid, math.random(1, 4))
				end
			end
		end
	end

	local LOOP_HITBOX_SIZE = Config.LOOP_HITBOX_SIZE
	local position = humanoidRootPart.Position

	while humanoidRootPart:IsDescendantOf(workspace) and ResoundingSlashesServer.Id[player.UserId] == v2 do
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position.X, humanoidRootPart.Position.Y, position.Z) * humanoidRootPart.CFrame.Rotation * Config.LOOP_HITBOX_OFFSET,
			hitboxSize = LOOP_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
		task.wait(Config.LOOP_INTERVAL)
	end
end

function ResoundingSlashesServer.UnHold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ENDLAG)
	local v2 = ResoundingSlashesServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		ResoundingSlashesServer.Cancel(player, p, p2)
		v4()
	end)
	EffectsEvent.ToAllInRange(character, "Resounding SlashesVFX", character, "Final")
	task.wait(0.2)

	if v2 ~= ResoundingSlashesServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return
	end

	local hitboxSize = Config.LOOP_HITBOX_SIZE * Config.FINAL_HITBOX_MULT
	local hitboxCFrame = humanoidRootPart.CFrame * Config.FINAL_HITBOX_OFFSET
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = hitboxSize,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			if instance then
				local rootPart = instance:FindFirstChild("Humanoid").RootPart

				if p4 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
					local v7 = humanoidRootPart.CFrame.LookVector * 10
					Combat_Util.Knockback(script, character, rootPart, v7, 0.4)
				elseif p4 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p4 == true then
					local v7 = humanoidRootPart.CFrame.LookVector * 40 + createVector(0, 7, 0)
					Combat_Util.AddStun(script, character, p3, 1.5)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINAL_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, v7, 0.4)
					Combat_Util.RagDoll(script, character, p3, 1.5)
				end
			end
		end,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	v4()
end

function ResoundingSlashesServer.Cancel(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	EffectsEvent.ToAllInRange(character, "Resounding SlashesVFX", character, "Cancel")
end

return ResoundingSlashesServer