local createVector = vector.create
local OpOpClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}

function FindNearTarget(p, p2, p3, p4)
	local magnitude = 25
	local v2 = nil

	for _, descendant in pairs(workspace:GetDescendants()) do
		local humanoid = descendant:FindFirstChild("Humanoid")

		if not humanoid then
			continue
		end

		local rootPart = humanoid.RootPart

		if not (rootPart and humanoid ~= p2) then
			continue
		end

		local magnitude2 = (rootPart.Position - p3.Position).Magnitude

		if p4 / 2 < magnitude2 or humanoid.Health <= 0 then
			continue
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(descendant)

		if playerFromCharacter and _G.CheckAllyClient(localPlayer, playerFromCharacter) or not ((rootPart.Position - p).Magnitude <= magnitude) then
			continue
		end

		magnitude = (rootPart.Position - p).Magnitude
		v2 = descendant
	end

	return v2
end

function GetRoomSize(p)
	local player = p.Player
	local stats_Type = p.Stats_Type
	local X = math.clamp(160 + stats_Type.Value / 7.5, 160, 500)
	local v2 = math.clamp(150 + stats_Type.Value / 7.5, 150, 500)
	local child = workspace:FindFirstChild("OpeRoom" .. player.Name)

	if _G.CheckAwakeClient(player, "OpZ") and child then
		X = child.Size.X
	end

	return v2, X
end

local OpOp_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.OpOp_Data)

function OpOpClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local zRequire = OpOp_Data.ZRequire

	if localPlayer.PlayerStats.DF.Value < zRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "Z", zRequire })
		return
	end

	if _G.Cooldowns.DFZ then
		return
	end

	_G.Cooldowns.DFZ = true
	v.Z = true
	local cooldownClient = _G.GetCooldownClient("DFZ")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = nil
	local room = ReplicatedStorage.Chest.Animation.OpOp.Room
	local cEnd

	if _G.CheckAwakeClient(localPlayer, "OpZ") and not workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		room = ReplicatedStorage.Chest.Animation.OpOp.Roomv2
		cEnd = ReplicatedStorage.Chest.Animation.OpOp["C End"]
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 2,
			Color = Color3.fromRGB(0, 255, 255)
		})
	else
		cEnd = nil
	end

	local v3 = nil
	local bodyVelocity, bodyGyro

	if workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		v3 = true
		bodyVelocity = nil
		bodyGyro = nil
	else
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 0)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
	end

	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v4 = math.clamp((humanoidRootPart.CFrame.p - _G.MouseHit.p).magnitude, 0, 250)
	local _ = CFrame.new(humanoidRootPart.CFrame.p, _G.MouseHit.p) * CFrame.new(0, 0, -v4)
	task.spawn(function()
		if not v3 then
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = room
			})
		end

		PeodizService.HeartbeatWait({
			Time = 10
		}, function()
			if workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
				return true
			end

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				return true
			end

			if bodyVelocity then
				bodyVelocity.Velocity = Vector3.new()
			end

			if bodyGyro then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end
		end)
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})

		if workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Type = "Fly2",
				Mode = "Stop"
			})
		else
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Type = "Fly2",
				Mode = "Start",
				Time = 60,
				Color = Color3.fromRGB(0, 85, 255)
			})
		end

		if v2 then
			v2:Stop()
		end

		if cEnd then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = cEnd
			})
		end

		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_Z", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		if bodyGyro then
			bodyGyro:Destroy()
		end
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFZ = nil
	end)
end

function OpOpClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local xRequire = OpOp_Data.XRequire

	if localPlayer.PlayerStats.DF.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "X", xRequire })
		return
	end

	if not workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		return
	end

	local child = workspace:FindFirstChild("OpeRoom" .. localPlayer.Name)
	local _, v2 = GetRoomSize({
		Player = localPlayer,
		Stats_Type = localPlayer.PlayerStats.DF
	})
	local v3, v4, lastTime, bodyVelocity, bodyGyro, v5, xStart, xEnd, v6, v7

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpX") then
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if v2 / 1.25 < magnitude or _G.Cooldowns.DFX then
			return
		end

		_G.Cooldowns.DFX = true
		v.X = true
		v3 = _G.GetCooldownClient("DFX")
		v4 = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		lastTime = tick()
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 0)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		v5 = nil

		if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpX") then
			xStart = ReplicatedStorage.Chest.Animation.OpOp.XStart
			xEnd = ReplicatedStorage.Chest.Animation.OpOp.XEnd
			v6 = 0.35
		else
			v6 = 0.5
			xEnd = nil
		end

		if xStart then
			v5 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = xStart
			})
		end

		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			if tick() - lastTime < v6 then
				task.wait(v6)
			end

			if v5 then
				v5:Stop()
			end

			if xEnd then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = xEnd
				})
			end

			local v8 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_X", v8)
		end)
		v7 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_X", v7)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", v3)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
		task.spawn(function()
			v4:Delete()
		end)
		task.spawn(function()
			wait(v3)
			_G.Cooldowns.DFX = nil
		end)
	else
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if not (v2 / 2 < magnitude) then
			local magnitude2 = (_G.MouseHit.p - child.Position).Magnitude

			if not (v2 / 2 < magnitude2) then
				if _G.Cooldowns.DFX then
					return
				end

				_G.Cooldowns.DFX = true
				v.X = true
				v3 = _G.GetCooldownClient("DFX")
				v4 = _G.InstanceDoingClient({
					Parent = localPlayer
				})
				_G.ClearBv(humanoidRootPart)
				lastTime = tick()
				bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new()
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Parent = humanoidRootPart
				bodyGyro = Instance.new("BodyGyro")
				bodyGyro.MaxTorque = createVector(0, 1e999, 0)
				bodyGyro.P = 20000
				bodyGyro.Parent = humanoidRootPart
				mouse.TargetFilter = workspace.Effects
				humanoid.AutoRotate = false
				v5 = nil

				if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpX") then
					xStart = ReplicatedStorage.Chest.Animation.OpOp.XStart
					xEnd = ReplicatedStorage.Chest.Animation.OpOp.XEnd
					v6 = 0.35
				else
					v6 = 0.5
					xEnd = nil
				end

				if xStart then
					v5 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = xStart
					})
				end

				task.spawn(function()
					while task.wait() do
						bodyVelocity.Velocity = Vector3.new()
						bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

						if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
							break
						end
					end

					if tick() - lastTime < v6 then
						task.wait(v6)
					end

					if v5 then
						v5:Stop()
					end

					if xEnd then
						_G.PU.PlayOneShotAnim({
							Animator = humanoid,
							Animation = xEnd
						})
					end

					local v8 = {
						MouseHit = _G.MouseHit,
						Type = "Up"
					}
					ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_X", v8)
				end)
				v7 = {
					MouseHit = _G.MouseHit,
					Type = "Down"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_X", v7)
				ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", v3)
				mouse.TargetFilter = nil
				humanoid.AutoRotate = true
				task.spawn(function()
					bodyVelocity:Destroy()
					bodyGyro:Destroy()
				end)
				task.spawn(function()
					v4:Delete()
				end)
				task.spawn(function()
					wait(v3)
					_G.Cooldowns.DFX = nil
				end)
			end
		end
	end
end

function OpOpClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local cRequire = OpOp_Data.CRequire

	if localPlayer.PlayerStats.DF.Value < cRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "C", cRequire })
		return
	end

	if not workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		return
	end

	local child = workspace:FindFirstChild("OpeRoom" .. localPlayer.Name)
	local _, v2 = GetRoomSize({
		Player = localPlayer,
		Stats_Type = localPlayer.PlayerStats.DF
	})
	local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

	if v2 / 2 < magnitude or _G.Cooldowns.DFC then
		return
	end

	_G.Cooldowns.DFC = true
	v.C = true
	local cooldownClient = _G.GetCooldownClient("DFC")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local xCharge = ReplicatedStorage.Chest.Animation.OpOp.XCharge
	local counterShock = ReplicatedStorage.Chest.Animation.OpOp.CounterShock

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpC") then
		xCharge = ReplicatedStorage.Chest.Animation.OpOp["C Start"]
		counterShock = ReplicatedStorage.Chest.Animation.OpOp["C End"]
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 0.5,
			Color = Color3.fromRGB(255, 255, 0)
		})
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = xCharge
	})
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = counterShock
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_C", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFC = nil
	end)
end

function OpOpClient.V()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local vRequire = OpOp_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if not workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		return
	end

	local child = workspace:FindFirstChild("OpeRoom" .. localPlayer.Name)
	local _, v2 = GetRoomSize({
		Player = localPlayer,
		Stats_Type = localPlayer.PlayerStats.DF
	})

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpV") then
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if v2 / 1.25 < magnitude then
			return
		end
	else
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if v2 / 2 < magnitude then
			return
		end
	end

	if _G.Cooldowns.DFV then
		return
	end

	_G.Cooldowns.DFV = true
	v.V = true
	local cooldownClient = _G.GetCooldownClient("DFV")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local xCharge = ReplicatedStorage.Chest.Animation.OpOp.XCharge
	local counterShock = ReplicatedStorage.Chest.Animation.OpOp.CounterShock

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpV") then
		xCharge = ReplicatedStorage.Chest.Animation.OpOp["V Start"]
		counterShock = ReplicatedStorage.Chest.Animation.OpOp["V End"]
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = xCharge
	})
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = counterShock
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_V", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_V", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFV = nil
	end)
end

function OpOpClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local eRequire = OpOp_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

	local child = workspace:FindFirstChild("OpeRoom" .. localPlayer.Name)

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpE") and not child then
		if _G.Cooldowns.DFE then
			return
		end

		_G.Cooldowns.DFE = true
		v.E = true
		local cooldownClient = _G.GetCooldownClient("DFE")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.OpOp.E2End
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 1 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFE = nil
		end)
	else
		if not child then
			return
		end

		local _, v2 = GetRoomSize({
			Player = localPlayer,
			Stats_Type = localPlayer.PlayerStats.DF
		})
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if v2 / 2 < magnitude or _G.Cooldowns.DFE then
			return
		end

		_G.Cooldowns.DFE = true
		v.E = true
		local cooldownClient = _G.GetCooldownClient("DFE")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()

		if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpE") then
			local v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.OpOp.E1Start
			})
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
			bodyGyro.P = 20000
			bodyGyro.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			humanoid.AutoRotate = false

			local function FindNearestTarget(_)
				local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -25)).Position
				local cFrame = workspace.CurrentCamera.CFrame
				local v4 = 0
				local v5 = nil

				for _, descendant in pairs(workspace:GetDescendants()) do
					local humanoid2 = descendant:FindFirstChild("Humanoid")

					if not humanoid2 then
						continue
					end

					local rootPart = humanoid2.RootPart

					if not (rootPart and descendant ~= character) then
						continue
					end

					local magnitude2 = (rootPart.Position - child.Position).Magnitude

					if v2 / 2 < magnitude2 or not ((rootPart.Position - position).Magnitude <= 2500) then
						continue
					end

					local unit = (rootPart.Position - humanoidRootPart.Position).Unit
					local dot = cFrame.LookVector:Dot(unit)

					if not (dot >= 0.8 and v4 < dot) then
						continue
					end

					v5 = descendant
					v4 = dot
				end

				return v5
			end

			task.spawn(function()
				local highlight = nil

				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
					local v4 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 1, 500)
					local v5 = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v4)
					local v6 = FindNearTarget(v5.Position, humanoid, child, v2)

					if v6 then
						if not highlight then
							highlight = Instance.new("Highlight")
							highlight.FillTransparency = 0.15
						end

						highlight.Adornee = v6
						highlight.Parent = v6
					elseif highlight then
						highlight:Destroy()
						highlight = nil
					end

					if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 15 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				if highlight then
					highlight:Destroy()
				end

				v3:Stop()
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = ReplicatedStorage.Chest.Animation.OpOp.E1End
				})
				local v4 = {
					MouseHit = _G.MouseHit,
					CamCF = workspace.CurrentCamera.CFrame,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v4)
			end)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v4)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
			task.spawn(function()
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
		else
			local v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.OpOp.CS1
			})
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(0, 1e999, 0)
			bodyGyro.P = 20000
			bodyGyro.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			humanoid.AutoRotate = false
			task.spawn(function()
				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

					if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				v3:Stop()
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = ReplicatedStorage.Chest.Animation.OpOp.CS2
				})
				local v4 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v4)
			end)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_E", v4)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
			task.spawn(function()
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
		end

		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFE = nil
		end)
	end
end

function OpOpClient.B()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local bRequire = OpOp_Data.BRequire

	if localPlayer.PlayerStats.DF.Value < bRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "B", bRequire })
		return
	end

	local child = workspace:FindFirstChild("OpeRoom" .. localPlayer.Name)

	if not child then
		return
	end

	local _, v2 = GetRoomSize({
		Player = localPlayer,
		Stats_Type = localPlayer.PlayerStats.DF
	})
	local v3, v4, v5

	if _G.CheckAwakeClient(localPlayer, "OpZ") and _G.CheckAwakeClient(localPlayer, "OpB") then
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if v2 * 2 < magnitude or _G.Cooldowns.DFB then
			return
		end

		_G.Cooldowns.DFB = true
		v.B = true
		v3 = _G.GetCooldownClient("DFB")
		v4 = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		v5 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_B", v5)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", v3)
		task.spawn(function()
			v4:Delete()
		end)
		task.spawn(function()
			wait(v3)
			_G.Cooldowns.DFB = nil
		end)
	else
		local magnitude = (humanoidRootPart.Position - child.Position).Magnitude

		if not (v2 / 2 < magnitude) then
			local magnitude2 = (_G.MouseHit.p - child.Position).Magnitude

			if not (v2 / 2 < magnitude2) then
				if _G.Cooldowns.DFB then
					return
				end

				_G.Cooldowns.DFB = true
				v.B = true
				v3 = _G.GetCooldownClient("DFB")
				v4 = _G.InstanceDoingClient({
					Parent = localPlayer
				})
				v5 = {
					MouseHit = _G.MouseHit
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_OpOp_B", v5)
				ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", v3)
				task.spawn(function()
					v4:Delete()
				end)
				task.spawn(function()
					wait(v3)
					_G.Cooldowns.DFB = nil
				end)
			end
		end
	end
end

function OpOpClient.Deactive(p)
	v[p] = nil
end

return OpOpClient