local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local renderLoop = Util.RenderLoop
local _ = Util.MasterClock
local _ = Util.Sound
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lerpOutExpo(p, p2, p3)
	local v = 1 - (1 - p3) * (1 - p3) / math.exp(4 * p3)
	return p + (p2 - p) * v
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

-- equivalent calls inferred from this helper; original call sites unknown
local function punchCharge(p, duration, charged, parent)
	task.spawn(function()
		local v = {
			Glow = { 2, 0.1, tick() },
			LineSpikes = { 1, 0.025, tick() },
			RandLightning = { 1, 0.1, tick() },
			RandLightning2 = { 1, 0.1, tick() },
			Rays = { 3, 0.1, tick() },
			MotionLines = { 2, 0.05, tick() }
		}
		local v2 = {
			Air = { 1, 0.1, tick() },
			ChargeRing = { 1, 0.5, tick() },
			Star = { 1, 0.01, tick() },
			Twistins = { 1, 0.05, tick() }
		}
		local v3 = {
			Glow = 1,
			LineSpikes = 0.5,
			RandLightning = 1,
			RandLightning2 = 1,
			Rays = 1,
			Twistins = 1
		}
		local children = {}
		local children2 = {}
		local parent2 = Util.Sound:Play(
			charged and "Charge" or "OtherBeamCharge",
			p.Position,
			nil,
			charged and 1.4 + math.random(10, 18) / 100 or 5 + math.random(10, 18) / 100,
			charged and 1.6 or 1
		)

		if charged then
			local chorusSoundEffect = Instance.new("ChorusSoundEffect")
			chorusSoundEffect.Parent = parent2
		end

		local clone = script.ScintillantPunch:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.CFrame = p * CFrame.new(0, 5, 10)
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone.Initial:GetChildren()) do
			if not charged then
				child.Lifetime = NumberRange.new(child.Lifetime.Min / 1.5, child.Lifetime.Max / 1.5)
			end

			if v[child.Name] then
				table.insert(children, child)
			end
		end

		if parent then
			local fist = clone.Fist
			Util.Debris:AddItem(fist, 5)
			fist.Parent = parent

			for _, child in pairs(fist:GetChildren()) do
				if v2[child.Name] then
					table.insert(children2, child)
				end
			end
		end

		for _, v5 in pairs(children) do
			if v5 == nil then
				continue
			end

			local tween = TweenService:Create(
				v5,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					TimeScale = v5.Name == "MotionLines" and 0.5 or v3[v5.Name]
				}
			)
			tween.Completed:Connect(function() end)
			tween:Play()
		end

		local lastTime = tick()
		local _ = tick() - 1

		while tick() - lastTime < duration do
			if tick() - lastTime < duration / 4 * 3 then
				for _, v5 in pairs(children) do
					local nows = v[v5.Name]

					if not (tick() - nows[3] > nows[2]) then
						continue
					end

					v5:Emit(nows[1])
					nows[3] = tick()
				end

				clone.MotionLines:Emit(3)
			end

			if parent then
				for _, v5 in pairs(children2) do
					local nows = v2[v5.Name]

					if not (tick() - nows[3] > nows[2]) then
						continue
					end

					v5:Emit(nows[1])
					nows[3] = tick()
				end
			end

			task.wait()
		end

		for _, v5 in pairs(children) do
			if v5 ~= nil then
				v5.Enabled = false
			end
		end
	end)
end

