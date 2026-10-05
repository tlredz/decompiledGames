local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local OnSlaughtServer = {
	Id = {}
}
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local _ = table.find
local _ = table.insert
local Server_Mouse_Pos = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
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

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))

function OnSlaughtServer.Hold(player, p, p2)
	if p2.Anim ~= nil then
		p2.Anim:Stop()
		p2.Anim = nil
	end

	local v2 = OnSlaughtServer.Id[player.UserId]
	Server_Mouse_Pos.Create_Pos_Part(player.Character, script.Parent.Name, 7, p)
	EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Init")
	task.delay(Config.DASH_START_DELAY, function()
		if OnSlaughtServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Dash")
	end)
	task.spawn(function()
		local v3 = false

		if player == nil then
			return
		end

		local character = player.Character

		if character == nil then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid == nil or humanoidRootPart == nil then
			return
		end

		local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)

		if character:FindFirstChild("on_slaught_asd123asd") then
			character.on_slaught_asd123asd:Destroy()
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "on_slaught_asd123asd"
		boolValue.Parent = character
		local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
		local v4 = nil

		local function includeCaptured(list)
			local v5 = v4

			if v5 == nil or v5.Parent == nil or v5:FindFirstChild("Humanoid") == nil then
				return list
			end

			if table.find(list, v5) == nil then
				table.insert(list, v5)
			end

			return list
		end

		task.wait(Config.DASH_START_DELAY)

		while humanoid ~= nil and humanoidRootPart ~= nil and v3 == false and boolValue ~= nil and boolValue.Parent == character do
			local child = character:FindFirstChild("PosPart" .. script.Parent.Name)
			local cFrame = humanoidRootPart.CFrame

			if child then
				cFrame = Utility.SafeLookAt(
					humanoidRootPart.Position,
					Vector3.new(child.Position.X, humanoidRootPart.Position.Y, child.Position.Z),
					humanoidRootPart.CFrame
				)
			end

			local singlePartHitbox = Utility.SinglePartHitbox({
				Caster = character,
				ParamsName = formatted,
				Origin = cFrame * Config.DASH_HITBOX_OFFSET,
				BoxSize = Config.DASH_HITBOX_SIZE
			})

			if singlePartHitbox ~= nil then
				local model = singlePartHitbox:FindFirstAncestorOfClass("Model")

				if model ~= nil and model ~= character and model:FindFirstChild("Humanoid") ~= nil then
					v4 = model
				end

				v3 = true
			end

			wait(0.05)
		end

		EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Cancel")

		if v3 == true and humanoidRootPart and v2 == OnSlaughtServer.Id[player.UserId] then
			p2.ServerDriven = true
			ServerClientPortal.ToClient(player, script.Parent.Name)
			EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Slashes")
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "pause_gameplay"
			stringValue.Value = script.Parent.Name
			stringValue.Parent = getvaluesfolder
			local stringValue2 = Instance.new("StringValue")
			stringValue2.Name = "NR"
			stringValue2.Value = script.Parent.Name
			stringValue2.Parent = getvaluesfolder
			DebrisModule:AddItem(stringValue2, Config.SLASH_LOCK_DUR)
			DebrisModule:AddItem(stringValue, Config.SLASH_LOCK_DUR)
			timedThread(function(...)
				if v2 ~= OnSlaughtServer.Id[player.UserId] then
					return
				end

				local getvaluesfolder2 = Utility.getvaluesfolder(character)
				local SLASHES_DUR = Config.SLASHES_DUR
				local SLASHES_COUNT = Config.SLASHES_COUNT

				for _ = 1, SLASHES_COUNT do
					if v2 ~= OnSlaughtServer.Id[player.UserId] then
						break
					end

					local child = character:FindFirstChild("PosPart" .. script.Parent.Name)
					local cFrame = humanoidRootPart.CFrame

					if child then
						cFrame = Utility.SafeLookAt(
							humanoidRootPart.Position,
							Vector3.new(child.Position.X, humanoidRootPart.Position.Y, child.Position.Z),
							humanoidRootPart.CFrame
						)
					end

					local modelInRegion = Utility.GetModelInRegion(
						cFrame * Config.SLASH_HITBOX_OFFSET,
						Config.SLASH_HITBOX_SIZE,
						nil,
						nil
					)
					local v5 = v4

					if v5 ~= nil and v5.Parent ~= nil and v5:FindFirstChild("Humanoid") ~= nil and table.find(
						modelInRegion,
						v5
					) == nil then
						table.insert(modelInRegion, v5)
					end

					for _, v6 in pairs(modelInRegion) do
						if v2 ~= OnSlaughtServer.Id[player.UserId] then
							break
						end

						if not (v6 ~= character and v6:FindFirstChild("Humanoid") ~= nil) then
							continue
						end

						local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
						local humanoid2 = v6:FindFirstChild("Humanoid")
						local check_victim, _ = Checker.check_victim(script, character, v6)
						local getvaluesfolder3 = Utility.getvaluesfolder(v6)

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

						if check_victim == "Perfect" then
							Combat_Util.Perfect(script, character, v6)
						elseif check_victim == true or check_victim == "Blocking" then
							if check_victim == "Blocking" then
								Combat_Util.Block(script, character, v6, Config.SLASH_BLOCK_BREAK)
							else
								Combat_Util.AddStun(script, character, getvaluesfolder3, Config.SLASH_STUN)
								EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
								Combat_Util.Damage(script, character, v6, {
									Base = Config.SLASH_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_presets.stop_extra_anims(humanoid2)
								local v7 = math.random(1, 5)
								local v8 = v7 == 5 and 6 or v7
								local track = humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(
									character,
									"React_" .. v8
								))
								track:AdjustSpeed(2.25)
								track:Play()
							end
						end
					end

					task.wait(SLASHES_DUR / SLASHES_COUNT)
				end
			end, 2)

			if humanoid then
				p2.Anim = humanoid:LoadAnimation(script.onslaught_land)
				p2.Anim:Play()
			end

			task.wait(Config.LAND_DUR)

			if v2 ~= OnSlaughtServer.Id[player.UserId] then
				return
			end

			EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "End")
			task.wait(Config.UPDRAFT_DELAY)

			if v2 ~= OnSlaughtServer.Id[player.UserId] then
				return
			end

			local child = character:FindFirstChild("PosPart" .. script.Parent.Name)
			local cFrame = humanoidRootPart.CFrame

			if child then
				cFrame = Utility.SafeLookAt(
					humanoidRootPart.Position,
					Vector3.new(child.Position.X, humanoidRootPart.Position.Y, child.Position.Z),
					humanoidRootPart.CFrame
				)
			end

			local modelInRegion = Utility.GetModelInRegion(
				cFrame * Config.UPDRAFT_HITBOX_OFFSET,
				Config.UPDRAFT_HITBOX_SIZE,
				nil,
				nil
			)
			local v5 = false

			for _, v6 in pairs(modelInRegion) do
				if v5 == true then
					break
				end

				if not (v6 ~= character and v6:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v6:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v6)
				local getvaluesfolder2 = Utility.getvaluesfolder(v6)

				if not (v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) ~= true and humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart ~= nil) then
					continue
				end

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v6)
					v5 = true
				elseif check_victim == true or check_victim == "Blocking" then
					if check_victim == "Blocking" then
						Combat_Util.Block(script, character, v6, Config.UPDRAFT_BLOCK_BREAK)
					else
						Combat_Util.AddStun(script, character, getvaluesfolder2, Config.UPDRAFT_STUN)
						humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(character, "React_6")):Play()
						Combat_Util.Damage(script, character, v6, {
							Base = Config.UPDRAFT_DAMAGE,
							Skill = script.Parent.Name
						})
					end

					Combat_Util.Air_combo_up(character, v6)
				end
			end

			EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Jump")
			task.wait(Config.AIRSLASH_AT)

			if v2 ~= OnSlaughtServer.Id[player.UserId] then
				return
			end

			if p2.Anim ~= nil then
				p2.Anim:Stop()
			end

			if humanoid ~= nil then
				p2.Anim = humanoid:LoadAnimation(script.onslaugh_airslash)
				p2.Anim:Play()
			end

			task.wait(Config.AIRSLASH_HIT_AT)

			if v2 ~= OnSlaughtServer.Id[player.UserId] then
				return
			end

			local cFrame2 = humanoidRootPart.CFrame

			if child then
				cFrame2 = Utility.SafeLookAt(
					humanoidRootPart.Position,
					Vector3.new(child.Position.X, humanoidRootPart.Position.Y, child.Position.Z),
					humanoidRootPart.CFrame
				)
			end

			local AIRSLASH_HITBOX_SIZE = Config.AIRSLASH_HITBOX_SIZE
			local modelInRegion2 = Utility.GetModelInRegion(
				cFrame2 * CFrame.new(0, 0, -AIRSLASH_HITBOX_SIZE.Z / 1.7 + 5),
				AIRSLASH_HITBOX_SIZE,
				nil,
				nil
			)
			local v6 = v4

			if v6 ~= nil and v6.Parent ~= nil and v6:FindFirstChild("Humanoid") ~= nil and table.find(
				modelInRegion2,
				v6
			) == nil then
				table.insert(modelInRegion2, v6)
			end

			local v7 = cFrame2.LookVector * 1 * Config.AIRSLASH_KNOCKBACK
			local v8 = {}

			for _, v9 in pairs(modelInRegion2) do
				if v5 == true then
					break
				end

				if not (v9 ~= character and v9:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v9:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v9)
				local getvaluesfolder2 = Utility.getvaluesfolder(v9)

				if not (v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) ~= true and humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart ~= nil) then
					continue
				end

				if check_victim == "Blocking" then
					Combat_Util.Block(script, character, v9, Config.AIRSLASH_BLOCK_BREAK)
				elseif check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v9)
				elseif check_victim == true then
					Combat_Util.AddStun(script, character, getvaluesfolder2, Config.AIRSLASH_STUN)
					Combat_Util.Damage(script, character, v9, {
						Base = Config.AIRSLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, humanoidRootPart2, v7, 0.3)
					Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.AIRSLASH_RAGDOLL)
					table.insert(v8, v9)
				end
			end

			task.spawn(function()
				local BLEED_TICKS = Config.BLEED_TICKS
				local BLEED_DUR = Config.BLEED_DUR

				for _ = 1, BLEED_TICKS do
					task.wait(BLEED_DUR / BLEED_TICKS)

					for _, v9 in pairs(v8) do
						if Checker.check_victim(script, character, v9) ~= nil then
							Combat_Util.Damage(script, character, v9, {
								Base = Config.BLEED_DAMAGE,
								Skill = script.Parent.Name
							})
						end
					end
				end
			end)
			local raycastResult = workspace:Raycast(
				cFrame2.Position,
				cFrame2.LookVector * Config.SHOOT_DIST,
				raycastParams
			)
			local position

			if raycastResult then
				position = raycastResult.Position
			else
				position = (cFrame2 * CFrame.new(0, 0, -Config.SHOOT_DIST)).Position
			end

			p2.Shooted = true
			EffectsEvent.ToAllInRange(
				player,
				"OnSlaught_effs",
				player.Character,
				"Shoot",
				CFrame.lookAlong(position, cFrame2.LookVector)
			)
			task.delay(Config.EXPLOSION_DELAY, function()
				local EXPLOSION_HITBOX_SIZE = Config.EXPLOSION_HITBOX_SIZE
				local modelInRegion3 = Utility.GetModelInRegion(
					CFrame.lookAlong(position, cFrame2.LookVector),
					EXPLOSION_HITBOX_SIZE,
					nil,
					nil
				)

				for _, v9 in pairs(v8) do
					if table.find(modelInRegion3, v9) == nil then
						table.insert(modelInRegion3, v9)
					end
				end

				for _, v9 in pairs(modelInRegion3) do
					if v5 == true then
						break
					end

					if not (v9 ~= character and v9:FindFirstChild("Humanoid") ~= nil) then
						continue
					end

					local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")
					local humanoid2 = v9:FindFirstChild("Humanoid")
					local check_victim, _ = Checker.check_victim(script, character, v9)
					local getvaluesfolder2 = Utility.getvaluesfolder(v9)

					if not (v.Both(getvaluesfolder2, {
						pv = getvaluesfolder,
						name = "Choosing_1"
					}) ~= true and humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart ~= nil) then
						continue
					end

					if check_victim == "Blocking" or check_victim == "Perfect" then
						Combat_Util.Block(script, character, v9, Config.EXPLOSION_BLOCK_BREAK)
					elseif check_victim == true then
						Combat_Util.AddStun(script, character, getvaluesfolder2, Config.EXPLOSION_STUN)
						Combat_Util.Damage(script, character, v9, {
							Base = Config.EXPLOSION_DAMAGE,
							Skill = script.Parent.Name
						})
						local v10 = (position - humanoidRootPart2.Position).Unit * Config.EXPLOSION_KNOCKBACK + Vector3.new(
							0,
							-Config.EXPLOSION_DOWN_PULL,
							0
						)
						Combat_Util.Knockback(script, character, humanoidRootPart2, v10, 0.3, "remove_airbp")
						Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.EXPLOSION_RAGDOLL)
					end
				end
			end)
			task.wait(Config.SHOOT_END_AT)

			if v2 ~= OnSlaughtServer.Id[player.UserId] then
				return
			end

			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "Cancel", true)
		end
	end)
