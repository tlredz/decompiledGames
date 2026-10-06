local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Chest.Modules:WaitForChild("Utility"))
local PeodizService = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeodizService"))

function darker_rgb(data, _)
	local v = data.R * 255
	local v2 = data.G * 255
	local v3 = data.B * 255
	local v4 = math.random(-5, 5)
	return Color3.fromRGB(v - v4, v2 - v4, v3 - v4)
end

function multiplyCFrame(p, p2)
	local position = p.Position
	local cframe = p - position
	local v = position * p2
	local axisAngle, v2 = cframe:ToAxisAngle()
	local v3 = v2 * p2
	local cframe2 = CFrame.fromAxisAngle(axisAngle, v3)
	return CFrame.new(v) * cframe2
end

return function()
	local v = script.Parent.PrimaryPart.CFrame * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	script.Parent:PivotTo(v)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = 8
		}, function(p)
			math.floor(p * 8)
			local clone = script.ray:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = script.Parent.PrimaryPart.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Beam.Width0 = 0
			clone.Beam.Width1 = 0

			if math.random(1, 2) == 1 then
				clone.Beam.Color = ColorSequence.new(Color3.fromRGB(255, 75, 30))
			end

			TweenService:Create(
				clone.Beam,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = math.random(7, 15) / 2
				}
			):Play()
			TweenService:Create(
				clone.AT2,
				TweenInfo.new(math.random(60, 75) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(0, math.random(35, 70), 0)
				}
			):Play()
			task.spawn(function()
				wait(math.random(15, 25) / 100)
				TweenService:Create(
					clone.Beam,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				):Play()
			end)
			_G.PU:Dust(clone, 1)
		end)
	end)
	Utility.EmitParticles(script.Parent.Outer)
	task.spawn(function()
		Utility.ParticleHandler(script.Parent.Outer, true)
		wait(0.175)
		Utility.ParticleHandler(script.Parent.Outer, false)
	end)
	task.spawn(function()
		wait(0.375)
		Utility.ParticleHandler(script.Parent.Outer2, true)
		wait(0.4)
		script.Parent.Outer.flare.Enabled = true
		script.Parent.Outer.flare2.Enabled = true
		script.Parent.Outer.flare.Rate = 55
		script.Parent.Outer.flare2.Rate = 55
		wait(0.3)
		Utility.ParticleHandler(script.Parent.Outer2, false)
		script.Parent.Outer.flare.Enabled = false
		script.Parent.Outer.flare2.Enabled = false
		wait(0.15)
		Utility.EmitParticles(script.Parent.Main)
	end)
	script.Parent.Outer.flare.Rate = 0
	script.Parent.Outer.flare2.Rate = 0

	for i, part in pairs(script.Parent:GetChildren()) do
		if not (part:IsA("BasePart") and string.find(part.Name, "fracture")) then
			continue
		end

		part.Name = "fracture_" .. i
		part.PivotOffset = (script.Parent.Main.CFrame:Inverse() * part.CFrame):Inverse()
		part.Size = Vector3.new()
		part.CFrame = script.Parent.Main.CFrame
		part.Color = darker_rgb(Color3.fromRGB(122, 186, 235))

		if math.random(1, 2) == 1 then
			part.Color = darker_rgb(Color3.fromRGB(221, 155, 117))
		end

		local v2 = i
		local v3 = part
		task.spawn(function()
			wait()
			task.wait(v2 / 100)
			TweenService:Create(v3, TweenInfo.new(0.275, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = script.Parent.Main.CFrame * multiplyCFrame(v3:GetAttribute("BaseCF"), 0.75),
				Size = v3:GetAttribute("BaseSize") * 0.75
			}):Play()

			if math.random(1, 2) == 1 then
				TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(80, 123, 156))
				}):Play()
			else
				TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(171, 101, 66))
				}):Play()
			end

			wait(0.325)
			TweenService:Create(v3, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = script.Parent.Main.CFrame * multiplyCFrame(v3:GetAttribute("BaseCF"), 1.5),
				Size = v3:GetAttribute("BaseSize") * 1.5
			}):Play()
			local clone = script.ray:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = script.Parent.PrimaryPart.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Beam.Width0 = 0
			clone.Beam.Width1 = 0
			clone.Beam.Brightness = 3
			clone.AT2.Position = createVector(0, 15, 0)

			if math.random(1, 2) == 1 then
				clone.Beam.Color = ColorSequence.new(Color3.fromRGB(255, 75, 30))
			end

			TweenService:Create(
				clone.AT2,
				TweenInfo.new(math.random(70, 90) / 85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(0, math.random(35, 60) * 1.5, 0)
				}
			):Play()
			task.spawn(function()
				TweenService:Create(clone.Beam, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = math.random(7, 15) / 2 * 1.33
				}):Play()
				wait(0.8)
				TweenService:Create(clone.Beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
			_G.PU:Dust(clone, 2)
			wait(0.5)
			TweenService:Create(clone.Beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Brightness = 10
			}):Play()

			if math.random(1, 2) == 1 then
				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(122, 186, 235))
				}):Play()
			else
				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(221, 155, 117))
				}):Play()
			end

			wait(0.25)
			TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = script.Parent.Main.CFrame,
				Size = Vector3.new()
			}):Play()
		end)
	end
end