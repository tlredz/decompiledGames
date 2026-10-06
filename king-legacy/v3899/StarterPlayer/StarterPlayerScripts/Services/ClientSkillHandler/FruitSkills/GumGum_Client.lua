local createVector = vector.create
local GumGumClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local GumGum_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.GumGum_Data)

function GumGumClient.Z()
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

	local zRequire = GumGum_Data.ZRequire

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
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	local axe1 = ReplicatedStorage.Chest.Animation.GumGum.Axe1
	local axe2 = ReplicatedStorage.Chest.Animation.GumGum.Axe2

	if character.SecondForm.Value then
		axe1 = ReplicatedStorage.Chest.Animation.GumGum.RedHawk1
		axe2 = ReplicatedStorage.Chest.Animation.GumGum.RedHawk2
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	elseif character.ThirdForm.Value then
		axe1 = ReplicatedStorage.Chest.Animation.GumGum.Pistol1
		axe2 = ReplicatedStorage.Chest.Animation.GumGum.Pistol2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = axe1
	})
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		local highlight = nil

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if character.ThirdForm.Value then
				local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 1, 200)
				local v4 = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v3)
				local v5 = FindNearTarget(v4.Position, humanoid)

				if v5 then
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.FillTransparency = 0.15
					end

					highlight.Adornee = v5
					highlight.Parent = v5
				elseif highlight then
					highlight:Destroy()
					highlight = nil
				end
			end

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if highlight then
			highlight:Destroy()
		end

		if not character.ThirdForm.Value then
			if character.SecondForm.Value then
				if tick() - lastTime < 0.1 then
					task.wait(0.1)
				end
			elseif tick() - lastTime < 0.25 then
				task.wait(0.25)
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = axe2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_Z", v3)
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

function GumGumClient.X()
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

	local xRequire = GumGum_Data.XRequire

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
	local bazooka1 = ReplicatedStorage.Chest.Animation.GumGum.Bazooka1
	local bazooka2 = ReplicatedStorage.Chest.Animation.GumGum.Bazooka2

	if character.SecondForm.Value then
		bazooka1 = ReplicatedStorage.Chest.Animation.GumGum.JetBazooka1
		bazooka2 = ReplicatedStorage.Chest.Animation.GumGum.JetBazooka2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = bazooka1
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

		if tick() - lastTime < 0.15 then
			task.wait(0.15)
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = bazooka2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_X", v3)
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

function GumGumClient.C()
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

	local cRequire = GumGum_Data.CRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GumGum.JetGatling
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
	local v3 = character.ThirdForm.Value and 3 or 5
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not humanoid.Sit then
				if v3 < tick() - lastTime or _G.CheckStunClient(localPlayer) then
					break
				end
			else
				break
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		v2:Stop()
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_C", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		bodyVelocity.Velocity = Vector3.new()
		_G.PU:Dust(bodyVelocity, 0.01)
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

function GumGumClient.V()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if localPlayer.PlayerStats.DF.Value < GumGum_Data.VRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
			"Stats Require",
			{ "Power Fruit", "V", GumGum_Data.VRequire }
		)
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or _G.Cooldowns.DFV then
		return
	end

	_G.Cooldowns.DFV = true
	local cooldownClient = _G.GetCooldownClient("DFV")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})

	if not character.SecondForm.Value or localPlayer.PlayerStats.GumGear4Th.Value ~= "Snakeman" then
		local _ = character.SecondForm.Value or character.ThirdForm.Value
	end

	if character.SecondForm.Value or character.ThirdForm.Value then
		if character.SecondForm.Value then
			humanoid.AutoRotate = false
			_G.ClearBv(humanoidRootPart)
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.GumGum.SecondForm
			})
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
			bodyVelocity.Parent = humanoidRootPart
			_G.PU:Dust(bodyVelocity, 1.25)
		end
	else
		humanoid.AutoRotate = false
		_G.ClearBv(humanoidRootPart)
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GumGum.SecondForm
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Parent = humanoidRootPart
		_G.PU:Dust(bodyVelocity, 1.25)
	end

	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_V", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
	humanoid.AutoRotate = true
	spawn(function()
		instanceDoingClient:Delete()
	end)
	spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFV = nil
	end)
end

