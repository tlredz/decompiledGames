local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local lampSkill1 = FX:WaitForChild("FoxLamp").X.LampSkill1
local _WorldOrigin = workspace._WorldOrigin

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

local function viewerIsClose(p, p2, callback)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function FlameBurst(root, p, folder, duration)
	local flag = false
	task.spawn(function()
		local clone = lampSkill1.Phase2.HitFlame:Clone()
		clone:SetPrimaryPartCFrame(p * CFrame.new(0, 0, -1))
		clone.Parent = folder
		clone.Weld.Part0 = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		if typeof(duration) == "table" then
			os.clock()

			repeat
				task.wait()
			until duration.OnGoing == false
		else
			task.wait(duration)
		end

		flag = true
		clone.Weld:Destroy()

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = true
			end
		end
	end)
	task.spawn(function()
		local v = math.random(25, 40) / 100

		for _ = 1, 10 do
			if flag then
				break
			end

			local clone = lampSkill1.Phase2.TornadoSlash:Clone()
			clone.CFrame = root.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			clone.Parent = folder

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= 1.25
					descendant.CurveSize1 *= 1.25
					descendant.Width0 *= 1.25
					descendant.Width1 *= 1.25
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = descendant.CurveSize0 * 1.75,
							CurveSize1 = descendant.CurveSize1 * 1.75,
							Width0 = descendant.Width0 * 1.75,
							Width1 = descendant.Width1 * 1.75
						}
					)
					tween:Play()
					local v2 = descendant
					task.spawn(function()
						tween.Completed:Wait()
						local endDelay = v2:GetAttribute("EndDelay")
						tween = TweenService:Create(
							v2,
							TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * 1.25,
						descendant.Position.Y * 1.25,
						descendant.Position.Z * 1.25
					)
					TweenService:Create(descendant, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(
							descendant.Position.X * 1.75,
							descendant.Position.Y * 1.75,
							descendant.Position.Z * 1.75
						)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(30, 50)

				for i = 1, 7 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, -7.142857142857143) * CFrame.Angles(
								0,
								0,
								(math.rad(v3))
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
			task.wait(0.1)
		end
	end)
end

local function FlameTrails(cframe, parent)
	local clone = lampSkill1.Phase2.FlameTrail:Clone()
	clone.CFrame = cframe
	clone.Parent = parent

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local position = clone.Position
	local v = clone.CFrame * CFrame.new(0, 0, -math.random(85, 125)).Position
	local magnitude = (position - v).Magnitude
	clone.CFrame = CFrame.new(position, v)
	local v2 = (position - v) / 2
	local cframe2 = CFrame.new(CFrame.new(position) * (v2 / -1.5))
	local cframe3 = CFrame.new(CFrame.new(v) * (v2 / 1.5))
	local v3 = CFrame.new(cframe2.Position, cframe2.Position + cframe.LookVector) * CFrame.Angles(
		0,
		0,
		(math.rad((math.random(-180, 180))))
	)
	local v4 = CFrame.new(cframe3.Position, cframe3.Position + cframe.LookVector) * CFrame.Angles(
		0,
		0,
		(math.rad((math.random(-180, 180))))
	)
	local v5 = math.random(20, 30) * 1.5
	local v6 = v3 * CFrame.new(0, math.random(v5, v5 * 2), math.random(-v5 / 3, v5 / 3)).Position
	local v7 = v4 * CFrame.new(0, math.random(v5, v5 * 2), math.random(-v5 / 3, v5 / 3)).Position
	local v8 = math.random(25, 30) / 5
	local lastTime = tick()
	local v9 = magnitude / v8 / 60

	while tick() - lastTime < v9 do
		local v10 = (tick() - lastTime) / v9
		local v11 = cubicBezier(v10, position, v6, v7, v)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v11, v), v10)
		RunService.Heartbeat:Wait()
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GroundRocks(p, parent)
	task.spawn(function()
		for _ = 1, 5 do
			task.spawn(function()
				local clone = lampSkill1.Rock:Clone()
				local cFrame = p.CFrame
				clone.Position = cFrame * CFrame.new(math.random(-25, 25), math.random(-1, 3), math.random(-25, -5)).Position
				clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
				clone.Size = Vector3.new(math.random(2, 5), math.random(2, 5), math.random(2, 5))
				clone.Parent = parent
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
				bodyVelocity.P = 5000
				bodyVelocity.Parent = clone
				local v = CFrame.new(clone.Position, clone.Position + cFrame.LookVector) * CFrame.new(0, 50, 0)
				bodyVelocity.Velocity = v.LookVector * math.random(5, 50) * 10
				rocks:ApplyCollision(clone, nil, true)
				task.wait(math.random(5, 10) / 100)
				clone.Material = Enum.Material.Neon
				TweenService:Create(clone, TweenInfo.new(0.25), {
					Color = Color3.fromRGB(85, 130, 255)
				}):Play()
				bodyVelocity.Velocity = v.LookVector * math.random(25, 150)
				task.wait(math.random(5, 25) / 100)
				task.wait(0.15)
				Util.Debris:AddItem(bodyVelocity, 0.5)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				Util.Sound:Play("V Attacks- Rock flames ", clone)
				TweenService:Create(clone, TweenInfo.new(0.25), {
					Size = createVector(0, 0, 0),
					Color = Color3.fromRGB(3, 7, 13)
				}):Play()
				task.wait(0.225)
				bodyVelocity.Velocity = v.LookVector * 5

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait(0.05)
		end
	end)
end

local function Dash(root, folder, p)
	Util.Sound:Play("F Attacks- Transformed Lunge", root)
	local _ = p.DashRange
	local dashSpeed = p.DashSpeed
	local cFrame = root.CFrame
	local clone = lampSkill1.Phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	local clone2 = lampSkill1.Phase1.Dash:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	clone2.Weld.Part0 = root

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		task.wait(dashSpeed * 0.75)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "LineAttachment" then
				emitter.Enabled = false
			end
		end

		task.wait(dashSpeed * 0.125)

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StaffOrb(cFrame, folder, root, boolValue)
	task.spawn(function()
		local clone = lampSkill1.Phase2.StaffOrb:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		clone.Weld.Part0 = root

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				if effect:GetAttribute("EMIT") then
					effect:Emit(effect:GetAttribute("EmitCount"))
				else
					local v = effect
					task.spawn(function()
						task.wait(0.1)
						v.Enabled = true
					end)
				end
			elseif effect.Name == "OrbWeldA" then
				local tween = TweenService:Create(
					effect,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						C0 = effect.C0
					}
				)
				effect.C0 = CFrame.new(-5, 2.5, 0)
				tween:Play()
			elseif effect.Name == "OrbWeldB" then
				local tween = TweenService:Create(
					effect,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						C0 = effect.C0
					}
				)
				effect.C0 = CFrame.new(0, 3, 0)
				tween:Play()
			elseif effect.Name == "OrbWeldC" then
				local tween = TweenService:Create(
					effect,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						C0 = effect.C0
					}
				)
				effect.C0 = CFrame.new(5, 2.5, 0)
				tween:Play()
			end
		end

		task.wait(0.15)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0.25
		TweenService:Create(numberValue, TweenInfo.new(0.75), {
			Value = 0.1
		}):Play()
		local lastTime = nil

		while true do
			local value = numberValue.Value
			TweenService:Create(clone.Weld, TweenInfo.new(value, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					0,
					-2.0943951023931953
				)
			}):Play()

			if lastTime == nil or tick() - lastTime >= 0.05 then
				lastTime = tick()
				task.spawn(function()
					FlameTrails(CFrame.new(clone.OrbA.Position, clone.OrbA.Position + root.CFrame.LookVector), folder)
				end)
			end

			task.wait(value)

			if boolValue.Value ~= false then
				continue
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Trail") then
					effect.Enabled = false
				elseif effect:IsA("ParticleEmitter") then
					effect:Destroy()
				end
			end

			break
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GroundBurn(cFrame, root, folder, value, raycastParams)
	task.spawn(function()
		local lastTime = tick()
		local clone = lampSkill1.Phase2.GroundBurn:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		local lastTime2 = tick()
		local v = false

		while true do
			local cFrame2 = root.CFrame
			local raycastResult = workspace:Raycast(
				cFrame2 * CFrame.new(0, 0, -50).Position + createVector(0, 1, 0),
				createVector(-0, -15, -0),
				raycastParams
			)

			if raycastResult then
				clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + cFrame2.LookVector)

				if v == false then
					v = true

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				if tick() - lastTime >= 0.15 then
					lastTime = tick()
					GroundRocks(root, folder) -- equivalent call inferred; original call site unknown
				end
			elseif v == true then
				v = false

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			task.wait(0.1)

			if typeof(value) ~= "table" or value.OnGoing ~= false then
				if not (typeof(value) == "number" and value <= tick() - lastTime2) then
					continue
				end
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			break
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CameraEffect(p)
	local position = p.Position
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 80 then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(10, 7, 0.15, 1.2)
				local clone = lampSkill1.Phase3.ScreenColor:Clone()
				clone.Parent = game.Lighting
				local tween = TweenService:Create(clone, TweenInfo.new(0.025), {
					Brightness = clone.Brightness,
					Contrast = clone.Contrast,
					Saturation = clone.Saturation,
					TintColor = clone.TintColor
				})
				clone.Brightness = 0
				clone.Contrast = 0
				clone.Saturation = 0
				clone.TintColor = Color3.fromRGB(255, 255, 255)
				tween:Play()
				task.wait(0.1)
				local tween2 = TweenService:Create(clone, TweenInfo.new(0.1), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween2:Play()
				tween2.Completed:Wait()
				clone:Destroy()
			end)
		end
	end
