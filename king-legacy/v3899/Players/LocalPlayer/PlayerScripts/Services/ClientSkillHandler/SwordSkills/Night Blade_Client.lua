local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local NightBlade_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords["Night Blade_Data"])
local NightBladeClient = {}

function NightBladeClient.Z()
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

	local zRequire = NightBlade_Data.ZRequire

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
	local znotawake = ReplicatedStorage.Chest.Animation["Night Blade"].Znotawake

	if _G.CheckAwakeClient(localPlayer, "NightBladeZ") then
		znotawake = ReplicatedStorage.Chest.Animation["Night Blade"].ZAwakeLoop
	end

	local v2

	if _G.CheckAwakeClient(localPlayer, "NightBladeZ") then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 100000, 0)
		bodyGyro.P = 20000
		bodyGyro.Parent = humanoidRootPart
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = znotawake
		})
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
				Animation = ReplicatedStorage.Chest.Animation["Night Blade"].ZAwake
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_Z", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_Z", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		task.spawn(function()
			wait(0.25)
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end)
	else
		v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = znotawake,
			Speed = 1.5
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
		task.spawn(function()
			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

				if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 5 then
					break
				end
			end

			if v2 then
				v2:Stop()
			end

			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_Z", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_Z", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
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
		_G.Cooldowns.SWZ = nil
	end)
end

function NightBladeClient.X()
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

	local xRequire = NightBlade_Data.XRequire

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
	local xLoop = ReplicatedStorage.Chest.Animation["Night Blade"].XLoop
	local X = ReplicatedStorage.Chest.Animation["Night Blade"].X

	if _G.CheckAwakeClient(localPlayer, "NightBladeX") then
		xLoop = ReplicatedStorage.Chest.Animation["Night Blade"].XAwakeLoop
		X = ReplicatedStorage.Chest.Animation["Night Blade"].XAwake
	end

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = xLoop
	})
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
			Animation = X
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "X", cooldownClient)
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
		_G.Cooldowns.SWX = nil
	end)
end

function NightBladeClient.M1()
	local mouse = localPlayer:GetMouse()
	mouse.TargetFilter = workspace.Effects
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Night Blade_M1", v2)
	mouse.TargetFilter = nil
end

function NightBladeClient.Deactive(p)
	v[p] = nil
end

return NightBladeClient