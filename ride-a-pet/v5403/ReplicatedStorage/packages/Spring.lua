local TweenService = game:GetService("TweenService")
local Spring = {}
Spring.__index = Spring

function Spring.new(p, smoothTime: number, p2: number?)
	local velocity

	if typeof(p) == "CFrame" then
		velocity = CFrame.identity
	else
		velocity = p * 0
	end

	local v = {
		Current = p,
		Target = p,
		Velocity = velocity,
		SmoothTime = smoothTime,
		MaxSpeed = p2 == nil and 1e999 or p2
	}
	return (setmetatable(v, Spring))
end

function Spring:Update(p: number)
	local smoothDamp, velocity = TweenService:SmoothDamp(
		self.Current,
		self.Target,
		self.Velocity,
		self.SmoothTime,
		self.MaxSpeed,
		p
	)
	self.Current = smoothDamp
	self.Velocity = velocity
	return self.Current
end

function Spring:Impulse(p2)
	self.Velocity += p2
end

function Spring:Reset(p2)
	self.Current = p2
	self.Target = p2
	local velocity

	if typeof(self.Current) == "CFrame" then
		velocity = CFrame.identity
	else
		velocity = self.Current * 0
	end

	self.Velocity = velocity
end

return Spring