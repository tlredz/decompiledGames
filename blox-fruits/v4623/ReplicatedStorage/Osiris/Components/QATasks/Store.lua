local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local count = 0

local function use(p, p2)
	if p == nil then
		return Osiris.State(p2)
	end

	return p
end

local Store = {}
Store.ROOT_CHILDREN_KEY = "/"
Store.ANY_TAG = "(any tag)"

function Store.emptyEditor()
	count += 1
	return {
		Session = count,
		Mode = "None",
		Path = nil,
		Parent = nil,
		Key = "",
		Title = "",
		Description = "",
		IsGlobal = false,
		Tags = {},
		Steps = {},
		Expectations = {},
		NextRowId = 1,
		IsSubmitting = false,
		Error = nil
	}
end

function Store.use(options, options2)
	local v = options2 or {}
	local v2 = {
		Arguments = options or {}
	}
	local isOpen = v.isOpen

	if isOpen == nil then
		isOpen = Osiris.State(true)
	end

	v2.isOpen = isOpen
	v2.permissions = Osiris.State(nil)
	local currentPath = v.currentPath

	if currentPath == nil then
		currentPath = Osiris.State(nil)
	end

	v2.currentPath = currentPath
	local selectedPath = v.selectedPath

	if selectedPath == nil then
		selectedPath = Osiris.State(nil)
	end

	v2.selectedPath = selectedPath
	v2.tasks = Osiris.State({})
	v2.children = Osiris.State({})
	v2.progress = Osiris.State({})
	v2.build = Osiris.State(nil)
	v2.completions = Osiris.State({})
	v2.assignments = Osiris.State({})
	v2.stateLoaded = Osiris.State(false)
	v2.pending = Osiris.State({})
	v2.message = Osiris.State(nil)
	v2.messageIsError = Osiris.State(false)
	v2.filter = Osiris.State("")
	v2.tagFilter = Osiris.State("(any tag)")
	v2.onlyMine = Osiris.State(false)
	v2.filterKey = Osiris.State("")
	v2.testers = Osiris.State({})
	v2.testerChoice = Osiris.State("")
	v2.shaSummary = Osiris.State(nil)
	v2.editor = Osiris.State(nil)
	local navigatorPosition = v.navigatorPosition
	local vector = Vector2.new(40, 80)

	if navigatorPosition == nil then
		navigatorPosition = Osiris.State(vector)
	end

	v2.navigatorPosition = navigatorPosition
	local navigatorSize = v.navigatorSize
	local vector2 = Vector2.new(440, 560)

	if navigatorSize == nil then
		navigatorSize = Osiris.State(vector2)
	end

	v2.navigatorSize = navigatorSize
	local detailPosition = v.detailPosition
	local vector3 = Vector2.new(500, 80)

	if detailPosition == nil then
		detailPosition = Osiris.State(vector3)
	end

	v2.detailPosition = detailPosition
	local detailSize = v.detailSize
	local vector4 = Vector2.new(460, 560)

	if detailSize == nil then
		detailSize = Osiris.State(vector4)
	end

	v2.detailSize = detailSize
	local completionPosition = v.completionPosition
	local vector5 = Vector2.new(980, 80)

	if completionPosition == nil then
		completionPosition = Osiris.State(vector5)
	end

	v2.completionPosition = completionPosition
	local completionSize = v.completionSize
	local vector6 = Vector2.new(380, 340)

	if completionSize == nil then
		completionSize = Osiris.State(vector6)
	end

	v2.completionSize = completionSize
	local editorPosition = v.editorPosition
	local vector7 = Vector2.new(980, 440)

	if editorPosition == nil then
		editorPosition = Osiris.State(vector7)
	end

	v2.editorPosition = editorPosition
	local editorSize = v.editorSize
	local vector8 = Vector2.new(460, 520)

	if editorSize == nil then
		editorSize = Osiris.State(vector8)
	end

	v2.editorSize = editorSize
	local adminPosition = v.adminPosition
	local vector9 = Vector2.new(1380, 80)

	if adminPosition == nil then
		adminPosition = Osiris.State(vector9)
	end

	v2.adminPosition = adminPosition
	local adminSize = v.adminSize
	local vector10 = Vector2.new(400, 420)

	if adminSize == nil then
		adminSize = Osiris.State(vector10)
	end

	v2.adminSize = adminSize
	return v2
end

function Store.childrenKey(value)
	return value or "/"
end

function Store.setMessage(p, p2: string?, flag: boolean?)
	p.message:set(p2)
	p.messageIsError:set(flag == true)
end

return Store