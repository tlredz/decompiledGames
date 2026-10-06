local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local Cyborg_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Styles.Cyborg_Data)
local CyborgClient = {}

function CyborgClient.Z()
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

	local zRequire = Cyborg_Data.ZRequire

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
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 1e999, 0)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 0, 1e999)
	local prototypeFolder = character:FindFirstChild("PrototypeFolder")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_prototype_mode()
		return not prototypeFolder and "Melee" or prototypeFolder.Value
	end

	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v2

	if _G.CheckAwakeClient(localPlayer, "CyborgZ") then
		bodyVelocity.Parent = humanoidRootPart

		if get_prototype_mode() == "Melee" then
			v2 = nil
		else
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgZV2
			})
		end
	else
		v2 = nil
	end

	if get_prototype_mode() == "Melee" then
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	end

	task.spawn(function()
		while task.wait() do
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 4 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_Z", v3)

		if v2 then
			v2:Stop()
		end
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_Z", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.3)
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

function CyborgClient.X()
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

	local xRequire = Cyborg_Data.XRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgX1
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
			Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgX2
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "X", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		if _G.CheckAwakeClient(localPlayer, "CyborgX") then
			bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p).LookVector * -90
		end

		wait(0.125)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSX = nil
	end)
end

function CyborgClient.C()
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

	local cRequire = Cyborg_Data.CRequire

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
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgC1
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
		local v3 = _G.CheckAwakeClient(localPlayer, "CyborgX") and 3 or 10

		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or v3 < tick() - lastTime or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgC2
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_C", v4)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_C", v3)
	v2:Stop()
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "C", cooldownClient)
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
		_G.Cooldowns.FSC = nil
	end)
end

function CyborgClient.V()
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

	local vRequire = Cyborg_Data.VRequire

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

	if _G.CheckAwakeClient(localPlayer, "CyborgV") then
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
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_V", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_V", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "V", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			wait(0.125)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
	else
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Cyborg.CyborgV
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
			task.wait(0.3)

			if not v.V then
				return
			end

			v2:AdjustSpeed(0)
		end)
		local clone = ReplicatedStorage.Chest.Etc.Overload:Clone()
		clone.Parent = localPlayer.PlayerGui

		if localPlayer.PlayerGui:FindFirstChild("VenomTimer") then
			clone.Frame.Position = UDim2.new(0.916, 0, 0.52, 0)
		end

		local total = 0
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
				local v3 = math.max(0, total / 300)
				clone.Frame.Position = UDim2.new(
					clone.Frame.Position.X.Scale,
					math.random(-v3, v3),
					clone.Frame.Position.Y.Scale,
					math.random(-v3, v3)
				)
				total += 4
				local v4 = math.floor(total / 10)
				local uDim = UDim2.new(math.clamp(v4 / 90, 0, 1) * 0.88, 0, 0.441, 0)
				clone.Frame.Percentage.Text = v4 .. "%"
				game.TweenService:Create(clone.Frame.Bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Size = uDim
				}):Play()

				if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or total >= 900 or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_V", v3)
			v2:AdjustSpeed(1.25)
			v2.TimePosition = 0.7
			clone:Destroy()
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_V", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "V", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			wait(0.125)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSV = nil
	end)
end

function CyborgClient.E()
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

	local eRequire = Cyborg_Data.ERequire

	if localPlayer.PlayerStats.Melee.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Melee", "E", eRequire })
		return
	end

	if _G.Cooldowns.FSE then
		return
	end

	local v2 = _G.CheckAwakeClient(localPlayer, "CyborgE") and true or false

	if (humanoid.Health >= humanoid.MaxHealth or humanoid.Health == humanoid.MaxHealth) and not v2 then
		return
	end

	_G.Cooldowns.FSE = true
	v.E = true
	local cooldownClient = _G.GetCooldownClient("FSE")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(100000, 0, 100000)
	bodyVelocity.Parent = humanoidRootPart
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		if v2 then
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 5 or _G.CheckStunClient(localPlayer) then
					break
				end
			end
		else
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()

				if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 5 or humanoid.Health >= humanoid.MaxHealth or humanoid.Health == humanoid.MaxHealth or _G.CheckStunClient(localPlayer) then
					break
				end
			end
		end

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_E", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_E", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", "E", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		bodyVelocity:Destroy()
	end)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.FSE = nil
	end)
end

function CyborgClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("FS_Cyborg_M1")
end

function CyborgClient.Deactive(p)
	v[p] = nil
end

return CyborgClient