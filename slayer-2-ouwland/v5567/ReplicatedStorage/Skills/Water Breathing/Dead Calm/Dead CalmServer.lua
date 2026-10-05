local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Util = require(SAM.Services.Combat_Util)
local Cutscene_camera_handler = require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local CharGrabPosCorrector = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local Config = require(script.Parent.Config)
local DeadCalmServer = {
	Id = {}
}

function DeadCalmServer.Hold(player, _: Vector3, state)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local holdId = DeadCalmServer.Id[player.UserId]
	state.HoldId = holdId
	task.wait(Config.STARTUP_DUR)

	if holdId ~= DeadCalmServer.Id[player.UserId] then
		return
	end

	state.Value_Table = {}
	local name = script.Parent.Name .. " Skill Hitlist"

	if character:FindFirstChild(name) then
		character[name]:Destroy()
	end

	local folder = Instance.new("Folder", character)
	folder.Name = name
	table.insert(state.Value_Table, folder)
	local lastTime = os.clock()
	local cFrame = rootPart.CFrame
	local clone = script.CameraRig:Clone()
	clone.RootPart.RootPart.Part0 = rootPart
	clone.Parent = workspace.Debree
	clone.AnimationController.Animator:LoadAnimation(script.Camera):Play()
	Cutscene_camera_handler.Regular(player, clone.Bone)
	DebrisModule:AddItem(clone, Config.CUTSCENE_LENGTH)
	table.insert(state.Value_Table, clone)

	local function cutscene_values(rootPart2, parent, cFrame2)
		local stringValue = Instance.new("StringValue")
		stringValue.Value = player.Name
		stringValue.Name = "pause_gameplay"
		stringValue.Parent = parent
		DebrisModule:AddItem(stringValue, Config.CUTSCENE_LENGTH)
		table.insert(state.Value_Table, stringValue)
		local part = Instance.new("Part")
		part.Anchored = true
		part.Massless = true
		part.Transparency = 1
		part.CFrame = cFrame2
		part.CanCollide = false
		part.Parent = workspace.Debree
		DebrisModule:AddItem(part, Config.CUTSCENE_LENGTH)
		table.insert(state.Value_Table, part)
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = rootPart2
		weld.Parent = part
		table.insert(state.Value_Table, weld)
		local stringValue2 = Instance.new("StringValue")
		stringValue2.Name = "iframe"
		stringValue2.Value = player.Name
		stringValue2.Parent = parent
		DebrisModule:AddItem(stringValue2, Config.CUTSCENE_LENGTH)
		table.insert(state.Value_Table, stringValue2)
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "noragdoll"
		boolValue.Parent = parent
		DebrisModule:AddItem(boolValue, Config.CUTSCENE_LENGTH)
		table.insert(state.Value_Table, boolValue)
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "FOV"
		numberValue.Value = Config.CUTSCENE_FOV
		numberValue.Parent = parent
		DebrisModule:AddItem(numberValue, Config.CUTSCENE_LENGTH)
		table.insert(state.Value_Table, numberValue)
		return stringValue, part, weld, stringValue2, boolValue, numberValue
	end

	cutscene_values(rootPart, getvaluesfolder, cFrame)
	state.User_Animation = humanoid.Animator:LoadAnimation(script.User)
	state.User_Animation:Play()
	local count = 0

	local function fn(instance, parent, p2)
		if state.Cancelled then
			return
		end

		if instance then
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid2.RootPart
			local v4 = false

			for _, child in folder:GetChildren() do
				if child.Value == instance then
					v4 = true
				end
			end

			if not v4 then
				if p2 == "Blocking" or p2 == "Perfect" then
					Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
				elseif p2 == true then
					count += 1
					local objectValue = Instance.new("ObjectValue")
					objectValue.Name = instance.Name
					objectValue.Value = instance
					objectValue.Parent = folder
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

					if playerFromCharacter ~= nil then
						Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
					end

					local v5

					if count == 1 then
						v5 = { cutscene_values(rootPart2, parent, cFrame) }
					else
						v5 = { cutscene_values(
								rootPart2,
								parent,
								cFrame * CFrame.Angles(0, math.rad((math.random(-70, 70))), 0)
							) }
					end

					if state.Victim_Animation == nil then
						state.Victim_Animation = {}
					end

					local track = humanoid2.Animator:LoadAnimation(script.Victim)
					track:Play()
					CharGrabPosCorrector.Do(instance, track, Config.VICTIM_CORRECT_DUR, character)
					table.insert(state.Victim_Animation, track)
					local v6 = os.clock() - lastTime
					task.delay(Config.MULTI_SLASH_AT - v6, function()
						if state.Cancelled or Checker.check_victim(script, character, instance) == nil then
							return
						end

						for _ = 1, Config.MULTI_SLASH_COUNT do
							if state.Cancelled or Checker.check_victim(script, character, instance) == nil then
								break
							end

							Combat_Util.Damage(script, character, instance, {
								Base = Config.SLASH_DAMAGE,
								Skill = script.Parent.Name
							})
							task.wait(Config.MULTI_SLASH_DUR / Config.MULTI_SLASH_COUNT)
						end
					end)
					task.delay(Config.WAVE_AT - v6, function()
						if state.Cancelled or Checker.check_victim(script, character, instance) == nil then
							return
						end

						if track ~= nil then
							track:Stop()
							track = nil
						end

						for _, v7 in ipairs(v5) do
							v7:Destroy()
						end

						Combat_Util.AddStun(script, character, parent, Config.WAVE_STUN)
						Combat_Util.RagDoll(script:GetDescendants(), character, parent, Config.WAVE_RAGDOLL)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.WAVE_DAMAGE,
							Skill = script.Parent.Name
						})
					end)
				end
			end
		end
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.CATCH_HITBOX_OFFSET,
		hitboxSize = Config.CATCH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})

	if count > 0 then
		state.CutsceneStarted = true
		EffectsEvent.ToAllInRange(player, "Dead Calm VFX", player.Character, "Cutscene")
		task.wait(Config.CUTSCENE_LENGTH)
	else
		if state.User_Animation then
			state.User_Animation:Stop()
			state.User_Animation = nil
		end

		if state.Victim_Animation then
			for _, v4 in ipairs(state.Victim_Animation) do
				v4:Stop()
			end
		end

		EffectsEvent.ToAllInRange(player, "Dead Calm VFX", player.Character, "Startup")
		EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
	end

	if state.Value_Table then
		for _, v4 in state.Value_Table do
			v4:Destroy()
		end

		state.Value_Table = nil
	end
end

function DeadCalmServer.UnHold(p, vector: Vector3, p2)
	if not p2.CutsceneStarted then
		DeadCalmServer.Cancel(p, vector, p2)
	end
end

function DeadCalmServer.Cancel(player, _: Vector3, state)
	state.Cancelled = true

	if state.Value_Table then
		for _, v2 in state.Value_Table do
			v2:Destroy()
		end

		state.Value_Table = nil
	end

	if state.Victim_Animation then
		for _, v2 in ipairs(state.Victim_Animation) do
			v2:Stop()
		end
	end

	if state.User_Animation then
		state.User_Animation:Stop()
		state.User_Animation = nil
	end

	EffectsEvent.ToAllInRange(player, "Dead Calm VFX", player.Character, "Cancel")
end

return DeadCalmServer