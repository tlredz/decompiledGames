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

local CraterModes = {}

function CraterModes.Shrink(p, p2)
	local v2 = fn(p, v.SineMode(p2), {
		Size = createVector(0, 0, 0)
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function CraterModes.Melt(p, p2)
	local v2 = fn(p, v.SineMode(p2), {
		Position = p.Position + Vector3.new(0, -p.Size.Y * 1.5, 0)
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function CraterModes.FadeOut(p, p2)
	local v2 = fn(p, v.SineMode(p2), {
		Transparency = 1
	})
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function CraterModes.Enlarge(p, p2, p3)
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

function CraterModes.Grow(instance, p, p2)
	instance.CFrame += Vector3.new(0, -instance.Size.Y * 1.5, 0)
	local v2 = fn(instance, v.SineMode(p), p2)
	v2:Play()
	task.spawn(function()
		v2.Completed:Wait()
		v2:Destroy()
	end)
end

function CraterModes.FadeIn(p, p2, p3)
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

return CraterModes