local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local _ = Util.Sound
local _ = Util.PartCache
local cameraShaker = Util.CameraShaker
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Kitsune").X
local animation_2 = Instance.new("Animation")
animation_2.AnimationId = "rbxassetid://15534404249"
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://15534406382"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://15534408189"
local animation3 = Instance.new("Animation")
animation3.AnimationId = "rbxassetid://15534410702"

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

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function FoxSpin(folder, clone)
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
			end)()
		end

		task.wait(0.2)

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CurveSize0 = descendant.CurveSize0 * 0.5,
					CurveSize1 = descendant.CurveSize1 * 0.5
				}):Play()
			elseif descendant:IsA("Attachment") then
				TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = Vector3.new(
						descendant.Position.X * 0.5,
						descendant.Position.Y * 0.5,
						descendant.Position.Z * 0.5
					)
				}):Play()
			end
		end
	end)()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.075
	TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		Value = 0.025
	}):Play()

	for _ = 1, 20 do
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(numberValue.Value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					2.6179938779914944,
					0
				)
			}
		)
		tween:Play()
		TweenService:Create(clone, TweenInfo.new(numberValue.Value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(-0.13962634015954636, 0, 0)
		}):Play()
		tween.Completed:Wait()
	end

	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if beam:IsA("Beam") then
				beam:Destroy()
			end
		end
	end)()
end

local function FinalFoxSlam(folder)
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
				task.wait(startDelay / 2)
				tween:Play()
				task.wait(v2 / 2)
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
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-1.7453292519943295,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(-0.8726646259971648, 0, 0)
	}):Play()
end

local function GroundHit(position, p, p2)
	local ray, v, _ = Util.Ray(
		position + createVector(0, 1, 0),
		CFrame.new(position).UpVector * -10,
		{ workspace.Characters, workspace.Enemies },
		false
	)

	if ray then
		local clone = X.GroundHit:Clone()
		debris:AddItem(clone, 8)
		clone.CFrame = CFrame.new(v)
		Util.SetParentOverrideWithColor(clone, p, p2, "KitsuneFruitVFXColor")
		clone.Attachment.Orientation = Vector3.new(0, math.random(-90, 90), 0)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			coroutine.wrap(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				Util.EmitFix(v2, v2:GetAttribute("EmitCount"))
			end)()
		end
	end
end

