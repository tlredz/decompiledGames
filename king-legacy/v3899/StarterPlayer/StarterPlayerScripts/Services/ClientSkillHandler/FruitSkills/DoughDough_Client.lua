local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local DoughDough_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.DoughDough_Data)
local DoughDoughClient = {}

function DoughDoughClient.Z()
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

	local zRequire = DoughDough_Data.ZRequire

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
	local Z1 = ReplicatedStorage.Chest.Animation.DoughDough.Z1
	local Z2 = ReplicatedStorage.Chest.Animation.DoughDough.Z2

	if _G.CheckAwakeClient(localPlayer, "DoughZ") then
		Z1 = ReplicatedStorage.Chest.Animation.DoughDough.Z1Awake
		Z2 = ReplicatedStorage.Chest.Animation.DoughDough.Z2Awake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = Z1
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
			Animation = Z2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_Z", v3)
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

function DoughDoughClient.X()
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

	local xRequire = DoughDough_Data.XRequire

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
	local Z1 = ReplicatedStorage.Chest.Animation.DoughDough.Z1
	local Z2 = ReplicatedStorage.Chest.Animation.DoughDough.Z2

	if _G.CheckAwakeClient(localPlayer, "DoughX") then
		Z1 = ReplicatedStorage.Chest.Animation.DoughDough.X1Awake
		Z2 = ReplicatedStorage.Chest.Animation.DoughDough.X2Awake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = Z1
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
			Animation = Z2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_X", v3)
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

function DoughDoughClient.C()
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

	local cRequire = DoughDough_Data.CRequire

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
	bodyGyro.MaxTorque = createVector(0, 1e999, 1)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local dough2 = ReplicatedStorage.Chest.Animation.DoughDough.Dough2
	local fadeTime

	if _G.CheckAwakeClient(localPlayer, "DoughC") then
		dough2 = ReplicatedStorage.Chest.Animation.DoughDough.C1Awake
		fadeTime = 0.1
	else
		fadeTime = 0.25
	end

	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = dough2,
		FadeTime = fadeTime
	})
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v3:Stop()

		if _G.CheckAwakeClient(localPlayer, "DoughC") then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DoughDough.C2Awake
			})
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_C", v4)
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

function DoughDoughClient.V()
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

	local vRequire = DoughDough_Data.VRequire

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
	local dough3 = ReplicatedStorage.Chest.Animation.DoughDough.Dough3
	local fadeTime

	if _G.CheckAwakeClient(localPlayer, "DoughV") then
		dough3 = ReplicatedStorage.Chest.Animation.DoughDough.VAwake
		fadeTime = 0.1
	else
		fadeTime = 0.25
	end

	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = dough3,
		FadeTime = fadeTime
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

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 5 then
				break
			end
		end

		v3:Stop()
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_V", {
			Type = "Up"
		})
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_V", v4)
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

function DoughDoughClient.B()
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

	local bRequire = DoughDough_Data.BRequire

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

	if _G.CheckAwakeClient(localPlayer, "DoughB") then
		local currentCamera = workspace.CurrentCamera
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1000000, 0, 1000000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 1e999)
		bodyGyro.CFrame = CFrame.new(
			humanoidRootPart.Position,
			humanoidRootPart.Position + currentCamera.CFrame.LookVector
		)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local part = Instance.new("Part")
		part.Anchored = true
		part.Transparency = 1
		part.Size = createVector(50, 5, 50)
		part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
		part.Parent = workspace.Effects
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 3,
				Color = Color3.fromRGB(255, 246, 201)
			})

			while task.wait() do
				local v2 = math.rad(currentCamera.CFrame.RightVector:Dot(humanoidRootPart.CFrame.LookVector) * 90)
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 245, 215, 245)
				bodyGyro.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector
				) * CFrame.Angles(0, 0, v2)
				bodyVelocity.Velocity = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector * createVector(1, 0, 1)
				).LookVector * v3
				bodyVelocity.MaxForce = createVector(1000000, -50000, 1000000)
				part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { workspace.Effects, character, workspace.CharacterWorkshop }
				local ray = Ray.new(humanoidRootPart.CFrame.p, humanoidRootPart.CFrame.LookVector * 10)
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

				if not (raycastResult and raycastResult.Position) then
					local _ = ray.Origin + ray.Direction
				end

				if raycastResult then
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Velocity = humanoidRootPart.CFrame.UpVector * v3 / 1.5
				end

				if not v.B or character:GetAttribute("DoingCombo") or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.MaxTorque = createVector(0, 1000000, 0)
			bodyGyro.CFrame = humanoidRootPart.CFrame
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_B", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_B", v2)
		part:Destroy()
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro:Destroy()
			wait()
			bodyVelocity:Destroy()
		end)
	else
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DoughDough.DoughB1,
			FadeTime = 0.25
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

			v2:Stop(1)
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_B", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_B", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "B", cooldownClient)
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
		_G.Cooldowns.DFB = nil
	end)
