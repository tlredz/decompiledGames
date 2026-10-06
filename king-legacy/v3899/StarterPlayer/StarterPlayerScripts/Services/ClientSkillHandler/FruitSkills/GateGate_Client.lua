local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local currentCamera = workspace.CurrentCamera
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local TweenService = game:GetService("TweenService")
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local GateGate_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.GateGate_Data)
local v = {}
local GateGateClient = {}
local thisWorld = nil

for k, v4 in pairs(WorldsId.Testing) do
	if game.PlaceId ~= v4 then
		continue
	end

	thisWorld = k
	break
end

for k, v5 in pairs(WorldsId.KingLegacy) do
	if game.PlaceId ~= v5 then
		continue
	end

	thisWorld = k
	break
end

function GateGateClient.Z()
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

	local zRequire = GateGate_Data.ZRequire

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
	local v5 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GateGate.Z1
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

		v5:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GateGate.Z2
		})
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_Z", v6)
	end)
	local v6 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_Z", v6)
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

function GateGateClient.X()
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

	local xRequire = GateGate_Data.XRequire

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
	local v5 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GateGate.X1
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

		v5:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GateGate.X2
		})
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_X", v6)
	end)
	local v6 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_X", v6)
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

function GateGateClient.C()
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

	local cRequire = GateGate_Data.CRequire

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
	local v5 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GateGate.C1
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

			if not v.C or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
				break
			end
		end

		v5:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GateGate.C2
		})
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_C", v6)
	end)
	local v6 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_C", v6)
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

function GateGateClient.V()
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

	local vRequire = GateGate_Data.VRequire

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
	local v5 = _G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation.GateGate.V1
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

		v5:Stop()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.GateGate.V2
		})
		local v6 = {
			MouseHit = _G.MouseHit,
			Type = "Up"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_V", v6)
	end)
	local v6 = {
		MouseHit = _G.MouseHit,
		Type = "Down"
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_V", v6)
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

function GateGateClient.E()
	localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if game.PlaceId == WorldsId.KingLegacy.GoldenArena or game.PlaceId == WorldsId.Testing.GoldenArena then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Error GA",
			Overlay = true,
			Message = "<Error: Golden Arena>",
			Color = Color3.fromRGB(255, 74, 74)
		})
		return
	end

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill() then
		return
	end

	if _G.CheckInCombat() then
		return
	end

	local eRequire = GateGate_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

	if _G.Cooldowns.DFE then
		return
	end

	if not localPlayer.PlayerGui:FindFirstChild("GateWorld") then
		local clone = ReplicatedStorage.Chest.Gui.GateWorld:Clone()
		clone.Frame.Size = UDim2.fromScale(0, 0)
		clone.Parent = localPlayer.PlayerGui
		clone.Frame[thisWorld].Visible = true
		TweenService:Create(clone.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Size = UDim2.fromScale(0.83, 0.52)
		}):Play()
		task.spawn(function()
			_G.ButtonClicked()
			local gate = ReplicatedStorage.Chest.FruitEffect.Gate
			local effects = workspace.Effects
			local clone2 = gate.PortalSmall:Clone()
			_G.PU:Dust(clone2, 10)
			clone2.Parent = effects
			local v5 = true
			task.spawn(function()
				FastRenderer.new({
					Time = 5
				}, function()
					if not clone.Parent and v5 then
						Utility.ParticleHandler(clone2, false)
						v5 = nil
					end

					local viewportSize = currentCamera.ViewportSize
					local v6 = viewportSize.X / viewportSize.Y
					clone2.CFrame = currentCamera.CFrame * CFrame.new(0, -0.075, -v6 / 1.5)
				end)
			end)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://16013132116",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = humanoidRootPart
			sound:Play()
			task.spawn(function()
				Utility.ParticleHandler(clone2, true)
				task.wait(1)
				Utility.ParticleHandler(clone2, false)
			end)
		end)
		local connections = {}
		local name = nil

		for _, button in pairs(clone.Frame[thisWorld]:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local v5 = button
			table.insert(connections, button.MouseButton1Click:Connect(function()
				name = v5.Name
			end))
		end

		local v5 = nil
		table.insert(connections, clone.Frame.CloseButton.MouseButton1Click:Connect(function()
			v5 = true
		end))
		local starterFrame = localPlayer.PlayerGui.MainGui.StarterFrame

		local function IsFrameOpen()
			if starterFrame.Battlepass_Frame.Visible or starterFrame.ShopFrame.Visible or starterFrame.AllyFrame.Visible or starterFrame.FruitFrame.Visible or starterFrame.Inventory_Frame.Visible or starterFrame.MapFrame.Visible or starterFrame.ServerBrowserFrame.Visible or starterFrame.StatsFrame.Visible or starterFrame.TradeFrame.Visible or starterFrame.CrewFrame.Visible or starterFrame.Setting_Frame.Visible then
				return true
			end
		end

		local v6 = nil

		while wait(0.1) and not name and not v5 and not (humanoid.Health <= 0) and _G.IsEquiping(script.Name:gsub(
			"_Client",
			""
		)) and not (humanoid.Sit or _G.CheckStunClient(localPlayer)) do
			if not IsFrameOpen() then
				continue
			end

			v6 = true
			break
		end

		local v7 = {
			MouseHit = _G.MouseHit,
			ThisWorld = thisWorld,
			TeleportTo = name,
			Type = "Down"
		}
		local v8 = not v6 and ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_GateGate_E", v7)

		if v8 == "Teleport Successed" or v6 then
			_G.Cooldowns.DFE = true
			local cooldownClient = _G.GetCooldownClient("DFE")
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", cooldownClient)
			task.spawn(function()
				wait(cooldownClient)
				_G.Cooldowns.DFE = nil
			end)
		elseif v8 == "Teleport Failed" then
			_G.Cooldowns.DFE = true
			_G.GetCooldownClient("DFE")
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "E", 1)
			task.spawn(function()
				wait(1)
				_G.Cooldowns.DFE = nil
			end)
		end

		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		clone:Destroy()
	end
end

function GateGateClient.Deactive(p)
	v[p] = nil
end

return GateGateClient