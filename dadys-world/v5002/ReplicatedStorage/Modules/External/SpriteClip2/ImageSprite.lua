local Scheduler = require(script.Parent.Scheduler)
local v = {
	__tostring = function()
		return "ImageSprite"
	end
}
v.__index = v

function v:Play(p: number?)
	local __raw = self.__raw

	if __raw.isPlaying then
		return false
	end

	if p then
		self:SetFrame(p)
	end

	__raw.isPlaying = true
	__raw.__playcon = Scheduler:GetOnRenderSignal(__raw.frameRate):Connect(function()
		self:Advance()
	end)
	local playCalled = self.__signalcache.PlayCalled
	_ = playCalled and playCalled:Fire()
	return true
end

function v:Pause(flag: boolean?)
	local __raw = self.__raw

	if not __raw.isPlaying then
		return false
	end

	__raw.isPlaying = false
	__raw.__playcon:Disconnect()
	__raw.__playcon = nil
	local pauseCalled = not flag and self.__signalcache.PauseCalled
	_ = pauseCalled and pauseCalled:Fire()
	return true
end

function v:Stop()
	self:SetFrame(1)
	local v2 = self.Pause(self, true)
	local stopCalled = v2 and self.__signalcache.StopCalled
	_ = stopCalled and stopCalled:Fire()
	return v2
end

function v:Advance()
	local __raw = self.__raw
	local v2 = __raw.currentFrame + 1

	if __raw.spriteCount < v2 then
		if __raw.isPlaying and not __raw.isLooped then
			self:Pause()
			return
		else
			v2 = 1
		end
	end

	self:SetFrame(v2)
	local looped

	if v2 == 1 then
		looped = __raw.__signalcache.Looped
	else
		looped = false
	end

	_ = looped and looped:Fire()
end

function v:SetFrame(currentFrame: number)
	local __raw = self.__raw

	if currentFrame < 1 or __raw.spriteCount < currentFrame then
		error("Invalid frame number " .. currentFrame)
	end

	local currentFrame2 = __raw.currentFrame
	__raw.currentFrame = currentFrame
	local adornee = __raw.adornee

	if not adornee then
		return
	end

	local columnCount = __raw.columnCount
	local v2 = (currentFrame - 1) % columnCount
	local v3 = math.floor((currentFrame - 1) / columnCount)
	local spriteSize = __raw.spriteSize
	local edgeOffset = __raw.edgeOffset
	local spriteOffset = __raw.spriteOffset
	local v4 = edgeOffset.X + v2 * (spriteSize.X + spriteOffset.X)
	local v5 = edgeOffset.Y + v3 * (spriteSize.Y + spriteOffset.Y)
	adornee.ImageRectOffset = Vector2.new(v4, v5)
	local frameChanged

	if currentFrame2 == currentFrame then
		frameChanged = false
	else
		frameChanged = __raw.__signalcache.FrameChanged
	end

	_ = frameChanged and frameChanged:Fire()
	local frameLast

	if currentFrame == __raw.spriteCount then
		frameLast = __raw.__signalcache.FrameLast
	else
		frameLast = false
	end

	_ = frameLast and frameLast:Fire()
end

local v2 = {
	"FrameLast",
	"Looped",
	"FrameChanged",
	"PlayCalled",
	"PauseCalled",
	"StopCalled",
	"StaticChanged"
}
local ImageSprite = {}

for k, v3 in pairs(v2) do
	v2[v3] = true
end

function v:GetSignal(p2)
	local __signalcache = self.__signalcache
	local v3 = __signalcache[p2]

	if v3 then
		return v3.Event
	end

	if not v2[p2] then
		error("Invalid signal type " .. p2)
	end

	v3 = Instance.new("BindableEvent")
	__signalcache[p2] = v3
	return v3.Event
end

local function fn(object, p: string, image)
	local __raw = object.__raw
	local v3 = __raw[p]

	if v3 == image then
		return
	end

	if p == "isLooped" or p == "currentFrame" then
		error((`Property {p} is read-only`))
	end

	__raw[p] = image

	if p == "frameRate" then
		if __raw.isPlaying then
			object:Pause()
			object:Play()
		end
	elseif p == "spriteSize" then
		local adornee = __raw.adornee

		if adornee then
			if __raw.spriteSheetId ~= "" then
				adornee.Image = __raw.spriteSheetId
			end

			adornee.ImageRectSize = __raw.spriteSize
			object:SetFrame(__raw.currentFrame)
		end
	elseif p == "adornee" then
		if v3 then
			__raw.__destrcon:Disconnect()
		end

		if image then
			__raw.__destrcon = image.Destroying:Connect(function()
				object:Stop()
			end)

			if __raw.spriteSheetId ~= "" then
				image.Image = __raw.spriteSheetId
			end

			image.ImageRectSize = __raw.spriteSize
			object:SetFrame(__raw.currentFrame)
		end
	elseif p == "columnCount" or p == "spriteCount" or p == "edgeOffset" or p == "spriteOffset" then
		if __raw.adornee then
			object:SetFrame(__raw.currentFrame)
		end
	else
		local adornee = p == "spriteSheetId" and __raw.adornee

		if adornee then
			adornee.Image = image
		end
	end

	local staticChanged = __raw.__signalcache.StaticChanged
	_ = staticChanged and staticChanged:Fire(p)
end

function ImageSprite.new(data)
	local raw = {
		adornee = data.adornee,
		spriteSheetId = data.spriteSheetId or "",
		currentFrame = data.currentFrame or 1,
		spriteSize = data.spriteSize or Vector2.zero,
		spriteOffset = data.spriteOffset or Vector2.zero,
		edgeOffset = data.edgeOffset or Vector2.zero,
		spriteCount = data.spriteCount or 0,
		columnCount = data.columnCount or 0,
		frameRate = data.frameRate or 30,
		isLooped = data.isLooped == nil or data.isLooped,
		isPlaying = false,
		__signalcache = {}
	}
	raw.__raw = raw
	setmetatable(raw, v)
	local v4 = newproxy(true)
	local metatable = getmetatable(v4)

	function metatable.__tostring()
		return "ImageSprite"
	end

	metatable.__index = raw
	metatable.__newindex = fn

	if not raw.adornee or raw.spriteSheetId == "" then
		return v4
	end

	raw.adornee.Image = raw.spriteSheetId
	raw.adornee.ImageRectSize = raw.spriteSize
	v4:SetFrame(raw.currentFrame)
	raw.__destrcon = raw.adornee.Destroying:Connect(function()
		v4:Stop()
	end)
	return v4
end

return ImageSprite