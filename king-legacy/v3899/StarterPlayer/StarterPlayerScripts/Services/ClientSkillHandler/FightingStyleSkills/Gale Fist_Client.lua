local createVector = vector.create
local GaleFistClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityAtlas = require(ReplicatedStorage.Chest.Assets.Modules.EntityAtlas)
local v = {}
local GaleFist_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Styles["Gale Fist_Data"])

function FindNearestTarget(_, p, p2, max: number, value: number)
	local v2 = math.clamp((p2.Position - mouse.Hit.Position).Magnitude, 1, max)
	local _ = workspace.CurrentCamera.CFrame
	local position = (CFrame.new(p2.Position, mouse.Hit.Position) * CFrame.new(0, 0, -v2)).Position
	local magnitude = value or 100
	local v3 = nil

	for _, v4 in pairs(EntityAtlas.GetEntities()) do
		local humanoid = v4:FindFirstChild("Humanoid")

		if not humanoid then
			continue
		end

		local rootPart = humanoid.RootPart

		if not (rootPart and v4 ~= p and (rootPart.Position - position).Magnitude <= magnitude) then
			continue
		end

		magnitude = (rootPart.Position - position).Magnitude
		v3 = v4
	end

	return v3
end

function GaleFistClient.Z()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local zRequire = GaleFist_Data.ZRequire

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
		Animation = ReplicatedStorage.Chest.Animation.GaleFist.ZHold
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse2.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	local v3 = 300
	local v4 = 100
	task.spawn(function()
		local clone = nil

		while task.wait() do
			local parent = FindNearestTarget(nil, character, humanoidRootPart, v3, v4)

			if parent then
				if clone and not clone:IsDescendantOf(workspace) then
					clone:Destroy()
					clone = nil
				end

				if not clone then
					clone = ReplicatedStorage.Chest.Etc.GaleFistEffect.TargetGUI:Clone()
					clone.Enabled = true
				end

				local v6 = workspace.CurrentCamera.ViewportSize.Magnitude / 25
				clone.Size = UDim2.new(0, v6, 0, v6)

				if clone.Parent ~= parent then
					clone.Parent = parent
				end
			elseif clone then
				clone:Destroy()
				clone = nil
			end

			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime >= 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if clone then
			clone:Destroy()
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GaleFist.Z
		})
		local v5 = {
			MouseHit = _G.MouseHit,
			CameraCF = workspace.CurrentCamera.CFrame,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_Z", v5)
	end)
	local v5 = {
		MouseHit = _G.MouseHit,
		CameraCF = workspace.CurrentCamera.CFrame,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_Z", v5)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "Z", cooldownClient)
	mouse2.TargetFilter = nil
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

function GaleFistClient.X()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local xRequire = GaleFist_Data.XRequire

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
	tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GaleFist.XHold
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
	bodyGyro.Parent = humanoidRootPart
	mouse2.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GaleFist.XCast
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "X", cooldownClient)
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.125)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		wait(0.1)
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSX = nil
	end)
end

function GaleFistClient.C()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local cRequire = GaleFist_Data.CRequire

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
	_G.ClearBv(humanoidRootPart)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
	bodyGyro.Parent = humanoidRootPart
	mouse2.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GaleFist.CHold
	})
	task.spawn(function()
		local v3 = nil

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)

		if v3 then
			v3:Destroy()
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			CameraCF = workspace.CurrentCamera.CFrame,
			Type = "Up"
		}
		v2:Stop()
		local v5 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GaleFist.CCast,
			Speed = 0.5
		})
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_C", v4)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
		bodyPosition.MaxForce = createVector(0, 0, 0)
		bodyPosition.P = 20000
		bodyPosition.Parent = humanoidRootPart
		local lastTime = tick()
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
		local v6 = 425

		while true do
			task.wait()

			if tick() - lastTime >= 0.9 then
				break
			end

			local v7 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
			local v8 = humanoidRootPart.Position + createVector(0, -25, 0)

			if raycastResult and v7.Y < 0 then
				local position = raycastResult.Position
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, position.Y + 7, 0)
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
		end

		v5:AdjustSpeed(2)
		bodyVelocity.Velocity = createVector(0, 0, 0)
		task.spawn(function()
			wait(0.125)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
			bodyPosition:Destroy()
		end)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		CameraCF = workspace.CurrentCamera.CFrame,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_C", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "C", cooldownClient)
	humanoid.AutoRotate = true
	task.spawn(function()
		task.wait(1.1)
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSC = nil
	end)
end

function GaleFistClient.V()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local vRequire = GaleFist_Data.VRequire

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
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse2.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GaleFist.XHold
	})
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime >= 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GaleFist.XCast
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_V", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "V", cooldownClient)
	mouse2.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.125)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		task.wait(0.2)
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSV = nil
	end)
end

function GaleFistClient.B()
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

	local bRequire = GaleFist_Data.BRequire

	if localPlayer.PlayerStats.Melee.Value < bRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "B", bRequire })
		return
	end

	if character:GetAttribute("GaleAwakening") or not _G.CheckForcePowerClient(localPlayer, {
		Character = character,
		PowerType = "Gale Fist_Passives",
		Amount = 100
	}) or _G.Cooldowns.FSB then
		return
	end

	local cooldownClient = _G.GetCooldownClient("FSB")
	_G.Cooldowns.FSB = true
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_B", {})
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "B", cooldownClient)
	task.spawn(function()
		task.wait(cooldownClient)
		_G.Cooldowns.FSB = nil
	end)
end

function GaleFistClient.E()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local eRequire = GaleFist_Data.ERequire

	if localPlayer.PlayerStats.Melee.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "E", eRequire })
		return
	end

	if _G.Cooldowns.FSE then
		return
	end

	_G.Cooldowns.FSE = true
	local cooldownClient = _G.GetCooldownClient("FSE")
	local v2 = nil
	local v3 = nil
	local v4 = nil
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_E", {
		Type = "Down"
	})
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "E", cooldownClient)
	mouse2.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		if v4 then
			v4:Delete()
			v4 = nil
		end

		wait(0.1)

		if v2 then
			v2:Destroy()
			v2 = nil
		end

		if v3 then
			v3:Stop(0.2)
			v3 = nil
		end
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSE = nil
	end)
end

function GaleFistClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Gale Fist_M1")
end

function GaleFistClient.Deactive(p)
	v[p] = nil
end

return GaleFistClient