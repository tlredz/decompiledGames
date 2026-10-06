local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Chest.Modules:WaitForChild("Utility"))
require(ReplicatedStorage.Chest.Modules:WaitForChild("PeodizService"))

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
		wait(0.1)
		Utility.ParticleHandler(script.Parent.Outer2, true)
		wait(0.225)
		Utility.ParticleHandler(script.Parent.Outer2, false)
	end)

	for i, part in pairs(script.Parent:GetChildren()) do
		if not (part:IsA("BasePart") and string.find(part.Name, "fracture")) then
			continue
		end

		part.Name = "fracture_" .. i
		part.PivotOffset = (script.Parent.Main.CFrame:Inverse() * part.CFrame):Inverse()
		part.Size = Vector3.new()
		part.CFrame = script.Parent.Main.CFrame
		local _ = math.random(1, 2) == 1
		local v2 = i
		local v3 = part
		task.spawn(function()
			wait()
			task.wait(v2 / 100)

			if math.random(1, 2) == 1 then
				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(80, 123, 156))
				}):Play()
			else
				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = darker_rgb(Color3.fromRGB(171, 101, 66))
				}):Play()
			end

			TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
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
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(0, math.random(35, 60) * 1.5, 0)
				}
			):Play()
			task.spawn(function()
				TweenService:Create(
					clone.Beam,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = math.random(7, 15) / 2 * 1.33
					}
				):Play()
				wait(0.25)
				TweenService:Create(clone.Beam, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
			_G.PU:Dust(clone, 2)
			wait(0.1)
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

			wait(0.1)
			TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = script.Parent.Main.CFrame,
				Size = Vector3.new()
			}):Play()
		end)
	end
end