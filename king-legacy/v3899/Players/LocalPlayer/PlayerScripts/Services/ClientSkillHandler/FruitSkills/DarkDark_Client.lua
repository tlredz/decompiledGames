local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local DarkDark_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.DarkDark_Data)
local DarkDarkClient = {}

function DarkDarkClient.Z()
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

	local zRequire = DarkDark_Data.ZRequire

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
	local darkZ1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkZ1

	if _G.CheckAwakeClient(localPlayer, "DarkZ") then
		darkZ1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkZAwake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = darkZ1
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
	local flag = true
	task.spawn(function()
		if _G.CheckAwakeClient(localPlayer, "DarkZ") then
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if flag then
					flag = false
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
				end

				if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or _G.CheckStunClient(localPlayer) then
					break
				end
			end
		else
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or _G.CheckStunClient(localPlayer) then
					break
				end
			end
		end

		v2:Stop()
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.GetMouse(),
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_Z", v3)
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

function DarkDarkClient.X()
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

	local xRequire = DarkDark_Data.XRequire

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
	local darkX1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkX1

	if _G.CheckAwakeClient(localPlayer, "DarkX") then
		darkX1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkXAwake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = darkX1
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 then
				break
			end
		end

		v2:Stop()
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)
		bodyVelocity:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFX = nil
	end)
end

function DarkDarkClient.C()
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

	local cRequire = DarkDark_Data.CRequire

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
		if _G.CheckAwakeClient(localPlayer, "DarkC") then
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
			bodyPosition.MaxForce = createVector(0, 0, 0)
			bodyPosition.P = 20000
			bodyPosition.Parent = humanoidRootPart
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			math.clamp(humanoid.Health / humanoid.MaxHealth * 275, 125, 275)

			while task.wait() and v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 2 or _G.CheckStunClient(localPlayer)) do
				local v2 = math.clamp(humanoid.Health / humanoid.MaxHealth * 275, 125, 275)
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
			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_C", v2)
			task.spawn(function()
				bodyVelocity.Velocity = Vector3.new()
				bodyPosition:Destroy()
				_G.PU:Dust(bodyVelocity, 0.01)
				bodyGyro:Destroy()
			end)
		else
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
			bodyPosition.MaxForce = createVector(0, 0, 0)
			bodyPosition.P = 20000
			bodyPosition.Parent = humanoidRootPart
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			math.clamp(humanoid.Health / humanoid.MaxHealth * 250, 75, 250)

			while task.wait() and v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 1 or _G.CheckStunClient(localPlayer)) do
				local v2 = math.clamp(humanoid.Health / humanoid.MaxHealth * 250, 75, 250)
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
			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_C", v2)
			task.spawn(function()
				bodyVelocity.Velocity = Vector3.new()
				bodyPosition:Destroy()
				_G.PU:Dust(bodyVelocity, 0.01)
				bodyGyro:Destroy()
			end)
		end
	end)
	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_C", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.25)

		if bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end

		if bodyGyro.Parent then
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

function DarkDarkClient.V()
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

	local vRequire = DarkDark_Data.VRequire

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
	local darkV1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkV1
	local darkV2 = ReplicatedStorage.Chest.Animation.DarkDark.DarkV2

	if _G.CheckAwakeClient(localPlayer, "DarkV") then
		darkV1 = ReplicatedStorage.Chest.Animation.DarkDark.DarkVAwake1
		darkV2 = ReplicatedStorage.Chest.Animation.DarkDark.DarkVAwake2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = darkV1
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

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = darkV2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_V", v3)
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

function DarkDarkClient.B()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or not _G.CheckAwakeClient(
		localPlayer,
		"DarkB"
	) then
		return
	end

	local bRequire = DarkDark_Data.BRequire

	if localPlayer.PlayerStats.DF.Value < bRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "B", bRequire })
		return
	end

	if _G.Cooldowns.DFB then
		return
	end

	_G.Cooldowns.DFB = true
	v.B = true
	local cooldownClient = _G.GetCooldownClient("DFB")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.DarkDark.DarkBAwake1
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
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			bodyVelocity.Velocity = Vector3.new()

			if not v.B or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DarkDark.DarkBAwake2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_B", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DarkDark_B", v3)
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

function DarkDarkClient.Deactive(p)
	v[p] = nil
end

return DarkDarkClient