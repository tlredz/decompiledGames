local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local DragonDragon_Data = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits.DragonDragon_Data)
local DragonDragonClient = {}

function DragonDragonClient.Z()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Dragon") then
		return
	end

	local zRequire = DragonDragon_Data.ZRequire

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

	if character:FindFirstChild("Dragon") then
		_G.ClearBvDragon(humanoidRootPart)
		tick()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_HellBullet,
			FadeTime = 0.4
		})
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local v2 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_Z", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Z1
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

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Z2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_Z", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_Z", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "Z", cooldownClient)
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
		_G.Cooldowns.DFZ = nil
	end)
end

function DragonDragonClient.X()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Dragon") then
		return
	end

	local xRequire = DragonDragon_Data.XRequire

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

	if character:FindFirstChild("Dragon") then
		_G.ClearBvDragon(humanoidRootPart)
		local lastTime = tick()
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Start",
				Time = 1,
				Color = Color3.fromRGB(255, 0, 0)
			})

			while task.wait() and v.X and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer)) do

			end

			ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
				Mode = "Stop"
			})
			local v2 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_X", v2)
		end)
		local v2 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_X", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.X1
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
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }

			while task.wait() do
				bodyVelocity.Velocity = Vector3.new()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouse.Hit.p)

				if not v.X or not _G.IsEquiping(script.Name:gsub("_Client", "")) or humanoid.Sit or tick() - lastTime > 10 or _G.CheckStunClient(localPlayer) then
					break
				end
			end

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DragonDragon.X2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_X", v3)
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.Position = Vector3.new(0, humanoidRootPart.Position.Y, 0)
			bodyPosition.MaxForce = createVector(0, 0, 0)
			bodyPosition.P = 20000
			bodyPosition.Parent = humanoidRootPart
			PeodizService.HeartbeatWait({
				Time = 1.8
			}, function(_)
				if not character:FindFirstChild("ChargeFolder") or (humanoid.Sit or humanoid.Health <= 0) then
					return true
				end

				local v4 = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 1, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -25, 0),
					raycastParams
				)
				local v5 = humanoidRootPart.Position + createVector(0, -25, 0)

				if raycastResult and v4.Y < 0 then
					local position = raycastResult.Position
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = Vector3.new(0, position.Y + 14, 0)
					v4 *= createVector(1, 0, 1)
				elseif v5.Y < -3.35 and v4.Y < 0 then
					bodyVelocity.MaxForce = Vector3.new(bodyVelocity.MaxForce.X, 0, bodyVelocity.MaxForce.Z)
					bodyPosition.MaxForce = createVector(0, 10000000, 0)
					bodyPosition.Position = createVector(0, 14, 0)
					v4 *= createVector(1, 0, 1)
				else
					bodyVelocity.MaxForce = Vector3.new(
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.X,
						bodyVelocity.MaxForce.Z
					)
					bodyPosition.MaxForce = createVector(0, 0, 0)
				end

				bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4).LookVector * 250
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v4)
			end)
			task.spawn(function()
				bodyVelocity.Velocity = Vector3.new()
				task.wait(1)
				bodyPosition:Destroy()
				_G.PU:Dust(bodyVelocity, 0.01)
				bodyGyro:Destroy()
			end)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_X", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "X", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	end

	task.spawn(function()
		instanceDoingClient:Delete()
	end)
	task.spawn(function()
		wait(cooldownClient)
		_G.Cooldowns.DFX = nil
	end)
end

function DragonDragonClient.C()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Dragon") then
		return
	end

	local cRequire = DragonDragon_Data.CRequire

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

	if character:FindFirstChild("Dragon") then
		_G.ClearBvDragon(humanoidRootPart)
		tick()
		_G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_Roar
		})
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local v2 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_C", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
	else
		_G.ClearBv(humanoidRootPart)
		local lastTime = tick()
		local v2 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.C1
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

			v2:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DragonDragon.C2
			})
			local v3 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_C", v3)
		end)
		local v3 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_C", v3)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "C", cooldownClient)
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
		_G.Cooldowns.DFC = nil
	end)
end

