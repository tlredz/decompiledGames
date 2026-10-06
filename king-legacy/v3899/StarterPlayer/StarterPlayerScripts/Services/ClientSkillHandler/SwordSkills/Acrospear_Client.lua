local createVector = vector.create
local AcrospearClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local Acrospear_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords.Acrospear_Data)

function AcrospearClient.Z()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local zRequire = Acrospear_Data.ZRequire

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
	humanoid.AutoRotate = false
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(100000000, 100000000, 100000000)
	bodyGyro.P = 25000
	bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position)
	bodyGyro.Parent = humanoidRootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.Parent = humanoidRootPart
	local flag = true
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Acrospear.IntroZ
	})
	local v3 = nil
	task.spawn(function()
		task.wait(v2.Length)

		if flag then
			v3 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.Acrospear.LoopZ
			})
		end
	end)
	task.spawn(function()
		tick()

		while task.wait() do
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
			bodyVelocity.Velocity = Vector3.new()

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		flag = nil
		local UserInputService = game:GetService("UserInputService")
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local _ = CFrame.new(viewportPointToRay.Origin, viewportPointToRay.Origin + viewportPointToRay.Direction) * CFrame.new(
			0,
			0,
			-350
		)
		local UserInputService2 = game:GetService("UserInputService")

		if UserInputService2.TouchEnabled then
			local _ = _G.MouseHit
		end

		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrospear_Z", v4)
	end)
	local UserInputService = game:GetService("UserInputService")
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local _ = CFrame.new(viewportPointToRay.Origin, viewportPointToRay.Origin + viewportPointToRay.Direction) * CFrame.new(
		0,
		0,
		-350
	)
	local UserInputService2 = game:GetService("UserInputService")

	if UserInputService2.TouchEnabled then
		local _ = _G.MouseHit
	end

	local v4 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrospear_Z", v4)
	v2:Stop()

	if v3 then
		v3:Stop()
	end

	game.ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
	task.spawn(function()
		wait(0.3)
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
		humanoid.AutoRotate = true
	end)
	spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.SWZ = nil
	end)
	spawn(function()
		instanceDoingClient:Delete()
	end)
end

function AcrospearClient.X()
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

	local xRequire = Acrospear_Data.XRequire

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
		Animation = ReplicatedStorage.Chest.Animation.Acrospear["X Hold"]
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

			if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Acrospear["X Cast"]
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrospear_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrospear_X", v3)
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

function AcrospearClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrospear_M1")
end

function AcrospearClient.Deactive(p)
	v[p] = nil
end

return AcrospearClient