local function ProjectileHit(_WorldOrigin2, folder, position, player)
	local descendants = folder:GetDescendants()
	local v = 1.25

	for _, instance in ipairs(descendants) do
		if instance:IsA("BasePart") then
			instance.Transparency = 1
		elseif instance:IsA("ParticleEmitter") then
			instance.Enabled = false
		end
	end

	local cframe = CFrame.Angles(0, 0, 1.5707963267948966)
	local clone = X.TailSpin:Clone()
	debris:AddItem(clone, 10)
	clone.CFrame = folder.CFrame
	clone.Weld.Part0 = folder
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe
	Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "KitsuneFruitVFXColor")
	local clone2 = X.TailSpin4:Clone()
	debris:AddItem(clone2, 10)
	clone2.CFrame = folder.CFrame
	clone2.Position = position
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin2, player, "KitsuneFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v2 = emitter
		coroutine.wrap(function()
			task.wait(1.25)
			v2.Enabled = false
		end)()
	end

	local clone3 = X.TailSpinHit:Clone()
	debris:AddItem(clone3, 5)
	clone3.CFrame = folder.CFrame
	clone3.Position = position + createVector(0, -1, 0)
	clone3.CFrame *= CFrame.new(0, -4, -10)
	Util.SetParentOverrideWithColor(clone3, _WorldOrigin2, player, "KitsuneFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v2 = emitter
		coroutine.wrap(function()
			task.wait(1)
			v2.Enabled = false
		end)()
	end

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= v
			descendant.CurveSize1 *= v
			descendant.Width0 *= v
			descendant.Width1 *= v
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * v,
				descendant.Position.Y * v,
				descendant.Position.Z * v
			)
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
			local v2 = descendant
			coroutine.wrap(function()
				task.wait(1)
				v2.Enabled = false
			end)()
		end
	end

	coroutine.wrap(function()
		for _ = 1, 7 do
			local position2 = position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position2).magnitude <= 70 then
					cameraShaker:ShakeOnce(5.5, 4, 0.125, 0.18)
				end
			end

			task.wait(0.1)
		end

		task.wait(0.1)
		local position3 = position
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position3).magnitude <= 70 then
				cameraShaker:ShakeOnce(11, 7, 0.15, 0.3)
			end
		end
	end)()
	local clone4 = X.TailWheelMain:Clone()
	clone4.CFrame = CFrame.new(position, position + folder.CFrame.LookVector)
	Util.SetParentOverrideWithColor(clone4, _WorldOrigin2, player, "KitsuneFruitVFXColor")

	for _, descendant in pairs(clone4:GetDescendants()) do
		if descendant:IsA("AnimationController") then
			local track = descendant.Animator:LoadAnimation(animation2)
			track:Play()
			track:AdjustSpeed(5)
		elseif descendant:IsA("MeshPart") then
			TweenService:Create(descendant, TweenInfo.new(0.35), {
				Size = Vector3.new(descendant.Size.X / 1.5, descendant.Size.Y * 1.6, descendant.Size.Z * 1.6)
			}):Play()
		end
	end

	FoxSpin(clone, clone2)
	task.wait(0.1)

	for _, descendant in pairs(clone4:GetDescendants()) do
		if descendant:IsA("AnimationController") then
			local playingAnimationTracks = descendant.Animator:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in pairs(playingAnimationTracks) do
				playingAnimationTrack:Stop()
			end

			descendant.Animator:LoadAnimation(animation3):Play()
		elseif descendant:IsA("MeshPart") then
			TweenService:Create(
				descendant,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.3),
				{
					Size = createVector(0, 0, 0),
					Transparency = 1
				}
			):Play()
		end
	end

	debris:AddItem(clone4, 3)
	task.wait(0.2)
	local clone5 = X.FinalTailSpin:Clone()
	debris:AddItem(clone5, 8)
	local cframe2 = CFrame.Angles(2.792526803190927, 0, 0)
	local v2 = 1.75

	for _, descendant in pairs(clone5:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= v2
			descendant.CurveSize1 *= v2
			descendant.Width0 *= v2 * 1.5
			descendant.Width1 *= v2 * 1.5
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * v2,
				descendant.Position.Y * v2,
				descendant.Position.Z * v2
			)
		end
	end

	clone5.CFrame = folder.CFrame * CFrame.new(0, 0, 7)
	clone5.Weld.Part0 = folder
	clone5.Weld.C0 = clone5.Weld.Part0.CFrame:ToObjectSpace(clone5.Weld.Part1.CFrame) * cframe2
	Util.SetParentOverrideWithColor(clone5, _WorldOrigin2, player, "KitsuneFruitVFXColor")
	local clone6 = X.FinalTailHit:Clone()
	debris:AddItem(clone6, 5)
	clone6.CFrame = clone3.CFrame
	Util.SetParentOverrideWithColor(clone6, _WorldOrigin2, player, "KitsuneFruitVFXColor")

	for _, emitter in pairs(clone6:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
		end
	end

	GroundHit(clone3.CFrame.Position, _WorldOrigin2, player)
	FinalFoxSlam(clone5)
end

local function DashTrails(clonesByClone, cframe, magnitude, durationPer)
	for _, item in pairs(clonesByClone) do
		local v = item
		coroutine.wrap(function()
			local v2 = (v:GetAttribute("TrailJobId") or 0) + 1
			v:SetAttribute("TrailJobId", v2)
			v.CFrame = cframe * CFrame.new(math.random(-20, 20) / 5, math.random(-15, 15) / 5, math.random(-1, 1))
			local position = v.Position
			local v3 = cframe * CFrame.new(math.random(-15, 15) / 10, math.random(-15, 15) / 10, -magnitude).Position
			local magnitude2 = (position - v3).Magnitude
			v.CFrame = CFrame.new(position, v3)
			local v4 = (position - v3) / 2
			local position2 = CFrame.new(CFrame.new(position) * (v4 / -1.5)).Position
			local position3 = CFrame.new(CFrame.new(v3) * (v4 / 1.5)).Position
			local v5 = magnitude2 / 5
			local v6 = position2 + Vector3.new(math.random(-v5, v5), math.random(-v5, v5), math.random(-v5, v5))
			local v7 = position3 + Vector3.new(math.random(-v5, v5), math.random(-v5, v5), math.random(-v5, v5))
			local lastTime = tick()
			local v8 = durationPer * (0.9 + math.random() * 0.1)

			while tick() - lastTime < v8 and v2 == v:GetAttribute("TrailJobId") do
				local v9 = (tick() - lastTime) / v8
				local v10 = cubicBezier(v9, position, v6, v7, v3)
				v.CFrame = v.CFrame:Lerp(CFrame.new(v10, v3), v9)
				RunService.Heartbeat:Wait()
			end
		end)()
	end
end

return function(player)
	local player2 = player.player
	local ID = player.ID

	if ID == 1 then
		local character = player.Character
		local holdValue = player.HoldValue
		math.random(1, 2)

		if not (character and holdValue) then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		local clone = X.Tail:Clone()
		Util.SetParentOverrideWithColor(clone, character, player2, "KitsuneFruitVFXColor")
		clone.RootPart.Weld.Part0 = humanoidRootPart
		local v = false
		local diedConnection = humanoid.Died:Once(function()
			v = true
		end)
		tick()

		local function running()
			local v2 = not v

			if v2 then
				if player.HoldValue == nil then
					return false
				else
					return player.HoldValue.Value == true
				end
			end

			return v2
		end

		while true do
			local v2 = not v

			if v2 then
				if player.HoldValue == nil then
					v2 = false
				else
					v2 = player.HoldValue.Value == true
				end
			end

			if v2 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid then
				RunService.Heartbeat:Wait()
			else
				if clone then
					debris:AddItem(clone, 1.5)
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				return
			end
		end
	elseif ID == 2 then
		local dashPoints = player.DashPoints
		local durationPer = player.DurationPer

		if (dashPoints[1].Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local clone = X.FoxBody:Clone()
		debris:AddItem(clone, #dashPoints * 0.5 + 2)
		clone.CFrame = dashPoints[1]
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "KitsuneFruitVFXColor")
		clone.Fox.AnimationController:LoadAnimation(animation):Play()
		clone.Anchored = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		Util.Sound:Play("KitsuneXZigzagBullet", clone)
		local clone2 = X.StartImpact:Clone()
		clone2.CFrame = dashPoints[1]
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "KitsuneFruitVFXColor")
		local clone3 = X.Dash:Clone()
		clone3.CFrame = dashPoints[1]
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "KitsuneFruitVFXColor")
		local _ = dashPoints[1]
		local clonesByClone = {}

		for _ = 1, 5 do
			local clone4 = X.DashTrail:Clone()
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "KitsuneFruitVFXColor")

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			clonesByClone[clone4] = clone4
		end

		for i = 1, #dashPoints do
			local dashPoint = dashPoints[i]
			local v

			if i < #dashPoints then
				v = CFrame.new(dashPoints[i + 1].Position, dashPoint.p) * CFrame.Angles(0, 3.141592653589793, 0)
				local magnitude = (dashPoint.p - dashPoints[i + 1].Position).Magnitude
				DashTrails(clonesByClone, CFrame.new(dashPoint.p, dashPoints[i + 1].Position), magnitude, durationPer)
			end

			clone2.CFrame = dashPoint

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end

			clone3.CFrame = dashPoint
			coroutine.wrap(function()
				task.wait(0.15)

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
					end
				end
			end)()

			if v == nil then
				continue
			end

			local lastTime = tick()

			while tick() - lastTime < durationPer do
				clone:PivotTo(dashPoint:Lerp(v, (tick() - lastTime) / durationPer))
				RunService.Heartbeat:Wait()
			end

			clone:PivotTo(v)
		end

		task.wait(0.1)

		for _, folder in pairs(clonesByClone) do
			if folder == nil then
				continue
			end

			for _, effect in pairs(folder:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
					continue
				end

				effect.Enabled = false
			end
		end

		local descendants = clone:GetDescendants()

		for _, instance in ipairs(descendants) do
			if instance:IsA("BasePart") then
				instance.Transparency = 1
			elseif instance:IsA("ParticleEmitter") then
				instance.Enabled = false
			end
		end

		task.delay(2, function()
			if clone2 then
				clone2:Destroy()
			end

			if clone3 then
				clone3:Destroy()
			end

			for _, v in pairs(clonesByClone) do
				if v ~= nil then
					v:Destroy()
				end
			end

			clonesByClone = nil
		end)
	elseif ID == 3 then
		local cFrame = player.CFrame

		if (cFrame.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		if cFrame then
			local clone = X.FoxBody:Clone()
			debris:AddItem(clone, 7)
			clone.Anchored = true
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "KitsuneFruitVFXColor")
			Util.Sound:Play("X Attacks- Tail wheel slash", cFrame)
			Util.Sound:Play("KitsuneXTailWheel", cFrame)
			coroutine.wrap(function()
				ProjectileHit(_WorldOrigin, clone, cFrame.Position, player2)
			end)()
		end
	end
end