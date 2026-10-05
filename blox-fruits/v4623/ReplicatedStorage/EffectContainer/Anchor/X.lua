local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local masterClock = Util.MasterClock
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.Luno.Misc
local _ = Util.PartCache
local cameraShaker = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local X = FX:WaitForChild("Anchor").X
local TweenService = game:GetService("TweenService")

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function ScreenCrackEffect(parent)
	local currentCamera = workspace.CurrentCamera
	task.spawn(function()
		task.wait(0.175)
		cameraShaker:ShakeOnce(20, 10, 0.15, 0.2)
		local clone = X.ScreenColor1:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.Parent = currentCamera
		local tween = TweenService:Create(clone, TweenInfo.new(0.05), {
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
		tween.Completed:Wait()
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
	task.spawn(function()
		task.wait(0.175)
		local clone = X.CameraFocus:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.Parent = parent
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
		end)

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

		task.wait(5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

local function DashTrail(clone, position)
	local position2 = clone.Position
	local magnitude = (position2 - position).Magnitude
	clone.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(20, 30)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v5 = math.random(25, 30) / 5
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function SlashTrail(clone, position, p)
	local position2 = clone.Position
	local magnitude = (position2 - position).Magnitude
	clone.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(10, 15)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v5 = math.random(25, 30) / 25

	if p == true then
		v5 *= 3
		v2 /= 3
	end

	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function AnchorSlash(parent, part, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local _ = data.SlashAngle2
	local cFrameAddition = data.CFrameAddition
	local clone = data.SlashType:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = part.CFrame
	clone.Weld.Part0 = part
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cFrameAddition * slashAngle
	clone.Parent = parent

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local startDelay = beam:GetAttribute("StartDelay")
		local v = beam
		local v2 = beam:GetAttribute("EndDelay")
		task.spawn(function()
			local tween = TweenService:Create(v, TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = v.Width0,
				Width1 = v.Width1
			})
			v.Width0 = 0
			v.Width1 = 0
			task.wait(startDelay)
			tween:Play()
		end)
	end

	for _ = 1, 3 do
		local tween = TweenService:Create(
			clone.Weld,
			TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					1.0471975511965976,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(1.3089969389957472, 0, 0)
	}):Play()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			local v = effect
			task.spawn(function()
				local endDelay = v:GetAttribute("EndDelay")
				local tween = TweenService:Create(
					v,
					TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end
end

local function EnemyCharacterHitSlash(CF1, _WorldOrigin2, humanoidRootPart)
	Util.Sound:Play("AnchorXHit", humanoidRootPart)

	for _ = 1, 5 do
		task.spawn(function()
			local clone = X.SlashTrail:Clone()
			Util.Debris:AddItem(clone, 3)
			clone.CFrame = CF1 * CFrame.new(math.random(-5, 5), math.random(-5, 5) / 2, math.random(-20, -15))
			clone.Parent = _WorldOrigin2

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			SlashTrail(
				clone,
				CFrame.new(clone.Position) * CFrame.new(
					math.random(-5, 5) * 3,
					math.random(20, 40),
					math.random(-5, 5) * 3
				).Position,
				false
			)
			SlashTrail(clone, CF1 * CFrame.new(0, -1, -19).Position, true)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end

	task.wait(0.4)
	task.spawn(function()
		local clone = X.UpperSlash:Clone()
		Util.Debris:AddItem(clone, 5)
		AnchorSlash(_WorldOrigin2, humanoidRootPart, {
			Multiplier = 2,
			SlashAngle = CFrame.Angles(-0.17453292519943295, 3.2288591161895095, 0),
			CFrameAddition = CFrame.new(0, 0, 0),
			SlashType = clone
		})
	end)
	task.spawn(function()
		task.wait(0.07)
		local clone = X.DownSlashImpact:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = CF1 * CFrame.new(0, 27, -25)
		clone.Parent = _WorldOrigin2

		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Funky")) then
				continue
			end

			for _ = 1, 9 do
				local clone2 = emitter:Clone()
				Util.Debris:AddItem(clone2, 5)
				clone2:SetAttribute("Funky", nil)
				clone2.Parent = emitter.Parent
				clone2.Drag = emitter.Drag + math.random(-2, 3)
				task.spawn(function()
					for i = 1, 14 do
						clone2.Acceleration = Vector3.new(
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5
						)
						task.wait(math.random(10, 20) / 200)
					end
				end)
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if humanoidRootPart and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart == humanoidRootPart or (workspace.CurrentCamera.CFrame.p - humanoidRootPart.Position).Magnitude < 90 then
			cameraShaker:ShakeOnce(20, 10, 0.15, 0.85)
		end

		task.wait(0.03)
		local v = CF1 * createVector(0, 0, -20)
		local ray, v2, v3 = Util.Ray(
			v + createVector(0, 1, 0),
			CFrame.new(v).UpVector * -20,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone2 = X.DownSlamGroundHit:Clone()
			Util.Debris:AddItem(clone2, 5)
			clone2.CFrame = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), CF1.LookVector) + v2, v3)
			clone2.Parent = _WorldOrigin2

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BaseUpperSlash(CF1, humanoidRootPart, parent)
	Util.Sound:Play("AnchorXHitStart", humanoidRootPart)
	task.spawn(function()
		task.spawn(function()
			local clone = X.UpperSlash:Clone()
			Util.Debris:AddItem(clone, 5)
			AnchorSlash(parent, humanoidRootPart, {
				Multiplier = 2,
				SlashAngle = CFrame.Angles(-1.5707963267948966, 0.2617993877991494, 0),
				CFrameAddition = CFrame.new(0, 0, 0),
				SlashType = clone
			})
		end)
		task.wait(0.075)
		local clone = X.UpperSlashImpact:Clone()
		Util.Debris:AddItem(clone, 4)
		clone.CFrame = CF1 * CFrame.new(0, 0, -20) * CFrame.Angles(0, 0, -0.17453292519943295)
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Funky")) then
				continue
			end

			for _ = 1, 10 do
				local clone2 = emitter:Clone()
				Util.Debris:AddItem(clone2, 5)
				clone2:SetAttribute("Funky", nil)
				clone2.Parent = emitter.Parent
				clone2.Drag = emitter.Drag + math.random(-2, 3)
				task.spawn(function()
					for i = 1, 14 do
						clone2.Acceleration = Vector3.new(
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5
						)
						task.wait(math.random(10, 20) / 200)
					end
				end)
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local v = CF1 * createVector(5, 0, -1)
		local ray, position, v3 = Util.Ray(
			v + createVector(0, 1, 0),
			CFrame.new(v).UpVector * -20,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone2 = X.GroundImpactSpark:Clone()
			Util.Debris:AddItem(clone2, 3)
			clone2.CFrame = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), CF1.LookVector) + position, v3) * CFrame.Angles(
				0,
				0,
				-0.17453292519943295
			)
			clone2.Parent = parent

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone3 = X.GroundCut:Clone()
			Util.Debris:AddItem(clone3, 3)
			clone3.CFrame = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), CF1.LookVector) + position, v3)
			clone3.Position = position
			clone3.Parent = parent

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)
end

