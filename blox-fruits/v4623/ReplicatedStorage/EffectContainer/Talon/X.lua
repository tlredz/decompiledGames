local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	if data.Mode == 1 then
		local reference = data.Reference

		if not (reference and reference.Parent) then
			return
		end

		local clone = script.FireRings:Clone()
		clone:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -6) * CFrame.Angles(1.5707963267948966, 0, 0))
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			local tween = TweenService:Create(child, TweenInfo.new(0.5 + math.random() * 0.3, Enum.EasingStyle.Sine), {
				Size = child.Size * createVector(2.5, 0.75, 2.5),
				Color = child.Color:Lerp(Color3.new(), 0.15),
				Transparency = 1,
				CFrame = child.CFrame * CFrame.new(0, math.random(6, 18), 0) * CFrame.Angles(0, 3.141592653589793, 0)
			})
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		end

		task.delay(1, function()
			clone:Destroy()
		end)
		local clone2 = script.Dragon:Clone()
		clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		clone2.Parent = _WorldOrigin
		local clones = {}

		for _ = 1, 3 do
			local clone3 = script.Shockwave:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = _WorldOrigin
			table.insert(clones, clone3)
		end

		local v = Util.Sound:Play("FlameVortex3", clone2.PrimaryPart)
		local lastTime = tick()
		local value = cFrame
		local count = 0
		local p = nil

		while tick() - lastTime < 1.5 and reference:IsDescendantOf(workspace) do
			local v2 = (tick() - lastTime) / 1.5
			local lerped = value:Lerp(reference.Value, 0.4)
			value = reference.Value
			local lerped2 = Color3.fromRGB(255, 122, 56):Lerp(Color3.new(1, 1, 1), math.sin(v2 * 30) * 0.15)
			clone2.One.Color = lerped2:Lerp(Color3.new(1, 1, 1), 0.1)
			clone2:SetPrimaryPartCFrame(lerped * CFrame.Angles(1.5707963267948966, 3.141592653589793, 4.71238898038469))
			count += 1

			for k, v3 in pairs(clones) do
				local v4 = k / 3 * 3.141592653589793 * 2
				local v5 = math.sin(v2 * 10) ^ 2 * 5 + 6
				local v6 = v2 * 25 + v4
				local v7 = lerped * Vector3.new(math.sin(v6) * v5, math.cos(v6) * v5, 0)
				local magnitude = (v7 - v3.Position).Magnitude

				if v3.Position ~= cFrame.p and not _G.FastMode then
					local part = Instance.new("Part")
					part.Size = Vector3.new(2.5, 2.5, magnitude)
					part.CFrame = CFrame.new(v7, v3.Position) * CFrame.new(0, 0, -magnitude / 2)
					part.Color = v3.Color
					part.CastShadow = false
					part.Anchored = true
					part.CanCollide = false
					part.Material = "Neon"
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(part, TweenInfo.new(0.5), {
						Size = part.Size * createVector(0, 0, 1),
						Color = Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 1), 0.15)
					})
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				v3.CFrame = CFrame.new(v7, v3.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			end

			if count % 2 == 0 then
				local v3 = lerped * CFrame.new(0, -1, 4)

				if p then
					local magnitude = (v3.p - p).Magnitude
					local part = Instance.new("Part")
					part.Size = Vector3.new(magnitude, 7, 7)
					part.CFrame = CFrame.new(v3.p, p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					part.Color = lerped2:Lerp(Color3.new(), 0.15)
					part.Shape = "Cylinder"
					part.CastShadow = false
					part.Anchored = true
					part.CanCollide = false
					part.Material = "Neon"
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(
						part,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Size = part.Size * createVector(1, 0, 0),
							Color = part.Color:Lerp(Color3.new(), 0.25)
						}
					)
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				p = v3.p
			end

			task.wait()
		end

		Util.Sound:FadeOut(v, 0.4)

		for _, child in pairs(clone2:GetChildren()) do
			local tween = TweenService:Create(child, TweenInfo.new(0.4), {
				Size = Vector3.new()
			})
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		end

		for _, v2 in pairs(clones) do
			v2.Transparency = 1
			v2.ParticleEmitter.Enabled = false
			local v3 = v2
			task.delay(2, function()
				v3:Destroy()
			end)
		end

		wait(1)
		clone2:Destroy()
	elseif data.Mode == 2 then
		Util.Sound:Play("FlameNukeExplosion3", cFrame)
		local clone = script.FireCone:Clone()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clone.ParticleEmitter.Size = NumberSequence.new(6, 18)
		local clone2 = script.CurvedRing:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		local tween = TweenService:Create(clone2, TweenInfo.new(0.66), {
			Size = clone2.Size * createVector(23, 0.15, 23),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.new(0, 23, 0)
		})
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()

		for _ = 1, 4 do
			for _ = 1, 12 do
				local color = math.random() > 0.25 and Color3.fromRGB(218, 133, 65) or Color3.fromRGB(170, 85, 0)
				local v = math.random() < 0.5 and 1 or 0.125 + math.random() * 0.1
				local v2 = 10 + math.random() * 15 + (1 - v) * 15
				local part = Instance.new("Part")
				part.CastShadow = false
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2
				)
				part.Size = createVector(1, 1, 1)
				part.Color = color
				part.Transparency = 0
				part.Material = "Neon"
				local specialMesh = Instance.new("SpecialMesh")
				specialMesh.MeshType = "Sphere"
				specialMesh.Scale = Vector3.new(v, v, 1) * v2 * 2
				specialMesh.Parent = part
				part.Parent = _WorldOrigin
				local tweenInfo = TweenInfo.new(0.15 + math.random() * 0.25 + v / 5)
				TweenService:Create(part, tweenInfo, {
					Color = part.Color:Lerp(Color3.new(1, 0, 0), 0.4)
				}):Play()
				local tween2 = TweenService:Create(specialMesh, tweenInfo, {
					Scale = Vector3.new(),
					Offset = Vector3.new(0, 0, v2 * (0.75 + math.random() * 1.75))
				})
				tween2.Completed:Connect(function()
					part:Destroy()
				end)
				tween2:Play()
			end

			clone.ParticleEmitter:Emit(7)
			task.wait(0.016666666666666666)
		end

		clone.ParticleEmitter.Enabled = false
		wait(2)
		clone:Destroy()
	end
end