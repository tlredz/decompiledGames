local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local v = {}
local IceIce_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.IceIce_Data)
local IceIceClient = {}

function IceIceClient.Z()
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

	local zRequire = IceIce_Data.ZRequire

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
	local iceZ1 = ReplicatedStorage.Chest.Animation.IceIce.IceZ1
	local iceZ2 = ReplicatedStorage.Chest.Animation.IceIce.IceZ2

	if _G.CheckAwakeClient(localPlayer, "IceZ") then
		iceZ1 = ReplicatedStorage.Chest.Animation.IceIce.IceZAwake1
		iceZ2 = ReplicatedStorage.Chest.Animation.IceIce.IceZAwake2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = iceZ1
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

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = iceZ2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_Z", v3)
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

function IceIceClient.X()
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

	local xRequire = IceIce_Data.XRequire

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
	local iceX = ReplicatedStorage.Chest.Animation.IceIce.IceX

	if _G.CheckAwakeClient(localPlayer, "IceX") then
		iceX = ReplicatedStorage.Chest.Animation.IceIce.IceXAwake1
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = iceX
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
		if _G.CheckAwakeClient(localPlayer, "IceX") then
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
				Animation = ReplicatedStorage.Chest.Animation.IceIce.IceXAwake2
			})
		else
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 then
					break
				end
			end

			v2:Stop()
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_X", v3)
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

function IceIceClient.C()
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

	local cRequire = IceIce_Data.CRequire

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
	local iceC1 = ReplicatedStorage.Chest.Animation.IceIce.IceC1
	local iceC2 = ReplicatedStorage.Chest.Animation.IceIce.IceC2

	if _G.CheckAwakeClient(localPlayer, "IceC") then
		iceC1 = ReplicatedStorage.Chest.Animation.IceIce.IceCAwake1
		iceC2 = ReplicatedStorage.Chest.Animation.IceIce.IceCAwake2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = iceC1
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
		if _G.CheckAwakeClient(localPlayer, "IceC") then
			if _G.CheckAwakeClient(localPlayer, "IceC") then
				local v3 = 0

				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

					if v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) then
						local v4 = v3 + 1
						v3 = v4 > 360 and 0 or v4
					else
						break
					end
				end
			end
		else
			local v3 = 0

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) then
					local v4 = v3 + 1
					v3 = v4 > 360 and 0 or v4
				else
					break
				end
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = iceC2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_C", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_C", v3)
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

function IceIceClient.V()
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

	local vRequire = IceIce_Data.VRequire

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
	local iceC1 = ReplicatedStorage.Chest.Animation.IceIce.IceC1
	local iceC2 = ReplicatedStorage.Chest.Animation.IceIce.IceC2

	if _G.CheckAwakeClient(localPlayer, "IceV") then
		iceC1 = ReplicatedStorage.Chest.Animation.IceIce.IceVAwake1
		iceC2 = ReplicatedStorage.Chest.Animation.IceIce.IceVAwake2
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = iceC1
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
		if _G.CheckAwakeClient(localPlayer, "IceV") then
			if _G.CheckAwakeClient(localPlayer, "IceV") then
				while task.wait() do
					bodyVelocity.Velocity = Vector3.new()
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

					if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
						break
					end
				end
			end
		else
			local v3 = 0

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if v.V and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) then
					local v4 = v3 + 1
					v3 = v4 > 360 and 0 or v4
				else
					break
				end
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = iceC2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_V", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_V", v3)
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

function IceIceClient.E()
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

	local eRequire = IceIce_Data.ERequire

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

	if _G.CheckAwakeClient(localPlayer, "IceE") then
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.IceIce.IceEAwake
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
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 300,
				Color = Color3.fromRGB(170, 255, 255)
			})
			math.clamp(humanoid.Health / humanoid.MaxHealth * 145, 65, 145)

			while task.wait() do
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 145, 65, 145)
				local v4 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -25, 0),
					raycastParams
				)
				local v5 = humanoidRootPart.Position + createVector(0, -25, 0)

				if raycastResult and v4.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
					v4 *= createVector(1, 0, 1)
				elseif v5.Y < -3.35 and v4.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = createVector(0, 14, 0)
					v4 *= createVector(1, 0, 1)
				else
					bodyVelocity.MaxForce = Vector3.new(
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.Z
					)
					bodyPosition.MaxForce = createVector(0, 0, 0)
				end

				bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4).LookVector * v3
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4)

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 300 or _G.CheckStunClient(localPlayer) then
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
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_E", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_E", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity.Velocity = Vector3.new()
			bodyPosition:Destroy()
			_G.PU:Dust(bodyVelocity, 0.01)
			bodyGyro:Destroy()
		end)
	else
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.IceIce.IceSurf
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(100000, 0, 100000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
		bodyGyro.P = 10000
		bodyGyro.CFrame = CFrame.new(
			humanoidRootPart.Position,
			humanoidRootPart.Position + currentCamera.CFrame.LookVector
		)
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			local currentCamera2 = workspace.CurrentCamera
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 30,
				Color = Color3.fromRGB(170, 255, 255)
			})

			while task.wait() do
				local v3 = math.rad(currentCamera2.CFrame.RightVector:Dot(humanoidRootPart.CFrame.LookVector) * 80)
				local v4 = math.clamp(humanoid.Health / humanoid.MaxHealth * 100, 65, 100)
				bodyGyro.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera2.CFrame.LookVector
				) * CFrame.Angles(0, 0, v3)
				bodyVelocity.Velocity = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera2.CFrame.LookVector * createVector(1, 0, 1)
				).LookVector * v4

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 30 or _G.CheckStunClient(localPlayer) then
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
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_E", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_IceIce_E", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyGyro:Destroy()
			bodyVelocity.Velocity = Vector3.new()
			wait(wait())
			bodyVelocity:Destroy()
		end)
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function IceIceClient.Deactive(p)
	v[p] = nil
end

return IceIceClient