local function solidPunch(cFrame, charged)
	local v = {
		FloatSparks = charged and 45 or 25,
		EnergyClouds = 25,
		SilverLegs = 15,
		Spikes = 5,
		RainbowSpikes = 5,
		Updraft = 5,
		Shockwave = 1
	}
	local v2 = renderLoop.new(tick(), 3, 4, 60)
	v2:SetGroupFunction("Rings", function(instance, p, data, p2)
		local v3 = math.min((tick() - p) / data.Life, 1)
		local v4 = 0 + (data.SizeGoal.X - 0) * v3
		local v5 = data.Transparency[1]
		local transparency = v5 + (data.Transparency[2] - v5) * v3
		instance.CFrame = instance.CFrame * CFrame.new(0, data.Speed * p2, 0) * CFrame.Angles(0, math.rad(30 * p2), 0)
		instance.Size = Vector3.new(v4, 0 + (data.SizeGoal.Y - 0) * v3, v4)
		instance.Transparency = transparency

		if instance.Transparency >= 1 then
			instance:Destroy()
		end
	end)
	v2:SetGroupFunction("DecalRings", function(instance, p, data, p2)
		local v3 = tick() - p
		local v4 = math.min(v3 / data.Life, 1)
		local v5 = lerpOutExpo(0, data.SizeGoal.X, v4) -- equivalent call inferred; original call site unknown
		local transparency = lerpOutExpo(data.Transparency[1], data.Transparency[2], v4) -- equivalent call inferred; original call site unknown
		instance:SetPrimaryPartCFrame(instance.WindA.CFrame * CFrame.new(0, data.Speed * p2, 0) * CFrame.Angles(
			0,
			math.rad(5 * p2),
			0
		))

		for _, v9 in pairs({ instance.WindA, instance.WindB }) do
			local mesh = v9.Mesh
			local v10 = v5 * (v9.Name == "WindA" and -1 or 1)
			local Y = data.SizeGoal.Y
			mesh.Scale = Vector3.new(v10, lerpOutExpo(0, Y, v4), v5)
			v9.Decal.Transparency = transparency
		end

		if data.Life <= v3 then
			instance:Destroy()
		end
	end)
	v2:Start()
	task.spawn(function()
		for i = 1, 3 do
			local clone = script.WindMesh:Clone()
			Util.Debris:AddItem(clone, 3)
			clone.Size = Vector3.new()
			clone.Transparency = -2
			clone.CFrame = cFrame * CFrame.new(0, 0, i * -20) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			clone.Parent = _WorldOrigin
			v2:AddInstance("Rings", clone, {
				Index = i,
				Life = i * 0.2,
				SizeGoal = createVector(80, 20, 80),
				Transparency = { -3, 1 },
				Speed = 2
			})

			if charged then
				local clone2 = script.WindRing:Clone()
				Util.Debris:AddItem(clone2, 3)
				clone2.WindA.Mesh.Scale = Vector3.new()
				clone2.WindB.Mesh.Scale = Vector3.new()
				clone2.WindA.Decal.Transparency = 0
				clone2.WindB.Decal.Transparency = 0
				clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, i * -20) * CFrame.Angles(1.5707963267948966, 0, 0))
				clone2.Parent = _WorldOrigin
				v2:AddInstance("DecalRings", clone2, {
					Index = i,
					Life = i * 0.8,
					SizeGoal = createVector(40, 10, 40),
					Transparency = { 0, 1 },
					Speed = -0.05
				})
			end

			task.wait(0.05)
		end
	end)
	Util.Sound:Play(
		"DeepPunch",
		cFrame.Position,
		nil,
		charged and 0.85 + math.random(-5, 5) / 100 or 1 + math.random(-5, 5) / 100,
		2.5
	)

	if charged then
		local parent = Util.Sound:Play("CannonFire", cFrame.Position, nil, 0.75 + math.random(-5, 5) / 100, 0.3)
		local chorusSoundEffect = Instance.new("ChorusSoundEffect")
		chorusSoundEffect.Parent = parent
	end

	local clone = script.ScintillantPunch:Clone()
	Util.Debris:AddItem(clone, 3)
	local clone2 = script.AfterPunchFX:Clone()
	Util.Debris:AddItem(clone2, 3)
	clone.CFrame = cFrame * CFrame.new(0, 5, 10)
	clone2.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	task.spawn(function()
		for _ = 1, charged and 2 or 1 do
			for _, child in pairs(clone.Burst:GetChildren()) do
				if v[child.Name] then
					child:Emit(v[child.Name])
				end
			end

			task.wait(0.05)
		end
	end)
	clone2.Attachment.Star:Emit(charged and math.random(10, 15) or math.random(5, 8))
	clone2.Attachment.PunchEndAir:Emit(charged and math.random(3, 5) or math.random(1, 2))
	local position = cFrame.Position
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 80 then
			Util.CameraShaker:ShakeOnce(25, 25, 0.1, 1)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function afterImage(parts, transparency, material, color, duration, cframe, magnitude)
	task.spawn(function()
		local clone = script.DashTrail:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = cframe
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cframe and clone.CFrame + cframe.lookVector.Unit * magnitude or clone.CFrame
			}
		)
		tween.Completed:Connect(function()
			task.spawn(function()
				task.wait(1)

				if clone then
					clone:Destroy()
				end
			end)
		end)
		tween:Play()

		for _, item in pairs(parts) do
			if item == nil then
				continue
			end

			local v = item:FindFirstChildOfClass("SpecialMesh") and true or false
			local clone2 = item:Clone()

			if clone2:IsA("MeshPart") then
				clone2.TextureID = ""
			end

			Util.Debris:AddItem(clone2, duration + 0.5)

			if #clone2:GetDescendants() > 0 then
				if v then
					for _, specialMesh in pairs(clone2:GetChildren()) do
						if not specialMesh:IsA("SpecialMesh") then
							specialMesh:Destroy()
						end
					end
				else
					clone2:ClearAllChildren()
				end
			end

			clone2.CFrame = item.CFrame
			clone2.Material = material
			clone2.Color = color
			clone2.Transparency = transparency
			clone2.Parent = _WorldOrigin
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					CFrame = cframe and clone2.CFrame + cframe.lookVector.Unit * magnitude or clone2.CFrame
				}
			)
			tween2.Completed:Connect(function()
				if clone2 then
					clone2:Destroy()
				end
			end)
			tween2:Play()
		end
	end)
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local character = player.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Humanoid
			local holdValue = player.HoldValue

			if humanoidRootPart and humanoid and holdValue then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
					return
				end

				local v = Util.Sound:Play("AuraSound", humanoidRootPart, nil, 1.3, 0.8)
				Util.Debris:AddItem(v, 60)
				v.Looped = true
				local clone = script.CChargeAura.Attachment:Clone()
				Util.Debris:AddItem(clone, 60)
				clone.Parent = humanoidRootPart
				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.05 or diedConnection and player.HoldValue and player.HoldValue.Value == true
				end

				tick()

				while (tick() - lastTime < 0.05 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid do
					RunService.RenderStepped:Wait()
				end

				if v then
					v:Destroy()
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

				if diedConnection then
					diedConnection:Disconnect()
				end
			end
		end
	elseif stage == 2 then
		local char = player.Char
		local _ = player.TargetChar
		local _ = player.Timestamp
		local _ = player.TravelTime
		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local v = {
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

			for _, part in pairs(humanoidRootPart.Parent:GetChildren()) do
				if part:IsA("BasePart") and v[part.Name] then
					table.insert(parts, part)
				end
			end

			local targetPosition = player.TargetPosition
			local magnitude = (humanoidRootPart.Position - targetPosition).magnitude
			afterImage(
				parts,
				0.2,
				"Neon",
				Color3.fromRGB(245, 255, 192),
				0.2,
				CFrame.new(humanoidRootPart.Position, targetPosition),
				magnitude
			) -- equivalent call inferred; original call site unknown
			local parent = Util.Sound:Play(
				"PlasmaZap",
				humanoidRootPart.Position,
				nil,
				0.7 + math.random(-15, 5) / 100,
				0.5
			)
			local chorusSoundEffect = Instance.new("ChorusSoundEffect")
			chorusSoundEffect.Parent = parent
			local position = humanoidRootPart.Position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and (humanoidRootPart2.Position - position).magnitude <= 20 then
					Util.CameraShaker:ShakeOnce(5, 5, 0.1, 0.4)
				end
			end
		end
	elseif stage == 3 then
		local targetChar = player.TargetChar
		local humanoidRootPart

		if targetChar then
			humanoidRootPart = targetChar:FindFirstChild("HumanoidRootPart") or nil
		end

		local travelTime = player.TravelTime
		local timestamp = player.Timestamp
		local _ = player.EndLag
		local grabTime = player.GrabTime
		local char = player.Char
		local charged = player.Charged
		local humanoidRootPart2 = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			if (humanoidRootPart2.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local duration = math.max(grabTime - (Util.MasterClock:GetTime() - timestamp), 0.1)
			local v2 = char == game.Players.LocalPlayer.Character
			local _ = humanoidRootPart2.Position
			local targetPosition = player.TargetPosition
			local magnitude = (humanoidRootPart2.Position - targetPosition).magnitude
			local cFrame = CFrame.new(humanoidRootPart2.Position, targetPosition) * CFrame.new(0, 0, -magnitude + 5)
			local leftHand = char:FindFirstChild("LeftHand")

			if humanoidRootPart then
				punchCharge(cFrame, math.max(duration - 0.2, 0.1), charged, leftHand or nil) -- equivalent call inferred; original call site unknown
				Util.Sound:Play("BuddhaGrab", humanoidRootPart.Position, nil, 1.6 + math.random(-15, 5) / 100, 1)
			end

			local stringValue

			if targetChar then
				stringValue = Instance.new("StringValue")
				Util.Debris:AddItem(stringValue, 1)
				stringValue.Name = "SHV2CGrabbed"
				stringValue.Parent = char
			else
				stringValue = nil
			end

			local function punchTimedFunction()
				if stringValue then
					stringValue:Destroy()
				end

				if v2 then
					humanoidRootPart2.CFrame = cFrame

					if targetChar then
						Util.BodyMover.new(char):Create("BodyGyro", {
							Priority = 10000,
							Duration = duration,
							CFrame = CFrame.new(humanoidRootPart2.Position, targetPosition)
						})
						Util.BodyMover.new(char):Create("BodyPosition", {
							Priority = 10000,
							Duration = duration,
							Position = humanoidRootPart2.Position
						})
					end
				end

				if targetChar then
					local superhumanV2CHit = Util.Anims:Get(char, "SuperhumanV2CHit")
					superhumanV2CHit:Play()
					superhumanV2CHit:AdjustSpeed(charged and 0.15 or 1.5)

					if charged then
						task.spawn(function()
							task.wait(0.75)

							if superhumanV2CHit then
								superhumanV2CHit.TimePosition = 0.3
								superhumanV2CHit:AdjustSpeed(1.5)
							end
						end)
					end

					local currentCamera = workspace.CurrentCamera
					local v4 = 0.016666666666666666
					task.spawn(function()
						local character = game.Players.LocalPlayer.Character
						local flag = false

						if character then
							local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart3 and (humanoidRootPart3.Parent == char or humanoidRootPart3.Parent == targetChar) then
								task.spawn(function()
									tick()
									local total = 1
									RunService:BindToRenderStep(
										"SHv2UltCam",
										Enum.RenderPriority.Camera.Value + 1,
										function()
											total += 4
											local v5 = { currentCamera.CFrame:GetComponents() }
											local v6 = currentCamera
											local fieldOfView = currentCamera.FieldOfView
											local v7 = 70 - total / 6 * 1.05 * math.cos(total / 4)
											local v8 = v4 * 60 * 0.1
											v6.FieldOfView = fieldOfView + (v7 - fieldOfView) * v8
											currentCamera.CFrame = CFrame.new(table.unpack(v5))
											v4 = RunService.RenderStepped:Wait()
										end
									)
								end)
								flag = true
							end
						end

						task.wait(duration)

						if flag then
							currentCamera.FieldOfView = 70
							RunService:UnbindFromRenderStep("SHv2UltCam")
						end

						solidPunch(cFrame * CFrame.new(0, 0, -3), charged)
					end)
				end
			end

			local tween = TweenService:Create(
				humanoidRootPart2,
				TweenInfo.new(travelTime * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = cFrame
				}
			)
			tween.Completed:Connect(function()
				punchTimedFunction()
			end)
			tween:Play()
			Util.Sound:Play("KiDash", humanoidRootPart2.Position, nil, 1.5 + math.random(-5, 5) / 100, 0.6)
		end
	end
end