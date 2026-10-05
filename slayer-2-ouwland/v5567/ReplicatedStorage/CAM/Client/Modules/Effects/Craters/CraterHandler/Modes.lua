local createVector = vector.create
local TweenService = game:GetService("TweenService")
local v = {
	SineMode = function(duration)
		return TweenInfo.new(duration, Enum.EasingStyle.Sine)
	end
}

local function fn(...)
	return TweenService:Create(...)
end

local Modes = {}

function Modes.Shrink(p, p2)
	if p == nil then
		return
	end

	local v2 = fn(p, v.SineMode(p2), {
		Size = createVector(0, 0, 0)
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function Modes.Melt(p, p2)
	if p == nil then
		return
	end

	local v2 = fn(p, v.SineMode(p2), {
		Position = p.Position + Vector3.new(0, -p.Size.X * 1.5, 0)
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function Modes.FadeOut(p, p2)
	if p == nil then
		return
	end

	local v2 = fn(p, v.SineMode(p2), {
		Transparency = 1
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function Modes.Enlarge(p, p2, p3)
	if p == nil then
		return
	end

	local size = p.Size
	p.CFrame = p3.CFrame
	p.Size = createVector(0, 0, 0)
	local v2 = fn(p, v.SineMode(p2), {
		Size = size
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function Modes.Grow(instance, p, p2)
	if instance == nil then
		return
	end

	instance.CFrame *= CFrame.new(0, -instance.Size.X / 1.5, 0)
	local v2 = fn(instance, v.SineMode(p), p2)
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function Modes.FadeIn(p, p2, p3)
	if p == nil then
		return
	end

	p.CFrame = p3.CFrame
	local transparency = p.Transparency
	p.Transparency = 1
	local v2 = fn(p, v.SineMode(p2), {
		Transparency = transparency
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

return Modes