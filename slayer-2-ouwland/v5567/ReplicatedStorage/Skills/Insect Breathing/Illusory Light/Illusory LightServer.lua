local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
require(global.Subsets.Gameplay.ManuelCancel)
local AppliedTicks = require(global.Subsets.Gameplay.AppliedTicks)
local Clans = require(CAM.Clans)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
require(SAM.Services.Server_Mouse_Pos)
local Cutscene_camera_handler = require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
local CharGrabPosCorrector = require(global.Subsets.Gameplay.CharGrabPosCorrector)
local Config = require(script.Parent.Config)
local IllusoryLightServer = {
	Id = {},
	Hold = function(player, _, _)
		if not player then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		Utility.getvaluesfolder(character)

		if not humanoidRootPart then
			return
		end

		EffectsEvent.ToAllInRange(player, "Illusory_Light_VFX", character, "Hold")
	end
}

function IllusoryLightServer.UnHold(player, _, _)
	if player == nil or player.Character == nil or player.Character.PrimaryPart == nil or player.Character:FindFirstChild("Humanoid") == nil then
		return
	end

	local character = player.Character
	local humanoid = character.Humanoid
	local rootPart = humanoid.RootPart
	local _ = humanoid.Animator
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = IllusoryLightServer.Id[player.UserId]
	task.wait(Config.RELEASE_DELAY)

	if IllusoryLightServer.Id[player.UserId] ~= v2 then
		return
	end

	local count = 0
	local name = script.Parent.Name .. character.Name .. "Camera"
	local instances = { character }
	local clone = nil
	local cFrame = rootPart.CFrame

	local function fn(instance, parent, p, _)
		if instance then
			local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

			if p == "Blocking" or p == "Perfect" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
				local v4 = vector.normalize(cFrame.Position - rootPart2.Position) * -Config.BLOCK_KNOCKBACK
				Combat_Util.Knockback(
					script,
					character,
					rootPart2,
					Vector3.new(v4.X, 0, v4.Z),
					Config.BLOCK_KNOCKBACK_DUR
				)
			elseif p == true then
				table.insert(instances, instance)
				count += 1
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = Config.CUTSCENE_FOV
				numberValue.Name = "FOV"
				numberValue.Parent = parent
				DebrisModule:AddItem(numberValue, Config.CUTSCENE_DURATION - 0.1)

				for _, v4 in ipairs({ "pause_gameplay", "iframe" }) do
					Utility.AddValue(parent, v4, Config.CUTSCENE_DURATION)
				end

				local v4 = Utility.lock(rootPart2, cFrame, Config.CUTSCENE_DURATION)

				if clone == nil and count == 1 then
					clone = script.CameraRig:Clone()
					clone.Name = name
					clone.RootPart.RootPart.Part0 = rootPart
					clone.Parent = workspace.Debree
					clone.AnimationController:LoadAnimation(script.Camera):Play()
					DebrisModule:AddItem(clone, Config.CUTSCENE_DURATION - 0.6)
					Cutscene_camera_handler.Regular(player, clone.Bone)
				end

				if clone ~= nil then
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

					if playerFromCharacter ~= nil then
						Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
					end
				end

				local animator = instance:FindFirstChild("Humanoid"):FindFirstChild("Animator")

				if animator then
					local track = animator:LoadAnimation(script.Victim)
					track:Play()
					CharGrabPosCorrector.Do(instance, track, Config.FINISHER_AT - 0.05, character)
				end

				task.delay(Config.FINISHER_AT, function()
					if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
						return
					end

					if v4 ~= nil then
						v4:Destroy()
						v4 = nil
					end

					Combat_Util.AddStun(script, character, parent, Config.FINISHER_STUN)
					Combat_Util.RagDoll(script, character, parent, Config.FINISHER_RAGDOLL)
					task.wait(Config.FINISHER_DAMAGE_DELAY)

					if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINISHER_DAMAGE,
						Skill = script.Parent.Name
					})

					if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
						local v5 = Utility.AddValue(
							parent,
							AppliedTicks.ByName.Poison.Value,
							Config.POISON_DURATION,
							"ObjectValue",
							character
						)
						v5:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
						v5:SetAttribute("Skill", script.Parent.Name)
					end
				end)

				if count == 1 then
					local animator2 = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
					Utility.lock(rootPart, cFrame, Config.CUTSCENE_DURATION)

					if animator2 then
						local track = animator2:LoadAnimation(script.User)
						track:Play()
						CharGrabPosCorrector.Do(character, track, Config.CUTSCENE_DURATION, character)
					end

					for _, v5 in ipairs({ "pause_gameplay", "iframe" }) do
						Utility.AddValue(getvaluesfolder, v5, Config.CUTSCENE_DURATION)
					end

					local numberValue2 = Instance.new("NumberValue")
					numberValue2.Value = Config.CUTSCENE_FOV
					numberValue2.Name = "FOV"
					numberValue2.Parent = getvaluesfolder
					DebrisModule:AddItem(numberValue2, Config.CUTSCENE_DURATION - 0.1)
				end
			end
		end
	end

	os.clock()
	Utility.CreateHitbox({
		caster = character,
		visualize = false,
		hitboxCFrame = rootPart.CFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})

	if count == 0 then
		EffectsEvent.ToAllInRange(player, "Illusory_Light_VFX", character, "Thrust", count)
	else
		EffectsEvent.ToAllInRange(
			player,
			"Illusory_Light_VFX",
			character,
			"Cutscene",
			{ name, Config.CUTSCENE_DURATION, instances }
		)
	end
end

function IllusoryLightServer.Cancel(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Illusory_Light_VFX", character, "Cancel")
end

return IllusoryLightServer