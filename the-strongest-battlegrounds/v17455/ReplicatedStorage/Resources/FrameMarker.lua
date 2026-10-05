local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local FrameMarker = {}
FrameMarker.__index = FrameMarker

function FrameMarker.new(p)
	return (setmetatable({
		Framerate = p.Framerate or 60,
		_FrameMarkerElapsed = 0,
		_sequences = {}
	}, FrameMarker))
end

function FrameMarker:At(p2, p3)
	self._sequences[p2] = p3
end

function FrameMarker:Chain(items)
	for k, item in items do
		self:At(k, item)
	end

	self:Play()
	return self
end

function FrameMarker:Update(p)
	self._FrameMarkerElapsed += p * self.Framerate
end

function FrameMarker:Play()
	self._Connection = RunService.Heartbeat:Connect(function(dt)
		for k, callback in self._sequences do
			if not (k <= self._FrameMarkerElapsed) then
				continue
			end

			task.spawn(callback, self)
			self._sequences[k] = nil
		end

		self._FrameMarkerElapsed += dt * self.Framerate

		if next(self._sequences) == nil and self._Connection then
			self._Connection:Disconnect()
			self._Connection = nil
		end
	end)
end

function FrameMarker:Stop()
	self.Framerate = 0
end

function FrameMarker:Destroy()
	if self._Connection then
		self._Connection:Disconnect()
		self._Connection = nil
	end

	self:Stop()
	setmetatable(self, nil)
end

return FrameMarker