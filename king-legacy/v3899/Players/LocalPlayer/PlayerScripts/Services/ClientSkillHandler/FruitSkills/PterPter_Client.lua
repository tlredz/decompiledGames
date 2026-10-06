local createVector = vector.create
local PterPterClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local v = {}
local PterPter_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.PterPter_Data)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

function PterPterClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Pteranodon_KL") then
		return
	end

	local zRequire = PterPter_Data.ZRequire

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

	if character:FindFirstChild("Pteranodon_KL") then
		_G.ClearBvDragon(humanoidRootPart)
	else
		_G.ClearBv(humanoidRootPart)
	end

	local lastTime = tick()
	local pteranodon_KL = character:FindFirstChild("Pteranodon_KL")
	local v2 = 5
	local v3

	if pteranodon_KL then
		v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://109355822069083"
		})
	else
		v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://131296660384461"
		})
		v2 = 10
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

			if v.Z and _G.IsEquiping(script.Name:gsub("_Client", "")) and not humanoid.Sit then
				if v2 < tick() - lastTime or _G.CheckStunClient(localPlayer) then
					break
				end
			else
				break
			end
		end

		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.7
			}, function(_)
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)
			end)
		end)

		if v3 then
			v3:Stop()
		end

		if not pteranodon_KL then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://83693418220471"
			})
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_Z", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_Z", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
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
		_G.Cooldowns.DFZ = nil
	end)
end

function PterPterClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Pteranodon_KL") then
		return
	end

	local xRequire = PterPter_Data.XRequire

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

	if character:FindFirstChild("Pteranodon_KL") then
		_G.ClearBvDragon(humanoidRootPart)
	else
		_G.ClearBv(humanoidRootPart)
	end

	local lastTime = tick()
	local v2 = nil
	local pteranodon_KL = character:FindFirstChild("Pteranodon_KL")

	if pteranodon_KL then
		if pteranodon_KL then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://79194092662268"
			})
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://72535090426274"
			})
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://90150983622406"
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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 1,
			Color = Color3.fromRGB(170, 85, 255)
		})

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 1.5
			}, function(_)
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)
			end)
		end)

		if pteranodon_KL then
			if pteranodon_KL then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://108956809165735",
					Priority = Enum.AnimationPriority.Action2
				})
			end
		else
			if v2 then
				v2:Stop()
			end

			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://102068158343703"
			})
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)

	if pteranodon_KL and v2 then
		v2:Stop()
	end

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

function PterPterClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Pteranodon_KL") then
		return
	end

	local cRequire = PterPter_Data.CRequire

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
	local pteranodon_KL = character:FindFirstChild("Pteranodon_KL")
	local lastTime = tick()
	local v2

	if pteranodon_KL then
		if pteranodon_KL then
			_G.ClearBvDragon(humanoidRootPart)
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://76515357500887"
			})
			local flying = humanoidRootPart:FindFirstChild("Flying")
			local flyingGyro = humanoidRootPart:FindFirstChild("FlyingGyro")
			local flyingBP = humanoidRootPart:FindFirstChild("FlyingBP")
			local v5, v6

			if flying then
				v5 = "MaxAxesForce"
				v6 = "VectorVelocity"
			else
				flying = nil
				v5 = "MaxForce"
				v6 = "Velocity"
			end

			local v7 = flyingGyro or nil
			local v8 = flyingBP or nil
			mouse.TargetFilter = workspace.Effects
			task.spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local lastTime2 = tick()
				local total = 90
				local v9 = 250
				local v10 = nil
				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Start",
					Time = 4,
					Color = Color3.fromRGB(170, 85, 255)
				})
				character:SetAttribute("CustomFlyingMoving", true)
				PeodizService.HeartbeatWait({
					Time = 4
				}, function(_)
					if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 4 or humanoid.Health <= 0 then
						return true
					end

					total += 10

					if not character:GetAttribute("CustomFlyingMoving") then
						character:SetAttribute("CustomFlyingMoving", true)
					end

					local v11 = math.clamp(humanoid.Health / humanoid.MaxHealth * total, 100, v9)
					local v12 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)

					if tick() - lastTime2 > 2 and not v10 then
						v10 = true
						v9 = 350
						total += 100
					end

					if v8 then
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -25, 0),
							raycastParams
						)
						local v13 = humanoidRootPart.Position + createVector(0, -25, 0)

						if raycastResult and v12.Y < 0 then
							local position = raycastResult.Position
							flying[v5] = Vector3.new(flying.MaxAxesForce.X, 0, flying.MaxAxesForce.Z)
							v8.MaxForce = createVector(0, 10000000, 0)
							v8.Position = Vector3.new(0, position.Y + 14, 0)
							v12 *= createVector(1, 0, 1)
						elseif v13.Y < -3.35 and v12.Y < 0 then
							flying[v5] = Vector3.new(flying.MaxAxesForce.X, 0, flying.MaxAxesForce.Z)
							v8.MaxForce = createVector(0, 10000000, 0)
							v8.Position = createVector(0, 14, 0)
							v12 *= createVector(1, 0, 1)
						else
							flying[v5] = Vector3.new(flying[v5].X, flying[v5].X, flying[v5].Z)
							v8.MaxForce = createVector(0, 0, 0)
						end
					end

					flying[v6] = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v12).LookVector * v11
					v7.P = 30000
					v7.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v12)
				end)
				character:SetAttribute("CustomFlyingMoving", nil)
				v7.P = 5000
				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})

				if v2 then
					v2:Stop()
				end

				local v11 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_C", v11)
			end)
			local v9 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_C", v9)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
			mouse.TargetFilter = nil
		end
	else
		_G.ClearBv(humanoidRootPart)
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://108294355421643"
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
		local v3 = nil
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 1,
				Color = Color3.fromRGB(170, 85, 255)
			})

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			bodyGyro:Destroy()

			if v2 then
				v2:Stop()
			end

			if not pteranodon_KL then
				v3 = _G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://125093290444125"
				})
			end

			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_C", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_C", v4)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
		mouse.TargetFilter = nil

		if v3 then
			v3:Stop()
		end

		task.spawn(function()
			bodyVelocity:Destroy()
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

function PterPterClient.V()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Pteranodon_KL") then
		return
	end

	local vRequire = PterPter_Data.VRequire

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
	local pteranodon_KL = character:FindFirstChild("Pteranodon_KL")

	if pteranodon_KL then
		if pteranodon_KL then
			_G.ClearBvDragon(humanoidRootPart)
			_G.ClearBv(humanoidRootPart)
		end
	else
		_G.ClearBv(humanoidRootPart)
	end

	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_V", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)

	if not character:FindFirstChild("Pteranodon_KL") then
		_G.StopAnimationClient(humanoid, {
			PterIdle = true,
			PterFly = true,
			PterGlide = true
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

function PterPterClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Pteranodon_KL") then
		return
	end

	local eRequire = PterPter_Data.ERequire

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

	if character:FindFirstChild("Pteranodon_KL") then
		_G.ClearBvDragon(humanoidRootPart)
	else
		_G.ClearBv(humanoidRootPart)
	end

	local lastTime = tick()
	local currentCamera = workspace.CurrentCamera
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + currentCamera.CFrame.LookVector)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local pteranodon_KL = character:FindFirstChild("Pteranodon_KL")
	local v2 = nil

	if pteranodon_KL then
		if pteranodon_KL then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://96628988129991",
				Priority = Enum.AnimationPriority.Action2
			})
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = "rbxassetid://121642145949148"
			})
		end
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://114009824324108"
		})
	end

	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_E", v3)

		if v2 then
			v2:Stop()
		end
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_E", v3)
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

function PterPterClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_PterPter_M1", v2)
end

function PterPterClient.Deactive(p)
	v[p] = nil
end

return PterPterClient