local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Debris = game:GetService("Debris")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local SlitheringSerpentServer = {
	Id = {}
}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)

function SlitheringSerpentServer.Hold(player)
	local v2 = SlitheringSerpentServer.Id[player.UserId]

	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	character:SetAttribute("SkillStartupLocation", humanoidRootPart.Position)
	Utility.getvaluesfolder(character)
	task.delay(0.05, function()
		if SlitheringSerpentServer.Id[player.UserId] == v2 then
			EffectsEvent.ToAllInRange(humanoidRootPart, "SlitheringSerpent_effs", character, "Start")
		end
	end)
end

local GRAB_DAMAGE_FRAMES = Config.GRAB_DAMAGE_FRAMES
local CharGrabPosCorrector = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local Cutscene_camera_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("Cutscene_camera_handler"))

function SlitheringSerpentServer.UnHold(player, vector2: Vector3)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local skillStartupLocation = character:GetAttribute("SkillStartupLocation")
	character:SetAttribute("SkillStartupLocation", nil)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	Utility.getvaluesfolder(character)
	local unit = (vector2 - humanoidRootPart.Position).Unit
	local vector3 = Vector3.new(unit.X, unit.Y, unit.Z)
	local v2 = CFrame.lookAlong(humanoidRootPart.Position, vector3) * Config.DASH_GOAL_OFFSET
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"SlitheringSerpent_effs",
		character,
		"Dash",
		nil,
		vector3,
		skillStartupLocation,
		v2.Position
	)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "Transparent"
	stringValue.Value = script.Parent.Name
	stringValue.Parent = getvaluesfolder
	DebrisModule:AddItem(stringValue, Config.DASH_WINDOW)
	local v3 = false
	local cframe2 = nil
	local v4 = SlitheringSerpentServer.Id[player.UserId]
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local DASH_BLOCK_BREAK = Config.DASH_BLOCK_BREAK
	task.spawn(function()
		local v5 = {}
		local v6 = {}

		for _ = 1, Config.DASH_SCAN_TICKS do
			task.wait(Config.DASH_SCAN_TICK)

			if v3 == true then
				break
			end

			cframe2 = CFrame.lookAlong(humanoidRootPart.Position, vector3) * Config.DASH_HITBOX_OFFSET
			local DASH_HITBOX_SIZE = Config.DASH_HITBOX_SIZE
			local modelInRegion = Utility.GetModelInRegion(cframe2, DASH_HITBOX_SIZE, nil, nil)

			for _, v7 in pairs(modelInRegion) do
				if not (v7 ~= character and v7:FindFirstChild("Humanoid") ~= nil and table.find(v5, v7) == nil) then
					continue
				end

				table.insert(v5, v7)
				local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v7:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v7)
				local getvaluesfolder2 = Utility.getvaluesfolder(v7)

				if v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) == true then
					continue
				end

				local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart3 ~= nil) then
					continue
				end

				if check_victim == true then
					v3 = true
					table.insert(v6, v7)
				elseif check_victim == "Blocking" or check_victim == "Perfect" then
					Combat_Util.Block(script, character, v7, DASH_BLOCK_BREAK)
				end
			end

			if v3 == true then
				break
			end
		end

		if stringValue and stringValue:IsDescendantOf(getvaluesfolder) then
			stringValue:Destroy()
		end

		if #v6 > 0 and character ~= nil and v4 == SlitheringSerpentServer.Id[player.UserId] and humanoid ~= nil then
			local vector4 = Vector3.new(vector3.X, 0, vector3.Z)
			local unit2

			if vector4.Magnitude > 0.01 then
				unit2 = vector4.Unit
			else
				unit2 = humanoidRootPart.CFrame.LookVector
			end

			local raycastResult = workspace:Raycast(
				cframe2.Position + createVector(0, 8, 0),
				createVector(0, -60, 0),
				RaycastHelper.Crater
			)
			local v7

			if raycastResult == nil then
				v7 = cframe2.Position
			else
				v7 = raycastResult.Position + createVector(0, 3, 0)
			end

			cframe2 = CFrame.lookAlong(v7, unit2)
			cframe2 = RaycastHelper.ResolveGrabPin(humanoidRootPart.Position, cframe2, Config.GRAB_WALL_CLEARANCE)
			local clone = table.clone(v6)
			table.insert(clone, player.Character)
			EffectsEvent.ToAllInRange(humanoidRootPart, "SlitheringSerpent_effs", character, "Success", clone)
			local track = humanoid.Animator:LoadAnimation(script.SlitheringSerpent_Attacker)
			track:Play(0)
			CharGrabPosCorrector.Do(character, track, nil, character)
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "pause_gameplay"
			boolValue.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue, Config.GRAB_LOCK_DUR)
			local part = Instance.new("Part")
			part.Anchored = true
			part.Massless = true
			part.Transparency = 1
			part.CFrame = cframe2
			part.CanCollide = false
			part.Parent = workspace.Debree
			DebrisModule:AddItem(part, Config.GRAB_LOCK_DUR)
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = humanoidRootPart
			local cFrame = cframe2
			local clone2 = script.CameraRig:Clone()
			clone2.RootPart.RootPart.Part0 = humanoidRootPart
			clone2.Parent = workspace.Debree
			clone2.AnimationController:LoadAnimation(script.SlitheringSerpent_Camera):Play()
			Cutscene_camera_handler.Regular(player, clone2.Bone)
			local boolValue2 = Instance.new("BoolValue")
			boolValue2.Name = "iframe"
			boolValue2.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue2, Config.GRAB_LOCK_DUR)
			local boolValue3 = Instance.new("BoolValue")
			boolValue3.Name = "noragdoll"
			boolValue3.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue3, Config.GRAB_LOCK_DUR)
			DebrisModule:AddItem(clone2, Config.GRAB_RELEASE_AT)
			weld.Parent = part
			DebrisModule:AddItem(weld, Config.GRAB_LOCK_DUR)
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = "FOV"
			numberValue.Value = Config.GRAB_FOV
			numberValue.Parent = getvaluesfolder
			Debris:AddItem(numberValue, Config.GRAB_LOCK_DUR)

			for _, v9 in pairs(v6) do
				if Checker.check_victim(script, character, v9) == nil then
					continue
				end

				local playerFromCharacter = game.Players:GetPlayerFromCharacter(v9)

				if playerFromCharacter ~= nil then
					Cutscene_camera_handler.Regular(playerFromCharacter, clone2.Bone)
				end

				local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					continue
				end

				local humanoid2 = v9:FindFirstChild("Humanoid")

				if humanoid2 == nil then
					continue
				end

				local track2 = humanoid2:LoadAnimation(script.SlitheringSerpent_Victim)
				track2:Play(0)
				local getvaluesfolder2 = Utility.getvaluesfolder(v9)
				local numberValue2 = Instance.new("NumberValue")
				numberValue2.Name = "FOV"
				numberValue2.Value = Config.GRAB_FOV
				numberValue2.Parent = getvaluesfolder2
				Debris:AddItem(numberValue2, Config.GRAB_LOCK_DUR)
				CharGrabPosCorrector.Do(v9, track2, nil, character)
				local boolValue4 = Instance.new("BoolValue")
				boolValue4.Name = "pause_gameplay"
				boolValue4.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue4, Config.GRAB_LOCK_DUR)
				local stringValue2 = Instance.new("StringValue")
				stringValue2.Name = "iframe"
				stringValue2.Value = getvaluesfolder.Name
				stringValue2.Parent = getvaluesfolder2
				DebrisModule:AddItem(stringValue2, Config.GRAB_LOCK_DUR)
				local boolValue5 = Instance.new("BoolValue")
				boolValue5.Name = "noragdoll"
				boolValue5.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue5, Config.GRAB_LOCK_DUR)
				local part2 = Instance.new("Part")
				part2.Anchored = true
				part2.Transparency = 1
				part2.Massless = true
				part2.CFrame = cFrame
				part2.CanCollide = false
				part2.Parent = workspace.Debree
				DebrisModule:AddItem(part2, Config.GRAB_VICTIM_WELD_DUR)
				local weld2 = Instance.new("Weld")
				weld2.Part0 = humanoidRootPart2
				weld2.Part1 = part2
				weld2.Parent = part2
				local part3 = humanoidRootPart2
				local v11 = v9
				task.spawn(function()
					for i, v12 in ipairs(GRAB_DAMAGE_FRAMES) do
						local v13, base = next(v12)
						task.wait(v13)

						if part3 == nil then
							break
						end

						if Checker.check_victim(script, character, v11) ~= nil and character then
							Combat_Util.Damage(script, character, v11, {
								Base = base,
								Skill = script.Parent.Name
							})
						end
					end
				end)
				local part4 = humanoidRootPart2
				local v15 = v9
				task.spawn(function()
					if part4 == nil then
						return
					end

					task.wait(Config.GRAB_RELEASE_AT)

					if weld2 then
						weld2:Destroy()
					end

					if boolValue5 then
						boolValue5:Destroy()
					end

					task.wait()
					local getvaluesfolder3 = Utility.getvaluesfolder(v15)

					if part4 == nil then
						return
					end

					if Checker.check_victim(script, character, v15) ~= nil and character then
						Combat_Util.AddStun(script, character, getvaluesfolder3, Config.FINISH_STUN)
						Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.FINISH_RAGDOLL)
					end
				end)
			end
		end
	end)
end

function SlitheringSerpentServer.Cancel(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	character:SetAttribute("SkillStartupLocation", nil)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	for _, child in pairs(getvaluesfolder:GetChildren()) do
		if child.Name == "Transparent" and child.Value == script.Parent.Name then
			child:Destroy()
		end
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "SlitheringSerpent_effs", character, "Cancel")
end

return SlitheringSerpentServer