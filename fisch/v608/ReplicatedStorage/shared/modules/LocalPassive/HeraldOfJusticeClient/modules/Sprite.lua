local Sprite = {}
Sprite.__index = Sprite
Sprite.__index = Sprite

function Sprite.new(data)
	local object = setmetatable({}, Sprite)
	object.Gui = data.gui
	object.FrameWidth = data.frameWidth
	object.FrameHeight = data.frameHeight
	object.Columns = data.columns
	object.StartFrame = data.startFrame or 1
	object.EndFrame = data.endFrame or object.StartFrame
	object.FPS = data.fps or 12
	object.Loop = data.loop == nil or data.loop
	object.Playing = data.autoPlay == nil or data.autoPlay
	object.CurrentFrame = object.StartFrame
	object._lastTick = os.clock()
	object._accum = 0
	object.Gui.ImageRectSize = Vector2.new(object.FrameWidth, object.FrameHeight)
	object:SetFrame(object.CurrentFrame)
	return object
end

function Sprite:SetFrame(startFrame: number)
	if startFrame < self.StartFrame then
		startFrame = self.StartFrame
	end

	if self.EndFrame < startFrame then
		startFrame = self.EndFrame
	end

	self.CurrentFrame = startFrame
	local v = startFrame - self.StartFrame
	local v2 = v % self.Columns
	local v3 = math.floor(v / self.Columns)
	local v4 = v2 * self.FrameWidth
	local v5 = v3 * self.FrameHeight
	self.Gui.ImageRectOffset = Vector2.new(v4, v5)
end

function Sprite:Play()
	if self.Playing then
		return
	end

	self.Playing = true
	self._accum = 0
	self._lastTick = os.clock()
	self:SetFrame(self.StartFrame)
end

function Sprite:Stop()
	self.Playing = false
end

function Sprite:Reset()
	self._accum = 0
	self._lastTick = os.clock()
	self:SetFrame(self.StartFrame)
end

function Sprite:Update(...)
	if not self.Playing or self.FPS <= 0 then
		return
	end

	local now = os.clock()
	local v = now - self._lastTick
	self._lastTick = now
	local v2 = 1 / self.FPS
	self._accum += v

	if self._accum < v2 then
		return
	end

	self._accum -= v2
	local startFrame = self.CurrentFrame + 1

	if self.EndFrame < startFrame then
		if self.Loop then
			startFrame = self.StartFrame
		else
			startFrame = self.EndFrame
			self.Playing = false
		end
	end

	self:SetFrame(startFrame)
end

function Sprite:Destroy()
	self.Playing = false
end

return Sprite