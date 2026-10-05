local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function adjustY(data, p, p2)
	local _ = (data - p).Magnitude

	if data.Y < p.Y - 2 then
		return (Vector3.new(data.X, data.Y + p2, data.Z))
	end

	return data
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

local function punchDart(userCFrame)
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	local clone = script.PunchSpike:Clone()
	Util.Debris:AddItem(clone, 2)
	local clone2 = script.FinalPunch:Clone()
	Util.Debris:AddItem(clone2, 5)
	clone:SetPrimaryPartCFrame(userCFrame * cframe)
	clone.Parent = _WorldOrigin
	clone2.CFrame = userCFrame * CFrame.new(0, 0, -5)
	clone2.Parent = _WorldOrigin

	for _, child in pairs(clone2:GetChildren()) do
		if child.Name == "Dots" then
			child:Emit(13)
		elseif child.Name == "SpikeLight" then
			child:Emit(3)
		elseif child.Name == "SpikeDark" then
			child:Emit(5)
		elseif child.Name == "Ring" then
			child:Emit(1)
		end
	end

	for _, child in pairs(clone:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = child.CFrame * CFrame.new(0, -25, 0)
			}
		)
		local v = child
		tween.Completed:Connect(function()
			if v then
				v:Destroy()
			end
		end)
		tween:Play()

		for _, child2 in pairs(child:GetChildren()) do
			if child2.Name == "Mesh" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = Vector3.new(child2.Scale.X - 1, 5, child2.Scale.Z - 1)
					}
				)
				local v2 = child
				tween2.Completed:Connect(function()
					if v2 then
						v2:Destroy()
					end
				end)
				tween2:Play()
			elseif child2.Name == "Decal" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1
					}
				)
				local v2 = child
				tween2.Completed:Connect(function()
					if v2 then
						v2:Destroy()
					end
				end)
				tween2:Play()
			end
		end
	end
end

local function startDashWind(cFrame)
	local clone = script.DashStart:Clone()
	Util.Debris:AddItem(clone, 4)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Dust:Emit(math.random(5, 8))
	local ray, v, _ = Util.Ray(
		cFrame.Position,
		CFrame.new(cFrame.Position).UpVector.Unit * -10,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local v2 = cFrame * CFrame.new(0, 0, -5)

	if ray then
		clone.Rock:Emit(math.random(5, 8))
		local cframe = CFrame.new(v, (Vector3.new(v2.X, v.Y, v2.Z)))
		local clone2 = script.LeftShockwave:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone2.CFrame = cframe * CFrame.new(-8, 0, 0) * CFrame.Angles(0, -0.2617993877991494, 0)
		clone2.Parent = _WorldOrigin
		local clone3 = script.RightShockwave:Clone()
		Util.Debris:AddItem(clone3, 2)
		clone3.CFrame = cframe * CFrame.new(8, 0, 0) * CFrame.Angles(0, 0.2617993877991494, 0)
		clone3.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone2,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(8, 15, 80),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.new(-10, 10, 15)
			}
		)
		tween.Completed:Connect(function()
			if clone2 then
				clone2:Destroy()
			end
		end)
		local tween2 = TweenService:Create(
			clone3,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(8, 15, 80),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.new(10, 10, 15)
			}
		)
		tween2.Completed:Connect(function()
			if clone3 then
				clone3:Destroy()
			end
		end)
		tween:Play()
		tween2:Play()
	end
end

