local createVector = vector.create
local RumbleRumbleClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
require(ReplicatedStorage.Chest.Modules.PeoUtils)
local v = {}
local RumbleRumble_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.RumbleRumble_Data)

function RumbleRumbleClient.Z()
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

	local zRequire = RumbleRumble_Data.ZRequire

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
	local Z1 = ReplicatedStorage.Chest.Animation.RumbleRumble.Z1
	local Z2 = ReplicatedStorage.Chest.Animation.RumbleRumble.Z2
	local speed

	if _G.CheckAwakeClient(localPlayer, "RumbleZ") then
		Z1 = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.Z1
		Z2 = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.Z2
		speed = 1.5
	else
		speed = 1
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
		Animation = Z1
	})
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = Z2,
			Speed = speed
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_Z", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_Z", v4)
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

function RumbleRumbleClient.X()
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

	local xRequire = RumbleRumble_Data.XRequire

	if localPlayer.PlayerStats.DF.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "X", xRequire })
	elseif _G.CheckAwakeClient(localPlayer, "RumbleX") then
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.X1
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
		local v3 = true
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 20
			}, function()
				if not v3 then
					return true
				end

				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			end)
		end)
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 0.7,
			Color = Color3.fromRGB(0, 255, 255)
		})
		task.spawn(function()
			while task.wait() and v.X and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10) do

			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.X2
			})
			task.wait(0.1)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_X", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_X", v4)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		v3 = nil
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
	else
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.X1
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
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.X2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_X", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_X", v3)
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
end

function RumbleRumbleClient.C()
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

	local cRequire = RumbleRumble_Data.CRequire

	if localPlayer.PlayerStats.DF.Value < cRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "C", cRequire })
	elseif _G.CheckAwakeClient(localPlayer, "RumbleC") then
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
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.C1
		})
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
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.C2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_C", v3)
			PeodizService.HeartbeatWait({
				Time = 1.5
			}, function(_)
				if not character:FindFirstChild("ChargeFolder") or (humanoid.Sit or humanoid.Health <= 0) then
					return true
				end

				local v4 = math.clamp(humanoid.Health / humanoid.MaxHealth * 500, 275, 550)
				local v5 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -25, 0),
					raycastParams
				)
				local v6 = humanoidRootPart.Position + createVector(0, -25, 0)

				if raycastResult and v5.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
					v5 *= createVector(1, 0, 1)
				elseif v6.Y < -3.35 and v5.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = createVector(0, 14, 0)
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
			end)

			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * 10
				_G.PU:Dust(bodyVelocity, 0.1)
			end

			bodyPosition:Destroy()
			bodyGyro:Destroy()
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_C", v3)
		v2:Stop()
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFC = nil
		end)
	else
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
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.C1
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

				if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.C2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_C", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_C", v3)
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
end

function RumbleRumbleClient.V()
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

	local vRequire = RumbleRumble_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
	elseif _G.CheckAwakeClient(localPlayer, "RumbleV") then
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.V1
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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 3,
			Color = Color3.fromRGB(0, 255, 255)
		})
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.V2Cast
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_V", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_V", v3)
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
	else
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.V1
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
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.V2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_V", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_V", v3)
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
end

function RumbleRumbleClient.E()
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

	local eRequire = RumbleRumble_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
	elseif _G.CheckAwakeClient(localPlayer, "RumbleE") then
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.E1
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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 1,
			Color = Color3.fromRGB(0, 255, 255)
		})
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.E2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_E", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_E", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyGyro:Destroy()
			bodyVelocity.Velocity = Vector3.new()
			wait(wait())
			bodyVelocity:Destroy()
		end)
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFE = nil
		end)
	else
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.E1
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

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.E2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_E", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_RumbleRumble_E", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyGyro:Destroy()
			bodyVelocity.Velocity = Vector3.new()
			wait(wait())
			bodyVelocity:Destroy()
		end)
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFE = nil
		end)
	end
end

function RumbleRumbleClient.Deactive(p)
	v[p] = nil
end

return RumbleRumbleClient