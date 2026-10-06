local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local BrachioBrachio_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.BrachioBrachio_Data)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local BrachioBrachioClient = {}

function BrachioBrachioClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Brachiosaurus") then
		return
	end

	local zRequire = BrachioBrachio_Data.ZRequire

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
	local brachiosaurus = character:FindFirstChild("Brachiosaurus")
	local v2 = nil
	task.spawn(function()
		if brachiosaurus then
			if brachiosaurus then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://126357016532184"
				})
				v2 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://130587708856140"
				})
			end
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.AlloAllo.Z1
			})
		end

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if bodyGyro and bodyGyro.Parent then
			bodyGyro:Destroy()
		end

		if v2 then
			v2:Stop()

			if brachiosaurus then
				if brachiosaurus then
					_G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://70804222970105"
					})
				end
			else
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = ReplicatedStorage.Chest.Animation.AlloAllo.Z2
				})
			end
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_Z", v3)
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

function BrachioBrachioClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Brachiosaurus") then
		return
	end

	local xRequire = BrachioBrachio_Data.XRequire

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
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	local v2 = nil
	task.spawn(function()
		local brachiosaurus = character:FindFirstChild("Brachiosaurus")

		if brachiosaurus then
			if brachiosaurus then
				local v3 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://138443703740792"
				})

				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

					if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				if v3 then
					v3:Stop()
				end
			end
		else
			local v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://129903775672370"
			})

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2 = true

			if v3 then
				v3:Stop()
			end

			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://125120627868186"
			})
			local v4 = Scheduler.new(0.4)
			v4:OnStep(function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity.Velocity = Vector3.new()
				end

				if bodyGyro and bodyGyro.Parent then
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
				end
			end)
			v4:Ignore()
			v4:Execute()
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_X", v3)
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

function BrachioBrachioClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Brachiosaurus") then
		return
	end

	local cRequire = BrachioBrachio_Data.CRequire

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
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(300000, 300000, 300000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	local bodyPosition = nil
	mouse.TargetFilter = workspace.Effects
	local brachiosaurus = character:FindFirstChild("Brachiosaurus")
	local v2 = nil
	task.spawn(function()
		if brachiosaurus then
			if brachiosaurus then
				bodyPosition = Instance.new("BodyPosition")
				bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
				bodyPosition.MaxForce = createVector(0, 0, 0)
				bodyPosition.P = 20000
				bodyPosition.Parent = humanoidRootPart
			end
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://138783823033057"
			})
		end

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if v2 then
			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://115742311972611"
			})
		end

		if brachiosaurus then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://115568775305447"
			})
			task.spawn(function()
				local total = 0
				Scheduler.new(1.3):OnStep(function()
					if bodyVelocity and bodyVelocity.Parent and bodyGyro and bodyGyro.Parent and bodyPosition and bodyPosition.Parent then
						total += 10
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * total, 50, 300)
						local v4 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -30, 0),
							raycastParams
						)
						local v5 = humanoidRootPart.Position + createVector(0, -30, 0)

						if raycastResult and v4.Y < 0 then
							local position = raycastResult.Position
							bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
							bodyPosition.MaxForce = createVector(0, 10000000, 0)
							bodyPosition.Position = Vector3.new(0, position.Y + 20, 0)
							v4 *= createVector(1, 0, 1)
						elseif v5.Y < -3.35 and v4.Y < 0 then
							bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
							bodyPosition.MaxForce = createVector(0, 10000000, 0)
							bodyPosition.Position = createVector(0, 20, 0)
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
					end
				end):Execute()

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
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_C", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
	task.spawn(function()
		if not brachiosaurus then
			task.wait(0.25)
			bodyVelocity:Destroy()

			if bodyGyro and bodyGyro.Parent then
				bodyGyro:Destroy()
			end
		end
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFC = nil
	end)
end

function BrachioBrachioClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Brachiosaurus") then
		return
	end

	local vRequire = BrachioBrachio_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	character:FindFirstChild("Brachiosaurus")
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

	if not character:FindFirstChild("Brachiosaurus") then
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://92788885652031"
		})
	end

	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_V", v2)
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

function BrachioBrachioClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Brachiosaurus") then
		return
	end

	local eRequire = BrachioBrachio_Data.ERequire

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
	local brachiosaurus = character:FindFirstChild("Brachiosaurus")
	local lastTime = tick()
	local v2 = nil
	local v3 = 175
	local v4 = 4

	if brachiosaurus then
		if brachiosaurus then
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://121748388107073",
				Speed = 3
			})
			v3 = 240
			v4 = 30
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://124717736790447"
		})
	end

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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 120,
			Color = Color3.fromRGB(85, 170, 255)
		})
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local v5 = 90
		math.clamp(humanoid.Health / humanoid.MaxHealth * v5, v3 / 2, v3)

		while task.wait() do
			if v3 <= v5 then
				v5 = v3
			else
				v5 += 8
			end

			local v6 = math.clamp(humanoid.Health / humanoid.MaxHealth * v5, v3 / 2, v3)
			local v7 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -35, 0), raycastParams)
			local v8 = humanoidRootPart.Position + createVector(0, -35, 0)

			if raycastResult and v7.Y < 0 then
				local position = raycastResult.Position
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, position.Y + v4, 0)
				v7 *= createVector(1, 0, 1)
			elseif v8.Y < -3.35 and v7.Y < 0 then
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, v4, 0)
				v7 *= createVector(1, 0, 1)
			else
				bodyVelocity.MaxForce = Vector3.new(
					bodyVelocity.MaxForce.X,
					bodyVelocity.MaxForce.X,
					bodyVelocity.MaxForce.Z
				)
				bodyPosition.MaxForce = createVector(0, 0, 0)
			end

			bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v7).LookVector * v6
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v7)

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 120 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})

		if v2 then
			v2:Stop()
		end

		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_E", v6)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_E", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		bodyVelocity.Velocity = Vector3.new()
		bodyPosition:Destroy()
		_G.PU:Dust(bodyVelocity, 0.01)
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function BrachioBrachioClient.M1()
	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) then
		return
	end

	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BrachioBrachio_M1", v2)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
end

function BrachioBrachioClient.Deactive(p)
	v[p] = nil
end

return BrachioBrachioClient