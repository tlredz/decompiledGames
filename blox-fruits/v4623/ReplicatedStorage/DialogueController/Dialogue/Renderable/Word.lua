local TextService = game:GetService("TextService")
local parentModule = require(script.Parent)
require(script.Parent.Parent.Parent.TextTags)
require(script.Parent.Parent.Parent.Translation)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local object = setmetatable({}, {
	__index = parentModule
})
object.__index = object

function object.new(data)
	local v = parentModule.new()
	v._rawRichText = data.rich
	v._rawText = data.raw
	v._lineBreakAfter = data.lineBreakAfter == true
	v._animate = data.animate
	v._textXAlignment = data.textXAlignment
	v._textYAlignment = data.textYAlignment
	v._sprite = data.sprite
	v._bubble = data.bubble
	return (setmetatable(v, object))
end

function object:_measure()
	if self._sprite then
		local imageRectSize = self._sprite.ImageRectSize
		local v = not (imageRectSize and imageRectSize.Y > 0) and 1 or imageRectSize.X / imageRectSize.Y
		return Vector2.new(20 * v, 20)
	else
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = self._rawText
		getTextBoundsParams.Font = rbxassetfontsfamiliesHighwayGothicjson
		getTextBoundsParams.Size = 20
		local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

		if success then
			return textBoundsAsync
		end

		return Vector2.zero
	end
end

return object