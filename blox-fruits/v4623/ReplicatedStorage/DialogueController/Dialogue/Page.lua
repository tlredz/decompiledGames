local Translation = require(script.Parent.Parent.Translation)
local Renderable = require(script.Parent.Renderable)
local Word = require(script.Parent.Renderable.Word)
local Option = require(script.Parent.Option)
local Head = require(script.Parent.Head)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Page = {}
Page.__index = Page

-- equivalent calls inferred from this helper; original call sites unknown
local function resetCancelConfig()
	return {
		text = nil,
		hidden = false,
		forced = false,
		randomizeSwap = false,
		swapRoll = nil,
		configure = nil,
		option = nil
	}
end

local function resetBuiltState(p)
	p._renderables = {}
	p._textGroups = {}
	p._textSources = {}
	p._textTransforms = {}
	p._textIndex = 1
	p._options = {}
	p._specialReactComponents = {}
	p._title = nil
	p._subtitle = nil
	p._subtitleSet = false
	p._cancel = resetCancelConfig()
	p._floatingHead = nil
	p._onFinishedFn = nil
	p._advancePage = nil
	p._advanceDelay = nil
	p._skippable = true
	p._skipReveal = not p._dialogue or p._dialogue._skipRevealDefault ~= false
	p._closeRequested = false
	p._redirectPage = nil
end

local function createTextGroup(p: string, callback)
	local result = {}
	local translated = Translation.translate(p)

	if callback then
		translated = callback(translated)
	end

	for _, v in Translation.toWords(translated) do
		table.insert(result, Word.new(v))
	end

	return result
end

function Page.new(dialogue, state, builder)
	local self = setmetatable({
		_dialogue = dialogue,
		_state = state,
		_builder = builder,
		_redirectPage = nil,
		_refreshKey = 0,
		_revealKey = 0,
		_maid = nil
	}, Page)
	resetBuiltState(self)
	return self
end

function Page:addText(p2: string)
	table.insert(self._textGroups, (createTextGroup(p2)))
	table.insert(self._textSources, p2)
	return self
end

function Page:replaceText(p: string)
	self._textGroups = {}
	self._textSources = {}
	self._textTransforms = {}
	self._textIndex = 1
	self._refreshKey += 1
	self._revealKey += 1
	self:addText(p)

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		self._state._window:refreshText()
	end

	return self
end

function Page:replaceTextWithoutReplay(p: string)
	self._textGroups = {}
	self._textSources = {}
	self._textTransforms = {}
	self._textIndex = 1
	self._refreshKey += 1
	self:addText(p)

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		self._state._window:refreshText()
	end

	return self
end

function Page:setCurrentText(p: string)
	self._textGroups[self._textIndex] = createTextGroup(p)
	self._textSources[self._textIndex] = p
	self._textTransforms[self._textIndex] = nil
	self._refreshKey += 1
	self._revealKey += 1

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		self._state._window:refreshText()
	end

	return self
end

function Page:transformCurrentText(callback)
	local _textSource = self._textSources[self._textIndex]

	if not _textSource then
		return self
	end

	self._textTransforms[self._textIndex] = callback
	self._textGroups[self._textIndex] = createTextGroup(_textSource, callback)
	self._refreshKey += 1
	self._revealKey += 1

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		self._state._window:refreshText()
	end

	return self
end

function Page:swapTranslatedText(p: string, p2: string)
	local v = false

	for k, _textSource in self._textSources do
		if _textSource ~= p then
			continue
		end

		local v2 = {}
		local _textTransform = self._textTransforms[k]
		local v3

		if _textTransform then
			v3 = _textTransform(p2)
		else
			v3 = p2
		end

		for _, v4 in Translation.toWords(v3) do
			table.insert(v2, Word.new(v4))
		end

		self._textGroups[k] = v2
		v = true
	end

	for _, _renderable in self._renderables do
		v = _renderable:swapTranslatedText(p, p2) or v
	end

	return v
end

local function parseRenderableConfig(value, callback)
	if typeof(value) == "function" then
		return nil, value
	end

	assert(typeof(value) == "table", "addRenderable expects a config table or constructor function")
	assert(typeof(callback) == "function", "addRenderable expects a constructor function")
	return value, callback
end

function Page:addRenderable(value, callback)
	if typeof(value) == "function" then
		callback = value
		value = nil
	else
		assert(typeof(value) == "table", "addRenderable expects a config table or constructor function")
		assert(typeof(callback) == "function", "addRenderable expects a constructor function")
	end

	local v = Renderable.new(value)
	callback(v)
	table.insert(self._renderables, v)
	return self
end

function Page:addOption(callback)
	local v = Option.new(self._dialogue, self._state)
	callback(v)
	table.insert(self._options, v)
	return self
end

function Page:addOptionType(optionType: string, callback)
	local v = Option.new(self._dialogue, self._state)
	v._optionType = optionType
	callback(v)
	table.insert(self._options, v)
	return self
end

function Page:addPurchaseOption(p, p2: string, callback, value: string?, value2: string?)
	local v = Option.new(self._dialogue, self._state)
	v._optionType = "Purchase"
	v:setBubble("None", (`<color="{value or "#43b041"}">{tostring(p)}</color>`)):setText((`<color="{value2 or "White"}">{p2}</color>`))

	if callback then
		callback(v)
	end

	table.insert(self._options, v)
	return self
