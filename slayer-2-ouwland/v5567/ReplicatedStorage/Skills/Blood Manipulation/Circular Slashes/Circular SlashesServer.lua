local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local CircularSlashesServer = {
	Id = {}
}
game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Server_Mouse_Pos = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local _ = table.find
local _ = table.remove
local Config = require(script.Parent.Config)
local typeof2 = typeof
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local _ = math.clamp

function CircularSlashesServer.Hold(player)
	local _ = CircularSlashesServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		Server_Mouse_Pos.Create_Pos_Part(character, script.Name, 10)
		character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Humanoid")
	end
end

function Weld(part, p)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = p
	weldConstraint.Parent = p
end

require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Cutscene_camera_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("Cutscene_camera_handler"))

-- equivalent calls inferred from this helper; original call sites unknown
local function removeSpaces(name)
	return name:gsub(" ", "")
end

local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function CircularSlashesServer.UnHold(player, p, _)
	local v2 = CircularSlashesServer.Id[player.UserId]
	task.spawn(function()
		if player ~= nil and player.Character then
			EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Cancel")

			if v2 ~= CircularSlashesServer.Id[player.UserId] then
				return
			end

			local character = player.Character
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			character:WaitForChild("Humanoid")
			local position = humanoidRootPart.Position
			local clamped, _, _, v3 = RaycastHelper.MaximizeRayServer(
				character,
				position,
				p,
				Config.AIM_RADIUS,
				true,
				8
			)
			local getvaluesfolder = Utility.getvaluesfolder(character)
			local child = character:FindFirstChild("PosPart" .. script.Name)

			if child ~= nil and (child.Position - child:GetAttribute("DefaultPos")).Magnitude > 3 then
				clamped = Server_Mouse_Pos.Clamp(character, child.Position, Config.AIM_RADIUS) or clamped
			end

			local unit = (clamped - position).Unit
			local vector2 = Vector3.new(unit.X, 0, unit.Z)

			if v3 ~= nil and v3:FindFirstChild("HumanoidRootPart") then
				clamped = v3.HumanoidRootPart
			end

			wait(0.03)

			if character == nil or not character:FindFirstChild("HumanoidRootPart") then
				return
			end

			if clamped ~= nil and typeof2(clamped) == "Instance" then
				clamped = clamped.Position
			end

			if clamped == nil or typeof2(clamped) ~= "Vector3" then
				return
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid == nil then
				return
			end

			EffectsEvent.ToAllInRange(player, "CircularSlashes_effs", player.Character, "Throw", clamped)
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "InvisibleItem"
			stringValue.Value = "SickleLeft,SickleRight"
			stringValue:SetAttribute("Script", removeSpaces(script.Parent.Name))
			stringValue.Parent = getvaluesfolder
			Debris:AddItem(stringValue, Config.SICKLE_HIDE_DUR)
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)
			local v4 = (clamped - humanoidRootPart.Position) / Config.THROW_SEGMENTS
			local v5 = false
			local v6 = {}
			local v7 = {}
			local cframe = nil

			for i = 1, Config.THROW_SEGMENTS do
				if v5 == true then
					break
				end

				cframe = CFrame.lookAlong(humanoidRootPart.Position + v4 * i, vector2)
				local THROW_HITBOX_SIZE = Config.THROW_HITBOX_SIZE
				local modelInRegion = Utility.GetModelInRegion(cframe, THROW_HITBOX_SIZE, nil, nil)

				for _, v8 in pairs(modelInRegion) do
					if not (v8 ~= character and v8:FindFirstChild("Humanoid") ~= nil and table.find(v6, v8) == nil) then
						continue
					end

					table.insert(v6, v8)
					local humanoidRootPart2 = v8:FindFirstChild("HumanoidRootPart")
					local humanoid2 = v8:FindFirstChild("Humanoid")
					local check_victim, _ = Checker.check_victim(script, character, v8)
					local getvaluesfolder2 = Utility.getvaluesfolder(v8)

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
						table.insert(v7, v8)
						v5 = true
					elseif check_victim == "Blocking" or check_victim == "Perfect" then
						Combat_Util.Block(script, character, v8, Config.THROW_BLOCK_BREAK)
					end
				end

				if v5 == true then
					break
				else
					task.wait(Config.THROW_STEP_INTERVAL)
				end
			end

			if #v7 == 0 and character ~= nil and v2 == CircularSlashesServer.Id[player.UserId] and humanoid ~= nil then
				EffectsEvent.ToAllInRange(player, "CircularSlashes_effs", player.Character, "Comeback", clamped)
			end

			if #v7 > 0 and character ~= nil and v2 == CircularSlashesServer.Id[player.UserId] and humanoid ~= nil then
				if stringValue.Parent == getvaluesfolder then
					stringValue:Destroy()
				end

				local clone = table.clone(v7)
				table.insert(clone, character)
				EffectsEvent.ToAllInRange(player, "CircularSlashes_effs", character, "Success", clone)
				humanoid.Animator:LoadAnimation(script.CircularSlashes_Attacker):Play(0)
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder
				DebrisModule:AddItem(boolValue, Config.CUTSCENE_DUR)
				local part = Instance.new("Part")
				part.Anchored = true
				part.Massless = true
				part.Transparency = 1
				part.CFrame = cframe
				part.CanCollide = false
				part.Parent = workspace.Debree
				DebrisModule:AddItem(part, Config.CUTSCENE_DUR)
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = humanoidRootPart
				local cFrame = cframe * Config.VICTIM_GRAB_OFFSET
				local clone2 = script.CamReAdd:Clone()
				clone2.PrimaryPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.696026563644409, 0)
				Weld(humanoidRootPart, clone2.PrimaryPart)
				clone2.Parent = workspace.Debree
				clone2.AnimationController:LoadAnimation(script.CircularSlashes_Camera):Play()
				Cutscene_camera_handler.Regular(player, clone2.Cam)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "iframe"
				boolValue2.Parent = getvaluesfolder
				DebrisModule:AddItem(boolValue2, Config.CUTSCENE_DUR)
				local boolValue3 = Instance.new("BoolValue")
				boolValue3.Name = "noragdoll"
				boolValue3.Parent = getvaluesfolder
				DebrisModule:AddItem(boolValue3, Config.CUTSCENE_DUR)
				DebrisModule:AddItem(clone2, Config.CUTSCENE_DUR)
				weld.Parent = part
				DebrisModule:AddItem(weld, Config.CUTSCENE_DUR)

				for _, v9 in pairs(v7) do
					if Checker.check_victim(script, character, v9) == nil then
						continue
					end

					local playerFromCharacter = game.Players:GetPlayerFromCharacter(v9)

					if playerFromCharacter ~= nil then
						Cutscene_camera_handler.Regular(playerFromCharacter, clone2.Cam)
					end

					local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 == nil then
						continue
					end

					local humanoid2 = v9:FindFirstChild("Humanoid")

					if humanoid2 == nil then
						continue
					end

					local track = humanoid2:LoadAnimation(script.CircularSlashes_Victim)
					track:Play(0)
					local getvaluesfolder2 = Utility.getvaluesfolder(v9)
					local boolValue4 = Instance.new("BoolValue")
					boolValue4.Name = "pause_gameplay"
					boolValue4.Parent = getvaluesfolder2
					DebrisModule:AddItem(boolValue4, Config.VICTIM_CUTSCENE_DUR)
					local stringValue2 = Instance.new("StringValue")
					stringValue2.Name = "iframe"
					stringValue2.Value = getvaluesfolder.Name
					stringValue2.Parent = getvaluesfolder2
					DebrisModule:AddItem(stringValue2, Config.VICTIM_CUTSCENE_DUR)
					local boolValue5 = Instance.new("BoolValue")
					boolValue5.Name = "noragdoll"
					boolValue5.Parent = getvaluesfolder2
					DebrisModule:AddItem(boolValue5, Config.VICTIM_CUTSCENE_DUR)
					local part2 = Instance.new("Part")
					part2.Anchored = true
					part2.Transparency = 1
					part2.Massless = true
					part2.CFrame = cFrame
					part2.CanCollide = false
					part2.Parent = workspace.Debree
					DebrisModule:AddItem(part2, Config.VICTIM_CUTSCENE_DUR)
					local weld2 = Instance.new("Weld")
					weld2.Part0 = humanoidRootPart2
					weld2.Part1 = part2
					weld2.Parent = part2
					local v10 = Config.CUTSCENE_DAMAGE_FRAMES
					local part3 = humanoidRootPart2
					local v12 = v9
					task.spawn(function()
						for i, v13 in ipairs(v10) do
							local v14, base = next(v13)
							task.wait(v14)

							if part3 == nil then
								break
							end

							if Checker.check_victim(script, character, v12) ~= nil and character then
								Combat_Util.Damage(script, character, v12, {
									Base = base,
									Skill = script.Parent.Name
								})
							end
						end
					end)
					local part4 = humanoidRootPart2
					local v17 = v9
					task.spawn(function()
						if part4 == nil then
							return
						end

						task.wait(Config.VICTIM_CUTSCENE_DUR)

						if weld2 then
							weld2:Destroy()
						end

						if boolValue5 then
							boolValue5:Destroy()
						end

						if track and track.IsPlaying then
							track:Stop()
						end

						task.wait()
						local getvaluesfolder3 = Utility.getvaluesfolder(v17)

						if part4 == nil then
							return
						end

						if Checker.check_victim(script, character, v17) ~= nil and character then
							Combat_Util.AddStun(script, character, getvaluesfolder3, Config.FINISH_STUN)
							Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.FINISH_RAGDOLL)
							local v18 = cframe.RightVector + createVector(0, 1, 0)
							Combat_Util.Knockback(script, character, part4, v18 * Config.FINISH_KNOCKBACK, 0.2)
						end
					end)
				end
			end
		end
	end)
end

function CircularSlashesServer.Cancel(player)
	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "SerpentSlash_effs", player.Character, "Cancel")
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local v2 = removeSpaces(script.Parent.Name) -- equivalent call inferred; original call site unknown

		for _, child in pairs(getvaluesfolder:GetChildren()) do
			if child.Name == "InvisibleItem" and child:GetAttribute("Script") == v2 then
				child:Destroy()
			end
		end
	end
end

return CircularSlashesServer