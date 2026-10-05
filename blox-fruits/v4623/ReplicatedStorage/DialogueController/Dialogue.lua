require(script.Parent.Types)
local TextTags = require(script.Parent.TextTags)
local Page = require(script.Page)
local Head = require(script.Head)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue.new()
	return (setmetatable({
		_state = nil,
		_title = "",
		_titleSprite = nil,
		_subtitle = nil,
		_top = nil,
		_pages = {},
		_pagesById = {},
		_onRenderSteppedFn = nil,
		_skipRevealDefault = true,
		_built = false,
		_maid = nil
	}, Dialogue))
end

function Dialogue:setTitle(title: string, p: string?, p2)
	self._title = title

	if p then
		self:setTitleSprite(p, p2)
	end

	return self
end

function Dialogue:setTitleSprite(p2: string?, p3)
	if not p2 then
		self._titleSprite = nil
		return self
	end

	local sprite = TextTags.sprite(p2)

	if sprite then
		self._titleSprite = {
			sprite = sprite,
			wiggle = p3 and p3.wiggle
		}
		return self
	end

	warn("[DIALOGUE]", (`unknown title sprite "{p2}"`))
	self._titleSprite = nil
	return self
end

function Dialogue:setSubtitle(subtitle: string?)
	self._subtitle = subtitle
	return self
end

function Dialogue:noSkipReveal()
	self._skipRevealDefault = false
	return self
end

function Dialogue:onRenderStepped(onRenderSteppedFn)
	self._onRenderSteppedFn = onRenderSteppedFn
	return self
end

function Dialogue:getNPC()
	local _state = self._state

	if _state then
		return (_state:getNPC())
	end

	return nil
end

function Dialogue:getMaid()
	if not self._maid then
		self._maid = Maid.new()
	end

	return self._maid
end

local function currentPage(p, p2: string)
	local _state = p._state
	assert(_state ~= nil, (`dialogue:{p2}() requires an active dialogue`))
	local current = _state:getCurrent()
	assert(current ~= nil, (`dialogue:{p2}() requires a current page`))
	return current
end

function Dialogue:pageRedirect(p2)
	local _state = self._state
	assert(_state ~= nil, "dialogue:pageRedirect() requires an active dialogue")
	local current = _state:getCurrent()
	assert(current ~= nil, "dialogue:pageRedirect() requires a current page")
	return current:pageRedirect(p2)
end

function Dialogue:dialogueRedirect(p2)
	local _state = self._state
	assert(_state ~= nil, "dialogue:dialogueRedirect() requires an active dialogue")
	local current = _state:getCurrent()
	assert(current ~= nil, "dialogue:dialogueRedirect() requires a current page")
	return current:dialogueRedirect(p2)
end

function Dialogue:addPage(id, build)
	if typeof(id) ~= "string" then
		build = id
		id = nil
	end

	assert(typeof(build) == "function", "addPage expects a page constructor function")
	local v = {
		id = id,
		build = build
	}
	table.insert(self._pages, v)

	if id then
		assert(self._pagesById[id] == nil, (`duplicate page id "{id}"`))
		self._pagesById[id] = v
	end

	self._top = self._top or v
	return self
end

function Dialogue:build()
	assert(self._top ~= nil, "dialogue has no pages")
	self._built = true
	return self
end

function Dialogue:_destroyMaid()
	local _maid = self._maid

	if not _maid then
		return
	end

	self._maid = nil
	_maid:Destroy()
end

function Dialogue:_buildInline(callback, p)
	local v = Page.new(self, p, callback)
	callback(v)

	if v._closeRequested then
		v:_destroyMaid()
		return nil
	end

	local _redirectPage = v._redirectPage

	if _redirectPage then
		v:_destroyMaid()

		if _redirectPage.kind == "inline" then
			return self:_buildInline(_redirectPage.build, p)
		end

		if _redirectPage.kind == "dialogue" then
			return _redirectPage.dialogue:_buildTop(p)
		end

		return nil
	else
		if v._floatingHead then
			Head.show(v._floatingHead)
		end

		return v
	end
end

function Dialogue:_buildTop(p)
	assert(self._built, (`dialogue "{self._title}" was never :build()`))
	return self:_buildInline(self._top.build, p)
end

function Dialogue:_openInline(p, object2)
	local _buildInline = self:_buildInline(p, object2)

	if _buildInline then
		return (object2:push(_buildInline))
	end

	return nil
end

function Dialogue:_openById(p: string, p2)
	local v = self._pagesById[p]
	assert(v ~= nil, (`no page with id "{p}" in dialogue "{self._title}"`))
	return self:_openInline(v.build, p2)
end

function Dialogue:_openTop(object2)
	local _buildTop = self:_buildTop(object2)

	if _buildTop then
		return (object2:push(_buildTop))
	end

	return nil
end

function Dialogue:_replaceInline(p, object2)
	local _buildInline = self:_buildInline(p, object2)

	if _buildInline then
		return (object2:replaceCurrent(_buildInline))
	end

	return nil
end

function Dialogue:_replaceTop(object2)
	local _buildTop = self:_buildTop(object2)

	if _buildTop then
		return (object2:replaceCurrent(_buildTop))
	end

	return nil
end

return Dialogue