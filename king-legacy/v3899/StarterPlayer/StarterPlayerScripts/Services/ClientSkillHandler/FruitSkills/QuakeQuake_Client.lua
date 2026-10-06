local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local QuakeQuake_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.QuakeQuake_Data)
local QuakeQuakeClient = {}

function QuakeQuakeClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckAwakeClient(localPlayer, "QuakeZ") then
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or _G.Cooldowns.DFZ then
			return
		end

		_G.Cooldowns.DFZ = true
		local cooldownClient = _G.GetCooldownClient("DFZ")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeZ1_V2
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
		v.Z = true
		spawn(function()
			while wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeZ2_V2,
				Speed = 1.5
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_Z", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_Z", v3)
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
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
	else
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
			return
		end

		if character:FindFirstChild("RightHand") then
			if localPlayer.PlayerStats.DFName.Value ~= "QuakeQuake" or _G.Cooldowns.DFZ then
				return
			end

			_G.Cooldowns.DFZ = true
			local cooldownClient = _G.GetCooldownClient("DFZ")
			local instanceDoingClient = _G.InstanceDoingClient({
				Parent = localPlayer
			})
			_G.ClearBv(humanoidRootPart)
			local _ = character.RightHand
			local lastTime = tick()
			v.Z = true
			local v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeHold
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
			spawn(function()
				while true do
					local RunService = game:GetService("RunService")

					if not RunService.RenderStepped:Wait() then
						break
					end

					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

					if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				v2:Stop()
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeFire
				})
				v2:AdjustSpeed(3)
				game.ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
				humanoid.AutoRotate = true
				mouse.TargetFilter = nil
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
				local v3 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_Z", v3)
			end)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_Z", v3)
			task.spawn(function()
				instanceDoingClient:Delete()
			end)
			task.spawn(function()
				wait(cooldownClient)
				_G.Cooldowns.DFZ = nil
			end)
		end
	end
end

function QuakeQuakeClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckAwakeClient(localPlayer, "QuakeX") then
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or _G.Cooldowns.DFX then
			return
		end

		_G.Cooldowns.DFX = true
		local cooldownClient = _G.GetCooldownClient("DFX")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeHold2,
			Speed = 0.4
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
		v.X = true
		spawn(function()
			while wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeFire2,
				Speed = 0.4
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_X", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_X", v3)
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFX = nil
		end)
	else
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
			return
		end

		if character:FindFirstChild("RightHand") and character:FindFirstChild("LeftHand") then
			if localPlayer.PlayerStats.DF.Value < QuakeQuake_Data.XRequire then
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
					"Stats Require",
					{ "Power Fruit", "X", QuakeQuake_Data.XRequire }
				)
				return
			end

			if localPlayer.PlayerStats.DFName.Value ~= "QuakeQuake" or _G.Cooldowns.DFX then
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
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.Gura2,
				FadeTime = 0.15
			})
			task.spawn(function()
				task.wait(0.6)

				if v then
					v2.TimePosition = 0.6
					v2:AdjustSpeed(0)
				end
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			humanoid.AutoRotate = false
			spawn(function()
				while wait() do
					bodyVelocity.Velocity = Vector3.new()

					if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				coroutine.wrap(function()
					local TweenService = game:GetService("TweenService")
					TweenService:Create(v2, TweenInfo.new(0.12), {
						TimePosition = 0.75
					}):Play()
					v2:AdjustSpeed(0)
				end)()
				local v3 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_X", v3)
			end)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_X", v3)
			task.spawn(function()
				wait(0.25)
				bodyVelocity:Destroy()
			end)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
			task.spawn(function()
				instanceDoingClient:Delete()
			end)
			task.spawn(function()
				wait(cooldownClient)
				_G.Cooldowns.DFX = nil
			end)
			v2:Stop(0.15)
		end
	end
end

function QuakeQuakeClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckAwakeClient(localPlayer, "QuakeC") then
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or localPlayer.PlayerStats.DF.Value < 300 then
			return
		end

		if _G.Cooldowns.DFC then
			return
		end

		_G.Cooldowns.DFC = true
		local cooldownClient = _G.GetCooldownClient("DFC")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.Gura3
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
		local v3 = nil
		task.spawn(function()
			task.wait(0.35)

			if not v3 then
				v2.TimePosition = 0.35
				v2:AdjustSpeed(0)
			end
		end)
		v.C = true
		spawn(function()
			while wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v3 = true
			v2:AdjustSpeed(1)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_C", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_C", v4)
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
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
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
			return
		end

		if character:FindFirstChild("Humanoid") and character:FindFirstChild("RightHand") then
			if localPlayer.PlayerStats.DF.Value < QuakeQuake_Data.CRequire then
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
					"Stats Require",
					{ "Power Fruit", "C", QuakeQuake_Data.CRequire }
				)
				return
			end

			if localPlayer.PlayerStats.DFName.Value ~= "QuakeQuake" or _G.Cooldowns.DFC then
				return
			end

			_G.Cooldowns.DFC = true
			local cooldownClient = _G.GetCooldownClient("DFC")
			local instanceDoingClient = _G.InstanceDoingClient({
				Parent = localPlayer
			})
			_G.ClearBv(humanoidRootPart)
			local lastTime = tick()
			v.C = true
			local v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.Gura1
			})
			task.spawn(function()
				task.wait(0.4)

				if v.C then
					v2.TimePosition = 0.4
					v2:AdjustSpeed(0)
				end
			end)
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
			spawn(function()
				while true do
					local RunService = game:GetService("RunService")

					if not RunService.RenderStepped:Wait() then
						break
					end

					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

					if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				v2:AdjustSpeed(3)
				local v3 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_C", v3)
			end)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_C", v3)
			task.spawn(function()
				wait(0.25)
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
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
		end
	end
end

function QuakeQuakeClient.V()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckAwakeClient(localPlayer, "QuakeV") then
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or localPlayer.PlayerStats.DF.Value < 400 then
			return
		end

		if _G.Cooldowns.DFV then
			return
		end

		_G.Cooldowns.DFV = true
		local cooldownClient = _G.GetCooldownClient("DFV")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.Gura3,
			Speed = 0.4
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
		v.V = true
		task.spawn(function()
			task.wait(0.35)

			if v.V then
				v2.TimePosition = 0.35
				v2:AdjustSpeed(0)
			end
		end)
		spawn(function()
			while wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:AdjustSpeed(1)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_V", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_V", v3)
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFV = nil
		end)
	else
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
			return
		end

		if character:FindFirstChild("RightHand") and character:FindFirstChild("LeftHand") then
			if localPlayer.PlayerStats.DF.Value < QuakeQuake_Data.VRequire then
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
					"Stats Require",
					{ "Power Fruit", "V", QuakeQuake_Data.VRequire }
				)
				return
			end

			if localPlayer.PlayerStats.DFName.Value ~= "QuakeQuake" or _G.Cooldowns.DFV then
				return
			end

			_G.Cooldowns.DFV = true
			local cooldownClient = _G.GetCooldownClient("DFV")
			local _ = character.RightHand
			local _ = character.LeftHand
			local instanceDoingClient = _G.InstanceDoingClient({
				Parent = localPlayer
			})
			v.V = true
			local v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.Gura3,
				FadeTime = 0.15
			})
			task.spawn(function()
				task.wait(0.35)

				if v.V then
					v2.TimePosition = 0.35
					v2:AdjustSpeed(0)
				end
			end)
			_G.ClearBv(humanoidRootPart)
			local lastTime = tick()
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Parent = humanoidRootPart
			mouse.TargetFilter = workspace.Effects
			humanoid.AutoRotate = false
			spawn(function()
				while true do
					local RunService = game:GetService("RunService")

					if not RunService.RenderStepped:Wait() then
						break
					end

					bodyVelocity.Velocity = Vector3.new()

					if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end

				v2:AdjustSpeed(0.7)
				local v3 = {
					MouseHit = _G.MouseHit,
					Type = "Up"
				}
				ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_V", v3)
			end)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Down"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_V", v3)
			task.spawn(function()
				wait(0.25)
				bodyVelocity:Destroy()
			end)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
			mouse.TargetFilter = nil
			humanoid.AutoRotate = true
			task.spawn(function()
				instanceDoingClient:Delete()
			end)
			task.spawn(function()
				wait(cooldownClient)
				_G.Cooldowns.DFV = nil
			end)
		end
	end
end

function QuakeQuakeClient.B()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckAwakeClient(localPlayer, "QuakeB") then
		if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
			return
		end

		if localPlayer.PlayerStats.DF.Value < QuakeQuake_Data.BRequire then
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
				"Stats Require",
				{ "Power Fruit", "B", QuakeQuake_Data.BRequire }
			)
			return
		end

		if _G.Cooldowns.DFB then
			return
		end

		_G.Cooldowns.DFB = true
		local cooldownClient = _G.GetCooldownClient("DFB")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.QuakeQuake.QuakeB
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
		v.B = true
		spawn(function()
			while wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.B or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			_G.VisibleGui(nil)
			v2:Stop()
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_B", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_QuakeQuake_B", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		_G.VisibleGui(true)
		spawn(function()
			wait(1.5)
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			humanoid.AutoRotate = true
			bodyGyro:Destroy()
			bodyVelocity:Destroy()
		end)
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFB = nil
		end)
	end
end

function QuakeQuakeClient.Deactive(p)
	v[p] = nil
end

return QuakeQuakeClient