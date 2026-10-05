local Scheduler = require(script.Parent.Scheduler)
local v = {
	__tostring = function()
		return "ScriptedImageSprite"
	end
}
v.__index = v

function v:Play()
	local __raw = self.__raw

	if __raw.isPlaying then
		return false
	end

	__raw.isPlaying = true
	__raw.__playcon = Scheduler:GetOnRenderSignal(__raw.frameRate):Connect(function()
		self:Advance()
	end)
	local playCalled = self.__signalcache.PlayCalled
	_ = playCalled and playCalled:Fire()
	return true
end

function v:Pause()
	local __raw = self.__raw

	if not __raw.isPlaying then
		return false
	end

	__raw.isPlaying = false
	__raw.__playcon:Disconnect()
	__raw.__playcon = nil
	local pauseCalled = self.__signalcache.PauseCalled
	_ = pauseCalled and pauseCalled:Fire()
	return true
end

function v:Advance()
	local onRenderCallback = self.onRenderCallback

	if onRenderCallback then
		onRenderCallback(self)
	end
end

function v:SetFrame(currentFrame: Vector2)
	local __raw = self.__raw
	local currentFrame2 = __raw.currentFrame
	__raw.currentFrame = currentFrame
	local adornee = __raw.adornee

	if not adornee then
		return
	end

	local edgeOffset = __raw.edgeOffset
	local spriteOffset = __raw.spriteOffset
	local spriteSize = __raw.spriteSize
	local v2 = edgeOffset.X + (currentFrame.X - 1) * (spriteSize.X + spriteOffset.X)
	local v3 = edgeOffset.Y + (currentFrame.Y - 1) * (spriteSize.Y + spriteOffset.Y)
	adornee.ImageRectOffset = Vector2.new(v2, v3)
	local frameChanged

	if currentFrame2 == currentFrame then
		frameChanged = false
	else
		frameChanged = __raw.__signalcache.FrameChanged
	end

	_ = frameChanged and frameChanged:Fire()
end

local v2 = {
	"FrameChanged",
	"PlayCalled",
	"PauseCalled",
	"StaticChanged"
}
local ScriptedImageSprite = {}

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

	if __raw[p] == image then
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
		if image then
			if __raw.spriteSheetId ~= "" then
				image.Image = __raw.spriteSheetId
			end

			image.ImageRectSize = __raw.spriteSize
			object:SetFrame(__raw.currentFrame)
		end
	elseif p == "edgeOffset" or p == "spriteOffset" then
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

function ScriptedImageSprite.new(data)
	local raw = {
		adornee = data.adornee,
		spriteSheetId = data.spriteSheetId or "",
		currentFrame = data.currentFrame or Vector2.one,
		spriteSize = data.spriteSize or Vector2.zero,
		spriteOffset = data.spriteOffset or Vector2.zero,
		edgeOffset = data.edgeOffset or Vector2.zero,
		frameRate = data.frameRate or 30,
		isPlaying = false,
		onRenderCallback = data.onRenderCallback,
		__signalcache = {}
	}
	raw.__raw = raw
	setmetatable(raw, v)
	local v4 = newproxy(true)
	local metatable = getmetatable(v4)

	function metatable.__tostring()
		return "ScriptedImageSprite"
	end

	metatable.__index = raw
	metatable.__newindex = fn

	if raw.adornee and raw.spriteSheetId ~= "" then
		raw.adornee.Image = raw.spriteSheetId
		raw.adornee.ImageRectSize = raw.spriteSize
		v4:SetFrame(raw.currentFrame)
	end

	return v4
end

return ScriptedImageSprite