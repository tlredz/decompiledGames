local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local SerpentSlashServer = {
	Id = {}
}
game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Server_Mouse_Pos = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local ImpactSounds = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Utility"):WaitForChild("ImpactSounds"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local _ = table.find
local _ = table.remove
local Config = require(script.Parent.Config)
local AIM_RADIUS = Config.AIM_RADIUS
local typeof2 = typeof
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local _ = math.clamp

function SerpentSlashServer.Hold(player)
	local _ = SerpentSlashServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		Server_Mouse_Pos.Create_Pos_Part(character, script.Name, 10)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Humanoid")
		EffectsEvent.ToAllInRange(humanoidRootPart, "SerpentSlash_effs", character, "Start")
		Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, Config.HOLD_UPDRAFT_HEIGHT, nil, Config.HOLD_UPDRAFT_DUR)
	end
end

local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function SerpentSlashServer.UnHold(player, p, _)
	local v2 = SerpentSlashServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	local flag = false
	local track = nil
	local attachment = nil
	local v5 = false
	local boolValue = nil
	v3:Connect(function()
		if track ~= nil then
			track:Stop()
			track = nil

			if v5 == false then
				EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Cancel")
			end
		end

		if boolValue then
			boolValue:Destroy()
			boolValue = nil
		end

		if attachment ~= nil then
			attachment:Destroy()
			attachment = nil
		end

		SerpentSlashServer.Cancel(player, p)
		flag = true
	end)
	task.delay(0.1, function()
		if flag then
			return
		end

		if player ~= nil and player.Character then
			EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Cancel")

			if v2 ~= SerpentSlashServer.Id[player.UserId] then
				return
			end

			local character = player.Character
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			local humanoid = character:WaitForChild("Humanoid")

			if humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "air_combo_bp" then
						Debris:AddItem(child, 0.2)
					end
				end
			end

			local clamped, _, _, v6 = RaycastHelper.MaximizeRayServer(
				character,
				humanoidRootPart.Position,
				p,
				AIM_RADIUS,
				true,
				3
			)
			local getvaluesfolder = Utility.getvaluesfolder(character)
			local child = character:FindFirstChild("PosPart" .. script.Name)

			if child ~= nil and (child.Position - child:GetAttribute("DefaultPos")).Magnitude > 3 then
				clamped = Server_Mouse_Pos.Clamp(character, child.Position, AIM_RADIUS) or clamped
			end

			local vector2 = Vector3.new(
				humanoidRootPart.Position.X - clamped.X,
				0,
				humanoidRootPart.Position.Z - clamped.Z
			)

			if vector2.Magnitude < 0.01 then
				local lookVector = humanoidRootPart.CFrame.LookVector
				vector2 = Vector3.new(-lookVector.X, 0, -lookVector.Z)
			end

			local v7 = not (vector2.Magnitude > 0.01) and createVector(0, 0, 1) or vector2.Unit
			local humanoidRootPart2

			if v6 == nil or not v6:FindFirstChild("HumanoidRootPart") then
				humanoidRootPart2 = clamped + Vector3.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0)
			else
				humanoidRootPart2 = v6.HumanoidRootPart
			end

			EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Shoot", clamped)
			wait(Config.SHOOT_IMPACT_DELAY)

			if flag or (character == nil or not character:FindFirstChild("HumanoidRootPart")) then
				return
			end

			if humanoidRootPart2 ~= nil and typeof2(humanoidRootPart2) == "Instance" then
				humanoidRootPart2 = humanoidRootPart2.Position
				clamped = humanoidRootPart2 - Vector3.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0)
			end

			if humanoidRootPart2 == nil or typeof2(humanoidRootPart2) ~= "Vector3" or humanoid == nil then
				return
			end

			local modelInRegion = Utility.GetModelInRegion(
				CFrame.new(humanoidRootPart2),
				Config.IMPACT_HITBOX_SIZE,
				nil,
				nil
			)
			local cframe = CFrame.lookAlong(
				humanoidRootPart2 + Vector3.new(math.random(-3, 3) / 3 * 2, 0, math.random(-3, 3) / 3 * 2),
				v7
			)
			local v8 = false

			for _, v9 in pairs(modelInRegion) do
				if v9 == character then
					continue
				end

				local getvaluesfolder2 = Utility.getvaluesfolder(v9)

				if v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) == true then
					continue
				end

				local check_victim = Checker.check_victim(script, character, v9)

				if check_victim == true then
					v8 = true
				elseif check_victim == "Blocking" or Checker == "Perfect" then
					Combat_Util.Block(script, character, v9, Config.IMPACT_BLOCK_BREAK)
				end
			end

			if flag then
				return
			end

			if v8 == true then
				EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Success", clamped)
				track = humanoid.Animator:LoadAnimation(script.SerpentSlash_Loop)
				track:Play()
				humanoidRootPart.CFrame = cframe
				attachment = Instance.new("Attachment")
				attachment.Name = "air_combo_bp"
				local alignPosition = Instance.new("AlignPosition", attachment)
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Attachment0 = attachment
				alignPosition.Responsiveness = 45
				alignPosition.MaxForce = 10000
				DebrisModule:AddItem(attachment, 3)
				alignPosition.Position = cframe.Position
				attachment.Parent = humanoidRootPart
				boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder
				DebrisModule:AddItem(boolValue, Config.BITE_LOCK_DUR)
				local BITE_TICK_COUNT = Config.BITE_TICK_COUNT
				local v9 = false

				for i = 1, BITE_TICK_COUNT do
					if v9 == true or flag or humanoidRootPart == nil or humanoid == nil then
						break
					end

					v5 = i == BITE_TICK_COUNT

					if v5 then
						if track then
							track:Stop()
							track = nil
						end

						if humanoid then
							local track2 = humanoid.Animator:LoadAnimation(script.SerpentSlash_Slash)
							track2:Play()
							track2:AdjustSpeed(1.35)
						end

						task.wait(0.07)

						if flag then
							break
						end
					end

					local v10 = Vector3.new(math.random(-3, 3) / 3, 0.05, math.random(0, 3) / 3) * 2

					if v5 then
						v10 = humanoidRootPart.CFrame.lookVector * Config.FINAL_KNOCKBACK + humanoidRootPart.CFrame.rightVector * Config.FINAL_KNOCKBACK_SIDE
					end

					local modelInRegion2 = Utility.GetModelInRegion(cframe, Config.BITE_HITBOX_SIZE, nil, nil)
					local v11 = nil

					for _, v12 in pairs(modelInRegion2) do
						if v9 == true then
							break
						end

						if v12 ~= character and v12:FindFirstChild("Humanoid") ~= nil then
							local humanoidRootPart3 = v12:FindFirstChild("HumanoidRootPart")
							local humanoid2 = v12:FindFirstChild("Humanoid")
							local check_victim, _ = Checker.check_victim(script, character, v12)
							local getvaluesfolder2 = Utility.getvaluesfolder(v12)

							if v.Both(getvaluesfolder2, {
								pv = getvaluesfolder,
								name = "Choosing_1"
							}) == true then
								continue
							end

							if humanoidRootPart3 ~= nil and humanoid2 ~= nil and humanoidRootPart ~= nil then
								if check_victim == "Perfect" then
									Combat_Util.Perfect(script, character, v12)
									v9 = true
								elseif check_victim == true or check_victim == "Blocking" then
									if check_victim == "Blocking" then
										Combat_Util.Block(script, character, v12, Config.BITE_BLOCK_BREAK)
									else
										Combat_Util.Add_Strict_Stun(
											script,
											character,
											getvaluesfolder2,
											Config.BITE_STUN
										)
										EffectsEvent.ToAllInRange(
											player,
											"Normal_Sword_Slash_Effect",
											humanoidRootPart3
										)
										Combat_Util.Damage(script, character, v12, {
											Base = v5 and Config.FINAL_DAMAGE or Config.BITE_TICK_DAMAGE,
											Skill = script.Parent.Name
										})
										v11 = v11 or v12
										Combat_Util.Knockback(
											script,
											character,
											humanoidRootPart3,
											v10,
											v5 and Config.FINAL_KNOCKBACK_DUR or Config.BITE_TICK_KNOCK_DUR
										)

										if v5 == true then
											Combat_Util.RagDoll(
												script,
												character,
												getvaluesfolder2,
												Config.FINAL_RAGDOLL
											)
										else
											Combat_presets.stop_extra_anims(humanoid2)
											local v13 = math.random(1, 5)
											local v14 = v13 == 5 and 6 or v13
											local track2 = humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(
												player,
												"React_" .. v14
											))
											track2:AdjustSpeed(2.25)
											track2:Play()
										end
									end
								end
							end
						end

						if v11 ~= nil then
							ImpactSounds.Play(character, script.Parent.Name, v11)
						end
					end

					task.wait(Config.BITE_TOTAL_DUR / BITE_TICK_COUNT)
				end

				if v5 ~= true and flag == false then
					v3:Fire()
					v4()
				end

				if track then
					track:Stop()
					track = nil
				end

				if alignPosition then
					alignPosition:Destroy()
				end
			else
				EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Explode", clamped)
			end

			Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)
		end
	end)
end

function SerpentSlashServer.Cancel(player)
	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Cancel")
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil then
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "air_combo_bp" then
					child:Destroy()
				end
			end
		end
	end
end

return SerpentSlashServer