local createVector = vector.create
local SpinoSpinoClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local v = {}
local SpinoSpino_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.SpinoSpino_Data)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

function SpinoSpinoClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Spinosaurus") then
		return
	end

	local xRequire = SpinoSpino_Data.XRequire

	if localPlayer.PlayerStats.DF.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "Z", xRequire })
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
		Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.Z1
	})
	local total = 100
	local v3, v4

	if character:FindFirstChild("Spinosaurus") then
		v3 = 250
		v4 = 20
	else
		v3 = 200
		v4 = 4
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(10000000, 10000000, 10000000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(10000000, 10000000, 10000000)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.Z2,
			Speed = 1.5
		})
		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_Z", v5)
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
		bodyPosition.MaxForce = createVector(0, 0, 0)
		bodyPosition.P = 20000
		bodyPosition.Parent = humanoidRootPart
		PeodizService.HeartbeatWait({
			Time = 1.5
		}, function(_)
			if not character:FindFirstChild("ChargeFolder") or (humanoid.Sit or humanoid.Health <= 0) then
				return true
			end

			total += 8
			local v6 = math.clamp(humanoid.Health / humanoid.MaxHealth * total, v3 / 2, v3)
			local v7 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
			local v8 = humanoidRootPart.Position + createVector(0, -25, 0)

			if raycastResult and v7.Y < 0 then
				local position = raycastResult.Position
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, position.Y + v4, 0)
				v7 *= createVector(1, 0, 1)
			elseif v8.Y < -3.35 and v7.Y < 0 then
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = createVector(0, 14, 0)
				v7 *= createVector(1, 0, 1)
			else
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 10000000, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 0, 0)
			end

			bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v7).LookVector * v6
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v7)
		end)
		task.spawn(function()
			bodyVelocity.Velocity = Vector3.new()
			task.wait(0.5)
			bodyPosition:Destroy()
			_G.PU:Dust(bodyVelocity, 0.01)
			bodyGyro:Destroy()
		end)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_Z", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFZ = nil
	end)
end

function SpinoSpinoClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Spinosaurus") then
		return
	end

	local xRequire = SpinoSpino_Data.XRequire

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
	local spinosaurus = character:FindFirstChild("Spinosaurus")
	local v2

	if spinosaurus then
		v2 = nil
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.X1
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
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 1.5
			}, function(_)
				if not character:FindFirstChild("ChargeFolder") then
					return true
				end

				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)
			end)
		end)

		if v2 then
			v2:Stop()
		end

		if spinosaurus then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SpinoSpino["Skill 2"]
			})
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.X2
			})
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
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
		_G.Cooldowns.DFX = nil
	end)
end

function SpinoSpinoClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Spinosaurus") then
		return
	end

	local cRequire = SpinoSpino_Data.CRequire

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
	local spinosaurus = character:FindFirstChild("Spinosaurus")
	local v2

	if spinosaurus then
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

		if spinosaurus then
			if spinosaurus then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = ReplicatedStorage.Chest.Animation.SpinoSpino["Skill 3"]
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
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_C", v3)
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

function SpinoSpinoClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Spinosaurus") then
		return
	end

	local vRequire = SpinoSpino_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	character:FindFirstChild("Spinosaurus")
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

	if not character:FindFirstChild("Spinosaurus") then
		_G.PU.PlayOneShotAnim(humanoid, ReplicatedStorage.Chest.Animation.SpinoSpino.Transform)
	end

	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_V", v2)
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

function SpinoSpinoClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Spinosaurus") then
		return
	end

	local eRequire = SpinoSpino_Data.ERequire

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
	local currentCamera = workspace.CurrentCamera
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1000000, 0, 1000000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 1e999)
	bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + currentCamera.CFrame.LookVector)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = "InvisibleFloor"
	part.Transparency = 1
	part.Size = createVector(50, 5, 50)
	part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
	part.Parent = workspace.Island
	local spinosaurus = character:FindFirstChild("Spinosaurus")
	local v2 = nil
	local v3 = 50
	local v4 = 175

	if spinosaurus then
		if spinosaurus then
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.SpinoSpino["Skill 5"],
				Speed = 2
			})
			v4 = 245
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.SpinoSpino.ELoop
		})
	end

	task.spawn(function()
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 60,
			Color = Color3.fromRGB(255, 112, 112)
		})
		character:SetAttribute("SpeedLine", true)
		local hipHeight = humanoid.HipHeight

		if spinosaurus then
			if spinosaurus then
				humanoid.HipHeight = 18.5
			end
		else
			humanoid.HipHeight = 9
		end

		while task.wait() do
			local v5 = math.rad(currentCamera.CFrame.RightVector:Dot(humanoidRootPart.CFrame.LookVector) * 90)

			if v4 <= v3 then
				v3 = v4
			else
				v3 += 6
			end

			local v6 = math.clamp(humanoid.Health / humanoid.MaxHealth * v3, v4 / 2, v4)
			bodyGyro.CFrame = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + currentCamera.CFrame.LookVector
			) * CFrame.Angles(0, 0, v5)
			bodyVelocity.Velocity = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + currentCamera.CFrame.LookVector * createVector(1, 0, 1)
			).LookVector * v6
			bodyVelocity.MaxForce = createVector(1000000, -50000, 1000000)
			part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { workspace.Effects, character, workspace.CharacterWorkshop }
			local ray = Ray.new(humanoidRootPart.CFrame.p, humanoidRootPart.CFrame.LookVector * 10)
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

			if not (raycastResult and raycastResult.Position) then
				local _ = ray.Origin + ray.Direction
			end

			if raycastResult then
				bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
				bodyVelocity.Velocity = humanoidRootPart.CFrame.UpVector * v6 / 1.5
			end

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 60 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if hipHeight > 3 and not character:FindFirstChild("Spinosaurus") then
			humanoid.HipHeight = 2.657
		else
			humanoid.HipHeight = hipHeight
		end

		if v2 then
			v2:Stop()
		end

		character:SetAttribute("SpeedLine", false)
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_E", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_E", v5)
	part:Destroy()
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		bodyVelocity.Velocity = Vector3.new()
		task.wait()
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
end

function SpinoSpinoClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_SpinoSpino_M1", v2)
end

function SpinoSpinoClient.Deactive(p)
	v[p] = nil
end

return SpinoSpinoClient