local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local AlloAllo_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.AlloAllo_Data)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local AlloAlloClient = {}

function AlloAlloClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Allosaurus") then
		return
	end

	local zRequire = AlloAllo_Data.ZRequire

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
	local allosaurus = character:FindFirstChild("Allosaurus")
	local v2 = nil
	task.spawn(function()
		if not allosaurus then
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
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.AlloAllo.Z2
			})
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_Z", v3)
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

function AlloAlloClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Allosaurus") then
		return
	end

	local xRequire = AlloAllo_Data.XRequire

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
		local allosaurus = character:FindFirstChild("Allosaurus")
		local v3 = nil

		if allosaurus then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://115486685246045"
			})
			task.delay(0.4, function()
				if not v2 then
					v3 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://90130804164788"
					})
				end
			end)
		else
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.AlloAllo.X1
			})
		end

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

		if allosaurus then
			local v4 = Scheduler.new(0.3)
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
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://131751862796906"
			})
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.AlloAllo.X2
			})
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_X", v4)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_X", v3)
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

function AlloAlloClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Allosaurus") then
		return
	end

	local cRequire = AlloAllo_Data.CRequire

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
	local allosaurus = character:FindFirstChild("Allosaurus")
	local v2

	if allosaurus then
		v2 = nil
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.C1
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

		if allosaurus then
			if allosaurus then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://125289155004526"
				})
			end
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.C2
			})
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_C", v3)
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

function AlloAlloClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Allosaurus") then
		return
	end

	local vRequire = AlloAllo_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	character:FindFirstChild("Allosaurus")
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

	if not character:FindFirstChild("Allosaurus") then
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://94944366742415"
		})
	end

	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_V", v2)
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

function AlloAlloClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Allosaurus") then
		return
	end

	local eRequire = AlloAllo_Data.ERequire

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
	local animation, v3

	if character:FindFirstChild("Allosaurus") then
		animation = "rbxassetid://115113352738780"
		v3 = 250
	else
		animation = "rbxassetid://73615195165114"
		v3 = 200
	end

	local v4 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = animation
	})
	task.spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local v5 = 90
		math.clamp(humanoid.Health / humanoid.MaxHealth * v5, v3 / 2, v3)
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 60,
			Color = Color3.fromRGB(255, 255, 255)
		})

		while task.wait() do
			if v3 <= v5 then
				v5 = v3
			else
				v5 += 4
			end

			local v6 = math.clamp(humanoid.Health / humanoid.MaxHealth * v5, v3 / 2, v3)
			local v7 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
			local v8 = humanoidRootPart.Position + createVector(0, -25, 0)

			if raycastResult and v7.Y < 0 then
				local position = raycastResult.Position
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
				v7 *= createVector(1, 0, 1)
			elseif v8.Y < -3.35 and v7.Y < 0 then
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = createVector(0, 14, 0)
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

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 60 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v4:Stop()
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_E", v6)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_E", v5)
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

function AlloAlloClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_AlloAllo_M1", v2)
end

function AlloAlloClient.Deactive(p)
	v[p] = nil
end

return AlloAlloClient