local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage.FX)
local kitsuneSkillVUnTransform = FX:WaitForChild("Kitsune").KitsuneSkillVUnTransform
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)

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

return function(p)
	local root = p.Root
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(root.Parent)

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local folder = Instance.new("Folder")
	Util.Debris:AddItem(folder, 5)
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, playerFromCharacter, "KitsuneFruitVFXColor")
	local cframe = CFrame.new(root.CFrame.Position)
	task.spawn(function()
		local clone = kitsuneSkillVUnTransform.Aura:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "KitsuneFruitVFXColor")

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("PointLight") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 20, true),
					{
						Range = descendant.Range + 15
					}
				):Play()
			end
		end

		task.wait(0.25)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("PointLight") then
				TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0
				}):Play()
			end
		end
	end)
	task.spawn(function()
		local clone = kitsuneSkillVUnTransform.AuraStart:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = kitsuneSkillVUnTransform.Explosion:Clone()
		clone2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone2, folder, playerFromCharacter, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				Util.EmitFix(v, v:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			for _ = 1, 3 do
				local v = math.random(10, 50) / 250
				local v2 = math.random(100, 250) / 100
				local v3 = math.random(30, 40) / 10
				local clone3 = kitsuneSkillVUnTransform.SpinTornado:Clone()
				clone3.CFrame = cframe * CFrame.new(0, math.random(45, 50), 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				Util.SetParentOverrideWithColor(clone3, folder, playerFromCharacter, "KitsuneFruitVFXColor")

				for _, descendant in pairs(clone3:GetDescendants()) do
					if descendant:IsA("Beam") then
						local tween = TweenService:Create(
							descendant,
							TweenInfo.new(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								CurveSize0 = descendant.CurveSize0 * v2,
								CurveSize1 = descendant.CurveSize1 * v2
							}
						)
						descendant.CurveSize0 /= v3
						descendant.CurveSize1 /= v3
						tween:Play()
					elseif descendant:IsA("Attachment") then
						local tween = TweenService:Create(
							descendant,
							TweenInfo.new(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(
									descendant.Position.X * v2,
									descendant.Position.Y * v2,
									descendant.Position.Z * v2
								)
							}
						)
						descendant.Position = Vector3.new(
							descendant.Position.X / v3,
							descendant.Position.Y / v3,
							descendant.Position.Z / v3
						)
						tween:Play()
					end
				end

				task.spawn(function()
					for i = 1, 10 do
						local tween = TweenService:Create(
							clone3,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.new(0, -math.clamp(20 - i * 4, 0, 20), 0) * CFrame.Angles(
									0,
									math.rad(-math.random(80, 120)),
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end
				end)
				local folder2 = clone3
				task.spawn(function()
					task.wait(v * math.random(50, 70) / 100)

					for i, beam in pairs(folder2:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(
								beam,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end

					task.wait(0.3)
					folder2:Destroy()
				end)
			end
		end)
	end)

	for _ = 1, 7 do
		task.spawn(function()
			task.wait(math.random(10, 25) / 100)
			local clone = kitsuneSkillVUnTransform.AuraTrail:Clone()
			clone.Position = cframe.Position + Vector3.new(
				math.random(-100, 100) / 2,
				math.random(-5, 25),
				math.random(-100, 100) / 2
			)
			Util.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "KitsuneFruitVFXColor")
			local position = clone.Position
			local position2 = cframe.Position
			local magnitude = (position - position2).Magnitude
			clone.CFrame = CFrame.new(position, position2)
			local v = (position - position2) / 2
			local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
			local v2 = magnitude * 1.15
			local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(1, 2), math.random(-v2, v2))
			local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(1, 2), math.random(-v2, v2))

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				end
			end

			local v5 = math.random(30, 60) / 10
			local lastTime = tick()
			local v6 = magnitude / v5 / 60

			while tick() - lastTime < v6 do
				local v7 = (tick() - lastTime) / v6
				local v8 = cubicBezier(v7, position, v3, v4, position2)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position2), v7)
				RunService.Heartbeat:Wait()
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end)
	end
end