local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Combat_Util = require(SAM.Services.Combat_Util)
local Utility = require(CAM.Global.Utility)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local PartBox = require(CAM.Global.PartBox)
local Config = require(script.Parent.Config)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local AnnihilationTypeServer = {
	Id = {}
}
local v2 = Config.DASH_DURATION + Config.CUTSCENE_DURATION + Config.MANUAL_CANCEL_BUFFER
local annihilationTypeCamera = script.AnnihilationTypeCamera
local annihilationTypeUser = script.AnnihilationTypeUser
local annihilationTypeVictim = script.AnnihilationTypeVictim

function AnnihilationTypeServer.Hold(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v3 = AnnihilationTypeServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(humanoidRootPart, "Annihilation Type VFX", character, "Start", humanoidRootPart.CFrame)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Add(PartBox.new({
		Shape = "Cylinder",
		Center = humanoidRootPart.CFrame,
		Size = Config.UPDRAFT_ZONE_SIZE,
		MaxDuration = Config.UPDRAFT_DURATION,
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
				Combat_Util.Block(script, character, instance, Config.UPDRAFT_BLOCK_BREAK)
			elseif p3 == true then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid and humanoid.RootPart

				if rootPart == nil then
					return
				end

				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					Vector3.new(0, Config.UPDRAFT_KNOCKBACK, 0),
					Config.UPDRAFT_LIFT_TIME
				)
				Combat_Util.AddStun(script, character, p2, Config.UPDRAFT_STUN)
			end
		end
	}))
	task.wait(Config.STARTUP_LOOP_DURATION)

	if AnnihilationTypeServer.Id[player.UserId] ~= v3 then
		return
	end

	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	p.probeVictim = nil

	while AnnihilationTypeServer.Id[player.UserId] == v3 do
		local cFrame = humanoidRootPart.CFrame
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * CFrame.new(Config.FRONT_STOP_OFFSET),
			BoxSize = Config.FRONT_STOP_SIZE
		})

		if singlePartHitbox then
			p.probeVictim = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		else
			task.wait(0.1)
		end
	end
end

function AnnihilationTypeServer.UnHold(player, vector: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = AnnihilationTypeServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, v2)
	v4:Connect(function()
		AnnihilationTypeServer.Id[player.UserId] = -1
		AnnihilationTypeServer.Cancel(player, vector, state)
	end)
	local unit = (vector - rootPart.Position).Unit
	local cFrame = rootPart.CFrame
	local v6 = nil
	local instances = {}
	local clone = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * CFrame.new(Config.FRONT_STOP_OFFSET),
		hitboxSize = Config.FRONT_STOP_SIZE,
		targets = state.probeVictim,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid2.RootPart

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.CATCH_BLOCK_BREAK)
				Combat_Util.Knockback(
					script,
					character,
					rootPart2,
					rootPart.CFrame.LookVector.Unit * Config.BLOCK_KNOCKBACK,
					0.2
				)
			elseif p2 == true then
				table.insert(instances, instance)
				cleanIt:Add(Utility.AddValue(p, "iframe", Config.CUTSCENE_DURATION, "StringValue", character.Name))
				cleanIt:Add(Utility.AddValue(p, "pause_gameplay", Config.CUTSCENE_DURATION))
				cleanIt:Add(Utility.AddValue(p, "skill_stand_still", Config.CUTSCENE_DURATION))
				cleanIt:Add(Utility.lock(rootPart2, cFrame, 2.62))

				if #instances == 1 then
					v6 = instance
					clone = script.Camera:Clone()
					cleanIt:Add(clone)
					clone:PivotTo(rootPart.CFrame * CFrame.new(0, -3, 0))
					cleanIt:Add(task.delay(1.3333333333333333, function()
						if not (v3 == AnnihilationTypeServer.Id[player.UserId] and clone.Parent ~= nil) then
							return
						end

						clone:PivotTo(rootPart.CFrame * CFrame.new(0, -2, 0))
					end))
					clone.Parent = workspace.Debree
					local track = clone.AnimationController.Animator:LoadAnimation(annihilationTypeCamera)
					cleanIt:Add(track)
					track:Play()
					Cutscene_camera_handler.Regular(player, clone.Camera)
					cleanIt:Add(task.delay(3.4, function()
						if clone.Parent ~= nil then
							clone:Destroy()
						end
					end))
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.CUTSCENE_DURATION))
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CUTSCENE_DURATION))
					cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.CUTSCENE_DURATION))
					cleanIt:Add(Utility.lock(rootPart, cFrame, Config.CUTSCENE_DURATION))
					local track2 = animator:LoadAnimation(annihilationTypeUser)
					cleanIt:Add(track2)
					track2:Play()
					CharGrabPosCorrector.Do(character, track2, Config.CUTSCENE_DURATION, character)
				end

				local playerFromCharacter = clone and Players:GetPlayerFromCharacter(instance)

				if playerFromCharacter then
					Cutscene_camera_handler.Regular(playerFromCharacter, clone.Camera)
				end

				local track = humanoid2:FindFirstChild("Animator"):LoadAnimation(annihilationTypeVictim)
				cleanIt:Add(track)
				track:Play()
				CharGrabPosCorrector.Do(instance, track, 3.4, character)
				task.delay(3.4, function()
					if not (v3 == AnnihilationTypeServer.Id[player.UserId] and Checker.check_victim(
						script,
						character,
						instance
					) ~= nil) then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.CUTSCENE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p, Config.CUTSCENE_STUN)
					Combat_Util.RagDoll(script, character, p, Config.CUTSCENE_STUN)
					Combat_Util.Knockback(
						script,
						character,
						rootPart2,
						unit * Config.CUTSCENE_KNOCKBACK,
						Config.CUTSCENE_TIME
					)
				end)
			end
		end,
		After = function()
			if v3 ~= AnnihilationTypeServer.Id[player.UserId] then
				return
			end

			if #instances > 0 then
				local clone2 = table.clone(instances)
				table.insert(clone2, character)
				EffectsEvent.ToAllInRange(
					rootPart,
					"Annihilation Type VFX",
					character,
					"Cutscene",
					rootPart.CFrame,
					clone2
				)

				if clone and clone.Parent ~= nil then
					EffectsEvent.ToAllInRange(
						rootPart,
						"Annihilation Type VFX",
						character,
						"UltimateCamera",
						clone,
						clone2
					)
				end
			else
				AnnihilationTypeServer.Cancel(player, vector, state)
			end
		end
	})
	task.wait(Config.CUTSCENE_DURATION)

	if v3 ~= AnnihilationTypeServer.Id[player.UserId] then
		return
	end

	v5()
	cleanIt:Clean()
end

function AnnihilationTypeServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	EffectsEvent.ToAllInRange(player, "Annihilation Type VFX", player.Character, "Cancel")
	cleanIt:Clean()
end

return AnnihilationTypeServer