local circle = script.Parent:WaitForChild("Circle")
local bigCircle = script.Parent:WaitForChild("BigCircle")
local fadeCircle = script.Parent:WaitForChild("FadeCircle")
local fadeCircle2 = script.Parent:WaitForChild("FadeCircle2")
local star = script.Parent:WaitForChild("Star")
local shape = script.Parent:WaitForChild("Shape")
local line = script.Parent:WaitForChild("Line")
local TweenService = game:GetService("TweenService")

function Reset()
	circle.Visible = nil
	bigCircle.Visible = nil
	fadeCircle.Visible = nil
	fadeCircle2.Visible = nil
	star.Visible = nil
	shape.Visible = nil
	line.Visible = nil
	circle.Rotation = 0
	bigCircle.Rotation = 0
	fadeCircle.Rotation = 0
	star.Rotation = 0
	shape.Rotation = 0
	line.Rotation = 0
	circle.ImageTransparency = 1
	circle.Size = UDim2.new(0, 0, 0, 0)
	bigCircle.ImageTransparency = 1
	bigCircle.Size = UDim2.new(0, 0, 0, 0)
	star.Size = UDim2.new(0, 0, 0, 0)
	line.Size = UDim2.new(0, 0, 0.25, 0)
	shape.ImageTransparency = 0
	fadeCircle.ImageTransparency = 1
end

function StartSecretCutscene()
	Reset()
	local lastTime = tick()
	circle.Visible = true
	TweenService:Create(circle, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(circle, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
		Size = UDim2.new(0.35, 0, 0.35, 0)
	}):Play()
	local lastTime2 = tick()
	local lastTime3 = tick()
	local thread = task.spawn(function()
		while task.wait() do
			local v = 1 + (tick() - lastTime3) / 1.25
			circle.Rotation += 0.3 * v

			if bigCircle.Visible then
				bigCircle.Rotation -= 0.15 * v
			end

			if fadeCircle.Visible then
				local v2 = math.abs((math.sin((tick() - lastTime) * 1.5))) * 0.2
				fadeCircle.ImageTransparency = 1 - v2
				fadeCircle.Rotation += 0.6 * v
				fadeCircle2.ImageTransparency = 1 - v2 / 3
				fadeCircle2.Rotation -= 0.6 * v
			end

			if not star.Visible then
				continue
			end

			star.Rotation -= 0.75 * (1 + (tick() - lastTime2) * 1)
			shape.Rotation = star.Rotation
			line.Rotation = star.Rotation
		end
	end)
	task.wait(0.5)
	bigCircle.Visible = true
	TweenService:Create(bigCircle, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(bigCircle, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = UDim2.new(0.6, 0, 0.6, 0)
	}):Play()
	task.wait(1)
	fadeCircle.Visible = true
	fadeCircle2.Visible = true
	lastTime = tick()
	task.wait(1.5)
	lastTime2 = tick()
	star.Visible = true
	shape.Visible = true
	line.Visible = true
	TweenService:Create(star, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(0.35, 0, 0.35, 0),
		ImageTransparency = 0
	}):Play()
	TweenService:Create(shape, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(2, 0, 2, 0)
	}):Play()
	TweenService:Create(shape, TweenInfo.new(3, Enum.EasingStyle.Exponential), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(line, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = UDim2.new(1, 0, 0.35, 0)
	}):Play()
	TweenService:Create(line, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		ImageTransparency = 1
	}):Play()
	task.wait(3)
	TweenService:Create(star, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
		Size = UDim2.new(15, 0, 15, 0)
	}):Play()
	task.wait(1)
	Reset()
	script.Parent.BackgroundFrame.Visible = true
	task.cancel(thread)
	task.wait(2)
	script.Parent.BackgroundFrame.Visible = nil
end

while wait(2) do
	StartSecretCutscene()
end