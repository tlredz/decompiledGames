local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local SnowSnow_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.SnowSnow_Data)
local SnowSnowClient = {}

function SnowSnowClient.Z()
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

	local zRequire = SnowSnow_Data.ZRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowZ1
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

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowZ2
		})

		if _G.CheckAwakeClient(localPlayer, "SnowZ") then
			bodyGyro.MaxTorque = createVector(50000, 25000, 25000)
			bodyGyro.P = 2000
			task.spawn(function()
				local lastTime2 = tick()

				repeat
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
					wait()
				until tick() - lastTime2 > 1 or humanoid.Health <= 0
			end)
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_Z", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
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
		_G.Cooldowns.DFZ = nil
	end)
end

function SnowSnowClient.X()
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

	local xRequire = SnowSnow_Data.XRequire

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

	if _G.CheckAwakeClient(localPlayer, "SnowX") then
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC1
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 10000, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 0)
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
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			task.spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 150, 50, 150)
				PeodizService.HeartbeatWait({
					Time = 3
				}, function()
					v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 150, 50, 150)
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
				end)
			end)
			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowX22
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_X", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_X", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity.Velocity = Vector3.new()
			bodyPosition:Destroy()
			_G.PU:Dust(bodyVelocity, 0.01)
			bodyGyro:Destroy()
		end)
	else
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC1
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

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_X", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_X", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFX = nil
	end)
end

function SnowSnowClient.C()
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

	local cRequire = SnowSnow_Data.CRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC1
	})
	local snowC2 = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC2

	if _G.CheckAwakeClient(localPlayer, "SnowC") then
		snowC2 = ReplicatedStorage.Chest.Animation.SnowSnow.SnowC22
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
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = snowC2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_C", v3)
	v2:Stop()
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
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
		_G.Cooldowns.DFC = nil
	end)
end

function SnowSnowClient.V()
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

	local vRequire = SnowSnow_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
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
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowV1
	})
	local snowV2 = ReplicatedStorage.Chest.Animation.SnowSnow.SnowV2

	if _G.CheckAwakeClient(localPlayer, "SnowV") then
		snowV2 = ReplicatedStorage.Chest.Animation.SnowSnow.SnowV22
		bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	end

	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = snowV2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_V", v3)
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

function SnowSnowClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Snow_Wing") then
		return
	end

	local eRequire = SnowSnow_Data.ERequire

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

	if _G.CheckAwakeClient(localPlayer, "SnowE") then
		if character:GetAttribute("SpeedLine") then
			character:SetAttribute("SpeedLine", nil)
		end

		if character:FindFirstChild("Snow_Wing") then
			_G.StopAnimationClient(humanoid, {
				SnowEV2 = true
			})
			_G.ClearBvDragon(humanoidRootPart)
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowEV2Start
			})
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SnowSnow.SnowEV2,
				Speed = 1.5
			})
		end

		_G.ClearBv(humanoidRootPart)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_E", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
	else
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
		humanoid.AutoRotate = false
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_E", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_E", v2)
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
	end

	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function SnowSnowClient.M1()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit or not character:FindFirstChild("Snow_Wing") then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Snow_Wing") or _G.Cooldowns.DFM1 then
		return
	end

	_G.Cooldowns.DFM1 = true
	v.M1 = true
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	mouse.TargetFilter = workspace.Effects
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SnowSnow_M1", v2)
	mouse.TargetFilter = nil
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(1.25)
		_G.Cooldowns.DFM1 = nil
	end)
end

function SnowSnowClient.Deactive(p)
	v[p] = nil
end

return SnowSnowClient