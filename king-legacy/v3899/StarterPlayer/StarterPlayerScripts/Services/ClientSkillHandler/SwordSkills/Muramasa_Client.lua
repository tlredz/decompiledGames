local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local v = {}
local Muramasa_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords.Muramasa_Data)
local MuramasaClient = {}

function MuramasaClient.Z()
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

	local zRequire = Muramasa_Data.ZRequire

	if localPlayer.PlayerStats.sword.Value < zRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Sword", "Z", zRequire })
		return
	end

	if _G.Cooldowns.SWZ then
		return
	end

	_G.Cooldowns.SWZ = true
	v.Z = true
	local cooldownClient = _G.GetCooldownClient("SWZ")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Muramasa.Z1
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	task.spawn(function()
		_G.shake("SmallestBump")
		wait()
		pcall(function()
			character["Real Sword"].Handle.Attachment.Sparks:Emit(2)
			character["Real Sword"].Handle.Attachment.Outline:Emit(1)
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.flame_floor:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.CFrame.p) * CFrame.new(0, -2.5, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript()
		end)
	end)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164100",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = humanoidRootPart
	sound:Play()
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v3 = nil
	task.spawn(function()
		while task.wait() do
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Muramasa_Z", v4)
		v2:Stop()
		v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Muramasa.Z2
		})
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Muramasa_Z", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		task.wait(0.3)

		if v3 then
			v3:Stop()
		end

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

function MuramasaClient.X()
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

	local xRequire = Muramasa_Data.XRequire

	if localPlayer.PlayerStats.sword.Value < xRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Sword", "X", xRequire })
		return
	end

	if _G.Cooldowns.SWX then
		return
	end

	_G.Cooldowns.SWX = true
	v.X = true
	local cooldownClient = _G.GetCooldownClient("SWX")
	local instanceDoingClient = _G.InstanceDoingClient({
		Parent = localPlayer
	})
	_G.ClearBv(humanoidRootPart)
	local lastTime = tick()
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Muramasa.X1
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	task.spawn(function()
		_G.shake("SmallestBump")
		wait()
		pcall(function()
			character["Real Sword"].Handle.Attachment.Sparks:Emit(2)
			character["Real Sword"].Handle.Attachment.Outline:Emit(1)
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.flame_floor:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.CFrame.p) * CFrame.new(0, -2.5, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript()
		end)
	end)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164100",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = humanoidRootPart
	sound:Play()
	mouse.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	local v3 = nil
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
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Muramasa_X", v4)
		v2:Stop()
		v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Muramasa.X2,
			Speed = 2
		})
	end)
	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Muramasa_X", v4)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "X", cooldownClient)
	mouse.TargetFilter = nil
	humanoid.AutoRotate = true
	task.spawn(function()
		wait(0.3)

		if v3 then
			v3:Stop()
		end

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

function MuramasaClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Muramasa_M1")
end

function MuramasaClient.Deactive(p)
	v[p] = nil
end

return MuramasaClient