local function LeviHitSlash(slashCF, humanoidRootPart, _WorldOrigin2)
	local cFrame = nil
	Util.Sound:Play("AnchorXHitArmored", humanoidRootPart)
	task.spawn(function()
		task.spawn(function()
			local clone = X.UpperSlash:Clone()
			Util.Debris:AddItem(clone, 5)
			AnchorSlash(_WorldOrigin2, humanoidRootPart, {
				Multiplier = 2.5,
				SlashAngle = CFrame.Angles(-1.5707963267948966, 0.4363323129985824, 0),
				CFrameAddition = CFrame.new(0, 0, 0),
				SlashType = clone
			})
		end)
		task.wait(0.075)
		local v2 = 15
		local _, v3, _ = Util.Ray(
			slashCF * CFrame.new(0, 0, 3).Position,
			CFrame.new(slashCF * CFrame.new(0, 0, 3).Position, slashCF * CFrame.new(0, 0, -v2).Position).LookVector * v2,
			{ workspace.Characters, workspace.Enemies }
		)
		local magnitude = (v3 - slashCF.Position).Magnitude
		cFrame = slashCF * CFrame.new(0, 0, -(magnitude * 0.9))
		local clone = X.UpperSlashImpact2:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = cFrame * CFrame.new(0, -25, 0) * CFrame.Angles(0, 0, -0.3490658503988659)
		clone.Parent = _WorldOrigin2

		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Funky")) then
				continue
			end

			for _ = 1, 10 do
				local clone2 = emitter:Clone()
				Util.Debris:AddItem(clone2, 4)
				clone2:SetAttribute("Funky", nil)
				clone2.Parent = emitter.Parent
				clone2.Drag = emitter.Drag + math.random(-2, 3)
				task.spawn(function()
					for i = 1, 14 do
						clone2.Acceleration = Vector3.new(
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5
						)
						task.wait(math.random(10, 20) / 200)
					end
				end)
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end
	end)
	task.wait(0.25)
	task.spawn(function()
		task.wait(0.07)
		local clone = X.DownSlashImpact2:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = cFrame * CFrame.Angles(0, 0, 0.5235987755982988)
		clone.Parent = _WorldOrigin2

		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Funky")) then
				continue
			end

			for _ = 1, 9 do
				local clone2 = emitter:Clone()
				Util.Debris:AddItem(clone2, 5)
				clone2:SetAttribute("Funky", nil)
				clone2.Parent = emitter.Parent
				clone2.Drag = emitter.Drag + math.random(-2, 3)
				task.spawn(function()
					for i = 1, 14 do
						clone2.Acceleration = Vector3.new(
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5,
							math.random(-50, 50) * 2.5
						)
						task.wait(math.random(10, 20) / 200)
					end
				end)
			end
		end

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

		task.wait(0.03)
		local character = game.Players.LocalPlayer.Character

		if character then
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and humanoidRootPart == humanoidRootPart2 then
				ScreenCrackEffect(_WorldOrigin2)
			end
		end

		local clone2 = X.ShieldBreakImpact:Clone()
		Util.Debris:AddItem(clone2, 3)
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin2

		for _, emitter in pairs(clone2:GetDescendants()) do
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
	end)
	task.spawn(function()
		local clone = X.UpperSlash:Clone()
		Util.Debris:AddItem(clone, 4)
		AnchorSlash(_WorldOrigin2, humanoidRootPart, {
			Multiplier = 2.75,
			SlashAngle = CFrame.Angles(-2.6179938779914944, -0.3490658503988659, 2.705260340591211),
			CFrameAddition = CFrame.new(0, 0, 0),
			SlashType = clone
		})
	end)
	task.wait(0.5)
