local Translation = require(script.Parent.Parent.Translation)
local TextTags = require(script.Parent.Parent.TextTags)
local Icon = require(script.Parent.Renderable.Icon)
local Word = require(script.Parent.Renderable.Word)
local Option = {}
Option.__index = Option
local v = {
	nevermind = {
		image = "rbxassetid://117642311710245"
	},
	exit = {
		image = "rbxassetid://117642311710245"
	},
	["return"] = {
		image = "rbxassetid://99961963437803"
	},
	back = {
		image = "rbxassetid://99961963437803"
	},
	enchant = {
		image = "rbxassetid://74788428061304"
	},
	learn = {
		image = "rbxassetid://77225418149199"
	},
	craft = {
		image = "rbxassetid://87666260882637",
		size = UDim2.fromScale(0.75, 0.75)
	}
}

function Option.new(dialogue, state)
	return (setmetatable({
		_dialogue = dialogue,
		_state = state,
		_optionType = nil,
		_effect = nil,
		_icon = nil,
		_iconFromText = false,
		_text = nil,
		_words = nil,
		_jump = nil,
		_selectedFn = nil,
		_hoverStateChangedFn = nil,
		_locked = false,
		_isCancel = false
	}, Option))
end

local function getRawLabel(p: string)
	local match = Translation.stripTags(p):match("^%s*(.-)%s*$")

	if match and match ~= "" then
		return match
	end

	return nil
end

local function getRawLabelIconConfig(p: string)
	local match = Translation.stripTags(p):match("^%s*(.-)%s*$")

	if not match or match == "" then
		match = nil
	end

	if match then
		return v[string.lower(match)]
	end

	return nil
end

local function getRawLabelSpriteNames(p: string)
	local match = Translation.stripTags(p):match("^%s*(.-)%s*$")

	if not match or match == "" then
		match = nil
	end

	if not match then
		return nil, nil
	end

	local formatted = `{match}1`
	local formatted2 = `{match}2`

	if TextTags.sprite(formatted) then
		match = formatted
	elseif not TextTags.sprite(match) then
		match = nil
	end

	if match and TextTags.sprite(formatted2) then
		return match, formatted2
	end

	return match, nil
end

function Option:setText(p: string)
	local v2 = nil
	local v3 = nil
	local v4

	if not (self._icon and not self._iconFromText) then
		local match = Translation.stripTags(p):match("^%s*(.-)%s*$")

		if not match or match == "" then
			match = nil
		end

		if match then
			v4 = v[string.lower(match)]
		end

		if not v4 then
			v2, v3 = getRawLabelSpriteNames(p)
		end
	end

	self._text = { p }
	self._words = {}

	for _, v5 in Translation.toWords(Translation.translate(p)) do
		table.insert(self._words, Word.new(v5))
	end

	if self._icon and not self._iconFromText then
		return self
	end

	if v4 then
		local icon = Icon.new():setImage(v4.image)

		if v4.size then
			icon:setOptionSize(v4.size)
		end

		self._icon = icon
		self._iconFromText = true
		return self
	elseif v2 then
		local icon = Icon.new():setSprite(v2)

		if v3 then
			icon:setBackgroundSprite(v3)
		end

		self._icon = icon
		self._iconFromText = true
		return self
	elseif self._iconFromText then
		self._icon = nil
		self._iconFromText = false
	end

	return self
end

function Option:setIcon(callback)
	local icon = Icon.new()
	callback(icon)
	self._icon = icon
	self._iconFromText = false
	return self
end

function Option:setSprite(p2: string)
	self._icon = Icon.new():setSprite(p2)
	self._iconFromText = false
	return self
end

function Option:setBubble(p2: string, p3: string)
	self._icon = Icon.new():setBubble(p2, p3)
	self._iconFromText = false
	return self
end

function Option:setType(optionType: string)
	self._optionType = optionType
	return self
end

function Option:setEffect(effect: string?)
	self._effect = effect
	return self
end

function Option:setLocked(flag: boolean?)
	self._locked = flag ~= false
	return self
end

function Option:onSelected(selectedFn)
	self._selectedFn = selectedFn
	return self
end

function Option:onHoverStateChanged(hoverStateChangedFn)
	self._hoverStateChangedFn = hoverStateChangedFn
	return self
end

function Option:jumpTo(value)
	self._jump = typeof(value) == "string" and {
		kind = "id",
		id = value
	} or {
		kind = "dialogue",
		dialogue = value
	}
	return self
end

function Option:jumpToPage(build)
	self._jump = {
		kind = "inline",
		build = build
	}
	return self
end

function Option:goBack(count: number?)
	self._jump = {
		kind = "back",
		count = count
	}
	return self
end

function Option:swapTranslatedText(p2: string, p3: string)
	if not self._text or #self._text ~= 1 or self._text[1] ~= p2 then
		return false
	end

	local words = {}

	for _, v3 in Translation.toWords(p3) do
		table.insert(words, Word.new(v3))
	end

	self._words = words
	return true
end

function Option:resolveJump(object)
	if self._selectedFn then
		self._selectedFn(self)
	end

	local _jump = self._jump

	if not _jump then
		return nil
	end

	if _jump.kind == "back" then
		return object:back(_jump.count)
	end

	if _jump.kind == "inline" then
		return self._dialogue:_openInline(_jump.build, object)
	end

	if _jump.kind == "id" then
		return self._dialogue:_openById(_jump.id, object)
	end

	if _jump.kind == "dialogue" then
		return _jump.dialogue:_openTop(object)
	end

	if _jump.kind == "dynamic" then
		return _jump.resolve(object)
	end

	return nil
end

return Option