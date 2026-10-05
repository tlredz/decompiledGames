local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local Z = FX:WaitForChild("Dino").Z

local function TailWhip(_WorldOrigin2, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local clone = data.SlashType:Clone()
	debris:AddItem(clone, 2)
	clone.CFrame = humanoidRootPart.CFrame
	clone.Weld.Part0 = humanoidRootPart
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")
	local descendants = clone:GetDescendants()

	for _, instance in ipairs(descendants) do
		if instance:IsA("Beam") then
			instance.CurveSize0 *= multiplier
			instance.CurveSize1 *= multiplier
			instance.Width0 *= multiplier
			instance.Width1 *= multiplier
		elseif instance:IsA("Attachment") then
			instance.Position = Vector3.new(
				instance.Position.X * multiplier,
				instance.Position.Y * multiplier,
				instance.Position.Z * multiplier
			)
		end
	end

	local descendants2 = clone:GetDescendants()

	for _, instance in ipairs(descendants2) do
		if instance:IsA("Beam") then
			instance.Enabled = true
			local startDelay = instance:GetAttribute("StartDelay")
			local v = instance
			local v2 = instance:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0 * 1.5,
						Width1 = v.Width1 * 1.5,
						CurveSize0 = v.CurveSize0 * 1.5,
						CurveSize1 = v.CurveSize1 * 1.5
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
			end)
		elseif instance:IsA("Attachment") then
			TweenService:Create(instance, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = Vector3.new(instance.Position.X * 1.5, instance.Position.Y * 1.5, instance.Position.Z * 1.5)
			}):Play()
		end
	end

	for _ = 1, 3 do
		local tween = TweenService:Create(
			clone.Weld,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					1.0471975511965976,
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
		CFrame = clone.CFrame * CFrame.Angles(0, 1.3089969389957472, 0)
	}):Play()
	local descendants3 = clone:GetDescendants()

	for _, effect in ipairs(descendants3) do
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

local function StartProjectileSlash(p, _WorldOrigin2, endPosition, lifetime, hit)
	local clone = Z.Phase1.ProjectileSlash:Clone()
	debris:AddItem(clone, 3)
	sound:Play("Tail Slash- Projectile", p.Position, nil, 1, 1)
	local descendants = clone:GetDescendants()

	for _, instance in ipairs(descendants) do
		if instance:IsA("Beam") then
			instance.CurveSize0 *= 2.5
			instance.CurveSize1 *= 2.5
			instance.Width0 *= 2.5
			instance.Width1 *= 2.5
		elseif instance:IsA("Attachment") then
			instance.Position = Vector3.new(
				instance.Position.X * 2.5,
				instance.Position.Y * 2.5,
				instance.Position.Z * 2.5
			)
		elseif instance:IsA("ParticleEmitter") then
			instance.Enabled = true

			if instance:GetAttribute("Scale") then
				instance.Size = NumberSequence.new(instance:GetAttribute("Scale") * 2.5)
			end
		elseif instance:IsA("BasePart") then
			instance.Size = Vector3.new(instance.Size.X * 2.5, instance.Size.Y * 2.5, instance.Size.Z * 2.5)
		end
	end

	clone.CFrame = p * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")
	local descendants2 = clone:GetDescendants()

	for _, beam in ipairs(descendants2) do
		if beam:IsA("Beam") then
			beam.Enabled = true
		end
	end

	local magnitude = (endPosition - clone.Position).Magnitude
	local _ = math.random(10, 20) / 10
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
		}
	)
	tween:Play()
	tween.Completed:Wait()

	if hit == nil then
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 0, -5)
		}):Play()
		local descendants3 = clone:GetDescendants()

		for _, effect in ipairs(descendants3) do
			if effect:IsA("Beam") then
				local v = effect
				task.spawn(function()
					local endDelay = v:GetAttribute("EndDelay")
					local tween2 = TweenService:Create(
						v,
						TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v:Destroy()
				end)
			elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	else
		local clone2 = Z.Phase1.ProjectileImpact:Clone()
		debris:AddItem(clone2, 3)
		clone2.CFrame = clone.CFrame
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin2, player, "TRexFruitVFXColor")
		sound:Play("Tail Slash- Explosion", clone2.Position, nil, 1, 1)
		clone:Destroy()
		local descendants3 = clone2:GetDescendants()

		for _, emitter in ipairs(descendants3) do
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
	end
end

return function(player2)
	local ID = player2.ID
	player = player2.player

	if ID == 1 then
		local character = player2.Character
		local holdValue = player2.HoldValue

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
					diedConnection = nil
				end)
				tick()

				local function running()
					return diedConnection and holdValue and holdValue.Value == true
				end

				local now = tick() - 1

				while diedConnection and holdValue and holdValue.Value == true and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoid and character do
					if tick() - now > 0.08 then
						now = tick()
					end

					RunService.Heartbeat:Wait()
				end

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end
			end
		end
	elseif ID == 2 then
		local endPosition = player2.EndPosition
		local character = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
				return
			end

			local cFrame = CFrame.new(humanoidRootPart.Position, endPosition) * CFrame.new(0, 0, -5)
			local clone = Z.Phase1.StartImpact:Clone()
			debris:AddItem(clone, 3)
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants = clone:GetDescendants()

			for _, emitter in ipairs(descendants) do
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

			local clone2 = Z.Phase1.StartImpact2:Clone()
			debris:AddItem(clone2, 3)
			clone2.CFrame = cFrame * CFrame.new(0, 0, 25)
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants2 = clone2:GetDescendants()

			for _, emitter in ipairs(descendants2) do
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

			TweenService:Create(clone2, TweenInfo.new(0.25), {
				CFrame = cFrame * CFrame.new(0, 0, -25)
			}):Play()
			task.spawn(function()
				TailWhip(_WorldOrigin, humanoidRootPart, {
					Multiplier = 1.5,
					SlashAngle = CFrame.Angles(0, -1.5707963267948966, 0),
					SlashAngle2 = CFrame.Angles(0, 0, 0),
					YPosition = 0,
					SlashType = Z.Phase1.TailSlash
				})
			end)
			task.wait(0.05)
			task.spawn(function()
				StartProjectileSlash(cFrame, _WorldOrigin, endPosition, player2.Lifetime, player2.Hit)
			end)
		end
	end
end