end

return function(player)
	local ID = player.ID

	if ID == 1 then
		return
	end

	if ID == 2 then
		local character = player.Character
		local startCF = player.StartCF
		local endCF = player.EndCF
		local timestamp = player.Timestamp
		local _ = player.Duration

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				if (endCF.p - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
					return
				end

				Util.Sound:Play("AnchorXFire", humanoidRootPart)
				local magnitude = (startCF.Position - endCF.Position).Magnitude
				local _ = masterClock:GetTime() - timestamp
				local _, v, _ = Util.Ray(
					startCF.Position,
					CFrame.new(startCF.Position, (startCF * CFrame.new(0, 0, -magnitude)).Position).LookVector * magnitude,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local clone = X.StartImpact:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.CFrame = startCF
				clone.Parent = _WorldOrigin

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

				local clone2 = X.Dash:Clone()
				Util.Debris:AddItem(clone2, 2)
				clone2.CFrame = startCF
				clone2.Parent = _WorldOrigin
				clone2.Weld.Part0 = humanoidRootPart

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter:GetAttribute("Funky") then
						for _ = 1, 9 do
							local clone3 = emitter:Clone()
							Util.Debris:AddItem(clone3, 5)
							clone3:SetAttribute("Funky", nil)
							clone3.Parent = emitter.Parent
							clone3.Drag = emitter.Drag + math.random(-2, 3)
							task.spawn(function()
								for i = 1, 14 do
									clone3.Acceleration = Vector3.new(
										math.random(-50, 50) * 2.5,
										math.random(-50, 50) * 2.5,
										math.random(-50, 50) * 2.5
									)
									task.wait(math.random(10, 20) / 200)
								end
							end)
						end
					end

					emitter.Enabled = true
				end

				for _ = 1, 4 do
					task.spawn(function()
						local clone3 = X.DashTrail:Clone()
						Util.Debris:AddItem(clone3, 3)
						clone3.CFrame = startCF * CFrame.new(
							math.random(-5, 5),
							math.random(-5, 5) / 2,
							math.random(-5, 5)
						)
						clone3.Parent = _WorldOrigin

						for _, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						DashTrail(
							clone3,
							CFrame.new(v, startCF.Position) * CFrame.new(
								math.random(-5, 5),
								math.random(-5, 5) / 2,
								math.random(-7, -5)
							).Position
						)

						for _, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end

				task.wait(0.3)
				clone2.Weld.Enabled = false
				clone2.Anchored = true

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end
		end
	elseif ID == 3 then
		local char1 = player.Char1
		local char2 = player.Char2
		local CF1 = player.CF1
		local _ = player.ServerTime
		local humanoidRootPart = char1 and char1:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if char2 then
				local humanoidRootPart2 = char2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					BaseUpperSlash(CF1, humanoidRootPart, _WorldOrigin) -- equivalent call inferred; original call site unknown
					EnemyCharacterHitSlash(CF1, _WorldOrigin, humanoidRootPart, humanoidRootPart2)
				end
			else
				BaseUpperSlash(CF1, humanoidRootPart, _WorldOrigin) -- equivalent call inferred; original call site unknown
			end
		end
	elseif ID == 4 then
		local char = player.Char
		local slashCF = player.SlashCF
		local _ = player.ServerTime
		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			LeviHitSlash(slashCF, humanoidRootPart, _WorldOrigin)
		end
	end
end