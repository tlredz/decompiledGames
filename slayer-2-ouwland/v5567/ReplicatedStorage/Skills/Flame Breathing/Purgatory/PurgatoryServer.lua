local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
ReplicatedStorage:WaitForChild("Communication")
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
require(SAM.Services.Server_Mouse_Pos)
local Cutscene_camera_handler = require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CharGrabPosCorrector = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("CharGrabPosCorrector"))
local Config = require(script.Parent.Config)
local PurgatoryServer = {
	Id = {},
	Hold = function(player, _, _)
		if not (player and player.Character) then
			return
		end

		EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "Start")
	end
}
local script2 = script

function PurgatoryServer.UnHold(player, p, p2)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if not humanoidRootPart then
		return
	end

	p2[character.Name .. script.Parent.Name] = {}
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.CAST_NR_DUR)
	local count = 0
	local cFrame = nil
	local clone = nil
	local clone2 = nil
	local instances = {}

	local function fn(instance, p3, p4, _)
		if instance then
			local rootPart = instance:FindFirstChild("Humanoid").RootPart

			if p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == true then
				count += 1

				if count == 1 then
					cFrame = humanoidRootPart.CFrame
					clone = script.DragonModel:Clone()
					clone.RootPart.RootWeld.Part0 = humanoidRootPart
					clone.Parent = workspace.Debree
					DebrisModule:AddItem(clone, Config.CUTSCENE_DUR)
					Utility.AddValue(
						getvaluesfolder,
						"camsubject",
						Config.CASTER_LOCK_DUR,
						"ObjectValue",
						character:FindFirstChild("Head")
					)
					clone.AnimationController.Animator:LoadAnimation(script.Dragon):Play()
					Utility.lock(humanoidRootPart, cFrame, Config.CASTER_LOCK_DUR)
					Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CASTER_LOCK_DUR)
					Utility.AddValue(getvaluesfolder, "iframe", Config.CASTER_LOCK_DUR)
					clone2 = script.CameraModel:Clone()
					clone2.RootPart.RootWeld.Part0 = humanoidRootPart
					clone2.Parent = workspace.Debree
					clone2.AnimationController:LoadAnimation(script.Camera):Play()
					Cutscene_camera_handler.Regular(player, clone2.camera)
					DebrisModule:AddItem(clone2, Config.CAMERA_DUR)
					local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")

					if animator then
						local track = animator:LoadAnimation(script.User)
						track:Play()
						CharGrabPosCorrector.Do(character, track, Config.CASTER_LOCK_DUR, character, true)
					end

					table.insert(instances, instance)
				end

				local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

				if playerFromCharacter ~= nil then
					Cutscene_camera_handler.Regular(playerFromCharacter, clone2.camera)
				end

				local animator = instance:FindFirstChild("Humanoid"):FindFirstChild("Animator")

				if animator then
					local track = animator:LoadAnimation(script.Victim)
					track:Play()
					CharGrabPosCorrector.Do(instance, track, Config.VICTIM_ANIM_DUR, character)
				end

				Utility.AddValue(p3, "pause_gameplay", Config.VICTIM_ANIM_DUR)
				Utility.AddValue(p3, "noragdoll", Config.VICTIM_ANIM_DUR)
				Utility.AddValue(p3, "iframe", Config.VICTIM_ANIM_DUR, "StringValue", character.Name)
				Combat_Util.Cancel(script, p3)
				local v2 = Utility.lock(rootPart, cFrame, Config.VICTIM_ANIM_DUR)
				task.delay(Config.HIT1_AT, function()
					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT1_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.HIT2_AT - Config.HIT1_AT)

					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.HIT2_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.VICTIM_ANIM_DUR - Config.HIT2_AT + 0.15)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINAL_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p3, Config.FINAL_STUN)
					Combat_Util.RagDoll(script, character, p3, Config.FINAL_RAGDOLL)

					if v2 ~= nil then
						v2:Destroy()
						v2 = nil
					end

					local v3 = (cFrame or humanoidRootPart.CFrame).LookVector * Config.FINAL_KNOCKBACK + vector.create(
						0,
						Config.FINAL_KNOCKUP,
						0
					)
					Combat_Util.Knockback(script, character, rootPart, v3, 0.2)
				end)
			end
		end
	end

	os.clock()
	local position = humanoidRootPart.Position
	local safeLookAt = Utility.SafeLookAt(position, p + vector.create(0, -p.Y + position.Y, 0), humanoidRootPart.CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = safeLookAt * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		TreeDestruction = true,
		After = function()
			if count > 0 then
				EffectsEvent.ToAllInRange(player, "PurgatoryVFX", character, "Cutscene", instances)
			else
				EffectsEvent.ToAllInRange(player, "PurgatoryVFX", character, "Jump")
			end
		end,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
end

function PurgatoryServer.Cancel(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Cancel")
end

return PurgatoryServer