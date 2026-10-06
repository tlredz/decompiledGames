local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local TreeTree_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.TreeTree_Data)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local TreeTreeClient = {}

function TreeTreeClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Tree_KL") then
		return
	end

	local zRequire = TreeTree_Data.ZRequire

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
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	local tree_KL = character:FindFirstChild("Tree_KL")
	local v2 = nil
	local v3 = nil
	local v4 = nil
	task.spawn(function()
		if tree_KL then
			if tree_KL then
				v3 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://103799114543059"
				})
				task.delay(0.4, function()
					if not v4 then
						v2 = _G.PU.PlayOneShotAnim({
							Animator = humanoid,
							Animation = "rbxassetid://126354585165382"
						})
					end
				end)
			end
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://139282061745529"
			})
		end

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v4 = true

		if bodyGyro and bodyGyro.Parent then
			bodyGyro:Destroy()
		end

		if v2 then
			v2:Stop()
		end

		if v3 then
			v3:Stop()
		end

		if tree_KL then
			if tree_KL then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://115532999882858"
				})
			end
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://112897298295770"
			})
		end

		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_Z", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_Z", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	task.spawn(function()
		wait(0.25)
		bodyVelocity:Destroy()

		if bodyGyro and bodyGyro.Parent then
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

function TreeTreeClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Tree_KL") then
		return
	end

	local xRequire = TreeTree_Data.XRequire

	if localPlayer.PlayerStats.DF.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "X", xRequire })
		return
	end

	if _G.Cooldowns.DFX then
		return
	end

	_G.Cooldowns.DFX = true
	v.X = true
	local cooldownClient = _G.GetCooldownClient("DFX")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	local v2 = nil
	task.spawn(function()
		local tree_KL = character:FindFirstChild("Tree_KL")
		local v3 = nil
		local v4 = nil
		local v5 = 10

		if tree_KL then
			v4 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://96109019922991",
				Speed = 1.5
			})
			task.delay(0.3, function()
				if not v2 then
					v3 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://90451962019119"
					})
				end
			end)
			v5 = 3
		else
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://128413195641371"
			})
		end

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			local v6 = _G.CheckStunClient(localPlayer)

			if tree_KL then
				v6 = false
			end

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or v5 < tick() - lastTime or v6 then
				break
			end
		end

		v2 = true

		if v3 then
			v3:Stop()
		end

		if v4 then
			v4:Stop()
		end

		if not (tree_KL or tree_KL) then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://86880181350806"
			})
			task.delay(0.4, function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local bodyPosition = Instance.new("BodyPosition")
				bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
				bodyPosition.MaxForce = createVector(0, 0, 0)
				bodyPosition.P = 20000
				bodyPosition.Parent = humanoidRootPart
				task.spawn(function()
					ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
						Mode = "Start",
						Time = 3,
						Color = Color3.fromRGB(170, 255, 0)
					})
					local total = 0
					local v6 = Scheduler.new(3)
					v6:OnStep(function()
						if not character:FindFirstChild("ChargeFolder") then
							v6:Destroy()
						elseif bodyVelocity and bodyVelocity.Parent and bodyGyro and bodyGyro.Parent and bodyPosition and bodyPosition.Parent then
							total += 10
							local raycastParams2 = RaycastParams.new()
							raycastParams2.FilterType = Enum.RaycastFilterType.Include
							raycastParams2.FilterDescendantsInstances = { workspace.Island }
							local v7 = math.clamp(humanoid.Health / humanoid.MaxHealth * total, 50, 120)
							local v8 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
							local raycastResult = workspace:Raycast(
								humanoidRootPart.Position,
								createVector(0, -15, 0),
								raycastParams2
							)
							local v9 = humanoidRootPart.Position + createVector(0, -15, 0)

							if raycastResult and v8.Y < 0 then
								local position = raycastResult.Position
								bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
								bodyPosition.MaxForce = createVector(0, 10000000, 0)
								bodyPosition.Position = Vector3.new(0, position.Y + 0, 0)
								v8 *= createVector(1, 0, 1)
							elseif v9.Y < -3.35 and v8.Y < 0 then
								bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
								bodyPosition.MaxForce = createVector(0, 10000000, 0)
								bodyPosition.Position = createVector(0, 0, 0)
								v8 *= createVector(1, 0, 1)
							else
								bodyVelocity.MaxForce = Vector3.new(
									bodyVelocity.MaxForce.X,
									bodyVelocity.MaxForce.X,
									bodyVelocity.MaxForce.Z
								)
								bodyPosition.MaxForce = createVector(0, 0, 0)
							end

							bodyVelocity.Velocity = CFrame.new(
								humanoidRootPart.Position,
								humanoidRootPart.Position + v8
							).LookVector * v7
							bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v8)
						end
					end)
					v6:Execute()
					ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
						Mode = "Stop"
					})

					if bodyPosition and bodyPosition.Parent then
						bodyPosition:Destroy()
					end

					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity.Velocity = Vector3.new()
						_G.PU:Dust(bodyVelocity, 0.25)
					end

					if bodyGyro and bodyGyro.Parent then
						_G.PU:Dust(bodyGyro, 0.25)
					end
				end)
			end)
			task.wait(0.25)
		end

		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_X", v6)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
	mouse.TargetFilter = nil
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
		_G.Cooldowns.DFX = nil
	end)
