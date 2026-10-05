local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local _ = ReplicatedStorage.Assets.Models.IceRock
return function(data)
	local cFrame = data.CFrame
	local v = data.Width[1]
	local v2 = data.Width[2]
	local height = data.Height
	local duration = data.Duration
	local length = data.Length

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 + data.Length then
		return
	end

	local part = Instance.new("Part")
	part.Size = Vector3.new(v + v2 / 4, v + v2 / 4, 6)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = cFrame * CFrame.new(0, 0, -3)
	part.Parent = _WorldOrigin
	local clone = game.ReplicatedStorage.Assets.Particles.IcyWind:Clone()
	clone.Enabled = true
	clone.Size = NumberSequence.new(v * 0.8, v * 1.2, v * 0.2)
	clone.Speed = NumberRange.new(length * 2.2, length * 2.4)
	clone.Parent = part

	for i = length / 10, length, length / 10 do
		local v3 = cFrame * CFrame.new(0, height / 2, -i)
		local cframe = nil
		local v4 = nil
		local cframe2 = nil
		local v5 = nil
		local v6 = nil

		for i2 = 0, 0.9, 0.1 do
			local ray, v7, v8 = Util.Ray(v3 * Vector3.new(0, 0, i2 * (length / 10)), Vector3.new(0, -height, 0), {
				workspace.Enemies,
				workspace.Characters,
				workspace.Boats,
				_WorldOrigin
			})

			if ray then
				cframe = CFrame.new(v7, v7 + v8)
				v5 = v8
				v4 = i2
				break
			elseif v7.Y < -4 then
				local vector2 = Vector3.new(v7.X, -4, v7.Z)
				v5 = createVector(0, 1, 0)
				cframe = CFrame.new(vector2, vector2 + v5)
				v4 = i2
				break
			end
		end

		if cframe then
			for i2 = v4 + 0.1, 1, 0.1 do
				local ray, v7, v8 = Util.Ray(v3 * Vector3.new(0, 0, i2 * (length / 10)), Vector3.new(0, -height, 0), {
					workspace.Enemies,
					workspace.Characters,
					workspace.Boats,
					_WorldOrigin
				})

				if ray then
					cframe2 = CFrame.new(v7, v7 + v8)
					v6 = v8
				elseif v7.Y < -4 then
					local vector2 = Vector3.new(v7.X, -4, v7.Z)
					v6 = createVector(0, 1, 0)
					cframe2 = CFrame.new(vector2, vector2 + v6)
				end
			end

			if cframe2 then
				local _ = (v5 + v6) / 2
				local v7 = v + (v2 - v) * (i / length)
				local magnitude = (cframe.p - cframe2.p).Magnitude
				local cFrame2 = CFrame.new(cframe.p, cframe2.p) * CFrame.new(0, 0, -magnitude / 2)
				local part2 = Instance.new("Part")
				part2.Material = "Ice"
				part2.Color = Color3.fromRGB(175, 221, 255)
				part2.Size = Vector3.new(v7, 0.33, magnitude)
				part2.Anchored = true
				part2.CanCollide = true
				part2.Transparency = 1
				part2.CFrame = cFrame2
				part2.Parent = _WorldOrigin
				local clone2 = script.ParticleEmitter:Clone()
				clone2.Parent = part2
				clone2:Emit(v7 * 0.4)
				local tween = TweenService:Create(part2, TweenInfo.new(0.15), {
					Size = Vector3.new(v7, 0.25, magnitude),
					Transparency = 0,
					CFrame = cFrame2
				})
				tween.Completed:Connect(function()
					wait(duration)
					local tween2 = TweenService:Create(part2, TweenInfo.new(0.3), {
						Transparency = 1
					})
					tween2.Completed:Connect(function()
						part2:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end
		end

		RunService.RenderStepped:Wait()
	end

	wait(0.15)
	clone.Enabled = false
	wait(1)
	part:Destroy()
end