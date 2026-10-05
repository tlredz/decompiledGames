local parentModule = require(script.Parent)
local TextTags = require(script.Parent.Parent.Parent.TextTags)
local Translation = require(script.Parent.Parent.Parent.Translation)
local object = setmetatable({}, {
	__index = parentModule
})
object.__index = object

function object.new(p)
	local v = parentModule.new(p)
	v._kind = "icon"
	v._image = nil
	v._imageRectOffset = nil
	v._imageRectSize = nil
	v._backgroundImage = nil
	v._backgroundImageRectOffset = nil
	v._backgroundImageRectSize = nil
	v._color = nil
	v._transparency = nil
	v._scaleType = nil
	v._size = nil
	v._optionSize = nil
	v._effect = nil
	v._bubble = nil
	return (setmetatable(v, object))
end

function object:setImage(image: string)
	self._image = image
	self._imageRectOffset = nil
	self._imageRectSize = nil
	return self
end

function object:setSprite(p2: string)
	local sprite = TextTags.sprite(p2)

	if not sprite then
		warn("[DIALOGUE]", (`unknown sprite "{p2}"`))
		return self
	end

	self._image = sprite.Image
	self._imageRectOffset = sprite.ImageRectOffset
	self._imageRectSize = sprite.ImageRectSize
	return self
end

function object:setBackgroundSprite(p2: string)
	local sprite = TextTags.sprite(p2)

	if not sprite then
		warn("[DIALOGUE]", (`unknown sprite "{p2}"`))
		return self
	end

	self._backgroundImage = sprite.Image
	self._backgroundImageRectOffset = sprite.ImageRectOffset
	self._backgroundImageRectSize = sprite.ImageRectSize
	return self
end

function object:setBubble(value: string, p2: string)
	local lower = value:lower()
	local v = lower == "none" or lower == "transparent" or lower == "invisible"
	local color = Color3.new(1, 1, 1)

	if not v then
		color = TextTags.color(value)

		if not color then
			warn("[DIALOGUE]", (`unknown bubble color "{value}"`))
			color = Color3.new(1, 1, 1)
		end
	end

	local riches = {}

	for _, v2 in Translation.toWords(p2) do
		if v2.rich ~= "" then
			table.insert(riches, v2.rich)
		end
	end

	self._bubble = {
		color = color,
		text = table.concat(riches, " "),
		transparent = v and true or nil
	}
	return self
end

function object:setColor(color: Color3?)
	self._color = color
	return self
end

function object:setTransparency(transparency: number?)
	self._transparency = transparency
	return self
end

function object:setScaleType(scaleType)
	self._scaleType = scaleType
	return self
end

function object:setSize(size: Vector2?)
	self._size = size
	self._calculatedAbsoluteSize = nil
	return self
end

function object:setOptionSize(optionSize: UDim2?)
	self._optionSize = optionSize
	return self
end

function object:setEffect(effect: string?)
	self._effect = effect
	return self
end

function object:_measure()
	return self._size or Vector2.new(20, 20)
end

return object