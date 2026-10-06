local createVector = vector.create
local v = 1
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v2 = {}
local AuthenticTripleKatana_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords["Authentic Triple Katana_Data"])
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local AuthenticTripleKatanaClient = {}

function AuthenticTripleKatanaClient.Z()
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

	local zRequire = AuthenticTripleKatana_Data.ZRequire

	if localPlayer.PlayerStats.sword.Value < zRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Sword", "Z", zRequire })
		return
	end

	if _G.Cooldowns.SWZ then
		return
	end

	_G.Cooldowns.SWZ = true
	v2.Z = true
	local cooldownClient = _G.GetCooldownClient("SWZ")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()

	if _G.CheckAwakeClient(localPlayer, "AuthenticTripleKatanaZ") then
		local aTKZ1Hold = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ1Hold
		local aTKZ1Cast = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ1Cast
		local v3 = v

		if v3 == 2 then
			aTKZ1Hold = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ2Hold
			aTKZ1Cast = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ2Cast
		elseif v3 == 3 then
			aTKZ1Hold = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ3Hold
			aTKZ1Cast = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"].ATKZ3Cast
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
		local v4 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = aTKZ1Hold
		})
		local v5 = v3 ~= 3 and 0.5 or cooldownClient
		task.spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v2.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v4:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = aTKZ1Cast
			})
			local v6 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_Z", v6)
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
			bodyPosition.MaxForce = createVector(0, 0, 0)
			bodyPosition.P = 20000
			bodyPosition.Parent = humanoidRootPart
			local v7 = v3 == 1 and 4 or 10
			PeodizService.HeartbeatWait({
				Time = 0.5
			}, function(_)
				if not character:FindFirstChild("ChargeFolder") or (humanoid.Sit or humanoid.Health <= 0) then
					return true
				end

				local v8 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -25, 0),
					raycastParams
				)
				local v9 = humanoidRootPart.Position + createVector(0, -25, 0)

				if raycastResult and v8.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + v7, 0)
					v8 *= createVector(1, 0, 1)
				elseif v9.Y < -3.35 and v8.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, v7, 0)
					v8 *= createVector(1, 0, 1)
				else
					bodyVelocity.MaxForce = Vector3.new(
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.Z
					)
					bodyPosition.MaxForce = createVector(0, 0, 0)
				end

				if v3 ~= 3 then
					bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v8).LookVector * 400
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v8)
				end
			end)
			task.spawn(function()
				bodyVelocity.Velocity = Vector3.new()
				task.wait(0.75)
				bodyPosition:Destroy()
				_G.PU:Dust(bodyVelocity, 0.01)
				bodyGyro:Destroy()
			end)
		end)
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}

		if ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_Z", v6) then
			if v == 1 then
				v = 2
			elseif v == 2 then
				v = 3
			elseif v == 3 then
				v = 1
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", v5)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(v5)
			_G.Cooldowns.SWZ = nil
		end)
	else
		local v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"]["3SS2Charge"]
		})
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
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v2.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v3:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"]["3SS2Fire"]
			})
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_Z", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_Z", v4)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
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
			_G.Cooldowns.SWZ = nil
		end)
	end
end

function AuthenticTripleKatanaClient.X()
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

	local xRequire = AuthenticTripleKatana_Data.XRequire

	if localPlayer.PlayerStats.sword.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Sword", "X", xRequire })
		return
	end

	if _G.Cooldowns.SWX then
		return
	end

	_G.Cooldowns.SWX = true
	v2.X = true
	local cooldownClient = _G.GetCooldownClient("SWX")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"]["3SS2XCharge"]
	})
	local _3SS2XFire = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"]["3SS2XFire"]

	if _G.CheckAwakeClient(localPlayer, "AuthenticTripleKatanaX") then
		_3SS2XFire = ReplicatedStorage.Chest.Animation["Authentic Triple Katana"]["3SS2XFirev2"]
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
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v2.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = _3SS2XFire
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_X", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_X", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "X", cooldownClient)
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
		_G.Cooldowns.SWX = nil
	end)
end

function AuthenticTripleKatanaClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Authentic Triple Katana_M1")
end

function AuthenticTripleKatanaClient.Deactive(p)
	v2[p] = nil
end

return AuthenticTripleKatanaClient