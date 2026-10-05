local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local CoilChokeServer = {
	Id = {}
}
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local find = table.find
local insert = table.insert
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local ANIM_SPEED = Config.ANIM_SPEED
local v2 = Config.ATTACKER_ANIM_TIME / ANIM_SPEED
local v3 = Config.VICTIM_ANIM_TIME / ANIM_SPEED

local function timedThread(fn, value)
	local thread = coroutine.create(fn)
	task.delay(value or 5, function()
		if coroutine.status(thread) == "running" then
			coroutine.close(thread)
		end
	end)
	local v4, v5 = coroutine.resume(thread)

	if not v4 then
		warn(v5)
	end

	return thread
end

function CoilChokeServer.Hold(player, _, _)
	local character = player.Character
	local _ = CoilChokeServer.Id[player.UserId]

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart ~= nil and humanoid ~= nil) then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "CoilChoke_effs", character, "Startup")
end

local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)

function CoilChokeServer.UnHold(player, _, _)
	local character = player.Character
	local v4 = CoilChokeServer.Id[player.UserId]

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart ~= nil and humanoid ~= nil) then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "CoilChoke_effs", character, "Start")
	local v5 = Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", Config.CAST_LOCK_DUR)
	local v6 = {}
	task.delay(Config.PREGRAB_DELAY, function()
		if v4 ~= CoilChokeServer.Id[player.UserId] then
			return
		end

		timedThread(function(...)
			if v4 ~= CoilChokeServer.Id[player.UserId] then
				return
			end

			local PREGRAB_SCAN_DUR = Config.PREGRAB_SCAN_DUR
			local getvaluesfolder = Utility.getvaluesfolder(character)
			local v7 = humanoidRootPart.CFrame * Config.PREGRAB_HITBOX_OFFSET
			local now = os.clock()

			while v4 == CoilChokeServer.Id[player.UserId] and now + PREGRAB_SCAN_DUR > os.clock() do
				local PREGRAB_HITBOX_SIZE = Config.PREGRAB_HITBOX_SIZE
				v6 = Utility.GetModelInRegion(v7, PREGRAB_HITBOX_SIZE, nil, nil)

				for _, v8 in pairs(v6) do
					if v4 ~= CoilChokeServer.Id[player.UserId] then
						break
					end

					if not (v8 ~= character and v8:FindFirstChild("Humanoid") ~= nil) then
						continue
					end

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

					if check_victim == "Perfect" then
						Combat_Util.Perfect(script, character, v8)
					elseif check_victim == true or check_victim == "Blocking" then
						if check_victim == "Blocking" then
							Combat_Util.Block(script, character, v8, Config.PREGRAB_BLOCK_BREAK)
						else
							Combat_Util.AddStun(script, character, getvaluesfolder2, Config.PREGRAB_STUN)
							EffectsEvent.ToAllInRange(
								humanoidRootPart,
								"Normal_Sword_Slash_Effect",
								humanoidRootPart2,
								-1
							)
							Combat_Util.Knockback(
								script,
								character,
								humanoidRootPart2,
								Vector3.new(0, Config.PREGRAB_KNOCKUP, 0),
								Config.PREGRAB_KNOCKUP_DUR
							)
							Combat_Util.Damage(script, character, v8, {
								Base = Config.PREGRAB_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_presets.stop_extra_anims(humanoid2)
							local v9 = math.random(1, 5)
							local v10 = v9 == 5 and 6 or v9
							local track = humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(
								character,
								"React_" .. v10
							))
							track:AdjustSpeed(2.25)
							track:Play()
						end
					end
				end

				task.wait(Config.PREGRAB_TICK)
			end
		end, 1.5)
	end)
	local v7, _ = ManuelCancel.new(player, Config.GRAB_CANCEL_WINDOW)
	v7:Connect(function()
		CoilChokeServer.Id[player.UserId] = 0
		v5:Destroy()
		EffectsEvent.ToAllInRange(humanoidRootPart, "CoilChoke_effs", character, "Cancel")
	end)
	task.delay(Config.GRAB_AT, function()
		if CoilChokeServer.Id[player.UserId] ~= v4 then
			return
		end

		local v8 = false
		Utility.getvaluesfolder(character)
		local GRAB_BLOCK_BREAK = Config.GRAB_BLOCK_BREAK
		local FINISH_DAMAGE = Config.FINISH_DAMAGE
		local character2 = player.Character

		if character2 == nil then
			return
		end

		local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
		local getvaluesfolder = Utility.getvaluesfolder(character2)
		local humanoid2 = character2:FindFirstChild("Humanoid")

		if humanoid2 == nil then
			return
		end

		local cFrame = humanoidRootPart2.CFrame * Config.GRAB_HITBOX_OFFSET
		local GRAB_HITBOX_SIZE = Config.GRAB_HITBOX_SIZE
		local v10 = false
		local v11 = {}
		local v12 = {}
		local tracks = {}
		local v13 = {}

		for _, v14 in pairs(v6) do
			if v10 == true then
				break
			end

			if not (v14 ~= character2 and v14:FindFirstChild("Humanoid") ~= nil) then
				continue
			end

			local humanoidRootPart3 = v14:FindFirstChild("HumanoidRootPart")
			local humanoid3 = v14:FindFirstChild("Humanoid")
			local check_victim, _ = Checker.check_victim(script, character2, v14)
			local getvaluesfolder2 = Utility.getvaluesfolder(v14)

			if v.Both(getvaluesfolder2, {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}) == true then
				continue
			end

			local humanoidRootPart4 = character2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart3 ~= nil and humanoid3 ~= nil and humanoidRootPart4 ~= nil) then
				continue
			end

			if check_victim == "Perfect" then
				Combat_Util.Perfect(script, character2, v14)
			elseif check_victim == "Blocking" then
				Combat_Util.Block(script, character2, v14, GRAB_BLOCK_BREAK)
			elseif check_victim == true then
				if Players:GetPlayerFromCharacter(v14) ~= nil then
					Utility.AddValue(
						getvaluesfolder2,
						"iframe",
						Config.VICTIM_PVP_IFRAME_DUR,
						"StringValue",
						character2.Name
					)
				end

				Combat_Util.Damage(script, character2, v14, {
					Base = Config.SLAM_DAMAGE,
					Skill = script.Parent.Name
				})
				local v15 = v14
				task.delay(Config.PULL_DAMAGE_AT / ANIM_SPEED, function()
					Combat_Util.Damage(script, character2, v15, {
						Base = Config.PULL_DAMAGE,
						Skill = script.Parent.Name
					})
				end)
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 1
				part.Massless = true
				part.CFrame = cFrame
				part.CanCollide = false
				part.Parent = workspace.Debree
				DebrisModule:AddItem(part, v3)
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue, v3)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "noragdoll"
				boolValue2.Parent = getvaluesfolder2
				DebrisModule:AddItem(boolValue2, v3)

				if game.Players:GetPlayerFromCharacter(v14) then
					table.insert(v11, game.Players:GetPlayerFromCharacter(v14))
				end

				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = humanoidRootPart3
				weld.Parent = part
				local track = humanoid3.Animator:LoadAnimation(script.coilchoke_victim)
				track.Priority = Enum.AnimationPriority.Action4
				track:Play(0, 1, ANIM_SPEED)
				local boolValue3 = Instance.new("BoolValue")
				boolValue3.Name = "noragdoll"
				boolValue3.Parent = getvaluesfolder2
				Combat_Util.AddStun(script, character2, getvaluesfolder2, v3 + Config.GRAB_STUN_EXTRA)
				DebrisModule:AddItem(boolValue3, v3)
				table.insert(v12, weld)
				table.insert(v12, boolValue3)
				table.insert(tracks, track)
				table.insert(v13, v14)
				v10 = true
				v8 = true
			end
		end

		if CoilChokeServer.Id[player.UserId] ~= v4 or not v8 then
			return EffectsEvent.ToAllInRange(humanoidRootPart2, "CoilChoke_effs", character2, "Cancel", true)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart2, "CoilChoke_effs", character2, "Success")
		task.delay(Config.FINISH_AT / ANIM_SPEED, function()
			for _, v14 in pairs(v12) do
				if not v14 then
					continue
				end

				local v15 = v14
				pcall(function()
					v15:Destroy()
				end)
			end

			for _, v14 in pairs(tracks) do
				if v14 ~= nil and v14.IsPlaying then
					v14:Stop(0)
				end
			end

			local modelInRegion = Utility.GetModelInRegion(cFrame, GRAB_HITBOX_SIZE, nil, nil)

			if typeof(v13) == "table" then
				for _, v14 in pairs(v13) do
					if find(modelInRegion, v14) == nil then
						insert(modelInRegion, v14)
					end
				end
			end

			for _, v14 in pairs(modelInRegion) do
				if not (v14 ~= character2 and v14:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart3 = v14:FindFirstChild("HumanoidRootPart")
				local humanoid3 = v14:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character2, v14)
				local getvaluesfolder2 = Utility.getvaluesfolder(v14)

				if v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) == true then
					continue
				end

				local humanoidRootPart4 = character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart3 ~= nil and humanoid3 ~= nil and humanoidRootPart4 ~= nil) then
					continue
				end

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character2, v14)
				elseif check_victim == "Blocking" then
					Combat_Util.Block(script, character2, v14, Config.FINISH_BLOCK_BREAK)
				elseif check_victim == true then
					local unit = ((cFrame * CFrame.new(0, 0, -3)).Position - humanoidRootPart3.Position).Unit
					Combat_Util.Knockback(
						script,
						character2,
						humanoidRootPart3,
						unit * Config.FINISH_KNOCKBACK,
						Config.FINISH_KNOCKBACK_DUR
					)
					Combat_Util.AddStun(script, character2, getvaluesfolder2, Config.FINISH_STUN)
					Combat_Util.RagDoll(script, character2, getvaluesfolder2, Config.FINISH_RAGDOLL)
					Combat_Util.Damage(script, character2, v14, {
						Base = FINISH_DAMAGE,
						Skill = script.Parent.Name
					})
				end
			end
		end)
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "pause_gameplay"
		boolValue.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue, v2 - 0.05)
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "iframe"
		boolValue2.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue2, v2 - 0.05)
		local boolValue3 = Instance.new("BoolValue")
		boolValue3.Name = "noragdoll"
		boolValue3.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue3, v2 - 0.05)
		local part = Instance.new("Part")
		part.Anchored = true
		part.Massless = true
		part.Transparency = 1
		part.CFrame = cFrame
		part.CanCollide = false
		part.Parent = workspace.Debree
		DebrisModule:AddItem(part, v2 - 0.05)
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = humanoidRootPart2
		weld.Parent = part
		DebrisModule:AddItem(weld, v2)
		humanoid2.Animator:LoadAnimation(script.coilchoke_player):Play(0.05, 1, ANIM_SPEED)
	end)
end

function CoilChokeServer.Cancel(player)
	if player.Character then
		EffectsEvent.ToAllInRange(player, "CoilChoke_effs", player.Character, "Cancel")
	end
end

return CoilChokeServer