function GumGumClient.E()
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

	local eRequire = GumGum_Data.ERequire

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
	task.spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local v2 = 100
		local color = Color3.fromRGB(255, 216, 197)
		local UFO = ReplicatedStorage.Chest.Animation.GumGum.UFO

		if character.SecondForm.Value then
			color = Color3.fromRGB(255, 170, 255)
			v2 = 125
		elseif character.ThirdForm.Value then
			color = Color3.fromRGB(170, 0, 0)
			UFO = ReplicatedStorage.Chest.Animation.FlameFlame.FlameFly
			v2 = 145
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 100,
			Color = color
		})
		local speed = v2 / 100
		local v4 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = UFO,
			Speed = speed
		})
		math.clamp(humanoid.Health / humanoid.MaxHealth * v2, v2 / 1.6, v2)

		while task.wait() do
			local v5 = math.clamp(humanoid.Health / humanoid.MaxHealth * v2, v2 / 1.6, v2)
			local v6 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -25, 0), raycastParams)
			local v7 = humanoidRootPart.Position + createVector(0, -25, 0)

			if raycastResult and v6.Y < 0 then
				local position = raycastResult.Position
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
				v6 *= createVector(1, 0, 1)
			elseif v7.Y < -3.35 and v6.Y < 0 then
				bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
				bodyPosition.MaxForce = createVector(0, 10000000, 0)
				bodyPosition.Position = createVector(0, 14, 0)
				v6 *= createVector(1, 0, 1)
			else
				bodyVelocity.MaxForce = Vector3.new(
					bodyVelocity.MaxForce.X,
					bodyVelocity.MaxForce.X,
					bodyVelocity.MaxForce.Z
				)
				bodyPosition.MaxForce = createVector(0, 0, 0)
			end

			bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v6).LookVector * v5
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v6)

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 100 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
		})
		v4:Stop()
		local v5 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_E", v5)
	end)
	local v2 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_E", v2)
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

function GumGumClient.M1()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or _G.Cooldowns.DFM1 then
		return
	end

	_G.Cooldowns.DFM1 = true
	v.M1 = true
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local pistol1 = ReplicatedStorage.Chest.Animation.GumGum.Pistol1
	local pistol2 = ReplicatedStorage.Chest.Animation.GumGum.Pistol2

	if character.SecondForm.Value then
		pistol1 = ReplicatedStorage.Chest.Animation.GumGum.JetPistol1
		pistol2 = ReplicatedStorage.Chest.Animation.GumGum.JetPistol2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = pistol1
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
		local highlight = nil

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if character.ThirdForm.Value then
				local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.p).Magnitude, 1, 150)
				local v4 = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p) * CFrame.new(0, 0, -v3)
				local v5 = FindNearTarget(v4.Position, humanoid)

				if v5 then
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.FillTransparency = 0.15
					end

					highlight.Adornee = v5
					highlight.Parent = v5
				elseif highlight then
					highlight:Destroy()
					highlight = nil
				end
			end

			if not v.M1 or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 then
				break
			end
		end

		for _, v3 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if v3.Name == "Pistol2" then
				v3.Priority = Enum.AnimationPriority.Action
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = pistol2,
			Priority = Enum.AnimationPriority.Action2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}

		if highlight then
			highlight:Destroy()
		end

		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_M1", v3)
	end)
	local v3 = {
		MouseHit = _G.GetMouse(),
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GumGum_M1", v3)
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
		wait(2)
		_G.Cooldowns.DFM1 = nil
	end)
end

function FindNearTarget(p, p2)
	local magnitude = 25
	local v2 = nil

	for _, descendant in pairs(workspace:GetDescendants()) do
		local humanoid = descendant:FindFirstChild("Humanoid")

		if not (humanoid and humanoid ~= p2) then
			continue
		end

		local rootPart = humanoid.RootPart

		if not rootPart or humanoid.Health <= 0 then
			continue
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(descendant)

		if playerFromCharacter and _G.CheckAllyClient(localPlayer, playerFromCharacter) or not ((rootPart.Position - p).Magnitude <= magnitude) then
			continue
		end

		magnitude = (rootPart.Position - p).Magnitude
		v2 = descendant
	end

	return v2
end

function GumGumClient.Deactive(p)
	v[p] = nil
end

return GumGumClient