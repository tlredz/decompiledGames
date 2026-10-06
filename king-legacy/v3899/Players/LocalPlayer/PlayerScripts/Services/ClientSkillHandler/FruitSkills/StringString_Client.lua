local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local v2 = 1
local StringString_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.StringString_Data)
local StringStringClient = {}

function StringStringClient.Z()
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

	local zRequire = StringString_Data.ZRequire

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
	tick()
	_G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.StringString.StringZ2
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
	local v3 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_Z", v3)
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

function StringStringClient.X()
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

	local xRequire = StringString_Data.XRequire

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
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.StringString.StringX1
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

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_X", v4)
		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.StringString.StringX2
		})
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_X", v4)
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

function StringStringClient.C()
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

	local cRequire = StringString_Data.CRequire

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
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.StringString.StringC1
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

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 3 then
				break
			end
		end

		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.StringString.StringC2
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_C", v4)
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

function StringStringClient.V()
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

	local vRequire = StringString_Data.VRequire

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
	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.StringString.StringV1
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

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_V", v4)
		v3:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.StringString.StringV2
		})
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_V", v4)
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

function StringStringClient.E()
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

	local eRequire = StringString_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

	if _G.Cooldowns.DFE then
		return
	end

	local stringPathAmount = localPlayer:FindFirstChild("StringPathAmount")

	if not stringPathAmount or stringPathAmount.Value < 1 then
		return
	end

	local _, v3, _ = CFrame.new(humanoidRootPart.CFrame.p, _G.MouseHit.p):ToOrientation()
	local lookcf = CFrame.new(humanoidRootPart.CFrame.p) * CFrame.fromOrientation(0, v3, 0)
	character:FindFirstChild("LeftGripAttachment", true)
	local tocf = lookcf * CFrame.new(0, 85, -125)

	local function swing(cFrame)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Parent = humanoidRootPart
		bodyVelocity.MaxForce = createVector(10000, 0, 10000)
		bodyVelocity.Velocity = CFrame.new(humanoidRootPart.CFrame.p, cFrame.p).LookVector * math.clamp(
			humanoid.Health / humanoid.MaxHealth * 185,
			50,
			185
		)
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 100000, 0)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		bodyGyro.CFrame = cFrame
		_G.PU:Dust(bodyGyro, 0.65)
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 1.5,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p)
				local v6 = math.floor(p * 179)
				bodyVelocity.MaxForce = Vector3.new(1, math.sin((math.rad(v6))), 1) * 10000
			end)
		end)
		_G.PU:Dust(bodyVelocity, 0.8)
	end

	v2 += 1

	if v2 > 4 then
		v2 = 1
	end

	task.spawn(function()
		wait()
		swing(tocf * CFrame.new(0, -25, 0))
	end)
	_G.Cooldowns.DFE = true
	v.E = true
	local cooldownClient = _G.GetCooldownClient("DFE")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	local v6 = {
		ReplicatedStorage.Chest.Animation.StringString.Left1,
		ReplicatedStorage.Chest.Animation.StringString.Right2,
		ReplicatedStorage.Chest.Animation.StringString.Left2,
		ReplicatedStorage.Chest.Animation.StringString.Right1
	}
	_G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = v6[v2]
	})
	local swing2 = {
		Player = localPlayer,
		tocf = tocf,
		startatt = character:FindFirstChild(({
			"LeftGripAttachment",
			"RightGripAttachment",
			"LeftGripAttachment",
			"RightGripAttachment"
		})[v2], true),
		lookcf = lookcf
	}
	task.delay(60, function()
		table.clear(swing2)
	end)
	ReplicatedStorage.Chest.Remotes.Bindables.PolyEvent:Fire("string_e", swing2)
	_G.ClearBv(humanoidRootPart)
	local v8 = {
		MouseHit = _G.MouseHit,
		Type = "Down",
		Swing = swing2
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_E", v8)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFE = nil
	end)
end

function StringStringClient.M1()
	if _G.CheckAwakeClient(localPlayer, "String") then
		local v3 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_StringString_M1", v3)
	end
end

function StringStringClient.Deactive(p)
	v[p] = nil
end

return StringStringClient