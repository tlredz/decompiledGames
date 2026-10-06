local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local Electro_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Styles.Electro_Data)
local ElectroClient = {}

function ElectroClient.Z()
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

	local zRequire = Electro_Data.ZRequire

	if localPlayer.PlayerStats.Melee.Value < zRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "Z", zRequire })
		return
	end

	if _G.Cooldowns.FSZ then
		return
	end

	_G.Cooldowns.FSZ = true
	v.Z = true
	local cooldownClient = _G.GetCooldownClient("FSZ")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Electro.ElectroZ1
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

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Electro.ElectroZ2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_Z", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.125)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSZ = nil
	end)
end

function ElectroClient.X()
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

	local xRequire = Electro_Data.XRequire

	if localPlayer.PlayerStats.Melee.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "X", xRequire })
		return
	end

	if _G.Cooldowns.FSX then
		return
	end

	_G.Cooldowns.FSX = true
	v.X = true
	local cooldownClient = _G.GetCooldownClient("FSX")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local electroStomp = ReplicatedStorage.Chest.Animation.Electro.ElectroStomp

	if _G.CheckAwakeClient(localPlayer, "ElectroX") then
		electroStomp = ReplicatedStorage.Chest.Animation.Electro.clap
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = electroStomp,
		Speed = 1.25
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
		task.spawn(function()
			task.wait(0.3)

			if v.X then
				v2:AdjustSpeed(0)
			end
		end)

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:AdjustSpeed(1)
		bodyGyro:Destroy()
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_X", v3)

	if v2 then
		v2:Stop()
	end

	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "X", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.125)
		bodyVelocity:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSX = nil
	end)
end

function ElectroClient.C()
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

	local cRequire = Electro_Data.CRequire

	if localPlayer.PlayerStats.Melee.Value < cRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "C", cRequire })
		return
	end

	if _G.Cooldowns.FSC then
		return
	end

	_G.Cooldowns.FSC = true
	v.C = true
	local cooldownClient = _G.GetCooldownClient("FSC")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})

	if _G.CheckAwakeClient(localPlayer, "ElectroC") then
		_G.ClearBv(humanoidRootPart)
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(0, 1e999, 0)
		bodyVelocity.Parent = humanoidRootPart
		local moveDirection = humanoid.MoveDirection
		local _, _, _ = humanoidRootPart.CFrame:toOrientation()
		local cFrame = humanoidRootPart.CFrame
		local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + moveDirection)

		if moveDirection.magnitude == 0 then
			cframe = cFrame
		end

		local ray = Ray.new(cFrame.p, cframe.LookVector * 70)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local _ = raycastResult and raycastResult.Instance

		if not (raycastResult and raycastResult.Position) then
			local _ = ray.Origin + ray.Direction
		end

		local v2 = {
			MouseHit = _G.MouseHit,
			CF = cframe
		}
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
		end)
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_C", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "C", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Electro.ElectroC1
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
				Animation = ReplicatedStorage.Chest.Animation.Electro.ElectroC2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_C", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_C", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "C", cooldownClient)
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
		_G.Cooldowns.FSC = nil
	end)
end

function ElectroClient.V()
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

	local vRequire = Electro_Data.VRequire

	if localPlayer.PlayerStats.Melee.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "V", vRequire })
		return
	end

	if _G.Cooldowns.FSV then
		return
	end

	_G.Cooldowns.FSV = true
	v.V = true
	local cooldownClient = _G.GetCooldownClient("FSV")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Electro.ElectroStomp,
		Speed = 1.25
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
		task.wait(0.3)

		if v.V then
			v2:AdjustSpeed(0)
		end
	end)
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:AdjustSpeed(1)
		bodyGyro:Destroy()
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_V", v3)
	v2:Stop()
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "V", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.125)
		bodyVelocity:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSV = nil
	end)
end

function ElectroClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Electro_M1")
end

function ElectroClient.Deactive(p)
	v[p] = nil
end

return ElectroClient