end

local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function OnSlaughtServer.UnHold(player, _, state)
	local v2 = OnSlaughtServer.Id[player.UserId]
	ServerClientPortal.Destroy(player, script.Parent.Name)

	if player and player.Character then
		if state.Anim ~= nil then
			if state.Shooted == nil then
				state.Anim:Stop()
			end

			state.Anim = nil
		end

		state.Shooted = nil
		local character = player.Character
		local getvaluesfolder = Utility.getvaluesfolder(character)

		for _, child in pairs(getvaluesfolder:GetChildren()) do
			if not (table.find({ "NR", "pause_gameplay" }, child.Name) and child.Value == script.Parent.Name) then
				continue
			end

			child:Destroy()
		end

		if character:FindFirstChild("on_slaught_asd123asd") then
			DebrisModule:AddItem(character.on_slaught_asd123asd, Config.DASH_DECAY_DUR)
		end
	end

	local v3, v4 = ManuelCancel.new(player, 0.1)
	v3:Connect(function()
		if player and player.Parent == game.Players then
			OnSlaughtServer.Id[player.UserId] = 0
		end

		OnSlaughtServer.Cancel(player)
		v4()
	end)
	task.delay(0.1, function()
		if OnSlaughtServer.Id[player.UserId] == v2 then
			local v5 = not state.Shooted
			EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Cancel", nil, v5)

			if player and player.Character then
				Server_Mouse_Pos.Delete_Pos_Part(player.Character, script.Parent.Name)
			end
		end
	end)
end

function OnSlaughtServer.Cancel(player, _, state)
	if player and player.Character then
		if state.Anim ~= nil then
			state.Anim:Stop()
			state.Anim = nil
		end

		ServerClientPortal.Destroy(player, script.Parent.Name)
		local character = player.Character
		local getvaluesfolder = Utility.getvaluesfolder(character)

		for _, child in pairs(getvaluesfolder:GetChildren()) do
			if not (table.find({ "NR", "pause_gameplay" }, child.Name) and child.Value == script.Parent.Name) then
				continue
			end

			child:Destroy()
		end

		if character:FindFirstChild("on_slaught_asd123asd") then
			character.on_slaught_asd123asd:Destroy()
		end

		Server_Mouse_Pos.Delete_Pos_Part(player.Character, script.Parent.Name)
	end

	local v2 = not state.Shooted
	EffectsEvent.ToAllInRange(player, "OnSlaught_effs", player.Character, "Cancel", nil, v2)
end

return OnSlaughtServer