local createVector = vector.create
local AcrodaggerClient = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local EntityAtlas = require(ReplicatedStorage.Chest.Assets.Modules.EntityAtlas)
local v = {}
local Acrodagger_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Swords.Acrodagger_Data)
local mouse = localPlayer:GetMouse()

function FindNearestTarget(_, p, p2, max: number, value: number)
	local v2 = math.clamp((p2.Position - mouse.Hit.Position).Magnitude, 1, max)
	local _ = workspace.CurrentCamera.CFrame
	local position = (CFrame.new(p2.Position, mouse.Hit.Position) * CFrame.new(0, 0, -v2)).Position
	local magnitude = value or 100
	local v3 = nil

	for _, v4 in ipairs(EntityAtlas.GetEntities()) do
		local humanoid = v4:FindFirstChild("Humanoid")

		if not humanoid then
			continue
		end

		local rootPart = humanoid.RootPart

		if not (rootPart and v4 ~= p and (rootPart.Position - position).Magnitude <= magnitude) then
			continue
		end

		magnitude = (rootPart.Position - position).Magnitude
		v3 = v4
	end

	return v3
end

function AcrodaggerClient.Z()
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

	local zRequire = Acrodagger_Data.ZRequire

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
		Animation = ReplicatedStorage.Chest.Animation.Acrodagger.ZHold
	})
	task.spawn(function()
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Start",
			Time = 0.5,
			Color = Color3.fromRGB(255, 0, 0)
		})
		local lastTime = tick()
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
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Mode = "Stop"
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
		v2:Stop()

		if tick() - lastTime >= 0.5 then
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.Acrodagger.ZFire2
			})
		else
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.Acrodagger.ZFire1
			})
		end

		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrodagger_Z", v3)
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
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrodagger_Z", {
		MouseHit = mouseHit,
		Type = "Down"
	})
	game.ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "Z", cooldownClient)
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

function AcrodaggerClient.X()
	local mouse2 = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	local xRequire = Acrodagger_Data.XRequire

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
		Animation = ReplicatedStorage.Chest.Animation.Acrodagger.XHold
	})
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.P = 20000
	bodyGyro.Parent = humanoidRootPart
	mouse2.TargetFilter = workspace.Effects
	humanoid.AutoRotate = false
	task.spawn(function()
		local clone = nil

		while true do
			task.wait(0.03333333333333333)
			local v3 = math.clamp((humanoidRootPart.Position - _G.MouseHit.Position).Magnitude, 1, 250)
			local _ = workspace.CurrentCamera.CFrame
			local cFMouse = CFrame.new(humanoidRootPart.Position, _G.MouseHit.Position) * CFrame.new(0, 0, -v3)
			local nearestTargetMouse = _G.FindNearestTargetMouse({
				Player = localPlayer,
				RootPart = humanoidRootPart,
				Humanoid = humanoid,
				Distance = 250,
				CFMouse = cFMouse
			})

			if nearestTargetMouse then
				if clone and not clone:IsDescendantOf(workspace) then
					clone:Destroy()
					clone = nil
				end

				if not clone then
					clone = ReplicatedStorage.Chest.Etc.GaleFistEffect.TargetGUI:Clone()
					clone.Enabled = true
				end

				local v5 = workspace.CurrentCamera.ViewportSize.Magnitude / 25
				clone.Size = UDim2.new(0, v5, 0, v5)

				if clone.Parent ~= nearestTargetMouse then
					clone.Parent = nearestTargetMouse
				end
			elseif clone then
				clone:Destroy()
				clone = nil
			end

			bodyVelocity.Velocity = Vector3.new()
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, _G.MouseHit.p)

			if not (not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) then
				continue
			end

			if clone then
				clone:Destroy()
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.Acrodagger.XFire
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

			local v5 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrodagger_X", v5)
			break
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
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrodagger_X", v3)
	ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("SW", "X", cooldownClient)
	mouse2.TargetFilter = nil
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

function AcrodaggerClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SW_Acrodagger_M1", v2)
end

function AcrodaggerClient.Deactive(p)
	v[p] = nil
end

return AcrodaggerClient