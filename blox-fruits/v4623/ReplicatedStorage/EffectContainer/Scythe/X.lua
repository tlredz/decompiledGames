local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local lookVector = cFrame.LookVector
	local speed = data.Speed
	local v = data.Duration - (masterClock:GetTime() - data.Timestamp)
	local radius = data.Radius

	if v < 0.2 then
		return
	end

	Util.Sound:Play("Ope.Levitate.Cut2", cFrame)
	local clone = script.ScytheRings2:Clone()
	clone:SetPrimaryPartCFrame(CFrame.new(data.Root.Position, data.Root.Position + lookVector))
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		child.Color = child.Color:Lerp(Color3.new(1, 0, 0), math.random() * 0.1)
		child.Size = child.Size.unit * 10
		local tween = TweenService:Create(child, TweenInfo.new(0.04 + math.random() * 0.04), {
			Size = child.Size * 3 * createVector(1, 0.75, 1),
			CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		local v2 = child
		tween.Completed:Connect(function()
			local size = v2.Size
			local lastTime = tick()

			while tick() - lastTime < 0.1 do
				local v3 = task.wait()
				local v4 = tick() - lastTime
				local v5 = math.cos(v4 * 20) * 0.1 + 1
				local v6 = math.sin(v4 * 60) * 0.15 + 1.2
				v2.Size = size * Vector3.new(v6, v5, v6)
				v2.CFrame *= CFrame.Angles(0, -v3 * 30 * 1, 0)
			end

			local tween2 = TweenService:Create(
				v2,
				TweenInfo.new(0.06 + math.random() * 0.08, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
				{
					Size = v2.Size * createVector(0, 0, 0),
					Color = v2.Color:Lerp(Color3.new(1, 0, 0), 0.2),
					CFrame = v2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}
			)
			tween2.Completed:Connect(function()
				v2:Destroy()
			end)
			tween2:Play()
		end)
		tween:Play()
	end

	task.delay(2, function()
		clone:Destroy()
	end)

	for _ = 1, 15 do
		local color = math.random() > 0.75 and Color3.fromRGB() or Color3.fromRGB(213, 115, 61)
		local v2 = math.random() < 0.3 and 1 or 0.125 + math.random() * 0.075
		local v3 = radius * 0.25 + math.random() * radius * 0.25 + (1 - v2) * 15
		local part = Instance.new("Part")
		part.CastShadow = false
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = cFrame * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 1.5707963267948966, 0) * CFrame.Angles(
			(math.random() - 0.5) * 0.5,
			(math.random() - 0.5) * 0.5,
			(math.random() - 0.5) * 0.5
		) * CFrame.Angles(0, 3.141592653589793 * (math.random() < 0.5 and 0 or 1), 0)
		part.Size = createVector(1, 1, 1)
		part.Color = color
		part.Transparency = 0
		part.Material = "Neon"
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = "Sphere"
		specialMesh.Scale = Vector3.new(v2, v2, 1) * v3
		specialMesh.Parent = part
		part.Parent = _WorldOrigin
		local tweenInfo = TweenInfo.new(0.1 + math.random() * 0.2 + v2 / 5)
		TweenService:Create(part, tweenInfo, {
			Color = part.Color:Lerp(Color3.new(1, 0, 0), 0.2)
		}):Play()
		local tween = TweenService:Create(specialMesh, tweenInfo, {
			Scale = Vector3.new(),
			Offset = Vector3.new(0, 0, v3 * math.random() * 2)
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end

	local v2 = false

	for i = 1, 5 do
		local cFrame2 = cFrame * CFrame.new(0, i * radius / 2, -5 - radius - speed * (1 - v))
		task.delay(0.03333333333333333, function()
			local clone2 = script.ScytheRings:Clone()
			clone2:SetPrimaryPartCFrame(cFrame2 * CFrame.Angles(0, 3.141592653589793 * math.random() * 2, 0))
			clone2.Parent = _WorldOrigin

			for i2, child in pairs(clone2:GetChildren()) do
				if math.random() < 0.33 then
					child:Destroy()
				else
					local attachment

					if v2 then
						attachment = nil
					else
						attachment = Instance.new("Attachment", workspace.Terrain)
						attachment.CFrame = cFrame2
						v2 = Util.Sound:Play("WindFastLoud", attachment)
					end

					local v5 = math.random() < 0.5 and -1 or 1
					child.Color = child.Color:Lerp(Color3.new(1, 0, 0), math.random() * 0.2)
					child.Size = child.Size.unit * radius
					local tween = TweenService:Create(child, TweenInfo.new(0.1 + math.random() * 0.05), {
						Size = child.Size * (2 + math.random() * 2.5) * createVector(1, 0.75, 1),
						CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793 * v5, 0)
					})
					local v6 = child
					tween.Completed:Connect(function()
						local size = v6.Size
						local lastTime = tick()

						while tick() - lastTime < v do
							local v8 = task.wait()
							local v9 = tick() - lastTime
							local v10 = math.cos(v9 * 10) * 0.2 + 1
							local v11 = math.sin(v9 * 30) * 0.3 + 1.2
							v6.Size = size * Vector3.new(v11, v10, v11)
							v6.CFrame = v6.CFrame * CFrame.Angles(0, -v8 * 15 * v5, 0) + lookVector * v8 * speed

							if attachment then
								attachment.CFrame = v6.CFrame
							end
						end

						local tween2 = TweenService:Create(
							v6,
							TweenInfo.new(
								0.06 + math.random() * 0.12,
								Enum.EasingStyle.Circular,
								Enum.EasingDirection.In
							),
							{
								Size = v6.Size * createVector(0, 0, 0),
								Color = v6.Color:Lerp(Color3.new(1, 0, 0), 0.2),
								CFrame = v6.CFrame * CFrame.new(0, math.random(6, 18), 0) * CFrame.Angles(
									0,
									3.141592653589793 * v5,
									0
								)
							}
						)
						tween2.Completed:Connect(function()
							v6:Destroy()

							if attachment then
								Util.Sound:FadeOut(v2, 0.66)
								task.delay(0.7, function()
									attachment:Destroy()
								end)
							end
						end)
						tween2:Play()
					end)
					tween:Play()
				end
			end

			task.delay(v + 1, function()
				clone2:Destroy()
			end)
		end)
		task.wait(0.016666666666666666)
	end
end