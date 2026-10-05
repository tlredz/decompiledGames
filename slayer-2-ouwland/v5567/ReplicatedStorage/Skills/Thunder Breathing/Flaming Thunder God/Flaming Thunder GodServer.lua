local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local Utility = require(global.Utility)
local RaycastHelper = require(global.RaycastHelper)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Cutscene_camera_handler = require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local v2 = Config.HIT_TIMES[#Config.HIT_TIMES] + Config.BURST_HIT_COUNT * Config.BURST_INTERVAL + Config.FINAL_HIT_DELAY
local CharGrabPosCorrector = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("CharGrabPosCorrector"))
local FlamingThunderGodServer = {
	Id = {},
	Hold = function(player, _, _)
		if not player then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Start")
	end
}
local script2 = script

function FlamingThunderGodServer.UnHold(player, p, p2)
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
	DebrisModule:AddItem(boolValue, 0.5)
	local count = 0
	local v3 = nil
	local clone = nil
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
					v3 = RaycastHelper.ResolveGrabPin(
						humanoidRootPart.Position,
						humanoidRootPart.CFrame,
						Config.GRAB_WALL_CLEARANCE
					)
					Utility.lock(humanoidRootPart, v3, Config.ANIM_DURATION)
					Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ANIM_DURATION)
					Utility.AddValue(getvaluesfolder, "iframe", Config.ANIM_DURATION)
					clone = script.CameraRig:Clone()
					clone.RootPart.RootPart.Part0 = humanoidRootPart
					clone.Parent = workspace.Debree
					clone.AnimationController:LoadAnimation(script["FTG Camera"]):Play()
					Cutscene_camera_handler.Regular(player, clone.Bone)
					DebrisModule:AddItem(clone, Config.ANIM_DURATION - 0.05)
					local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")

					if animator then
						local track = animator:LoadAnimation(script["FTG User"])
						track:Play()
						CharGrabPosCorrector.Do(character, track, Config.ANIM_DURATION, character)
					end

					table.insert(instances, instance)
				end

				local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

				if playerFromCharacter ~= nil then
					Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
				end

				local animator = instance:FindFirstChild("Humanoid"):FindFirstChild("Animator")
				local track

				if animator then
					track = animator:LoadAnimation(script["FTG Victim"])
					track:Play()
					CharGrabPosCorrector.Do(instance, track, v2 - 0.05, character)
				else
					track = nil
				end

				local v4 = Utility.AddValue(p3, "pause_gameplay", Config.ANIM_DURATION)
				local v5 = Utility.AddValue(p3, "noragdoll", Config.ANIM_DURATION)
				local v6 = Utility.AddValue(p3, "iframe", Config.ANIM_DURATION, "StringValue", character.Name)
				local v7 = Utility.lock(rootPart, v3, Config.ANIM_DURATION)
				task.spawn(function()
					local v8 = 0
					local total = 0

					for _, v9 in ipairs(Config.HIT_TIMES) do
						if Checker.check_victim(script2, character, instance) == nil then
							break
						end

						task.wait(v9 - v8)
						total += v9
						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT_DAMAGE,
							Skill = script.Parent.Name
						})
						v8 = v9
					end

					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					task.wait(Config.BURST_AT - total)

					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					for _ = 1, Config.BURST_HIT_COUNT do
						if Checker.check_victim(script2, character, instance) == nil then
							break
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.BURST_DAMAGE,
							Skill = script.Parent.Name
						})
						task.wait(Config.BURST_INTERVAL)
					end

					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					task.wait(Config.FINAL_HIT_DELAY)

					if Checker.check_victim(script2, character, instance) == nil then
						return
					end

					if v7 ~= nil then
						v7:Destroy()
						v7 = nil
					end

					if v4 ~= nil then
						v4:Destroy()
						v4 = nil
					end

					if v6 ~= nil then
						v6:Destroy()
						v6 = nil
					end

					if v5 ~= nil then
						v5:Destroy()
						v5 = nil
					end

					if track ~= nil then
						track:Stop()
						track = nil
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINAL_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p3, Config.FINAL_STUN)
					Combat_Util.RagDoll(script, character, p3, Config.FINAL_RAGDOLL)
				end)
			end
		end
	end

	os.clock()
	local HITBOX_SIZE = Config.HITBOX_SIZE
	EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Startup")
	local position = humanoidRootPart.Position
	local safeLookAt = Utility.SafeLookAt(position, p + vector.create(0, -p.Y + position.Y, 0), humanoidRootPart.CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = safeLookAt * Config.HITBOX_OFFSET,
		hitboxSize = HITBOX_SIZE,
		checker = Checker,
		TreeDestruction = true,
		After = function()
			if count > 0 then
				EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Cutscene", instances)
			else
				EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Attempt")
			end
		end,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
end

function FlamingThunderGodServer.Cancel(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Flaming_Thunder_God_VFX", character, "Cancel")
end

return FlamingThunderGodServer