end

function TreeTreeClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Tree_KL") then
		return
	end

	local cRequire = TreeTree_Data.CRequire

	if localPlayer.PlayerStats.DF.Value < cRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "C", cRequire })
		return
	end

	if _G.Cooldowns.DFC then
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
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local tree_KL = character:FindFirstChild("Tree_KL")
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart

	if tree_KL then
		if tree_KL then
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://72862929486924"
			})
			task.delay(0.6, function()
				if not v4 then
					v2 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://111498143423370"
					})
				end
			end)
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://88965588576917"
		})
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	end

	mouse.TargetFilter = workspace.Effects
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v4 = true

		if v3 then
			v3:Stop()
		end

		if v2 then
			v2:Stop()
		end

		if tree_KL then
			if tree_KL then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://78101675567235"
				})
			end
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://90647147723329"
			})
		end

		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_C", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_C", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
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

function TreeTreeClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Tree_KL") then
		return
	end

	local vRequire = TreeTree_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.Cooldowns.DFV = true
	local cooldownClient = _G.GetCooldownClient("DFV")
	_G.ClearBv(humanoidRootPart)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)

	if raycastResult then
		bodyVelocity.MaxForce = createVector(1e999, 0, 1e999)
	end

	bodyVelocity.Parent = humanoidRootPart
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_V", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
	bodyVelocity:Destroy()
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFV = nil
	end)
end

function TreeTreeClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Tree_KL") then
		return
	end

	local eRequire = TreeTree_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

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
	local tree_KL = character:FindFirstChild("Tree_KL")

	if tree_KL then
		if tree_KL then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(0, 1e999, 0)
			bodyGyro.P = 20000
			bodyGyro.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			task.spawn(function()
				local v2 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://80072151671176",
					Speed = 1.5
				})
				local v3 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://101462655927640"
				})

				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
					local v4 = _G.CheckStunClient(localPlayer)

					if tree_KL then
						v4 = false
					end

					if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or v4 then
						break
					end
				end

				if v3 then
					v3:Stop()
				end

				if v2 then
					v2:Stop()
				end

				local v4 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_E", v4)
			end)
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_E", v2)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			task.spawn(function()
				wait(0.25)
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
		end
	else
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
		bodyPosition.MaxForce = createVector(0, 0, 0)
		bodyPosition.P = 20000
		bodyPosition.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local v2 = 50
			math.clamp(humanoid.Health / humanoid.MaxHealth * v2, 85, 170)
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 60,
				Color = Color3.fromRGB(170, 255, 127)
			})

			while task.wait() do
				v2 = v2 >= 170 and 170 or v2 + 4
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * v2, 85, 170)
				local v4 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -25, 0),
					raycastParams
				)
				local v5 = humanoidRootPart.Position + createVector(0, -25, 0)

				if raycastResult and v4.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
					v4 *= createVector(1, 0, 1)
				elseif v5.Y < -3.35 and v4.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = createVector(0, 14, 0)
					v4 *= createVector(1, 0, 1)
				else
					bodyVelocity.MaxForce = Vector3.new(
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.Z
					)
					bodyPosition.MaxForce = createVector(0, 0, 0)
				end

				bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4).LookVector * v3
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 60 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_E", v3)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_E", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity.Velocity = Vector3.new()
			bodyPosition:Destroy()
			_G.PU:Dust(bodyVelocity, 0.01)
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

function TreeTreeClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_TreeTree_M1", v2)
end

function TreeTreeClient.Deactive(p)
	v[p] = nil
end

return TreeTreeClient