local function lightBurst(position, duration, color, range, brightness)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 2)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new()
	part.Position = position
	part.Parent = _WorldOrigin
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 0
	pointLight.Range = 0
	pointLight.Parent = part
	local tween = TweenService:Create(
		pointLight,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Range = range,
			Brightness = brightness
		}
	)
	tween.Completed:Connect(function()
		if part then
			part:Destroy()
		end
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function afterImage(items, transparency, material, color, duration, p, p2)
	task.spawn(function()
		for _, item in pairs(items) do
			if item == nil then
				continue
			end

			local v = item:FindFirstChildOfClass("SpecialMesh") and true or false
			local clone = item:Clone()

			if clone:IsA("MeshPart") then
				clone.TextureID = ""
			end

			Util.Debris:AddItem(clone, duration + 0.5)

			if #clone:GetDescendants() > 0 then
				if v then
					for _, specialMesh in pairs(clone:GetChildren()) do
						if not specialMesh:IsA("SpecialMesh") then
							specialMesh:Destroy()
						end
					end
				else
					clone:ClearAllChildren()
				end
			end

			clone.CFrame = item.CFrame
			clone.Material = material
			clone.Color = color
			clone.Transparency = transparency
			local model = Instance.new("Model", _WorldOrigin)
			Util.Debris:AddItem(model, duration + 0.5)
			clone.Parent = model
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					CFrame = p and clone.CFrame + p.lookVector.Unit * p2 or clone.CFrame
				}
			)
			tween.Completed:Connect(function()
				if model then
					model:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end)
			tween:Play()
		end
	end)
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local root = player.Root
		local humanoid = player.Humanoid
		local _ = player.Character
		local holdValue = player.HoldValue
		local chargeTime = player.ChargeTime

		if humanoid and root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local v = Util.Sound:Play("Charge", root, nil, 2, 1)
			local tween = TweenService:Create(
				v,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					PlaybackSpeed = 0.6
				}
			)
			tween.Completed:Connect(function()
				if v then
					v:Destroy()
				end
			end)
			tween:Play()
			local v2 = Util.Sound:Play("AuraSound", root, nil, 1.4, 1)
			v2.Looped = true
			local clone = script.ZCharge.Attachment:Clone()
			Util.Debris:AddItem(clone, 60)
			clone.Parent = root
			clone.Ring:Emit(1)
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

			local lastTime2 = tick()
			local v3 = false

			while (tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
				if not v3 and chargeTime < tick() - lastTime then
					for _, child in pairs(clone:GetChildren()) do
						child.Enabled = false
						child.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					end

					v3 = true
				end

				if tick() - lastTime2 > 0.01 then
					lastTime2 = tick()
				end

				RunService.RenderStepped:Wait()
			end

			if clone then
				task.spawn(function()
					for _, child in pairs(clone:GetChildren()) do
						child.Enabled = false
					end

					task.wait(2)

					if clone then
						clone:Destroy()
					end
				end)
			end

			if v2 then
				v2:Destroy()
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
		local _ = player.Velocity
		local character2 = game.Players.LocalPlayer.Character
		local _ = character2 and character == character2

		if character and root and humanoid then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local v = duration - (masterClock:GetTime() - timestamp)
			startDashWind(root.CFrame)

			if humanoid then
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
				Util.Sound:Play("Engulf", root, nil, 1.2, 1)
				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.25 or diedConnection
				end

				local clone = script.Punch.PounceRush:Clone()
				Util.Debris:AddItem(clone, v + 2)
				clone.Parent = root
				local lastTime2 = tick()
				local lastTime3 = tick()
				local cframe = CFrame.Angles(0, 3.141592653589793, 0)
				local clones = {}
				local v2 = {
					Vortex = 2,
					Shunted = 4,
					ShuntedFree = 4
				}

				while (tick() - lastTime < 0.25 or diedConnection) and tick() - lastTime < v and root and humanoid do
					if character:FindFirstChild("SH2Zended") then
						character.SH2Zended:Destroy()
						break
					end

					if tick() - lastTime3 > 0.1 then
						local clone2 = script.Comet:Clone()
						Util.Debris:AddItem(clone2, 2)
						clone2.CFrame = root.CFrame * cframe * CFrame.new(0, 0, -6)
						table.insert(clones, clone2)
						clone2.Parent = _WorldOrigin
						local tween = TweenService:Create(
							clone2,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = createVector(20, 20, 35),
								Transparency = 1
							}
						)
						tween.Completed:Connect(function()
							if clone2 then
								clone2:Destroy()
							end
						end)
						tween:Play()
						Util.Sound:Play("SetFire", root, nil, 1, 1)
						lastTime3 = tick()
					end

					if tick() - lastTime2 > 0.05 then
						if clone then
							for childName, v3 in pairs(v2) do
								if clone:FindFirstChild(childName) then
									clone[childName]:Emit(v3)
								end
							end
						end

						lastTime2 = tick()
					end

					for _, v3 in pairs(clones) do
						local _ = v3.CFrame - v3.CFrame.Position
						v3.CFrame = root.CFrame * cframe * CFrame.new(0, 0, -6)
					end

					RunService.RenderStepped:Wait()
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
		local punchAmount = player.PunchAmount
		local timestamp = player.Timestamp

		if (targetRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		local position = targetRoot.Position
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 60 then
				Util.CameraShaker:ShakeOnce(10, 15, 0.25, 0.5)
			end
		end

		local v = math.max(0.1, duration - (masterClock:GetTime() - timestamp))
		local character2 = game.Players.LocalPlayer.Character
		local v2 = character2 and userRoot.Parent == character2 and true or false
		local diedConnection = nil
		diedConnection = targetHumanoid.Died:Connect(function()
			diedConnection:Disconnect()
		end)
		local diedConnection2 = nil
		diedConnection2 = targetHumanoid.Died:Connect(function()
			diedConnection2:Disconnect()
		end)
		local position2 = targetRoot.Position
		local v3

		if v2 then
			if targetHumanoid.Parent and not targetHumanoid.Parent:FindFirstChild("Dragon") then
				workspace.CurrentCamera.CameraSubject = targetHumanoid
			end

			v3 = Util.BodyMover.new(userRoot.Parent):Create("BodyPosition", {
				Priority = 10000,
				Position = position2
			})
			userRoot.CFrame = CFrame.new(position2)
		else
			v3 = nil
		end

		local v4 = {
			Shockwave = 1,
			Spikes = 8,
			Sparks = 8,
			Core = 2,
			NegativeCore = 2,
			Orbs = 8,
			Ring = 1,
			Rays = 2
		}
		local clone

		if targetRoot then
			clone = script.Punch.PunchBurst:Clone()
			Util.Debris:AddItem(clone, v + 2)
			clone.Parent = targetRoot
		else
			clone = nil
		end

		local clone2

		if userRoot then
			clone2 = script.Phase.PhaseAttachment:Clone()
			Util.Debris:AddItem(clone2, v + 2)
			clone2.Parent = userRoot
		else
			clone2 = nil
		end

		local v5 = v / punchAmount
		local lastTime = tick()
		local lastTime2 = tick()
		local lastTime3 = tick()

		local function running()
			return tick() - lastTime < 0.25 or diedConnection and diedConnection2 and tick() - lastTime < v
		end

		local v6 = {
			Head = true,
			UpperTorso = true,
			LowerTorso = true,
			RightUpperArm = true,
			RightLowerArm = true,
			LeftUpperArm = true,
			LeftLowerArm = true,
			RightUpperLeg = true,
			RightLowerLeg = true,
			LeftUpperLeg = true,
			LeftLowerLeg = true,
			RightHand = true,
			LeftHand = true,
			RightFoot = true,
			LeftFoot = true
		}
		local parts = {}

		for _, part in pairs(userRoot.Parent:GetChildren()) do
			if part:IsA("BasePart") and v6[part.Name] then
				table.insert(parts, part)
			end
		end

		local superhumanV2ZHit = Util.Anims:Get(userRoot.Parent, "SuperhumanV2ZHit")
		superhumanV2ZHit:Play()

		while (tick() - lastTime < 0.25 or diedConnection and diedConnection2 and tick() - lastTime < v) and targetRoot and targetHumanoid and userRoot and userHumanoid and not userRoot:FindFirstChild("SHV2ZFinalTrigger") do
			if v5 < tick() - lastTime2 then
				lightBurst(targetRoot.Position, 0.1, Color3.fromRGB(156, 255, 247), math.random(15, 20), 6)
				Util.Sound:Play("Hit1", targetRoot.Position, nil, math.random(9, 12) / 10, 0.3)

				for childName, v7 in pairs(v4) do
					if clone:FindFirstChild(childName) then
						clone[childName]:Emit(v7)
					end
				end

				local position3 = targetRoot.Position
				local character3 = game.Players.LocalPlayer.Character

				if character3 ~= nil then
					local humanoidRootPart = character3:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and (humanoidRootPart.Position - position3).magnitude <= 60 then
						Util.CameraShaker:ShakeOnce(2, 3, 0.2, 0.2)
					end
				end

				lastTime2 = tick()
			end

			if tick() - lastTime3 > 0.15 then
				if #parts > 0 then
					task.spawn(function()
						local v7 = CFrame.new(clone.WorldPosition) * CFrame.Angles(0, math.random(-180, 180), 0)
						local v8 = v7 - v7.Position
						local _, v9, _ = Util.Ray(
							v7.Position,
							v7.LookVector.Unit * 20,
							{ workspace.Characters, workspace.Enemies },
							false
						)
						local cFrame = CFrame.new(v9) * v8 * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
							0,
							0,
							-5
						)

						if v2 then
							if v3 then
								v3:Set(cFrame.Position)
							end

							userRoot.CFrame = cFrame
						end

						if clone2 then
							clone2.PhaseLines:Emit(50)
						end

						Util.Sound:Play("Teleport", cFrame.Position, nil, math.random(9, 11) / 10, 1)
						superhumanV2ZHit.TimePosition = 1
						superhumanV2ZHit:AdjustSpeed(0)
						afterImage(parts, 0.2, "Neon", Color3.fromRGB(245, 255, 192), 0.4, v7, -35) -- equivalent call inferred; original call site unknown
					end)
				end

				lastTime3 = tick()
			end

			RunService.RenderStepped:Wait()
		end

		local sHV2ZFinalTrigger = userRoot:FindFirstChild("SHV2ZFinalTrigger")

		if sHV2ZFinalTrigger then
			sHV2ZFinalTrigger:Destroy()
		end

		parts = nil

		if v2 then
			if v3 then
				v3:Destroy()
			end

			userRoot.CFrame = CFrame.new(
				targetRoot.Position,
				(Vector3.new(Mouse.Hit.p.X, targetRoot.Position.Y, Mouse.Hit.p.Z))
			)
			userRoot.Velocity = CFrame.new(userRoot.CFrame.p, (userRoot.CFrame * CFrame.new(0, 5, -10)).p).lookVector.Unit * 150
			workspace.CurrentCamera.CameraSubject = userHumanoid
		end

		if diedConnection2 then
			diedConnection2:Disconnect()
		end

		if diedConnection then
			diedConnection:Disconnect()
		end
	elseif stage == 4 then
		local targetRoot = player.TargetRoot
		local userRoot = player.UserRoot
		local _ = player.Timestamp
		local userCFrame = player.UserCFrame

		if (targetRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		math.max(0.1, 1 - Util.MasterClock:GetTime())
		userRoot.CFrame = userCFrame
		local v = Util.BodyMover.new(userRoot.Parent):Create("BodyPosition", {
			Priority = -10000,
			Position = userCFrame.Position
		})
		Util.Debris:AddItem(v, 0.35)
		local v2 = Util.BodyMover.new(userRoot.Parent):Create("BodyGyro", {
			Priority = -10000,
			CFrame = userCFrame
		})
		Util.Debris:AddItem(v2, 0.35)
		task.spawn(function()
			task.wait(0.35)

			if v then
				v:Destroy()
			end

			if v2 then
				v2:Destroy()
			end
		end)
		local stringValue = Instance.new("StringValue")
		Util.Debris:AddItem(stringValue, 2)
		stringValue.Name = "SHV2ZFinalTrigger"
		stringValue.Parent = userRoot
		local character = game.Players.LocalPlayer and game.Players.LocalPlayer.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart == userRoot or humanoidRootPart == targetRoot) then
				local clone = script.StarkCC:Clone()
				Util.Debris:AddItem(clone, 1)
				clone.Parent = game:GetService("Lighting")
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Brightness = 0,
						Contrast = 0,
						Saturation = 0,
						TintColor = Color3.fromRGB(255, 255, 255)
					}
				)
				tween.Completed:Connect(function()
					if clone then
						clone:Destroy()
					end
				end)
				tween:Play()
			end
		end

		punchDart(userCFrame)
		Util.Sound:Play("Teleport", userRoot.Position, nil, math.random(6, 7) / 10, 1)
		Util.Sound:Play("HitKnockback", userRoot.Position, nil, math.random(9, 11) / 10, 0.5)
		local superhumanV2ZHit = Util.Anims:Get(userRoot.Parent, "SuperhumanV2ZHit")
		superhumanV2ZHit:Play()
		superhumanV2ZHit.TimePosition = 1.4
		superhumanV2ZHit:AdjustSpeed(1.2)
	end
end