local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local DemonDemon_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.DemonDemon_Data)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local DemonDemonClient = {}

function DemonDemonClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Demon_KL") then
		return
	end

	local zRequire = DemonDemon_Data.ZRequire

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
	local demon_KL = character:FindFirstChild("Demon_KL")
	local v2 = nil
	local v3 = nil
	local v4 = nil
	task.spawn(function()
		if demon_KL then
			if demon_KL then
				v3 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://71230890241757"
				})
				task.delay(0.33, function()
					if not v4 then
						v2 = _G.PU.PlayOneShotAnim({
							Animator = humanoid,
							Animation = "rbxassetid://132720998686873"
						})
					end
				end)
			end
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://132145017489004"
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

		if v2 then
			v2:Stop()
		end

		if v3 then
			v3:Stop()
		end

		if demon_KL then
			if demon_KL then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://120813289452503"
				})
			end
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://122257400678572"
			})
			local v5 = Scheduler.new(0.6)
			v5:Ignore()
			v5:OnStep(function()
				if not character:FindFirstChild("ChargeFolder") then
					v5:Destroy()
				end

				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end)
			v5:Execute()
		end

		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_Z", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_Z", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	task.delay(0.25, function()
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

function DemonDemonClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Demon_KL") then
		return
	end

	local xRequire = DemonDemon_Data.XRequire

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
	task.spawn(function()
		local v2 = nil
		local v3 = nil
		local v4 = nil

		if character:FindFirstChild("Demon_KL") then
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://98380656575875"
			})
			task.delay(0.33, function()
				if not v4 then
					v2 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://106542792413260"
					})
				end
			end)
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://73121661933883"
			})
		end

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v4 = true

		if v2 then
			v2:Stop()
		end

		if v3 then
			v3:Stop()
		end

		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_X", v5)
	end)
	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_X", v2)
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

function DemonDemonClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Demon_KL") then
		return
	end

	local cRequire = DemonDemon_Data.CRequire

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
	local demon_KL = character:FindFirstChild("Demon_KL")

	if demon_KL then
		if demon_KL then
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://122122878514021"
			})
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://125388974360731"
			})
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://105357338976246"
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
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if v2 then
			v2:Stop()
		end

		if v3 then
			v3:Stop()
		end

		if demon_KL then
			if demon_KL then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://134663222186478"
				})
			end
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://104426261698135"
			})
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_C", v4)
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

function DemonDemonClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Demon_KL") then
		return
	end

	local vRequire = DemonDemon_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	character:FindFirstChild("Demon_KL")
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
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_V", v2)
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

function DemonDemonClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Demon_KL") then
		return
	end

	local eRequire = DemonDemon_Data.ERequire

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
	local demon_KL = character:FindFirstChild("Demon_KL")

	if demon_KL then
		if demon_KL then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(0, 1e999, 0)
			bodyGyro.P = 20000
			bodyGyro.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			local v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://124915108218802"
			})
			local v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://120960558265663"
			})
			task.spawn(function()
				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

					if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				if v3 then
					v3:Stop()
				end

				if v2 then
					v2:Stop()
				end

				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://105607582763048"
				})
				local v4 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_E", v4)
			end)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_E", v4)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			task.delay(0.25, function()
				bodyVelocity:Destroy()

				if bodyGyro and bodyGyro.Parent then
					bodyGyro:Destroy()
				end
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://108352338511859"
		})
		task.spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local v3 = 50
			math.clamp(humanoid.Health / humanoid.MaxHealth * v3, 100, 200)
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 60,
				Color = Color3.fromRGB(255, 85, 0)
			})

			while task.wait() do
				v3 = v3 >= 200 and 200 or v3 + 4
				local v4 = math.clamp(humanoid.Health / humanoid.MaxHealth * v3, 100, 200)
				local v5 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -15, 0),
					raycastParams
				)
				local v6 = humanoidRootPart.Position + createVector(0, -15, 0)

				if raycastResult and v5.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + 5, 0)
					v5 *= createVector(1, 0, 1)
				elseif v6.Y < -3.35 and v5.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = createVector(0, 5, 0)
					v5 *= createVector(1, 0, 1)
				else
					bodyVelocity.MaxForce = Vector3.new(
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.Z
					)
					bodyPosition.MaxForce = createVector(0, 0, 0)
				end

				bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v5).LookVector * v4
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v5)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 60 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_E", v4)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_E", v3)
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

function DemonDemonClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DemonDemon_M1", v2)
end

function DemonDemonClient.Deactive(p)
	v[p] = nil
end

return DemonDemonClient