local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local PhoenixPhoenix_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.PhoenixPhoenix_Data)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

local function easeOutExpo(p)
	if p == 1 then
		return 1
	end

	return 1 - 2 ^ (-10 * p)
end

local PhoenixPhoenixClient = {}

function PhoenixPhoenixClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	local zRequire = PhoenixPhoenix_Data.ZRequire

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

	if character:FindFirstChild("Phoenix_Model") then
		_G.ClearBvDragon(humanoidRootPart)
	else
		_G.ClearBv(humanoidRootPart)
	end

	local lastTime = tick()
	local v2 = nil
	local phoenixZ1 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixZ1
	local phoenixZ2 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixZ2
	local action = Enum.AnimationPriority.Action

	if _G.CheckAwakeClient(localPlayer, "PhoenixZ") then
		if character:FindFirstChild("Phoenix_Model") then
			phoenixZ1 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.PhoenixE1
			phoenixZ2 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.PhoenixZLoop
			action = Enum.AnimationPriority.Action3
		else
			phoenixZ1 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.HybridHold
			phoenixZ2 = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.HybridCast
		end
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
		Animation = phoenixZ1
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
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = phoenixZ2,
			Priority = action
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_Z", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_Z", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true

	if _G.CheckAwakeClient(localPlayer, "PhoenixZ") and character:FindFirstChild("Phoenix_Model") and v2 then
		v2:Stop(0.4)
	end

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

function PhoenixPhoenixClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	local xRequire = PhoenixPhoenix_Data.XRequire

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
	local lastTime = tick()

	if character:FindFirstChild("Phoenix_Model") then
		_G.ClearBvDragon(humanoidRootPart)
		task.spawn(function()
			while task.wait() and v.X and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) do

			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_X", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_X", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
	else
		_G.ClearBv(humanoidRootPart)
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
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixX1
		})
		local v3 = _G.CheckAwakeClient(localPlayer, "PhoenixX")

		if v3 then
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 0.75,
				Color = Color3.fromRGB(0, 255, 255)
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

			if v3 then
				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixX2
			})
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_X", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_X", v4)
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

function PhoenixPhoenixClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	local cRequire = PhoenixPhoenix_Data.CRequire

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
	local phoenix_Model = character:FindFirstChild("Phoenix_Model")

	if phoenix_Model then
		_G.ClearBvDragon(humanoidRootPart)
	else
		_G.ClearBv(humanoidRootPart)
	end

	if _G.CheckAwakeClient(localPlayer, "PhoenixC") then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local lastTime = tick()
		local hybridHold = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.HybridHold
		local hybridSpin = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.HybridSpin

		if phoenix_Model and _G.CheckAwakeClient(localPlayer, "PhoenixV") then
			hybridHold = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.PhoenixC1
			hybridSpin = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.PhoenixC2
		end

		local v2 = nil
		local v3 = nil
		local v4 = nil
		local time = 1.5

		if phoenix_Model then
			if phoenix_Model and _G.CheckAwakeClient(localPlayer, "PhoenixV") then
				time = 2
				local flying = humanoidRootPart:FindFirstChild("Flying")
				local flyingGyro = humanoidRootPart:FindFirstChild("FlyingGyro")
				local flyingBP = humanoidRootPart:FindFirstChild("FlyingBP")
				v2 = flying or v2
				v3 = flyingGyro or v3

				if flyingBP then
					v4 = flyingBP
				end
			end
		else
			v2 = Instance.new("BodyVelocity")
			v2.Velocity = Vector3.new()
			v2.MaxForce = createVector(1e999, 1e999, 1e999)
			v2.Parent = humanoidRootPart
			v3 = Instance.new("BodyGyro")
			v3.MaxTorque = createVector(1e999, 1e999, 1e999)
			v3.P = 20000
			v3.Parent = humanoidRootPart
			v4 = Instance.new("BodyPosition")
			v4.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
			v4.MaxForce = createVector(0, 0, 0)
			v4.P = 20000
			v4.Parent = humanoidRootPart
		end

		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local v6 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = hybridHold
		})
		task.spawn(function()
			while task.wait() do
				if v2 and v2.Parent then
					v2.Velocity = Vector3.new()
				end

				if v3 and v3.Parent then
					v3.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
				end

				if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v6:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = hybridSpin
			})
			local v7 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_C", v7)
			local v8 = 0
			task.spawn(function()
				PeodizService.new({
					Time = 0.5,
					Tween = {
						EasingStyle = Enum.EasingStyle.Circular,
						EasingDirection = Enum.EasingDirection.In
					}
				}, function(p)
					v8 = p * 400
				end)
			end)

			if phoenix_Model then
				character:SetAttribute("CustomFlyingMoving", true)
			end

			PeodizService.HeartbeatWait({
				Time = time
			}, function(_)
				if not character:FindFirstChild("ChargeFolder") or (humanoid.Sit or humanoid.Health <= 0) then
					return true
				end

				if phoenix_Model and not character:GetAttribute("CustomFlyingMoving") then
					character:SetAttribute("CustomFlyingMoving", true)
				end

				local v9 = math.clamp(humanoid.Health / humanoid.MaxHealth * v8, 100, 400)
				local v10 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)

				if v4 then
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						createVector(0, -25, 0),
						raycastParams
					)
					local v11 = humanoidRootPart.Position + createVector(0, -25, 0)

					if raycastResult and v10.Y < 0 then
						local position = raycastResult.Position
						v2.MaxForce = Vector3.new(v2.MaxForce.X, 0, v2.MaxForce.Z)
						v4.MaxForce = createVector(0, 10000000, 0)
						v4.Position = Vector3.new(0, position.Y + 14, 0)
						v10 *= createVector(1, 0, 1)
					elseif v11.Y < -3.35 and v10.Y < 0 then
						v2.MaxForce = Vector3.new(v2.MaxForce.X, 0, v2.MaxForce.Z)
						v4.MaxForce = createVector(0, 10000000, 0)
						v4.Position = createVector(0, 14, 0)
						v10 *= createVector(1, 0, 1)
					else
						v2.MaxForce = Vector3.new(v2.MaxForce.X, v2.MaxForce.X, v2.MaxForce.Z)
						v4.MaxForce = createVector(0, 0, 0)
					end
				end

				v2.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v10).LookVector * v9
				v3.P = 30000
				v3.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v10)
			end)

			if phoenix_Model then
				character:SetAttribute("CustomFlyingMoving", nil)

				if v3 then
					v3.P = 5000
				end
			end

			task.spawn(function()
				if not character:FindFirstChild("Phoenix_Model") then
					if v2 and v2.Parent then
						v2.Velocity = Vector3.new()
						_G.PU:Dust(v2, 0.01)
					end

					if v3 and v3.Parent then
						v3:Destroy()
					end

					if v4 and v4.Parent then
						v4:Destroy()
					end
				end
			end)
		end)
		local v7 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_C", v7)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixC1
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
				Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixC2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_C", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_C", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			wait(0.5)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFC = nil
	end)
end

function PhoenixPhoenixClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	local vRequire = PhoenixPhoenix_Data.VRequire

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

	if character:FindFirstChild("Phoenix_Model") then
		_G.ClearBvDragon(humanoidRootPart)
	end

	_G.ClearBv(humanoidRootPart)
	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_V", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)

	if not character:FindFirstChild("Phoenix_Model") then
		_G.StopAnimationClient(humanoid, {
			PhoenixFullIdle = true,
			Idle = true,
			Fly = true,
			PhoenixGlide = true
		})
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFV = nil
	end)
end

function PhoenixPhoenixClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	if not character:FindFirstChild("Phoenix_Model") then
		local position = humanoidRootPart.Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }

		if workspace:Raycast(position, createVector(0, 25, 0), raycastParams) and not character:FindFirstChild("ChargeFolder") then
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Small Place", {
				Name = "Small Place"
			})
			return
		end
	end

	local eRequire = PhoenixPhoenix_Data.ERequire

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
	local lastTime = tick()

	if _G.CheckAwakeClient(localPlayer, "PhoenixE") and _G.CheckAwakeClient(localPlayer, "PhoenixV") then
		if character:FindFirstChild("Phoenix_Model") then
			_G.ClearBvDragon(humanoidRootPart)
			local v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.PhoenixE1
			})
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
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

				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})
				v2:Stop()
				local v3 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v3)
			end)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v3)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
			task.spawn(function()
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
		else
			_G.ClearBv(humanoidRootPart)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
			bodyVelocity.Parent = humanoidRootPart
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
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
					Color = Color3.fromRGB(0, 255, 255)
				})
				math.clamp(humanoid.Health / humanoid.MaxHealth * 225, 112.5, 225)

				while task.wait() do
					local v2 = math.clamp(humanoid.Health / humanoid.MaxHealth * 225, 112.5, 225)
					local v3 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						createVector(0, -25, 0),
						raycastParams
					)
					local v4 = humanoidRootPart.Position + createVector(0, -25, 0)

					if raycastResult and v3.Y < 0 then
						local position = raycastResult.Position
						bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
						bodyPosition.MaxForce = createVector(0, 10000000, 0)
						bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
						v3 *= createVector(1, 0, 1)
					elseif v4.Y < -3.35 and v3.Y < 0 then
						bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
						bodyPosition.MaxForce = createVector(0, 10000000, 0)
						bodyPosition.Position = createVector(0, 14, 0)
						v3 *= createVector(1, 0, 1)
					else
						bodyVelocity.MaxForce = Vector3.new(
							bodyVelocity.MaxForce.X,
							bodyVelocity.MaxForce.X,
							bodyVelocity.MaxForce.Z
						)
						bodyPosition.MaxForce = createVector(0, 0, 0)
					end

					bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v3).LookVector * v2
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v3)

					if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 300 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})
				task.spawn(function()
					bodyVelocity.Velocity = Vector3.new()
					_G.PU:Dust(bodyVelocity, 0.01)
					bodyPosition:Destroy()
					bodyGyro:Destroy()
				end)
				local v2 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v2)
			end)
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v2)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
		end
	elseif character:FindFirstChild("Phoenix_Model") then
		_G.ClearBvDragon(humanoidRootPart)
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixFullE,
			Speed = 1.75
		})
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local v3 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v3)
		v2:Stop()
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		_G.ClearBv(humanoidRootPart)
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixFly
		})
		local v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixFlyWing
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
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
				Color = Color3.fromRGB(0, 255, 255)
			})
			math.clamp(humanoid.Health / humanoid.MaxHealth * 125, 50, 125)

			while task.wait() do
				local v4 = math.clamp(humanoid.Health / humanoid.MaxHealth * 125, 50, 125)
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

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 300 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			v2:Stop()
			v3:Stop()
			task.spawn(function()
				bodyVelocity.Velocity = Vector3.new()
				_G.PU:Dust(bodyVelocity, 0.01)
				bodyPosition:Destroy()
				bodyGyro:Destroy()
			end)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_E", v4)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function PhoenixPhoenixClient.M1()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Phoenix_Model") then
		return
	end

	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	local phoenix_Model = character:FindFirstChild("Phoenix_Model")

	if phoenix_Model then
		if phoenix_Model then
			_G.ClearBvDragon(humanoidRootPart)
		end
	else
		_G.ClearBv(humanoidRootPart)
	end

	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PhoenixPhoenix_M1", v2)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
end

function PhoenixPhoenixClient.Deactive(p)
	v[p] = nil
end

return PhoenixPhoenixClient