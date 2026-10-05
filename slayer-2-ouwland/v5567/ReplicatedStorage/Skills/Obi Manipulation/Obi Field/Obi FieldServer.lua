local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObiFieldServer = {
	Id = {}
}
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local Config = require(script.Parent.Config)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local magnitude = Vector3.new(Config.FIELD_HITBOX_SIZE.X, 0, Config.FIELD_HITBOX_SIZE.Z).Magnitude

function ObiFieldServer.Hold(player)
	local v2 = ObiFieldServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local v3, v4 = ManuelCancel.new(player, Config.STARTUP_DUR)
		v3:Connect(function()
			if player and player.Parent == game.Players then
				ObiFieldServer.Id[player.UserId] = 0
			end

			EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "Cancel")
			v4()
		end)
		EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "Start")
		task.wait(Config.STARTUP_DUR)

		if v2 ~= ObiFieldServer.Id[player.UserId] then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local vector = Vector3.new(cFrame.Position.X, 0, cFrame.Position.Z)

		local function fn(instance, p, p2, state)
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart
			humanoid:FindFirstChild("Animator")

			if not state.HandledRibbon then
				state.HandledRibbon = true
				local ribbon = state.Ribbon
				DebrisModule:AddItem(ribbon, 1.25)

				if state.Face then
					DebrisModule:AddItem(state.Face, 0.01)
				end

				pcall(function()
					for _, v5 in pairs(ribbon.AnimationController.Animator:GetPlayingAnimationTracks()) do
						v5:Stop()
					end

					ribbon:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(script.TrapHit):Play()
				end)
				EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "TrapHit", ribbon)
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.TRAP_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.AddStun(script, character, p, Config.TRAP_STUN)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.TRAP_DAMAGE,
					Skill = script.Parent.Name
				})
				local v5 = ((state.Center.Position - rootPart.Position).Unit * -1 + Vector3.new(
					0,
					Config.TRAP_KNOCKUP,
					0
				)) * Config.TRAP_KNOCKBACK
				Combat_Util.Knockback(script, character, rootPart, v5, 0.2)
				Combat_Util.RagDoll(script, character, p, Config.TRAP_RAGDOLL)
			end
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		local count = 0

		local function fn2(victim, values, state)
			local humanoid = victim:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart
			humanoid:FindFirstChild("Animator")

			if state == nil then
				return
			end

			count += 1
			local v5 = rootPart.CFrame * CFrame.new(0, -(rootPart.Size.Y / 2 + humanoid.HipHeight), 0)
			local raycastResult = workspace:Raycast(rootPart.Position, rootPart.CFrame.YVector * -8, raycastParams)

			if raycastResult then
				v5 = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			end

			local clone = script.TrapRig:Clone()
			clone.Name = string.format("ObiField_%s_Trap_%i", character.Name, count)
			clone:PivotTo(v5 * CFrame.new(-0.12890625, 1.5190974533557893, -2.9268798828125) * CFrame.fromEulerAnglesYXZ(
				-2.2737367544323206e-13,
				-1.4210854715202004e-14,
				3.1415927410125732
			))
			clone.Parent = workspace.Debree
			task.delay(0.01, function()
				EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "TrapSpawn", clone)
			end)
			local extraArgs = {
				Center = v5,
				Ribbon = clone
			}
			local magnitude2 = (vector - Vector3.new(v5.Position.X, 0, v5.Position.Z)).Magnitude
			local v7 = Config.TRAP_MINIMUM_EXPIRY_DELAY + (Config.TRAP_MAXIMUM_EXPIRY_DELAY - Config.TRAP_MINIMUM_EXPIRY_DELAY) * (magnitude2 / magnitude)

			if state == true then
				Combat_Util.Add_Strict_Stun(script, character, values, v7 + 0.25)
				Utility.Add_No_GP(script, character, values, v7 + 0.25)
			end

			task.spawn(function()
				clone:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(script.TrapStart):Play()
				task.wait(1)

				if extraArgs.HandledRibbon then
					return
				end

				local track = clone:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(script.TrapLoop)
				track:Play()
				DebrisModule:AddItem(track, v7)
			end)
			DebrisModule:AddItem(clone, v7 + 2)
			task.delay(v7, function()
				if character == nil then
					return
				end

				Utility.CreateHitbox({
					caster = character,
					hitboxSize = Config.TRAP_HITBOX_SIZE,
					hitboxCFrame = v5,
					hitPriorityHandler = {
						callback = v.Both,
						data = {
							pv = getvaluesfolder,
							name = "Choosing_1"
						}
					},
					checker = Checker,
					extraArgs = extraArgs,
					hitDetected = fn
				})

				if not extraArgs.HandledRibbon then
					EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "TrapMiss", clone)
				end
			end)
		end

		task.spawn(function()
			while v2 == ObiFieldServer.Id[player.UserId] do
				local modelInRegion = Utility.GetModelInRegion(cFrame, Config.FIELD_HITBOX_SIZE, nil, nil)
				local v5 = {}

				for _, victim in pairs(modelInRegion) do
					if v2 ~= ObiFieldServer.Id[player.UserId] then
						break
					end

					if victim == character then
						continue
					end

					local humanoid = victim:FindFirstChild("Humanoid")
					local rootPart

					if humanoid ~= nil then
						rootPart = humanoid.RootPart or nil
					end

					if not (humanoid and rootPart) then
						continue
					end

					local getvaluesfolder2 = Utility.getvaluesfolder(victim)
					local check_victim = Checker.check_victim(script, character, victim)

					if check_victim == nil then
						continue
					end

					local child = getvaluesfolder2:FindFirstChild(Config.FIELD_SLOW_VALUE)

					if child ~= nil then
						child:Destroy()
					end

					local v7 = Utility.AddValue(getvaluesfolder2, Config.FIELD_SLOW_VALUE, Config.FIELD_SLOW_DURATION)
					v7:AddTag(StatTypes.ValueStatTag)
					v7:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.FIELD_SLOW_FACTOR)

					if v.Both(getvaluesfolder2, {
						pv = getvaluesfolder,
						name = "Choosing_1"
					}) ~= true then
						table.insert(v5, {
							Victim = victim,
							Values = getvaluesfolder2,
							State = check_victim,
							Distance = (rootPart.Position - cFrame.Position).Magnitude
						})
					end
				end

				table.sort(v5, function(a, b)
					return a.Distance < b.Distance
				end)

				for i = 1, Config.TRAP_LIMIT_PER_HITBOX do
					local v6 = v5[i]

					if v6 == nil then
						break
					else
						fn2(v6.Victim, v6.Values, v6.State)
					end
				end

				task.wait(Config.SPAWN_TRAPS_DELAY)
			end
		end)
	end
end

function ObiFieldServer.UnHold(p, p2, p3)
	local _ = ObiFieldServer.Id[p.UserId]
	ObiFieldServer.Cancel(p, p2, p3)
end

function ObiFieldServer.Cancel(player, _, _)
	if player ~= nil and player.Character then
		local character = player.Character
		EffectsEvent.ToAllInRange(character, "ObiField_effs", character, "Cancel")
	end
end

return ObiFieldServer