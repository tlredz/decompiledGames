local createVector = vector.create
local SpiritSpiritClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
_G.CloudXUsing = false
_G.SunCUsing = false
local SpiritSpirit_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.SpiritSpirit_Data)

function SpiritSpiritClient.Z()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local zRequire = SpiritSpirit_Data.ZRequire

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
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_Z", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFZ = nil
	end)
end

function SpiritSpiritClient.X()
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

	local xRequire = SpiritSpirit_Data.XRequire

	if localPlayer.PlayerStats.DF.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "X", xRequire })
		return
	end

	if not workspace.Effects:FindFirstChild("CloudPet " .. localPlayer.Name) or _G.Cooldowns.DFX then
		return
	end

	_G.Cooldowns.DFX = true
	v.X = true
	local cooldownClient = _G.GetCooldownClient("DFX")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	_G.CloudXUsing = true
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritX1
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

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritX2,
			Speed = 2
		})
		task.spawn(function()
			local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 0, 50)
			local v4 = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v3)
			local position = (CFrame.new(v4.p) * CFrame.new(0, 150, -50)).Position
			local cframe = CFrame.new(humanoidRootPart.Position)
			local child = workspace.Effects:FindFirstChild("CloudPet " .. localPlayer.Name)

			repeat
				if child and child:FindFirstChild("RootPart") and child.RootPart:FindFirstChild("BodyPosition") then
					child.RootPart.BodyPosition.Position = position
					child.RootPart.BodyGyro.CFrame = cframe
				end

				wait()
			until not _G.CloudXUsing or humanoid.Health <= 0
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_X", v3)
	_G.CloudXUsing = false
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
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
		_G.Cooldowns.DFX = nil
	end)
end

function SpiritSpiritClient.C()
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

	local cRequire = SpiritSpirit_Data.CRequire

	if localPlayer.PlayerStats.DF.Value < cRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "C", cRequire })
		return
	end

	if not workspace.Effects:FindFirstChild("SunPet " .. localPlayer.Name) or _G.Cooldowns.DFC then
		return
	end

	_G.Cooldowns.DFC = true
	v.C = true
	local cooldownClient = _G.GetCooldownClient("DFC")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	_G.SunCUsing = true
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritC1
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

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritC2,
			Speed = 1.3
		})
		spawn(function()
			local child = workspace.Effects:FindFirstChild("SunPet " .. localPlayer.Name)

			if child:FindFirstChild("AnimationController") then
				_G.PU.PlayOneShotAnim({
					Animator = child.AnimationController,
					Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SunFireBlow,
					Speed = 1.5
				})
			end

			repeat
				if child and child:FindFirstChild("RootPart") and child.RootPart:FindFirstChild("BodyPosition") then
					child.RootPart.BodyPosition.Position = (humanoidRootPart.CFrame * CFrame.new(0, -2, -10)).Position
					child.RootPart.BodyGyro.CFrame = humanoidRootPart.CFrame
				end

				wait()
			until not _G.SunCUsing or humanoid.Health <= 0
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_C", v3)
	_G.SunCUsing = false
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

function SpiritSpiritClient.V()
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

	local vRequire = SpiritSpirit_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if not workspace.Effects:FindFirstChild("CloudPet " .. localPlayer.Name) or _G.Cooldowns.DFV then
		return
	end

	_G.Cooldowns.DFV = true
	v.V = true
	local cooldownClient = _G.GetCooldownClient("DFV")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	_G.CloudXUsing = true
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritV1
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

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritV2,
			Speed = 2
		})
		task.spawn(function()
			local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 0, 150)
			local v4 = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v3)
			local position = (CFrame.new(v4.p) * CFrame.new(0, 150, -50)).Position
			local cframe = CFrame.new(humanoidRootPart.Position)
			local child = workspace.Effects:FindFirstChild("CloudPet " .. localPlayer.Name)

			repeat
				if child and child:FindFirstChild("RootPart") and child.RootPart:FindFirstChild("BodyPosition") then
					child.RootPart.BodyPosition.Position = position
					child.RootPart.BodyGyro.CFrame = cframe
				end

				wait()
			until not _G.CloudXUsing or humanoid.Health <= 0
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_V", v3)
	_G.CloudXUsing = false
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

function SpiritSpiritClient.E()
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

	local eRequire = SpiritSpirit_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

	if not workspace.Effects:FindFirstChild("CloudPet " .. localPlayer.Name) or _G.Cooldowns.DFE then
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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritFly
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 100000, 0)
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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 300,
			Color = Color3.fromRGB(255, 170, 255)
		})
		math.clamp(humanoid.Health / humanoid.MaxHealth * 125, 50, 125)

		while task.wait() do
			local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 125, 50, 125)
			local v4 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
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

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 300 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		v2:Stop()
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_E", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_E", v3)
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

function SpiritSpiritClient.B()
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

	local bRequire = SpiritSpirit_Data.BRequire

	if localPlayer.PlayerStats.DF.Value < bRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "B", bRequire })
		return
	end

	if not workspace.Effects:FindFirstChild("SunPet " .. localPlayer.Name) or _G.Cooldowns.DFB then
		return
	end

	_G.Cooldowns.DFB = true
	v.B = true
	local cooldownClient = _G.GetCooldownClient("DFB")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	_G.SunCUsing = true
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritB1
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

			if not v.B or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SpiritB2,
			Speed = 2
		})
		task.spawn(function()
			local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 0, 150)
			local position = (CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v3)).p
			local cframe = CFrame.new(humanoidRootPart.Position)
			local child = workspace.Effects:FindFirstChild("SunPet " .. localPlayer.Name)

			if child:FindFirstChild("AnimationController") then
				_G.PU.PlayOneShotAnim({
					Animator = child.AnimationController,
					Animation = ReplicatedStorage.Chest.Animation.SpiritSpirit.SunFireBlow
				})
			end

			repeat
				if child and child:FindFirstChild("RootPart") and child.RootPart:FindFirstChild("BodyPosition") then
					child.RootPart.BodyPosition.Position = position
					child.RootPart.BodyGyro.CFrame = cframe
				end

				wait()
			until not _G.SunCUsing or humanoid.Health <= 0
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_B", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpiritSpirit_B", v3)
	_G.SunCUsing = false
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", cooldownClient)
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
		_G.Cooldowns.DFB = nil
	end)
end

function SpiritSpiritClient.Deactive(p)
	v[p] = nil
end

return SpiritSpiritClient