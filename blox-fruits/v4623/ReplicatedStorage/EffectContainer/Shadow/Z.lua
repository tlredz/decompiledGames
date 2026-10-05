local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function trailPart(outer)
	local clone = outer:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Color = Color3.fromRGB(58, 0, 141),
			Size = clone.Size * 2 + Vector3.new(
				math.random(5, 45) / 10,
				math.random(5, 45) / 10,
				math.random(5, 45) / 10
			)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	return clone
end

local function pulsation(position)
	local v = math.random(15, 25) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 10)
	part.Anchored = true
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Transparency = 1
	part.Material = Enum.Material.ForceField
	part.Position = position
	part.Color = Color3.fromRGB(35, 0, 86)
	part.Transparency = -10
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = Vector3.new(3, v, 3)
	specialMesh.Parent = part
	part.Parent = _WorldOrigin
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		specialMesh,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Scale = Vector3.new(v, 5, v)
		}
	)
	local tween2 = TweenService:Create(
		part,
		TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Transparency = 1,
			Color = Color3.fromRGB(0, 0, 0)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	tween:Play()
	tween2:Play()
	return part
end

local function ring(cFrame)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new()
	part.Transparency = 1
	part.CFrame = cFrame
	local clone = script.TravelRing:Clone()
	clone.Parent = part
	part.Parent = _WorldOrigin
	clone:Emit(1)
end

local function poof(cFrame, p)
	Util.Sound:Play("SeekerFire", cFrame.p, nil, 1, 1)

	if p then
		local clone = script.ZPossessErupt:Clone()
		Util.Debris:AddItem(clone, 3)
		clone:SetPrimaryPartCFrame(cFrame)
		local shockwave = clone.Shockwave
		local smoke = clone.Root.Attachment.Smoke
		local spikyShockwave = clone.Root.Attachment.SpikyShockwave
		clone.Parent = _WorldOrigin
		smoke:Emit(6)
		spikyShockwave:Emit(1)
		shockwave.Size = createVector(3, 35, 3)
		shockwave.CFrame *= CFrame.new(0, 16.5, 0)
		local tween = TweenService:Create(
			shockwave,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(30, 0.2, 30),
				CFrame = shockwave.CFrame * CFrame.new(0, -17, 0)
			}
		)
		tween.Completed:Connect(function()
			shockwave:Destroy()
		end)
		tween:Play()
		local wind1 = clone.Wind1
		local wind2 = clone.Wind2
		local longSwirl = clone.LongSwirl
		longSwirl.Size = createVector(20, 5, 20)
		task.spawn(function()
			TweenService:Create(
				longSwirl,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(2, 40, 2)
				}
			):Play()
			TweenService:Create(wind1, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Transparency = 1,
				Size = createVector(3, 40, 3),
				Color = Color3.fromRGB(62, 19, 122)
			}):Play()
			TweenService:Create(wind2, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Transparency = 1,
				Size = createVector(1, 40, 1),
				Color = Color3.fromRGB(29, 16, 100)
			}):Play()
			local lastTime = tick()
			local v = 0.016666666666666666

			while true do
				local v2 = tick() - lastTime

				if v2 > 2 then
					break
				end

				clone:SetPrimaryPartCFrame(clone.Root.CFrame * CFrame.Angles(0, 0, (math.rad(v * 1 * 60))))
				longSwirl.CFrame = longSwirl.CFrame * CFrame.new(0, (3 + -2.8 * (v2 / 1)) * v * 60, 0) * CFrame.Angles(
					0,
					math.rad((30 + -30 * (v2 / 1)) * v * 60),
					0
				)
				wind1.CFrame *= CFrame.new(0, (0.5 + -0.5 * (v2 / 2)) * v * 60, 0)
				wind2.CFrame *= CFrame.new(0, (1.6 + -1.6 * (v2 / 2)) * v * 60, 0)
				v = RunService.RenderStepped:Wait()
			end
		end)
	else
		local clone = script.ZPossessErupt.Root:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clone.Attachment.Smoke:Emit(5)
		clone.Attachment.SpikyShockwave:Emit(1)
	end
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local root = player.Root
		local humanoid = player.Humanoid
		local _ = player.Character
		local holdValue = player.HoldValue

		if humanoid and root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local v = Util.Sound:Play("WarpSplat", root, nil, 2, 1)
			local tween = TweenService:Create(
				v,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					PlaybackSpeed = 0.1
				}
			)
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local lastTime = tick()

			local function running()
				return tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true
			end

			local clone = script.HoldZEffect.Attachment:Clone()
			debris:AddItem(clone, 300)
			clone.Parent = root
			task.spawn(function()
				clone.Curve:Emit(5)
				clone.Waves:Emit(1)
				wait(0.4)
				clone.BlackOrbs:Emit(10)
			end)
			local part = Instance.new("Part")
			part.Material = Enum.Material.Neon
			part.Shape = Enum.PartType.Ball
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CastShadow = false
			part.Color = Color3.fromRGB(0, 0, 0)
			part.Transparency = 1
			part.Size = createVector(12, 12, 12)
			part.Position = root.Position
			part.Parent = _WorldOrigin
			TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(2, 2, 2),
					Transparency = 0
				}
			):Play()
			local lastTime2 = tick()

			while (tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
				if tick() - lastTime2 > 0.01 then
					pulsation(root.Position)
					lastTime2 = tick()
				end

				part.Position = root.Position
				RunService.RenderStepped:Wait()
			end

			if part then
				part:Destroy()
			end

			if clone then
				for _, child in pairs(clone:GetChildren()) do
					local v2 = child
					task.spawn(function()
						v2.Enabled = false
						wait(1.5)
						v2:Destroy()
					end)
				end
			end

			if diedConnection then
				diedConnection:Disconnect()
			end
		end
	elseif stage == 2 then
		local root = player.Root
		local character = player.Character
		local humanoid = player.Humanoid
		local duration = player.Duration
		local timestamp = player.Timestamp
		local velocity = player.Velocity
		local hitValue = player.HitValue
		local character2 = game.Players.LocalPlayer.Character
		local v = character2 and character == character2 and true or false

		if character and root and humanoid then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local v2 = duration - (masterClock:GetTime() - timestamp)

			if v then
				local boolValue = Instance.new("BoolValue")
				Util.Debris:AddItem(boolValue, 3)
				boolValue.Name = "ShadowZBegin"
				boolValue.Parent = character
			end

			if humanoid then
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
				Util.Sound:Play("ShadowGlide", root, nil, 1.35, 2)
				local v3, v4

				if v then
					v3 = Util.BodyMover.new(character):Create("BodyVelocity", {
						Velocity = CFrame.new(root.Position, Mouse.Hit.p).lookVector.Unit * velocity
					})
					v4 = Util.BodyMover.new(character):Create("BodyGyro", {
						CFrame = CFrame.new(root.Position, Mouse.Hit.p)
					})
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.25 or diedConnection
				end

				local clone = script.ShadowMissile:Clone()
				debris:AddItem(clone, v2 + 5)
				clone:SetPrimaryPartCFrame(root.CFrame)
				clone.Parent = _WorldOrigin
				local value = nil
				local changedConnection = nil
				changedConnection = hitValue.Changed:Connect(function(p)
					value = p
					changedConnection:Disconnect()
				end)
				local lastTime2 = tick()
				local lastTime3 = tick()
				local v5 = {}

				while (tick() - lastTime < 0.25 or diedConnection) and tick() - lastTime < v2 and root and humanoid and hitValue do
					if hitValue.Value ~= Vector3.new() or value ~= nil then
						value = hitValue.Value
						break
					end

					if v then
						v4:Set(CFrame.new(root.Position, (Vector3.new(Mouse.Hit.p.X, Mouse.Hit.p.Y, Mouse.Hit.p.Z))))
						v3:Set(CFrame.new(root.Position, Mouse.Hit.p).lookVector.Unit * velocity)
					end

					if tick() - lastTime2 > 0.05 then
						table.insert(v5, (trailPart(clone.Outer)))
						lastTime2 = tick()
					end

					if tick() - lastTime3 > 0.1 then
						ring(root.CFrame)
						lastTime3 = tick()
					end

					for _, v6 in pairs(v5) do
						v6.CFrame = v6.CFrame * CFrame.new(0, 0, 0.1) * CFrame.Angles(0.2617993877991494, 0, 0)
					end

					clone:SetPrimaryPartCFrame(root.CFrame)
					RunService.RenderStepped:Wait()
				end

				if clone then
					local _ = clone.Inner
					local _ = clone.HeadPart

					for _, descendant in pairs(clone:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("BasePart") then
							descendant.Transparency = 1
						end
					end

					if value == nil then
						local cFrame = root.CFrame
						Util.Sound:Play("SeekerFire", cFrame.p, nil, 1, 1)
						local clone2 = script.ZPossessErupt.Root:Clone()
						Util.Debris:AddItem(clone2, 2)
						clone2.CFrame = cFrame
						clone2.Parent = _WorldOrigin
						clone2.Attachment.Smoke:Emit(5)
						clone2.Attachment.SpikyShockwave:Emit(1)
					end
				end

				if v then
					if v4 then
						v4:Destroy()
					end

					if v3 then
						v3:Destroy()
					end
				end

				if diedConnection then
					diedConnection:Disconnect()
				end
			end
		end
	elseif stage == 3 then
		local targetRoot = player.TargetRoot
		local targetHumanoid = player.TargetHumanoid
		local userRoot = player.UserRoot
		local userHumanoid = player.UserHumanoid
		local duration = player.Duration
		local crowAmount = player.CrowAmount
		local timestamp = player.Timestamp

		if (targetRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		task.spawn(function()
			local position = targetRoot.Position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 60 then
					Util.CameraShaker:ShakeOnce(10, 15, 0.25, 0.5)
				end
			end
		end)
		local _ = tick() - timestamp
		local character = game.Players.LocalPlayer.Character
		local v = character and userRoot.Parent == character and true or false

		if targetRoot then
			local clone = script.ZPossess.Attachment:Clone()
			debris:AddItem(clone, 2)
			clone.Parent = targetRoot
			clone.Curve:Emit(4)
			clone.Vortex:Emit(2)
			clone.Slash.Size = NumberSequence.new(24, 0)
			task.spawn(function()
				for _ = 1, crowAmount do
					clone.PurpleSlashes:Emit(1)
					clone.Slash:Emit(math.random(2, 3))
					wait(duration / crowAmount)
				end
			end)
		end

		local diedConnection = nil
		diedConnection = targetHumanoid.Died:Connect(function()
			diedConnection:Disconnect()
		end)
		local diedConnection2 = nil
		diedConnection2 = targetHumanoid.Died:Connect(function()
			diedConnection2:Disconnect()
		end)
		local v2 = duration / crowAmount
		local lastTime = tick()
		local lastTime2 = tick()

		local function running()
			return tick() - lastTime < 0.25 or diedConnection and diedConnection2
		end

		local position = targetRoot.Position
		local v3

		if v then
			if targetHumanoid.Parent and not targetHumanoid.Parent:FindFirstChild("AntiMover") then
				workspace.CurrentCamera.CameraSubject = targetHumanoid
			end

			v3 = Util.BodyMover.new(userRoot.Parent):Create("BodyPosition", {
				Priority = 10000,
				Position = position
			})
			userRoot.CFrame = CFrame.new(position)
		end

		while (tick() - lastTime < 0.25 or diedConnection and diedConnection2) and tick() - lastTime < duration and targetRoot and targetHumanoid and userRoot and userHumanoid do
			if v2 < tick() - lastTime2 then
				local v4 = math.random(0, 10)
				local v5 = CFrame.new(targetRoot.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					v4,
					-30
				)
				local v6 = v5 * CFrame.Angles(0, math.rad((math.random(-20, 20))), 0) * CFrame.new(0, -v4, 60)
				local bezier = {
					v5.p,
					(cflerp(v5, v6, 0.33) * CFrame.new(math.random(-15, 15), math.random(-15, 5), 0)).p,
					(cflerp(v5, v6, 0.66) * CFrame.new(math.random(-15, 15), math.random(-15, 5), 0)).p,
					v6.p
				}
				Effect.new("Shadow.Crows"):replicate({
					Type = 0,
					Life = 0.25,
					Bezier = bezier
				})
				lastTime2 = tick()
			end

			RunService.RenderStepped:Wait()
		end

		if v then
			if v3 then
				v3:Destroy()
			end

			if targetHumanoid.Parent and not targetHumanoid.Parent:FindFirstChild("AntiMover") then
				userRoot.CFrame = CFrame.new(
					targetRoot.Position,
					(Vector3.new(Mouse.Hit.p.X, targetRoot.Position.Y, Mouse.Hit.p.Z))
				)
			else
				userRoot.CFrame = CFrame.new(
					userRoot.Position,
					(Vector3.new(Mouse.Hit.p.X, userRoot.Position.Y, Mouse.Hit.p.Z))
				)
			end

			userRoot.Velocity = CFrame.new(userRoot.CFrame.p, (userRoot.CFrame * CFrame.new(0, 90, -10)).p).lookVector.Unit * 230
			workspace.CurrentCamera.CameraSubject = userHumanoid
		end

		poof(CFrame.new(userRoot.CFrame.p, (userRoot.CFrame * CFrame.new(0, 90, -10)).p), true)

		if diedConnection2 then
			diedConnection2:Disconnect()
		end

		if diedConnection then
			diedConnection:Disconnect()
		end
	end
end