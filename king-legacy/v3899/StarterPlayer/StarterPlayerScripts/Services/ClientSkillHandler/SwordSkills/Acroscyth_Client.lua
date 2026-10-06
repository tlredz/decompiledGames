local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local Acroscyth_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords.Acroscyth_Data)
local AcroscythClient = {}

function AcroscythClient.Z()
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

	local zRequire = Acroscyth_Data.ZRequire

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
	local v2 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Acroscyth.ZHold
	})
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 10
		}, function()
			if _G.MouseHit then
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)
				bodyVelocity.Velocity = Vector3.new()
			end

			if v.Z and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or _G.CheckStunClient(localPlayer)) then
				return
			else
				return true
			end
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

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acroscyth_Z", v3)
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

	local mouseHit = _G.MouseHit
	v2:AdjustSpeed(0)
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acroscyth_Z", {
		MouseHit = mouseHit,
		Type = "Down"
	})
	game.ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
	v2:Stop()
	_G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.Acroscyth.Z
	})
	spawn(function()
		wait(0.1)
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

function AcroscythClient.X()
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

	local xRequire = Acroscyth_Data.XRequire

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
		Animation = ReplicatedStorage.Chest.Animation.Acroscyth.ZHold
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
		PeodizService.HeartbeatWait({
			Time = 10
		}, function()
			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if v.X and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) then
				return
			else
				return true
			end
		end)
		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.Acroscyth.X,
			Speed = 2
		})
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

		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acroscyth_X", v3)
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

	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acroscyth_X", v3)
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

function AcroscythClient.M1()
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acroscyth_M1")
end

function AcroscythClient.Deactive(p)
	v[p] = nil
end

return AcroscythClient