end

local function SwordSlash(folder, folder2, _, folder3, root)
	Util.Sound:Play("Basic Attack 4", root)
	coroutine.wrap(function()
		task.wait(0.1)
		folder2.CFrame = root.CFrame * CFrame.new(0, 3, -25) * CFrame.Angles(0, 0, 1.7453292519943295)

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	task.delay(0.016666666666666666, function()
		folder.CFrame = root.CFrame * CFrame.new(0, 5, 3)
		folder.Weld.Part0 = root
		folder.Weld.C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			1.7453292519943295
		) * CFrame.Angles(3.490658503988659, 0, 0)
		folder.Parent = folder3
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-2.6179938779914944,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld:Destroy()
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-1.7453292519943295, 0, 0)
		}):Play()
	end)
end

return function(data)
	local root = data.Root
	local held = data.Held
	local victimValue = data.VictimValue

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	if victimValue:FindFirstChild("EndCFrame") then
		task.spawn(function()
			TweenService:Create(root, TweenInfo.new(data.Duration), {
				CFrame = victimValue.EndCFrame.Value
			}):Play()
		end)
	else
		local childAddedConnection = nil
		childAddedConnection = victimValue.ChildAdded:Connect(function(child)
			if child.Name == "EndCFrame" then
				TweenService:Create(root, TweenInfo.new(data.Duration), {
					CFrame = child.Value
				}):Play()
				childAddedConnection:Disconnect()
			end
		end)
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 10)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
	local range = data.Range
	local duration = data.Duration
	local flameDuration = data.FlameDuration

	if held == false then
		Dash(root, folder, {
			DashRange = range,
			DashSpeed = duration
		})
		local lastTime = os.clock()

		repeat
			task.wait()
		until victimValue.Value or os.clock() - lastTime > 1.5

		if victimValue.Value then
			local lastTime2 = os.clock()

			repeat
				task.wait()
			until victimValue:FindFirstChild("EndCFrame") or os.clock() - lastTime2 > 0.5

			local v = root.CFrame * CFrame.new(0, 0, -7)

			if victimValue:FindFirstChild("EndCFrame") then
				v = victimValue.EndCFrame.Value * CFrame.new(0, 0, -7)
			end

			Util.Sound:Play("F Attacks- Spin Slash", v)
			local clone = lampSkill1.Phase2.TargetHit:Clone()
			clone.CFrame = victimValue.Value.CFrame
			clone.Parent = folder
			DeleteImpactAfterDuration(clone)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Value = true
			boolValue.Parent = folder
			StaffOrb(v, folder, root, boolValue) -- equivalent call inferred; original call site unknown
			local v2 = Util.Sound:Play("KitsuneZtransformedDashSpin", root.Position)
			local v3 = Util.Sound:Play("C Attacks- Large Bullet Explosion", root.Position)
			task.wait(0.1)
			Util.Sound:Play("F Attacks- Spin Slash", v)
			FlameBurst(root, v, folder, flameDuration)
			GroundBurn(v, root, folder, flameDuration, raycastParams) -- equivalent call inferred; original call site unknown
			CameraEffect(v) -- equivalent call inferred; original call site unknown
			task.wait(flameDuration)
			Util.Sound:FadeOut(v2, 0.8)
			Util.Sound:FadeOut(v3, 0.8)
			boolValue.Value = false
		end
	else
		Util.Sound:Play("F Attacks- Spin Slash", root.Position)
		local v = Util.Sound:Play("KitsuneZtransformedDashSpin", root.Position)
		local v2 = Util.Sound:Play("C Attacks- Large Bullet Explosion", root.Position)
		local cFrame = root.CFrame * CFrame.new(0, 0, -7)
		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		boolValue.Parent = folder
		StaffOrb(cFrame, folder, root, boolValue) -- equivalent call inferred; original call site unknown
		local lastTime = os.clock()
		local v4 = {
			OnGoing = true
		}
		FlameBurst(root, cFrame, folder, v4)
		GroundBurn(cFrame, root, folder, v4, raycastParams) -- equivalent call inferred; original call site unknown
		CameraEffect(cFrame) -- equivalent call inferred; original call site unknown

		while not (os.clock() - lastTime > 0.4) or data.Holding.Value ~= false and data.Holding:IsDescendantOf(workspace) do
			task.wait()

			if flameDuration < os.clock() - lastTime then
				break
			end
		end

		Util.Sound:FadeOut(v, 0.8)
		Util.Sound:FadeOut(v2, 0.8)
		v4.OnGoing = false
		boolValue.Value = false

		if not victimValue:FindFirstChild("Dash") then
			local lastTime2 = tick()
			local dash = false

			while tick() - lastTime2 < 0.3 do
				dash = victimValue:FindFirstChild("Dash")

				if dash then
					break
				else
					task.wait()
				end
			end

			if not dash then
				return
			end
		end

		Dash(root, folder, {
			DashRange = range,
			DashSpeed = duration
		})
		local _ = root.CFrame
		task.wait(0.05)
		local clone = lampSkill1.Phase3.Slash4:Clone()
		local clone2 = lampSkill1.Phase3.SlashHit4:Clone()

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= 1.5
				descendant.CurveSize1 *= 1.5
				descendant.Width0 *= 1.5
				descendant.Width1 *= 1.5
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * 1.5,
					descendant.Position.Y * 1.5,
					descendant.Position.Z * 1.5
				)
			end
		end

		clone2.Parent = folder
		SwordSlash(clone, clone2, raycastParams, folder, root, raycastParams)
		local character = game.Players.LocalPlayer.Character

		if root == (character and character:FindFirstChild("HumanoidRootPart")) then
			Util.CameraShaker:ShakeOnce(5, 6, 0.15, 0.25)
		end
	end
end