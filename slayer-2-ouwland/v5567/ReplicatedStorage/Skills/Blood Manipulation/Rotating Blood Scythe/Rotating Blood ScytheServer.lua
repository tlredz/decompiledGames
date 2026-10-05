local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RotatingBloodScytheServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)

local function timedThread(fn, value)
	local thread = coroutine.create(fn)
	task.delay(value or 5, function()
		if coroutine.status(thread) == "running" then
			coroutine.close(thread)
		end
	end)
	local v2, v3 = coroutine.resume(thread)

	if not v2 then
		warn(v3)
	end

	return thread
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeSpaces(name)
	return name:gsub(" ", "")
end

function RotatingBloodScytheServer.Hold(player)
	if player == nil then
		return
	end

	local v2 = RotatingBloodScytheServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	task.wait(Config.WINDUP_VFX_AT)

	if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "RotatingBloodScythe_effs", character, "Windup")
	task.wait(Config.START_VFX_AT)

	if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "RotatingBloodScythe_effs", character, "Start")
	task.wait(Config.SPIN_AT)

	if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "InvisibleItem"
	stringValue.Value = "SickleLeft,SickleRight"
	stringValue:SetAttribute("Script", removeSpaces(script.Parent.Name))
	stringValue.Parent = getvaluesfolder
	Debris:AddItem(stringValue, Config.SICKLE_HIDE_DUR)
	timedThread(function(...)
		if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
			return
		end

		local position = humanoidRootPart.Position

		while v2 == RotatingBloodScytheServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil do
			local v3 = CFrame.new(position.X, humanoidRootPart.Position.Y, position.Z) * humanoidRootPart.CFrame.Rotation * Config.SPIN_HITBOX_OFFSET
			local SPIN_HITBOX_SIZE = Config.SPIN_HITBOX_SIZE
			local modelInRegion = Utility.GetModelInRegion(v3, SPIN_HITBOX_SIZE, nil, nil)

			for _, v4 in pairs(modelInRegion) do
				if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
					break
				end

				if not (v4 ~= character and v4:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v4:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v4)
				local getvaluesfolder2 = Utility.getvaluesfolder(v4)

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

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v4)
				elseif check_victim == true or check_victim == "Blocking" then
					if check_victim == "Blocking" then
						Combat_Util.Block(script, character, v4, Config.SPIN_BLOCK_BREAK)
					else
						Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SPIN_STUN, true)
						EffectsEvent.ToAllInRange(character, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
						Combat_Util.Damage(script, character, v4, {
							Base = Config.SPIN_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_presets.stop_extra_anims(humanoid2)
						local v5 = math.random(1, 5)
						local v6 = v5 == 5 and 6 or v5
						local track = humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(
							character,
							"React_" .. v6
						))
						track:AdjustSpeed(2.25)
						track:Play()
					end

					local v5 = (humanoidRootPart.Position - humanoidRootPart2.Position).Unit * Config.SPIN_PULL
					Combat_Util.Knockback(script, character, humanoidRootPart2, v5, Config.SPIN_PULL_DUR)
				end
			end

			task.wait(Config.SPIN_TICK_INTERVAL)
		end
	end, 6)
end

function RotatingBloodScytheServer.UnHold(player)
	if player == nil then
		return
	end

	local v2 = RotatingBloodScytheServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = removeSpaces(script.Parent.Name) -- equivalent call inferred; original call site unknown

	for _, child in pairs(getvaluesfolder:GetChildren()) do
		if child.Name == "InvisibleItem" and child:GetAttribute("Script") == v3 then
			Debris:AddItem(child, Config.SICKLE_UNHIDE_DELAY)
		end
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	task.wait(Config.FINISH_AT)

	if v2 ~= RotatingBloodScytheServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "RotatingBloodScythe_effs", character, "End")
	local modelInRegion = Utility.GetModelInRegion(
		humanoidRootPart.CFrame * Config.FINISH_HITBOX_OFFSET,
		Config.FINISH_HITBOX_SIZE,
		nil,
		nil
	)
	local v4 = humanoidRootPart.CFrame.LookVector * Config.FINISH_KNOCKBACK

	for _, v5 in pairs(modelInRegion) do
		local getvaluesfolder2 = Utility.getvaluesfolder(character)

		if not (v5 ~= character and v5:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v5:FindFirstChild("HumanoidRootPart")
		local humanoid2 = v5:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v5)
		local getvaluesfolder3 = Utility.getvaluesfolder(v5)

		if v.Both(getvaluesfolder3, {
			pv = getvaluesfolder2,
			name = "Choosing_1"
		}) == true then
			continue
		end

		local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart3 ~= nil) then
			continue
		end

		if check_victim == "Blocking" or check_victim == "Perfect" then
			Combat_Util.Block(script, character, v5, Config.FINISH_BLOCK_BREAK)
		elseif check_victim == true then
			Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder3, Config.FINISH_STUN)
			Combat_Util.Damage(script, character, v5, {
				Base = Config.FINISH_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.FINISH_RAGDOLL)
		end

		Combat_Util.Knockback(script, character, humanoidRootPart2, Vector3.new(v4.X, Config.FINISH_KNOCKUP, v4.Z), 0.4)
	end
end

function RotatingBloodScytheServer.Cancel(player)
	if player == nil then
		return
	end

	local character = player.Character
	character:SetAttribute("RAR_StartHolding", nil)
	EffectsEvent.ToAllInRange(character, "RotatingBloodScythe_effs", character, "Cancel")

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = removeSpaces(script.Parent.Name) -- equivalent call inferred; original call site unknown

	for _, child in pairs(getvaluesfolder:GetChildren()) do
		if child.Name == "InvisibleItem" and child:GetAttribute("Script") == v2 then
			child:Destroy()
		end
	end

	local getvaluesfolder2 = Utility.getvaluesfolder(character)
	local v3 = removeSpaces(script.Parent.Name) -- equivalent call inferred; original call site unknown

	for _, child in pairs(getvaluesfolder2:GetChildren()) do
		if child.Name == "InvisibleItem" and child:GetAttribute("Script") == v3 then
			child:Destroy()
		end
	end
end

return RotatingBloodScytheServer