local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local TwinHeadedReptileServer = {
	Id = {}
}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local RaycastHelper = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("RaycastHelper"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local ImpactSounds = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Utility"):WaitForChild("ImpactSounds"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)

function TwinHeadedReptileServer.Hold(player)
	local v2 = TwinHeadedReptileServer.Id[player.UserId]

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
	task.delay(0.05, function()
		if TwinHeadedReptileServer.Id[player.UserId] == v2 then
			EffectsEvent.ToAllInRange(player, "TwinHeadedReptile_effs", character, "Start")
		end
	end)
end

require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("Cutscene_camera_handler"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

function TwinHeadedReptileServer.UnHold(player, vector: Vector3)
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

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local unit = (vector - humanoidRootPart.Position).Unit
	local vector2 = Vector3.new(unit.X, 0, unit.Z)
	local cframe = CFrame.lookAlong(skillStartupLocation, vector2)
	local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * Config.DASH_RAY_RANGE, raycastParams)
	local cframe2 = cframe * Config.DASH_GOAL_OFFSET

	if raycastResult then
		cframe2 = CFrame.lookAlong(raycastResult.Position, vector2)
	end

	EffectsEvent.ToAllInRange(
		player,
		"TwinHeadedReptile_effs",
		character,
		"Dash",
		vector2,
		skillStartupLocation,
		cframe2.Position
	)
	local v2 = false
	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -15)
	local v4 = TwinHeadedReptileServer.Id[player.UserId]
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local DASH_BLOCK_BREAK = Config.DASH_BLOCK_BREAK
	local FINISH_DAMAGE = Config.FINISH_DAMAGE
	task.spawn(function()
		local v5 = {}
		local v6 = {}

		for _ = 1, Config.DASH_SCAN_TICKS do
			task.wait(Config.DASH_SCAN_TICK)

			if v2 == true then
				break
			end

			cFrame = humanoidRootPart.CFrame * Config.DASH_HITBOX_OFFSET
			local DASH_HITBOX_SIZE = Config.DASH_HITBOX_SIZE
			local modelInRegion = Utility.GetModelInRegion(cFrame, DASH_HITBOX_SIZE, nil, nil)

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
					v2 = true
					table.insert(v6, v7)
				elseif check_victim == "Blocking" or check_victim == "Perfect" then
					Combat_Util.Block(script, character, v7, DASH_BLOCK_BREAK)
				end
			end

			if v2 == true then
				break
			end
		end

		if #v6 > 0 and character ~= nil and v4 == TwinHeadedReptileServer.Id[player.UserId] and humanoid ~= nil then
			cFrame = RaycastHelper.ResolveGrabPin(humanoidRootPart.Position, cFrame, Config.GRAB_WALL_CLEARANCE)
			EffectsEvent.ToAllInRange(
				player,
				"TwinHeadedReptile_effs",
				character,
				"Success",
				vector2,
				skillStartupLocation
			)
			humanoid.Animator:LoadAnimation(script.Reptile_Attacker):Play(0)
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "pause_gameplay"
			boolValue.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue, Config.GRAB_LOCK_DUR)
			local part = Instance.new("Part")
			part.Anchored = true
			part.Massless = true
			part.Transparency = 1
			part.CFrame = cFrame
			part.CanCollide = false
			part.Parent = workspace.Debree
			DebrisModule:AddItem(part, Config.GRAB_LOCK_DUR)
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = humanoidRootPart
			local cFrame2 = cFrame * Config.GRAB_VICTIM_OFFSET
			local boolValue2 = Instance.new("BoolValue")
			boolValue2.Name = "iframe"
			boolValue2.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue2, Config.GRAB_LOCK_DUR)
			local boolValue3 = Instance.new("BoolValue")
			boolValue3.Name = "noragdoll"
			boolValue3.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue3, Config.GRAB_LOCK_DUR)
			weld.Parent = part
			DebrisModule:AddItem(weld, Config.GRAB_LOCK_DUR)
			local v8 = nil

			for _, v9 in pairs(v6) do
				if Checker.check_victim(script, character, v9) == nil then
					continue
				end

				game.Players:GetPlayerFromCharacter(v9)
				local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					continue
				end

				local humanoid2 = v9:FindFirstChild("Humanoid")

				if humanoid2 == nil then
					continue
				end

				if v8 == nil then
					v8 = v9
				end

				humanoid2:LoadAnimation(script.Reptile_Victim):Play(0)
				local getvaluesfolder2 = Utility.getvaluesfolder(v9)
				local boolValue4 = Instance.new("BoolValue")
				boolValue4.Name = "pause_gameplay"
				boolValue4.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue4, Config.GRAB_VICTIM_DUR)
				local stringValue = Instance.new("StringValue")
				stringValue.Name = "iframe"
				stringValue.Value = getvaluesfolder.Name
				stringValue.Parent = getvaluesfolder2
				DebrisModule:AddItem(stringValue, Config.GRAB_VICTIM_DUR)
				local boolValue5 = Instance.new("BoolValue")
				boolValue5.Name = "noragdoll"
				boolValue5.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue5, Config.GRAB_VICTIM_DUR)
				local part2 = Instance.new("Part")
				part2.Anchored = true
				part2.Transparency = 1
				part2.Massless = true
				part2.CFrame = cFrame2
				part2.CanCollide = false
				part2.Parent = workspace.Debree
				DebrisModule:AddItem(part2, Config.GRAB_LOCK_DUR)
				local weld2 = Instance.new("Weld")
				weld2.Part0 = humanoidRootPart2
				weld2.Part1 = part2
				weld2.Parent = part2
				local part3 = humanoidRootPart2
				local v11 = v9
				task.spawn(function()
					for i = 1, Config.BITE_TICK_COUNT do
						if part3 == nil then
							break
						end

						if Checker.check_victim(script, character, v11) ~= nil and character then
							Combat_Util.Damage(script, character, v11, {
								Base = Config.BITE_TICK_DAMAGE,
								Skill = script.Parent.Name
							})

							if v11 == v8 then
								ImpactSounds.Play(character, script.Parent.Name, v11)
							end
						end

						task.wait(Config.BITE_TICK)
					end
				end)
				local part4 = humanoidRootPart2
				local v15 = v9
				task.spawn(function()
					if part4 == nil then
						return
					end

					task.wait(Config.GRAB_VICTIM_DUR)

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
						Combat_Util.Damage(script, character, v15, {
							Base = FINISH_DAMAGE,
							Skill = script.Parent.Name
						})

						if v15 == v8 then
							ImpactSounds.Play(character, script.Parent.Name, v15)
						end

						Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.FINISH_RAGDOLL)
					end
				end)
			end
		end
	end)
end

function TwinHeadedReptileServer.Cancel(player)
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

	EffectsEvent.ToAllInRange(humanoidRootPart, "TwinHeadedReptile_effs", character, "Cancel")
end

return TwinHeadedReptileServer