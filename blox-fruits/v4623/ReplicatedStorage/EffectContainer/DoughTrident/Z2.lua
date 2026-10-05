local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local root = data.Root
	local duration = data.Duration
	local cFrame = root and root.CFrame or data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local v

	if data.Boom then
		duration = 0.125
		v = 3
	else
		v = 1
	end

	local lastTime = tick()

	while tick() - lastTime < duration do
		local v2

		if root then
			v2 = root.CFrame * (v == 1 and CFrame.new(0, 0.5, -12.5) or CFrame.new(0, 0.5, -12.5) * CFrame.Angles(
				0,
				0,
				0
			)) or cFrame
		else
			v2 = cFrame
		end

		if data.Boom then
			v = (3 + (tick() - lastTime) * 15) * (data.BoomMultiplier or 1)
		end

		for _ = 1, v * 4 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1) * (0.3 + math.random() * 0.7) * 4 * v
			part.CFrame = v2 * CFrame.Angles(
				(math.random() - 0.5) * 0.75,
				(math.random() - 0.5) * 0.75,
				(math.random() - 0.5) * 0.75
			)
			part.Color = Color3.fromRGB(240, 240, 240)
			part.Material = "Ice"
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(1, 1, 1)
			part.Parent = _WorldOrigin
			local v3 = math.random() < 0.5
			local tween = TweenService:Create(part, TweenInfo.new(0.1 + math.random() * (v3 and 0.4 or 0.1)), {
				Size = part.Size * Vector3.new(0, 0, v3 and 0 or 2),
				CFrame = part.CFrame * CFrame.new(0, 0, math.random(5, 50) * v)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		local clone = script.MochiSwirl:Clone()
		clone:SetPrimaryPartCFrame(v2 * CFrame.Angles(1.5707963267948966, math.random() * 3.141592653589793 * 2, 0))
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "Color1" then
				if math.random() < 0.25 then
					child:Destroy()
				else
					child.Transparency = math.random() * 0.7
					local v3 = 2 + math.random() * 2
					local tween = TweenService:Create(
						child,
						TweenInfo.new(
							0.1 + child.Size.Magnitude * 0.005 * v + math.random() * 0.1 * v,
							Enum.EasingStyle.Circular
						),
						{
							Size = child.Size * Vector3.new(v3, 2, v3) * v,
							CFrame = child.CFrame * CFrame.new(0, math.random(2, 10) * v, 0),
							Transparency = 1
						}
					)
					local v4 = child
					tween.Completed:Connect(function()
						v4:Destroy()
					end)
					tween:Play()
				end
			elseif child.Name == "Color2" then
				local v3 = 2.5 + math.random() * 2.5
				local v4 = v3 + math.random() * 2.5
				local v5 = v > 1 and 0 or v3
				local tween = TweenService:Create(child, TweenInfo.new(0.05 + math.random() * 0.05), {
					Size = child.Size * Vector3.new(v5, v4, v5) * v
				})
				local v6 = child
				tween.Completed:Connect(function()
					v6:Destroy()
				end)
				tween:Play()
			elseif child.Name == "FaintWind" then
				local tween = TweenService:Create(child, TweenInfo.new(0.15), {
					Size = createVector(0, 75, 0)
				})
				local v3 = child
				tween.Completed:Connect(function()
					v3:Destroy()
				end)
				tween:Play()
			end
		end

		task.delay(1, function()
			clone:Destroy()
		end)
		RunService.RenderStepped:Wait()
	end
end