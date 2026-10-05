local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cframe = CFrame.new(data.Position)
	local length = data.Length or 200
	local scale = data.Scale or 90
	local duration = data.Duration or 0.7
	local magnitude = (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 300 + length * 2 < magnitude then
		return
	end

	local v = masterClock:GetTime() - data.Timestamp

	if duration * 2 < v then
		return
	end

	coroutine.resume(coroutine.create(function()
		for i = 1, 4 do
			local v2 = i
			coroutine.resume(coroutine.create(function()
				local v3 = duration * 0.66
				local v4 = cframe * CFrame.Angles(0, 6.283185307179586 * (v2 / 4), 0)
				local clone = game.ReplicatedStorage.Assets.Models.FireMeshExplosion:Clone()
				clone.Root.Transparency = 1
				clone.Parent = _WorldOrigin
				clone:SetPrimaryPartCFrame(v4)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function iterate(fn)
					for i2, child in pairs(clone:GetChildren()) do
						fn(child)
					end
				end

				local function fn(instance)
					if instance.Name == "Shock" then
						TweenService:Create(instance, TweenInfo.new(v3 * 0.4, Enum.EasingStyle.Quad), {
							Size = instance.Size.unit * scale + Vector3.new(0, scale * 0.5, 0),
							CFrame = instance.CFrame * CFrame.new(0, scale / 3, 0)
						}):Play()
						delay(v3 * 0.4, function()
							TweenService:Create(
								instance,
								TweenInfo.new(v3 * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = instance.Size.unit * Vector3.new(scale * 3, scale * 0.25, scale * 3),
									CFrame = instance.CFrame * CFrame.new(0, -scale / 4, 0),
									Transparency = 1
								}
							):Play()
						end)
					elseif instance.Name == "Wind" then
						local function effect(instance2, p)
							TweenService:Create(
								instance2,
								TweenInfo.new(v3 * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Quad),
								{
									Size = instance2.Size.unit * scale * 2.5 * (1 - p * 0.2)
								}
							):Play()
							TweenService:Create(
								instance2,
								TweenInfo.new(v3 * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Linear),
								{
									CFrame = instance2.CFrame * CFrame.new(0, (p - 1) * scale * 0.125, 0) * CFrame.Angles(
										0,
										1.5707963267948966,
										0
									)
								}
							):Play()
							delay(v3 * 0.6 * (1 - p * 0.2), function()
								TweenService:Create(instance2, TweenInfo.new(v3 * 0.5, Enum.EasingStyle.Quad), {
									Transparency = 1,
									Size = Vector3.new(scale * 1.75 * (1 - p * 0.1), 0, scale * 1.75 * (1 - p * 0.1)),
									CFrame = instance2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
								}):Play()
							end)
						end

						effect(instance, 1)
						local clone2 = instance:Clone()
						clone2.CFrame = instance.CFrame
						clone2.Parent = clone
						effect(clone2, 2)
						local clone3 = instance:Clone()
						clone3.CFrame = instance.CFrame
						clone3.Parent = clone
						effect(clone3, 3)
					end
				end

				iterate(fn) -- equivalent call inferred; original call site unknown
				wait(v3)
				clone:Destroy()
			end))
			wait(duration * 0.2)
		end
	end))
	local sizesByChild = {}
	local v2 = {}

	for i = 1, 7 do
		local clone = game.ReplicatedStorage.Assets.Models.FireWind:Clone()
		clone.Parent = _WorldOrigin

		local function iterate2(callback)
			for i2, child in pairs(clone:GetChildren()) do
				callback(child)
			end
		end

		for _, child in pairs(clone:GetChildren()) do
			sizesByChild[child] = child.Size
			child.Size = createVector(0.1, 0.1, 0.1)
		end

		table.insert(v2, { clone, i / 7, iterate2 })
	end

	local lastTime = tick()
	local lastTime2 = tick()

	while tick() - lastTime < duration do
		local v3 = (tick() - lastTime) / duration
		local _ = tick() - lastTime2

		for _, v4 in pairs(v2) do
			if not (v4[2] < v3 and v4[1].Parent) then
				continue
			end

			v4[1]:SetPrimaryPartCFrame(cframe * CFrame.new(0, length * (v3 - v4[2]), 0) * CFrame.Angles(
				0,
				3.141592653589793 * v3 * 8 + v4[2] * 3.141592653589793,
				0
			) * CFrame.Angles(3.141592653589793, 0, 0))

			if not v4[4] then
				v4[4] = true
				v4[3](function(p)
					TweenService:Create(p, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
						Size = sizesByChild[p]
					}):Play()
				end)
			end

			if v4[5] or not (0.95 - v4[2] * 0.1 < v3) then
				continue
			end

			v4[5] = true
			local v5 = v4
			v4[3](function(p)
				local tween = TweenService:Create(p, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Transparency = 1,
					Size = Vector3.new(p.Size.X * v5[2] * 0.2, p.Size.Y, p.Size.Z * v5[2] * 0.2)
				})
				tween.Completed:Connect(function()
					v5[1]:Destroy()
				end)
				tween:Play()
			end)
		end

		lastTime2 = tick()
		RunService.RenderStepped:Wait()
	end

	wait(0.1)

	for _, v3 in pairs(v2) do
		if v3[1].Parent then
			v3[1]:Destroy()
		end
	end
end