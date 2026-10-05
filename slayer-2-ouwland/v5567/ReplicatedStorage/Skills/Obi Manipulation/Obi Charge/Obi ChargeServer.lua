local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ObiChargeServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
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

local insert = table.insert
local find = table.find
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function ObiChargeServer.Hold(player)
	if player == nil then
		return
	end

	local v2 = ObiChargeServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	EffectsEvent.ToAllInRange(character, "ObiCharge_effs", character, "Start")
	task.wait(Config.LOOP_START_AT)

	if v2 ~= ObiChargeServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "ObiCharge_effs", character, "Loop")
	timedThread(function(...)
		if v2 ~= ObiChargeServer.Id[player.UserId] then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		local name = script.Parent.Name .. " Skill Hitlist"

		if character:FindFirstChild(name) then
			character[name]:Destroy()
		end

		local v4 = {}
		local folder = Instance.new("Folder", character)
		folder.Name = name
		DebrisModule:AddItem(folder, 12)
		local v5 = false
		local parentChangedConnection = nil

		local function delete()
			if v5 == false then
				v5 = true

				if parentChangedConnection then
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end

				if v4 then
					for _, v6 in pairs(v4) do
						v6:Destroy()
					end

					v4 = nil
				end

				if folder ~= nil then
					folder:Destroy()
					folder = nil
				end
			end
		end

		parentChangedConnection = folder:GetPropertyChangedSignal("Parent"):Connect(delete)
		task.delay(10, delete)
		local v6 = {}

		while v2 == ObiChargeServer.Id[player.UserId] do
			local modelInRegion = Utility.GetModelInRegion(
				humanoidRootPart.CFrame * Config.CARRY_HITBOX_OFFSET,
				Config.CARRY_HITBOX_SIZE,
				nil,
				nil
			)

			if folder ~= nil then
				for _, child in pairs(folder:GetChildren()) do
					local value = child.Value

					if value and find(modelInRegion, value) == nil then
						insert(modelInRegion, value)
					end
				end
			end

			for _, v7 in pairs(modelInRegion) do
				if v6[v7] ~= nil then
					continue
				end

				v6[v7] = true
				local v8 = v7
				task.delay(Config.CARRY_HIT_COOLDOWN, function()
					v6[v8] = nil
				end)

				if v2 ~= ObiChargeServer.Id[player.UserId] then
					break
				end

				if not (v7 ~= character and v7:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v7:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v7)

				if check_victim == nil then
					continue
				end

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

				if check_victim == "Blocking" or check_victim == "Perfect" then
					Combat_Util.Block(script, character, v7, Config.CARRY_BLOCK_BREAK)
				elseif check_victim == true then
					local v9 = false

					for _, child in pairs(folder:GetChildren()) do
						if child.Value ~= v7 then
							continue
						end

						v9 = true
						break
					end

					if v9 == false then
						if v.Both(getvaluesfolder2, {
							pv = getvaluesfolder,
							lifetime = 0.05,
							name = "Carry_choose",
							add = true
						}) ~= true then
							if game.Players:GetPlayerFromCharacter(v7) == nil and humanoidRootPart2:CanSetNetworkOwnership() == true then
								humanoidRootPart2:SetNetworkOwner(player)
							end

							for _, v11 in ipairs(CollectionService:GetTagged("OuwWeld")) do
								if v11.Value == humanoidRootPart2 then
									v11:Destroy()
								end
							end

							local count = #folder:GetChildren()
							local v11 = (count % 2 == 0 and 1 or -1) * math.ceil(count / 2) * Config.CARRY_WELD_SPACING
							local ouwWeld = Utility.CreateOuwWeld(
								humanoidRootPart3,
								humanoidRootPart2,
								CFrame.new(v11, 0, Config.CARRY_WELD_FORWARD),
								Config.HOLD_LOCK_DURATION
							)

							if ouwWeld ~= nil then
								insert(v4, ouwWeld)
							end

							local v12 = Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.HOLD_LOCK_DURATION)
							local v13 = Utility.AddValue(
								getvaluesfolder2,
								"NOMouvementlines",
								Config.HOLD_LOCK_DURATION
							)
							insert(v4, v12)
							insert(v4, v13)
							Combat_Util.Cancel(script, getvaluesfolder2)
							local objectValue = Instance.new("ObjectValue")
							objectValue.Name = v7.Name
							objectValue.Value = v7
							objectValue.Parent = folder
							EffectsEvent.ToAllInRange(character, "ObiCharge_effs", v7, "Hit")
							Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.CARRY_STUN)
							Combat_Util.Damage(script, character, v7, {
								Base = Config.CARRY_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_presets.PlayReactAnim(humanoid2)
							local v14, v15 = ManuelCancel.new(v7, nil, { "Swapping" })
							v14:Connect(function()
								v15()

								if ouwWeld ~= nil then
									ouwWeld:Destroy()
								end

								if objectValue ~= nil then
									objectValue:Destroy()
								end

								if v12 ~= nil then
									v12:Destroy()
								end

								if v13 ~= nil then
									v13:Destroy()
								end
							end)
						end
					else
						Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.CARRY_STUN)
						Combat_Util.Damage(script, character, v7, {
							Base = Config.CARRY_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_presets.PlayReactAnim(humanoid2)
					end
				end
			end

			task.wait(Config.CARRY_TICK_INTERVAL)
		end
	end, 6)
end

function ObiChargeServer.UnHold(player)
	if player == nil then
		return
	end

	local _ = ObiChargeServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local v2 = script.Parent.Name .. " Skill Hitlist"
	local v3 = {}

	if character:FindFirstChild(v2) then
		for _, child in pairs(character[v2]:GetChildren()) do
			table.insert(v3, child.Value)
		end

		character[v2]:Destroy()
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local modelInRegion = Utility.GetModelInRegion(
		humanoidRootPart.CFrame * Config.RELEASE_HITBOX_OFFSET,
		Config.RELEASE_HITBOX_SIZE,
		nil,
		nil,
		false
	)

	for _, v4 in pairs(v3) do
		if table.find(modelInRegion, v4) == nil then
			table.insert(modelInRegion, v4)
		end
	end

	for _, v4 in pairs(modelInRegion) do
		local getvaluesfolder = Utility.getvaluesfolder(character)

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
				Combat_Util.Block(script, character, v4, Config.RELEASE_BLOCK_BREAK)
			else
				Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.RELEASE_STUN)
				Combat_Util.Damage(script, character, v4, {
					Base = Config.RELEASE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.RELEASE_RAGDOLL)
				local v5 = humanoidRootPart.CFrame.LookVector * Config.RELEASE_KNOCKBACK
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(v5.X, Config.RELEASE_KNOCKUP, v5.Z),
					0.2
				)
			end
		end
	end

	local v5 = false
	ManuelCancel.new(player, Config.FINAL_BLAST_AT, nil, script.Parent.Name):Connect(function()
		v5 = true
	end)
	EffectsEvent.ToAllInRange(character, "ObiCharge_effs", character, "Final")
	task.wait(Config.FINAL_BLAST_AT)

	if v5 == true or character == nil then
		return
	end

	local modelInRegion2 = Utility.GetModelInRegion(humanoidRootPart.CFrame, Config.BLAST_HITBOX_SIZE, nil, nil, false)

	for _, v6 in pairs(modelInRegion2) do
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if not (v6 ~= character and v6:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
		local humanoid2 = v6:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v6)
		local getvaluesfolder2 = Utility.getvaluesfolder(v6)

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
			Combat_Util.Perfect(script, character, v6)
		elseif check_victim == true or check_victim == "Blocking" then
			if check_victim == "Blocking" then
				Combat_Util.Block(script, character, v6, Config.BLAST_BLOCK_BREAK)
			else
				Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.BLAST_STUN)
				Combat_Util.Damage(script, character, v6, {
					Base = Config.BLAST_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.BLAST_RAGDOLL)
				local v7 = (humanoidRootPart2.Position - humanoidRootPart.Position).Unit * Config.BLAST_KNOCKBACK
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(v7.X, Config.BLAST_KNOCKUP, v7.Z),
					0.2
				)
			end
		end
	end
end

function ObiChargeServer.Cancel(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local v2 = script.Parent.Name .. " Skill Hitlist"

	if character:FindFirstChild(v2) then
		character[v2]:Destroy()
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	EffectsEvent.ToAllInRange(character, "ObiCharge_effs", character, "Cancel", true)
end

return ObiChargeServer