end

function DoughDoughClient.E()
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

	local eRequire = DoughDough_Data.ERequire

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
	local currentCamera = workspace.CurrentCamera

	if _G.CheckAwakeClient(localPlayer, "DoughE") then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1000000, 0, 1000000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 1e999)
		bodyGyro.CFrame = CFrame.new(
			humanoidRootPart.Position,
			humanoidRootPart.Position + currentCamera.CFrame.LookVector
		)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local part = Instance.new("Part")
		part.Anchored = true
		part.Transparency = 1
		part.Size = createVector(50, 5, 50)
		part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
		part.Parent = workspace.Effects
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 100,
				Color = Color3.fromRGB(255, 246, 201)
			})
			character:SetAttribute("SpeedLine", true)

			while task.wait() do
				local v2 = math.rad(currentCamera.CFrame.RightVector:Dot(humanoidRootPart.CFrame.LookVector) * 90)
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 225, 160, 225)
				bodyGyro.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector
				) * CFrame.Angles(0, 0, v2)
				bodyVelocity.Velocity = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector * createVector(1, 0, 1)
				).LookVector * v3
				bodyVelocity.MaxForce = createVector(1000000, -50000, 1000000)
				part.Position = Vector3.new(humanoidRootPart.Position.X, -6.1, humanoidRootPart.Position.Z)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { workspace.Effects, character, workspace.CharacterWorkshop }
				local ray = Ray.new(humanoidRootPart.CFrame.p, humanoidRootPart.CFrame.LookVector * 10)
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

				if not (raycastResult and raycastResult.Position) then
					local _ = ray.Origin + ray.Direction
				end

				if raycastResult then
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Velocity = humanoidRootPart.CFrame.UpVector * v3 / 1.5
				end

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 100 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			character:SetAttribute("SpeedLine", false)
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_E", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_E", v2)
		part:Destroy()
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			bodyGyro:Destroy()
			bodyVelocity.Velocity = Vector3.new()
			wait()
			bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
			bodyVelocity.Velocity = humanoidRootPart.CFrame.UpVector * 400
			task.wait(0.1)
			bodyVelocity.MaxForce = createVector(1000000, -120000, 1000000)
			_G.PU:Dust(bodyVelocity, 0.25)
		end)
	else
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(1000000, 0, 1000000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 1e999, 1e999)
		bodyGyro.CFrame = CFrame.new(
			humanoidRootPart.Position,
			humanoidRootPart.Position + currentCamera.CFrame.LookVector
		)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 100,
				Color = Color3.fromRGB(255, 246, 201)
			})

			while task.wait() do
				local v2 = math.rad(currentCamera.CFrame.RightVector:Dot(humanoidRootPart.CFrame.LookVector) * 80)
				local v3 = math.clamp(humanoid.Health / humanoid.MaxHealth * 150, 65, 150)
				bodyGyro.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector
				) * CFrame.Angles(0, 0, v2)
				bodyVelocity.Velocity = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + currentCamera.CFrame.LookVector * createVector(1, 0, 1)
				).LookVector * v3

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 100 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_E", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DoughDough_E", v2)
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

function DoughDoughClient.Deactive(p)
	v[p] = nil
end

return DoughDoughClient