local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local BuddhaBuddha_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.BuddhaBuddha_Data)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local BuddhaBuddhaClient = {}

function BuddhaBuddhaClient.Z()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Buddha") then
		return
	end

	local zRequire = BuddhaBuddha_Data.ZRequire

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

	if character:FindFirstChild("Buddha") then
		_G.UpdateCameraMaxZoom({
			Step = 100,
			Type = "Normal"
		})
	else
		_G.UpdateCameraMaxZoom({
			Step = 200,
			Type = "Normal"
		})
	end

	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_Z", v2)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFZ = nil
	end)
end

function BuddhaBuddhaClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Buddha") or not character:FindFirstChild("Buddha") then
		return
	end

	local xRequire = BuddhaBuddha_Data.XRequire

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
	local buddhaX1 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaX1
	local buddhaX2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaX2

	if _G.CheckAwakeClient(localPlayer, "BuddhaZ") and _G.CheckAwakeClient(localPlayer, "BuddhaX") then
		buddhaX1 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaX1Awake
		buddhaX2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaX2Awake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = buddhaX1,
		FadeTime = 0.4
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

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop(0.4)
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = buddhaX2,
			FadeTime = 0.4
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_X", v3)
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

function BuddhaBuddhaClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Buddha") or not character:FindFirstChild("Buddha") then
		return
	end

	local cRequire = BuddhaBuddha_Data.CRequire

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
	local buddhaC1 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaC1
	local buddhaC2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaC2

	if _G.CheckAwakeClient(localPlayer, "BuddhaZ") and _G.CheckAwakeClient(localPlayer, "BuddhaC") then
		buddhaC2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaC2Awake
	end

	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = buddhaC1,
		FadeTime = 0.4
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
	local v3 = true
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 20
		}, function()
			if not v3 then
				return true
			end

			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
		end)
	end)
	task.spawn(function()
		while task.wait() and v.C and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) do

		end

		v2:Stop(0.4)
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = buddhaC2,
			FadeTime = 0.4
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_C", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_C", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
	v3 = nil
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

function BuddhaBuddhaClient.V()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Buddha") or not character:FindFirstChild("Buddha") then
		return
	end

	local vRequire = BuddhaBuddha_Data.VRequire

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
	local buddhaV1 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaV1
	local buddhaV2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaV2
	local speed

	if _G.CheckAwakeClient(localPlayer, "BuddhaZ") and _G.CheckAwakeClient(localPlayer, "BuddhaV") then
		buddhaV1 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaV1Awake
		buddhaV2 = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaV2Awake
		speed = 1.15
	else
		speed = 1
	end

	local v3 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = buddhaV1,
		FadeTime = 0.4
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
	v3:Play(0.4)
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.V or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		if _G.CheckAwakeClient(localPlayer, "BuddhaV") and tick() - lastTime < 0.25 then
			task.wait(0.25)
		end

		v3:Stop(0.4)
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = buddhaV2,
			FadeTime = 0.4,
			Speed = speed
		})
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_V", v4)
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_V", v4)
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

function BuddhaBuddhaClient.E()
	if not _G.CheckAwakeClient(localPlayer, "BuddhaE") then
		return
	end

	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Buddha") or not character:FindFirstChild("Buddha") then
		return
	end

	local eRequire = BuddhaBuddha_Data.ERequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaE1,
		FadeTime = 0.4
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Name = "BuddhaBv"
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

			if not v.E or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		bodyVelocity.MaxForce = createVector(0, 1e999, 0)
		v2:Stop(0.4)
		local v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaE2,
			FadeTime = 0.4
		})
		local lastTime2 = os.clock()

		while task.wait() do
			local v4 = os.clock() - lastTime2
			local v5 = (1 - math.sin(1.5707963267948966 * math.min(v4 / 1, 1))) * 1000
			bodyVelocity.Velocity = Vector3.new(0, v5, 0)
			local v6 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

			if humanoid.MoveDirection.Magnitude > 0 then
				v6 = humanoid.MoveDirection * createVector(1, 0, 1)
			end

			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v6)

			if v4 > 1 then
				break
			end
		end

		task.delay(0.65, function()
			v3:Stop(0.4)
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.BuddhaBuddha.BuddhaE3,
				FadeTime = 0.4
			})
		end)
		bodyVelocity.Velocity = createVector(0, 0, 0)
		task.spawn(function()
			task.wait(0.05)
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			wait(0.2)
			bodyGyro:Destroy()
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_E", v4)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_E", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
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
		_G.Cooldowns.DFE = nil
	end)
end

function BuddhaBuddhaClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_BuddhaBuddha_M1", v2)
end

function BuddhaBuddhaClient.Deactive(p)
	v[p] = nil
end

return BuddhaBuddhaClient