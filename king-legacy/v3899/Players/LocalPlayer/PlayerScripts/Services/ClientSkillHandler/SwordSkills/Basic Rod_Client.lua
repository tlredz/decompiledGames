local createVector = vector.create
local BasicRodClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Chest.Modules.PeodizService)
local v = {}
local BasicRod_Data = require(game.ReplicatedStorage.Chest.Modules.SkillData.Swords["Basic Rod_Data"])

function BasicRodClient.Z()
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

	local zRequire = BasicRod_Data.ZRequire

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
		Animation = "rbxassetid://72840320764706"
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

			if not v.Z or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v2:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = "rbxassetid://119880663127256"
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_Z", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_Z", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
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
		_G.Cooldowns.SWZ = nil
	end)
end

function BasicRodClient.X()
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

	local xRequire = BasicRod_Data.XRequire

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
		Animation = "rbxassetid://84968854022818"
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
			Animation = "rbxassetid://96929920707061"
		})
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_X", v3)
	end)
	local v3 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_X", v3)
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

function BasicRodClient.M1()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() or character:GetAttribute("BeginFishing") then
		return
	end

	if character:GetAttribute("Fishing") then
		if character:GetAttribute("Fishing") then
			local v2 = {
				StopFishing = true,
				MouseHit = _G.MouseHit
			}
			_G.StopAnimationClient(humanoid, {
				FindingFishHold = true,
				["Fishing Waiting"] = true
			})
			_G.PU.PlayOneShotAnim(humanoid, ReplicatedStorage.Chest.Animation["Basic Rod"]["Fishing Pull Failed"])
			local sound = _G.PU.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://135208564477149",
				Volume = 0.25
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = humanoidRootPart
			sound:Play()
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
				Message = "Cancel Fishing",
				DebrisTime = 3,
				Color = Color3.fromRGB(255, 125, 125),
				Name = "Cancel Fishing",
				Overlay = true
			})
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_M1", v2)
		end
	else
		if _G.Cooldowns.BeginFishing then
			return
		end

		_G.Cooldowns.BeginFishing = true
		v.M1 = true
		local charge = 0
		local v3 = math.random(150, 225)
		local clone = ReplicatedStorage.Chest.Etc.Fishing.FishingChargeUI:Clone()
		clone.Adornee = character
		clone.Parent = character

		local function UpdateBar()
			local v4 = math.clamp(charge / 100, 0, 1)
			local color = Color3.fromRGB(255 - math.floor(v4 * 255), math.floor(v4 * 255), 0)
			clone.Background.Bar.Size = UDim2.fromScale(1, v4)
			clone.Background.Bar.BackgroundColor3 = color
			local v5 = math.floor(v4 * 100)
			clone.Background.TextLabel.Text = tostring(v5)
		end

		UpdateBar()
		local v4 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation["Basic Rod"].HoldingBefore
		})
		local lastTime = tick()
		local v5 = 1

		while v.M1 and not (humanoid.Health <= 0) and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) do
			charge = math.clamp(charge + v5 * RunService.Heartbeat:Wait() * v3, 0, 100)

			if charge == 0 or charge == 100 then
				v5 = -v5
			end

			UpdateBar()
		end

		if v4 and v4.IsPlaying then
			v4:Stop()
		end

		local v6 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation["Basic Rod"].Cast1,
			Speed = 2
		})
		local v7 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation["Basic Rod"]["Fishing Waiting"]
		})
		task.wait(0.25)
		task.delay(0.5, function()
			clone:Destroy()
		end)
		local v8 = {
			Charge = charge,
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Basic Rod_M1", v8)

		if v7 and v7.IsPlaying then
			v7:Stop()
		end

		if v6 and v6.IsPlaying then
			v6:Stop(0.5)
		end

		task.delay(1, function()
			_G.Cooldowns.BeginFishing = nil
		end)
	end
end

function BasicRodClient.Deactive(p)
	v[p] = nil
end

return BasicRodClient