function DragonDragonClient.V()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Dragon") then
		return
	end

	local vRequire = DragonDragon_Data.VRequire

	if localPlayer.PlayerStats.DF.Value < vRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "V", vRequire })
		return
	end

	if _G.Cooldowns.DFV then
		return
	end

	local position = humanoidRootPart.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Island }

	if workspace:Raycast(position, createVector(0, 45, 0), raycastParams) and not character:FindFirstChild("Dragon") then
		local message = localPlayer.PlayerStats.Language.Value == "TH" and "แปลงร่างที่นี่ไม่ได้" or "Can't transform in this place"
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Can not transform",
			Overlay = true,
			Message = message,
			Color = Color3.fromRGB(255, 124, 124)
		})
	else
		_G.Cooldowns.DFV = true
		v.V = true
		local cooldownClient = _G.GetCooldownClient("DFV")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBv(humanoidRootPart)
		tick()
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		local v2 = {
			MouseHit = _G.MouseHit
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_V", v2)
		ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", "V", cooldownClient)
		mouse.TargetFilter = nil
		humanoid.AutoRotate = true
		local dragon = character:FindFirstChild("Dragon")

		if dragon then
			if dragon then
				local dragonPOV = character:WaitForChild("Dragon", 10):WaitForChild("DragonPOV", 10)

				if dragonPOV then
					workspace.CurrentCamera.CameraSubject = dragonPOV
				end

				_G.UpdateCameraMaxZoom({
					Step = 200,
					Type = "Normal"
				})
			end
		else
			workspace.CurrentCamera.CameraSubject = humanoid
			_G.StopAnimationClient(humanoid, {
				Idle = true,
				Fly = true
			})
			_G.UpdateCameraMaxZoom({
				Step = 100,
				Type = "Normal"
			})
		end

		task.spawn(function()
			instanceDoingClient:Delete()
		end)
		task.spawn(function()
			wait(cooldownClient)
			_G.Cooldowns.DFV = nil
		end)
	end
end

function DragonDragonClient.E()
	local mouse = localPlayer:GetMouse()
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer) or _G.AntiMobSkill("Dragon") then
		return
	end

	local eRequire = DragonDragon_Data.ERequire

	if localPlayer.PlayerStats.DF.Value < eRequire then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Stats Require", { "Power Fruit", "E", eRequire })
		return
	end

	if _G.Cooldowns.DFE then
		return
	end

	if character:FindFirstChild("Dragon") then
		_G.Cooldowns.DFE = true
		v.E = true
		local cooldownClient = _G.GetCooldownClient("DFE")
		local instanceDoingClient = _G.InstanceDoingClient({
			Parent = localPlayer
		})
		_G.ClearBvDragon(humanoidRootPart)
		local lastTime = tick()
		local v2 = nil
		local v3 = _G.PU.PlayOneShotAnim({
			Animator = humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_BeamLoop,
			FadeTime = 0.4
		})
		mouse.TargetFilter = workspace.Effects
		humanoid.AutoRotate = false
		task.spawn(function()
			while task.wait() and v.E and _G.IsEquiping(script.Name:gsub("_Client", "")) and not (humanoid.Sit or tick() - lastTime > 10) do

			end

			v3:Stop()
			_G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_BeamCastStart
			})
			task.spawn(function()
				task.wait(0.1)

				if not _G.CheckStunClient(localPlayer) then
					v2 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_BeamCastLoop
					})
				end
			end)
			local v4 = {
				MouseHit = _G.MouseHit,
				Type = "Up"
			}
			ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_E", v4)
		end)
		local v4 = {
			MouseHit = _G.MouseHit,
			Type = "Down"
		}
		ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_E", v4)

		if v2 then
			v2:Stop(0.4)
			v2 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.DragonDragon.Dragon_BeamCastEnd,
				FadeTime = 0.4
			})
		end

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
	elseif not localPlayer.PlayerGui.Popup.Frame:FindFirstChild("Dragon Transform") then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = "Dragon Transform"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "< สกิลนี้ต้องใช้ร่างเต็ม >"
		else
			clone.Text = "< This skill need to use Full Form >"
		end

		clone.Parent = localPlayer.PlayerGui.Popup.Frame
	end
end

function DragonDragonClient.M1()
	local v2 = {
		MouseHit = _G.MouseHit
	}
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("DF_DragonDragon_M1", v2)
end

function DragonDragonClient.Deactive(p)
	v[p] = nil
end

return DragonDragonClient