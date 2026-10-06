local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local GasGas_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.GasGas_Data)
local GasGasClient = {}

function GasGasClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Gas_Model") then
		return
	end

	local zRequire = GasGas_Data.ZRequire

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
	local gasZ1Air = ReplicatedStorage.Chest.Animation.GasGas.GasZ1Air
	local gasZ2Air = ReplicatedStorage.Chest.Animation.GasGas.GasZ2Air
	local bodyVelocity, bodyGyro, speed

	if character:FindFirstChild("Gas_Model") then
		bodyVelocity = nil
		bodyGyro = nil
		speed = 1
	else
		_G.ClearBv(humanoidRootPart)
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		gasZ1Air = ReplicatedStorage.Chest.Animation.GasGas.GasZ1
		gasZ2Air = ReplicatedStorage.Chest.Animation.GasGas.GasZ2
		speed = 1.25
	end

	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = gasZ1Air
	})
	local lastTime = tick()
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity.Velocity = Vector3.new()
			end

			if bodyGyro and bodyGyro.Parent then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = gasZ2Air,
			Speed = speed
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_Z", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_Z", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		task.wait(0.2)

		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end

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

function GasGasClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Gas_Model") then
		return
	end

	local xRequire = GasGas_Data.XRequire

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
	local bodyVelocity, bodyGyro

	if character:FindFirstChild("Gas_Model") then
		bodyVelocity = nil
		bodyGyro = nil
	else
		_G.ClearBv(humanoidRootPart)
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
	end

	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GasGas.GasX1
	})
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity.Velocity = Vector3.new()
			end

			if bodyGyro and bodyGyro.Parent then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GasGas.GasX2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)

		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end

		if bodyGyro and bodyGyro.Parent then
			bodyGyro:Destroy()
		end
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFX = nil
	end)
end

function GasGasClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Gas_Model") then
		return
	end

	local cRequire = GasGas_Data.CRequire

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
	local bodyVelocity, bodyGyro

	if character:FindFirstChild("Gas_Model") then
		bodyVelocity = nil
		bodyGyro = nil
	else
		_G.ClearBv(humanoidRootPart)
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
	end

	local lastTime = tick()
	local gasC1 = ReplicatedStorage.Chest.Animation.GasGas.GasC1
	local gasC2 = ReplicatedStorage.Chest.Animation.GasGas.GasC2

	if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
		gasC1 = ReplicatedStorage.Chest.Animation.GasGas.GasC1Air
		gasC2 = ReplicatedStorage.Chest.Animation.GasGas.GasC2Air
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = gasC1
	})
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity.Velocity = Vector3.new()
			end

			if bodyGyro and bodyGyro.Parent then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = gasC2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_C", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)

		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end

		if bodyGyro and bodyGyro.Parent then
			bodyGyro:Destroy()
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

function GasGasClient.V()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Gas_Model") then
		return
	end

	local vRequire = GasGas_Data.VRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GasGas.GasV1
	})
	local bodyVelocity, bodyGyro

	if character:FindFirstChild("Gas_Model") then
		bodyVelocity = nil
		bodyGyro = nil
	else
		_G.ClearBv(humanoidRootPart)
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
	end

	local lastTime = tick()
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity.Velocity = Vector3.new()
			end

			if bodyGyro and bodyGyro.Parent then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GasGas.GasV2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_V", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)

		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end

		if bodyGyro and bodyGyro.Parent then
			bodyGyro:Destroy()
		end
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFV = nil
	end)
end

function GasGasClient.E()
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

	local eRequire = GasGas_Data.ERequire

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
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() and v.E and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) do

		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 10,
			Color = Color3.fromRGB(170, 0, 255)
		})
		task.delay(10, function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			v.Z = nil
			v.X = nil
			v.C = nil
			v.V = nil
			task.delay(1, function()
				_G.StopAnimationClient(humanoid, {
					TelekinesisIdle = true,
					TelekinesisFly = true
				})
			end)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_E", v2)
	end)
	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GasGas_E", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function GasGasClient.Deactive(p)
	v[p] = nil
end

return GasGasClient