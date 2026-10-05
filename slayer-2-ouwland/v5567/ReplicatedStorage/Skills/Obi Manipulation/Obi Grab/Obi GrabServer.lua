local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObiGrabServer = {
	Id = {}
}
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)

function ObiGrabServer.Hold(player)
	local _ = ObiGrabServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Humanoid")
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function ObiGrabServer.UnHold(player, _, _)
	local v2 = ObiGrabServer.Id[player.UserId]

	if player ~= nil and player.Character then
		player.Character:FindFirstChild("HumanoidRootPart")
		local character = player.Character

		if character == nil then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if Checker.check(player, script.Parent.Name) == nil then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid == nil then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local v3 = humanoidRootPart.Position - humanoidRootPart.CFrame.LookVector * Config.GRAB_WALL_RAY_BACK
		local raycastResult = workspace:Raycast(
			v3,
			humanoidRootPart.CFrame.LookVector * Config.GRAB_WALL_CLEARANCE,
			raycastParams
		)
		local v4

		if raycastResult then
			local magnitude = (raycastResult.Position - v3).Magnitude
			local v5 = Config.GRAB_WALL_CLEARANCE - magnitude
			v4 = v5 < 0 and 0 or v5
		else
			v4 = 0
		end

		local cFrame2 = cFrame * CFrame.new(0, 0, v4)
		local modelInRegion = Utility.GetModelInRegion(
			cFrame2 * Config.GRAB_HITBOX_OFFSET,
			Config.GRAB_HITBOX_SIZE,
			nil,
			nil
		)
		local cFrame3 = cFrame2 * Config.GRAB_VICTIM_OFFSET
		local v7 = {}
		local v8 = {}
		local v9 = false

		for _, v10 in pairs(modelInRegion) do
			if not (v10 ~= character and v10:FindFirstChild("Humanoid") ~= nil) then
				continue
			end

			local humanoidRootPart2 = v10:FindFirstChild("HumanoidRootPart")
			local humanoid2 = v10:FindFirstChild("Humanoid")
			local check_victim, _ = Checker.check_victim(script, character, v10)
			local getvaluesfolder2 = Utility.getvaluesfolder(v10)

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

			if check_victim == "Blocking" or check_victim == "Perfect" then
				Combat_Util.Block(script, character, v10, Config.GRAB_BLOCK_BREAK)
			elseif check_victim == true then
				v9 = true
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 1
				part.Massless = true
				part.CFrame = cFrame3
				part.CanCollide = false
				part.Parent = workspace.Debree
				DebrisModule:AddItem(part, Config.GRAB_HOLD_DUR)
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue, Config.GRAB_HOLD_DUR)
				local stringValue = Instance.new("StringValue")
				stringValue.Name = "iframe"
				stringValue.Value = getvaluesfolder.Name
				stringValue.Parent = getvaluesfolder2
				DebrisModule:AddItem(stringValue, Config.GRAB_HOLD_DUR)

				if game.Players:GetPlayerFromCharacter(v10) then
					table.insert(v7, game.Players:GetPlayerFromCharacter(v10))
				end

				table.insert(v8, v10)
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = humanoidRootPart2
				weld.Parent = part
				humanoid2.Animator:LoadAnimation(script.ObiGrabVictim):Play()
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "noragdoll"
				boolValue2.Parent = getvaluesfolder2
				Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.GRAB_HOLD_DUR)
				Combat_Util.Damage(script, character, v10, {
					Base = Config.GRAB_DAMAGE / 2,
					Skill = script.Parent.Name
				})
				DebrisModule:AddItem(boolValue2, Config.GRAB_HOLD_DUR)
				local v11 = v10
				local parent = getvaluesfolder2
				task.delay(Config.GRAB_HOLD_DUR, function()
					if ObiGrabServer.Id[player.UserId] == v2 and character and Checker.check_victim(
						script,
						character,
						v11
					) ~= nil then
						if weld ~= nil then
							weld:Destroy()
						end

						if boolValue2 then
							boolValue2:Destroy()
						end

						Combat_Util.Add_Strict_Stun(script, character, parent, Config.SLAM_STUN)
						Combat_Util.RagDoll(script, character, parent, Config.SLAM_RAGDOLL)
						Combat_Util.Damage(script, character, v11, {
							Base = Config.GRAB_DAMAGE / 2,
							Skill = script.Parent.Name
						})
					end
				end)
			end
		end

		if v9 == true then
			ServerClientPortal.ToClient(player, script.Parent.Name)
			EffectsEvent.ToAllInRange(character, "ObiGrab_effs", character, "Grabbed", v8[1])
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "pause_gameplay"
			boolValue.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue, Config.CASTER_LOCK_DUR)
			local boolValue2 = Instance.new("BoolValue")
			boolValue2.Name = "iframe"
			boolValue2.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue2, Config.CASTER_LOCK_DUR)
			local boolValue3 = Instance.new("BoolValue")
			boolValue3.Name = "noragdoll"
			boolValue3.Parent = getvaluesfolder
			DebrisModule:AddItem(boolValue3, Config.CASTER_LOCK_DUR)
			local part = Instance.new("Part")
			part.Anchored = true
			part.Massless = true
			part.Transparency = 1
			part.CFrame = cFrame2
			part.CanCollide = false
			part.Parent = workspace.Debree
			DebrisModule:AddItem(part, Config.CASTER_LOCK_DUR)
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = humanoidRootPart
			weld.Parent = part
			DebrisModule:AddItem(weld, Config.CASTER_LOCK_DUR)
			humanoid:LoadAnimation(script.ObiGrabUser):Play()
		else
			EffectsEvent.ToAllInRange(character, "ObiGrab_effs", character, "Miss")
		end
	end
end

function ObiGrabServer.Cancel(player, _, _)
	if player ~= nil and player.Character then
		local _ = player.Character
	end
end

return ObiGrabServer