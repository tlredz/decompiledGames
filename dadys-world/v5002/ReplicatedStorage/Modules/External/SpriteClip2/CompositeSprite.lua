local AssetService = game:GetService("AssetService")
local Scheduler = require(script.Parent.Scheduler)
local AssetService2 = game:GetService("AssetService")
local class = {}
class.__index = class

function class.__tostring()
	return "ScriptedEditableSprite"
end

function class:Play()
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

function class:Pause()
	local __raw = self.__raw

	if not __raw.isPlaying then
		return false
	end

	__raw.isPlaying = false
	__raw.__playcon:Disconnect()
	local pauseCalled = self.__signalcache.PauseCalled
	_ = pauseCalled and pauseCalled:Fire()
	return true
end

function class:Advance()
	local onRenderCallback = self.onRenderCallback

	if onRenderCallback then
		onRenderCallback(self)
	end
end

function class:SetFrame(currentFrame: Vector3)
	local __raw = self.__raw
	local currentFrame2 = __raw.currentFrame
	__raw.currentFrame = currentFrame
	local v = self.inputImages[currentFrame.Z] or error("Index out of range")

	if not v then
		return
	end

	local edgeOffset = __raw.edgeOffset
	local spriteOffset = __raw.spriteOffset
	local spriteSize = __raw.spriteSize
	local v2 = edgeOffset.X + (currentFrame.X - 1) * (spriteSize.X + spriteOffset.X)
	local v3 = edgeOffset.Y + (currentFrame.Y - 1) * (spriteSize.Y + spriteOffset.Y)
	self.outputImage:WritePixelsBuffer(
		__raw.outputPosition,
		spriteSize,
		v:ReadPixelsBuffer(Vector2.new(v2, v3), spriteSize)
	)
	local frameChanged

	if currentFrame2 == currentFrame then
		frameChanged = false
	else
		frameChanged = __raw.__signalcache.FrameChanged
	end

	_ = frameChanged and frameChanged:Fire()
end

function class:LoadInputImage(value, p)
	local __raw = self.__raw
	local v = p or #__raw.inputImages + 1
	local inputImages = __raw.inputImages

	if type(value) == "string" then
		value = AssetService2:CreateEditableImageAsync(value)
	end

	inputImages[v] = value
	self:SetFrame(__raw.currentFrame)
end

local v = {
	"FrameChanged",
	"PlayCalled",
	"PauseCalled",
	"StaticChanged"
}
local CompositeSprite = {}

for k, v2 in pairs(v) do
	v[v2] = true
end

function class:GetSignal(p2)
	local __signalcache = self.__signalcache
	local v2 = __signalcache[p2]

	if v2 then
		return v2.Event
	end

	if not v[p2] then
		error("Invalid signal type " .. p2)
	end

	v2 = Instance.new("BindableEvent")
	__signalcache[p2] = v2
	return v2.Event
end

local function fn(object, p: string, size)
	local __raw = object.__raw

	if __raw[p] == size then
		return
	end

	if p == "isLooped" or p == "currentFrame" or p == "inputImages" then
		error((`Property {p} is read-only`))
	end

	__raw[p] = size

	if p == "frameRate" then
		if __raw.isPlaying then
			object:Pause()
			object:Play()
		end
	elseif p == "outputImage" or p == "outputPosition" then
		object:SetFrame(__raw.currentFrame)
	elseif p == "spriteSize" then
		__raw.outputImage.Size = size

		if __raw.inputImage then
			object:SetFrame(__raw.currentFrame)
		end
	elseif (p == "edgeOffset" or p == "spriteOffset") and __raw.inputImage then
		object:SetFrame(__raw.currentFrame)
	end

	local staticChanged = __raw.__signalcache.StaticChanged
	_ = staticChanged and staticChanged:Fire(p)
end

function CompositeSprite.new(data)
	local raw = {
		inputImages = {},
		outputImage = data.outputImage,
		outputPosition = data.outputPosition or Vector2.zero,
		currentFrame = data.currentFrame or Vector2.one,
		spriteSize = data.spriteSize or error("Sprite size must be provided"),
		spriteOffset = data.spriteOffset or Vector2.zero,
		edgeOffset = data.edgeOffset or Vector2.zero,
		frameRate = data.frameRate or 30,
		isPlaying = false,
		onRenderCallback = data.onRenderCallback,
		__signalcache = {}
	}
	raw.__raw = raw
	setmetatable(raw, class)

	if not raw.outputImage then
		raw.outputImage = AssetService:CreateEditableImage({
			Size = raw.spriteSize
		})
	end

	local v3 = newproxy(true)
	local metatable = getmetatable(v3)

	function metatable.__tostring()
		return "CompositeSprite"
	end

	metatable.__index = raw
	metatable.__newindex = fn

	for k, v4 in pairs(data.inputImages or {}) do
		v3:LoadInputImage(v4)
	end

	return v3
end

return CompositeSprite