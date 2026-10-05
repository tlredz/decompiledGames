require(script.Parent.Parent.Types)
require(game.ReplicatedStorage.NPCManager.Types)
local State = {}
State.__index = State

local function destroyPageMaid(p)
	if not p then
		return
	end

	local _destroyMaid = p._destroyMaid

	if _destroyMaid then
		_destroyMaid(p)
	end
end

function State.new(window, value: string?, subtitle: string?, titleSprite, npc, dialogue)
	return (setmetatable({
		_pageStack = {},
		_window = window,
		_dialogue = dialogue,
		_title = value or "",
		_titleSprite = titleSprite,
		_subtitle = subtitle,
		_npc = npc,
		_npcLifecycleStarted = false
	}, State))
end

function State:getCurrent()
	return self._pageStack[#self._pageStack]
end

function State:push(p)
	local current = self:getCurrent()
	local _destroyMaid = current and current._destroyMaid

	if _destroyMaid then
		_destroyMaid(current)
	end

	table.insert(self._pageStack, p)
	return p
end

function State:replaceCurrent(p2)
	local v = table.remove(self._pageStack)
	local _destroyMaid = v and v._destroyMaid

	if _destroyMaid then
		_destroyMaid(v)
	end

	table.insert(self._pageStack, p2)
	return p2
end

function State:back(value: number?)
	for _ = 1, value or 1 do
		if #self._pageStack == 0 then
			break
		end

		local v = table.remove(self._pageStack)

		if not v then
			continue
		end

		local _destroyMaid = v._destroyMaid

		if _destroyMaid then
			_destroyMaid(v)
		end
	end

	return self:getCurrent()
end

function State:destroyPageMaids()
	for _, v in self._pageStack do
		if not v then
			continue
		end

		local _destroyMaid = v._destroyMaid

		if _destroyMaid then
			_destroyMaid(v)
		end
	end
end

function State:getDepth()
	return #self._pageStack
end

function State:setTitle(title: string)
	self._title = title
end

function State:getTitle()
	return self._title
end

function State:setTitleSprite(titleSprite)
	self._titleSprite = titleSprite
end

function State:getTitleSprite()
	return self._titleSprite
end

function State:setSubtitle(subtitle: string?)
	self._subtitle = subtitle
end

function State:getSubtitle()
	return self._subtitle
end

function State:getNPC()
	return self._npc
end

return State