end

function Page:toggleSpecialReactComponent(value: string, p2)
	local v

	if typeof(value) == "string" then
		v = value ~= ""
	else
		v = false
	end

	assert(v, "toggleSpecialReactComponent expects a component name")

	if self._specialReactComponents[value] == nil then
		self._specialReactComponents[value] = p2 or true
	else
		self._specialReactComponents[value] = nil
	end

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		self._state._window:render()
	end

	return self
end

function Page:setHead(floatingHead)
	self._floatingHead = floatingHead
	return self
end

function Page:setTitle(title: string)
	self._title = title
	return self
end

function Page:setSubtitle(subtitle: string?)
	self._subtitle = subtitle
	self._subtitleSet = true
	return self
end

function Page:setCancelText(text: string)
	self._cancel.text = text
	return self
end

function Page:noCancel()
	self._cancel.hidden = true
	return self
end

function Page:noSkip()
	self._skippable = false
	return self
end

function Page:noSkipReveal()
	self._skipReveal = false
	return self
end

function Page:forceCancel()
	self._cancel.forced = true
	return self
end

function Page:randomizeCancelSwap()
	self._cancel.randomizeSwap = true
	self._cancel.swapRoll = math.random()
	return self
end

function Page:onCancel(configure)
	self._cancel.configure = configure
	return self
end

function Page:onFinished(onFinishedFn)
	self._onFinishedFn = onFinishedFn
	return self
end

function Page:onPageAdvance(build)
	self._advancePage = {
		kind = "inline",
		build = build
	}
	return self
end

function Page:jumpToOnAdvance(id: string)
	self._advancePage = {
		kind = "id",
		id = id
	}
	return self
end

function Page:advanceAfterDelay(advanceDelay: number)
	local v

	if typeof(advanceDelay) == "number" then
		v = advanceDelay >= 0
	else
		v = false
	end

	assert(v, "advanceAfterDelay expects a non-negative number")
	self._advanceDelay = advanceDelay
	return self
end

function Page:getMaid()
	if not self._maid then
		self._maid = Maid.new()
	end

	return self._maid
end

function Page:close()
	self._closeRequested = true
	return self
end

function Page:refresh()
	local _builder = self._builder
	assert(_builder ~= nil, "page:refresh() requires a page builder")
	self:_destroyMaid()
	self._refreshKey += 1
	self._revealKey += 1
	resetBuiltState(self)
	_builder(self)

	if self._state and self._state.getCurrent and self._state:getCurrent() == self then
		if self._floatingHead then
			Head.show(self._floatingHead)
		end

		self._state._window:refreshText()
	end

	return self
end

local function redirect(state, redirectPage)
	assert(state._state ~= nil, "page redirect requires a dialogue state")

	if state._state.getCurrent and state._state:getCurrent() == state then
		local v = nil

		if redirectPage.kind == "inline" then
			v = state._dialogue:_replaceInline(redirectPage.build, state._state)
		elseif redirectPage.kind == "dialogue" then
			v = redirectPage.dialogue:_replaceTop(state._state)
		end

		if v then
			state._state._window:render()
			return v
		end
	end

	state._redirectPage = redirectPage
	return state
end

function Page.pageRedirect(p, build)
	assert(typeof(build) == "function", "pageRedirect expects a page constructor function")
	return (redirect(p, {
		kind = "inline",
		build = build
	}))
end

function Page.dialogueRedirect(p, dialogue)
	local v

	if dialogue == nil then
		v = false
	else
		v = dialogue._openTop ~= nil
	end

	assert(v, "dialogueRedirect expects a built dialogue")
	return (redirect(p, {
		kind = "dialogue",
		dialogue = dialogue
	}))
end

function Page:_destroyMaid()
	local _maid = self._maid

	if not _maid then
		return
	end

	self._maid = nil
	_maid:Destroy()
end

function Page:getCurrentText()
	return self._textGroups[self._textIndex]
end

function Page:getTitle()
	return self._title or self._state:getTitle()
end

function Page:getSubtitle()
	if self._subtitleSet then
		return self._subtitle
	end

	return self._state:getSubtitle()
end

function Page:advanceText()
	if self._textIndex < #self._textGroups then
		self._textIndex += 1
		return true
	else
		return false
	end
end

function Page:advancePage()
	local _advancePage = self._advancePage

	if not _advancePage then
		return nil
	end

	if _advancePage.kind == "inline" then
		return self._dialogue:_openInline(_advancePage.build, self._state)
	end

	if _advancePage.kind == "id" then
		return self._dialogue:_openById(_advancePage.id, self._state)
	end

	return nil
end

function Page:areOptionsVisible()
	return self._textIndex >= #self._textGroups
end

function Page:getCancelOption()
	if self._cancel.hidden or #self._options == 0 and not self._cancel.forced then
		return nil
	end

	if self._cancel.option then
		return self._cancel.option
	end

	local option = Option.new(self._dialogue, self._state)
	option._isCancel = true
	option:setText(self._cancel.text or "Nevermind")

	if self._cancel.configure then
		self._cancel.configure(option)
	end

	self._cancel.option = option
	return self._cancel.option
end

return Page