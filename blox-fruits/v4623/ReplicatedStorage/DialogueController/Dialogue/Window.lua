local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ReactComponents = require(script.Parent.Parent.ReactComponents)
local responses = ReactComponents.Responses
local special = ReactComponents.Special
local Snapshot = require(script.Parent.Renderable.Snapshot)
local v = {
	Chat = responses.ChatButton,
	Accept = responses.AcceptButton,
	Purchase = responses.PurchaseButton,
	Quest = responses.QuestButton,
	Boss = responses.QuestBossButton,
	Recommended = responses.QuestRecommendedButton,
	Locked = responses.QuestLockedButton,
	Leave = responses.NevermindButton,
	Event = responses.EventButton
}
local v2 = {}
local Window = {}
Window.__index = Window
local v3 = nil
local v4 = nil
local v5 = nil

local function getRoot()
	if v5 then
		return v5
	end

	local v6

	if v3 then
		v6 = v3
	else
		v6 = Instance.new("ScreenGui")
		v6.Name = "DialogueGui"
		v6.ResetOnSpawn = false
		v6.DisplayOrder = 5
		v6.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v6
	end

	v5 = ReactRoblox.createRoot(v6)
	return v5
end

function Window.setMountTarget(p)
	if v5 then
		v5:unmount()
		v5 = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	v3 = p
end

local function buildSteps(words)
	local total = 0
	local steps = {}

	for k, v7 in words do
		local graphemes = (v7.sprite and 1 or utf8.len(v7.raw) or #v7.raw) + (k < #words and 1 or 0)
		total += graphemes
		local animate = v7.animate
		table.insert(steps, {
			graphemes = graphemes,
			stepFrequency = animate and animate.stepFrequency,
			stepTime = animate and animate.stepTime,
			yieldAfter = animate and animate.yieldAfter
		})
	end

	return {
		steps = steps,
		total = total
	}
end

local v6 = {}

local function mergedSpecialProps(defaultProps, items, props)
	local result = not defaultProps and {} or table.clone(defaultProps)

	if items then
		for k, item in items do
			result[k] = item
		end
	end

	if props then
		for k, item in props do
			result[k] = item
		end
	end

	return result
end

local function makeSpecialSlotChildren(specialReactComponents, p, p2)
	local children = {}

	for _, v7 in specialReactComponents or {} do
		local name = v7.name
		local v8 = special.get(name)

		if v8 then
			if v8.slot == p then
				children[`special{name}`] = React.createElement(
					v8.component,
					(mergedSpecialProps(v8.defaultProps, p2, v7.props))
				)
			end
		elseif not v6[name] then
			warn("[DIALOGUE]", (`unknown special React component "{name}"`))
			v6[name] = true
		end
	end

	return children, next(children) ~= nil
end

local function Screen(props)
	local v7 = React.useMemo(function()
		return (buildSteps(props.words))
	end, { props.textKey })
	local steps = v7.steps
	local ref = React.useRef(props.textKey)
	local state, setState = React.useState(0)
	local ref2 = React.useRef(nil)
	local v8 = ref.current ~= props.textKey

	if v8 then
		ref.current = props.textKey
	end

	local v9 = v8 and 0 or state
	local v10 = v9 == -1 or v7.total <= v9
	React.useEffect(function()
		local textKey = props.textKey
		local thread = task.spawn(function()
			if props.entrance then
				task.wait(0.3)
			end

			local v11 = 0

			for _, step in steps do
				local v12 = v11 + step.graphemes

				while v11 < v12 do
					if ref.current ~= textKey then
						return
					end

					v11 = math.min(v12, v11 + (step.stepFrequency or 1))
					setState(v11)
					task.wait(step.stepTime or 0.01)
				end

				if step.yieldAfter then
					task.wait(step.yieldAfter)
				end
			end

			if ref.current == textKey then
				setState(-1)
			end
		end)
		ref2.current = thread
		return function()
			pcall(task.cancel, thread)
		end
	end, { props.textKey })
	local v11 = (props.slide or "shown") == "shown"

	local function clicked()
		if not v11 or props.skippable == false then
			return
		end

		if v10 then
			props.onAdvance()
			return
		end

		if props.skipReveal == false then
			return
		end

		if ref2.current then
			pcall(task.cancel, ref2.current)
		end

		setState(-1)
	end

	local ref3 = React.useRef(nil)
	ref3.current = clicked
	React.useEffect(function()
		if not v11 or not v10 or props.advanceDelay == nil or props.canAutoAdvance ~= true then
			return
		end

		local v12 = false
		local thread = task.delay(props.advanceDelay, function()
			if not v12 then
				props.onAdvance()
			end
		end)
		return function()
			v12 = true
			pcall(task.cancel, thread)
		end
	end, {
		props.textKey,
		props.advanceDelay or false,
		props.canAutoAdvance == true,
		v10,
		v11
	})
	React.useEffect(function()
		if not RunService:IsRunning() then
			return
		end

		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			local current = (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ref3.current

			if current then
				current()
			end
		end)
		return function()
			inputBeganConnection:Disconnect()
		end
	end, {})
	local state2, setState2 = React.useState({
		textKey = props.textKey,
		index = nil
	})
	local index

	if state2.textKey == props.textKey then
		index = state2.index
	else
		index = nil
	end

	local ref4 = React.useRef(nil)

	if v8 then
		ref4.current = nil
	end

	local function choose(current: number, callback)
		if ref4.current then
			return
		end

		ref4.current = current
		setState2({
			textKey = props.textKey,
			index = current
		})
		task.delay(0.2, callback)
	end

	local ref5 = React.useRef(choose)
	ref5.current = choose
	local v12 = React.useMemo(function()
		local result = {}

		for k, option in props.options do
			if not option.onActivated then
				continue
			end

			local v13 = k
			local v14 = option

			result[k] = function()
				ref5.current(v13, v14.onActivated)
			end
		end

		return result
	end, { props.options })
	local v13 = React.useMemo(function()
		local children = {}

		if props.optionsVisible and v11 then
			for k, option in props.options do
				local formatted = `{props.textKey}:option{k}`
				local dismiss

				if index ~= nil then
					dismiss = index == k and "chosen" or "others"
				end

				local onActivated = v12[k]
				local questLockedButton

				if option.locked then
					questLockedButton = responses.QuestLockedButton
				elseif option.optionType then
					questLockedButton = v[option.optionType]

					if not questLockedButton then
						if not v2[option.optionType] then
							warn("[DIALOGUE]", (`unknown option type "{option.optionType}"`))
							v2[option.optionType] = true
						end

						questLockedButton = responses.ChatButton
					end
				elseif option.isCancel then
					questLockedButton = responses.NevermindButton
				else
					questLockedButton = responses.ChatButton
				end

				local createElement = React.createElement
				local v16 = {
					text = option.text,
					words = option.words,
					icon = option.icon,
					effect = option.effect,
					layoutOrder = option.layoutOrder,
					dismiss = dismiss,
					modal = not props.terminating,
					onActivated = 0,
					onHoverStateChanged = 0
				}

				if option.locked then
					onActivated = nil
				end

				v16.onActivated = onActivated
				v16.onHoverStateChanged = option.onHoverStateChanged
				children[formatted] = createElement(questLockedButton, v16)
			end
		end

		return {
			children = children,
			hasAny = next(children) ~= nil
		}
	end, {
		props.optionsVisible,
		v11,
		index or false,
		props.options,
		v12,
		props.terminating,
		props.textKey
	})
	local children = v13.children
	local hasAny = v13.hasAny
	local v14 = React.useMemo(function()
		return {
			dialogueTitle = props.title,
			dialogueSubtitle = props.subtitle,
			optionsVisible = props.optionsVisible,
			interactive = v11
		}
	end, {
		props.title,
		props.subtitle or false,
		props.optionsVisible,
		v11
	})
	local v15 = React.useMemo(function()
		if props.optionsVisible and v11 then
			local specialSlotChildren, hasAny2 = makeSpecialSlotChildren(
				props.specialReactComponents,
				"optionsList",
				v14
			)
			return {
				children = specialSlotChildren,
				hasAny = hasAny2
			}
		else
			return {
				children = {},
				hasAny = false
			}
		end
	end, {
		props.specialReactComponents,
		v14,
		props.optionsVisible,
		v11
	})
	local v16 = React.useMemo(function()
		local specialSlotChildren, hasAny2 = makeSpecialSlotChildren(
			props.specialReactComponents,
			"dialogueWindow",
			v14
		)
		return {
			children = specialSlotChildren,
			hasAny = hasAny2
		}
	end, { props.specialReactComponents, v14 })
	local v17 = React.useMemo(function()
		local specialSlotChildren, hasAny2 = makeSpecialSlotChildren(props.specialReactComponents, "screen", v14)
		return {
			children = specialSlotChildren,
			hasAny = hasAny2
		}
	end, { props.specialReactComponents, v14 })
	local v18 = hasAny or v15.hasAny
	local v19 = React.useMemo(function()
		local result = {}

		for k, v20 in v16.children do
			result[k] = v20
		end

		local optionsList2

		if v18 then
			local createElement = React.createElement
			local optionsList = ReactComponents.OptionsList
			local specialChildren

			if v15.hasAny then
				specialChildren = v15.children
			end

			local v23

			if hasAny then
				v23 = children
			end

			optionsList2 = createElement(optionsList, {
				specialChildren = specialChildren
			}, v23)
		end

		result.optionsList = optionsList2
		return result
	end, {
		v16.children,
		v18,
		v15.hasAny,
		v15.children,
		hasAny,
		children
	})
	local createElement = React.createElement
	local dialogueWindow = ReactComponents.DialogueWindow
	local v20 = {
		words = props.words,
		renderables = props.renderables,
		visibleGraphemes = v10 and -1 or v9,
		name = props.title,
		titleSprite = props.titleSprite,
		subtitle = props.subtitle,
		showNextArrow = props.hasNextText and v10 and v11,
		slide = props.slide,
		entrance = props.entrance,
		modal = not props.terminating,
		onClick = clicked,
		pageButtonSelectable = 0
	}

	if v11 then
		if props.skippable == false then
			v11 = false
		else
			v11 = not hasAny
		end
	end

	v20.pageButtonSelectable = v11
	local element = createElement(dialogueWindow, v20, v19)

	if not v17.hasAny then
		return element
	end

	local v21 = {}

	for k, v22 in v17.children do
		v21[k] = v22
	end

	v21.dialogueWindow = element
	return React.createElement(React.Fragment, nil, v21)
end

function Window.new()
	return (setmetatable({
		_state = nil,
		_wantsToRender = false,
		_slide = "shown",
		_onAdvance = nil,
		_onSelect = nil,
		_lastScreenProps = nil,
		_dismissToken = 0,
		_hasRendered = false,
		_terminating = false
	}, Window))
end

function Window:setTerminating(terminating: boolean)
	if self._terminating == terminating then
		return
	end

	self._terminating = terminating
	self:render()
end

function Window:refreshText()
	if not self._wantsToRender then
		return
	end

	self._lastScreenProps = nil
	self:render()
end

function Window:setSlide(slide: string)
	if self._slide == slide then
		return
	end

	self._slide = slide
	self:render()
end

function Window.canRender(_)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return true
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function specialComponentSnapshots(_specialReactComponents)
	local result = {}

	for k, item in _specialReactComponents do
		local props

		if typeof(item) == "table" then
			props = table.clone(item)
		end

		table.insert(result, {
			name = k,
			props = props
		})
	end

	table.sort(result, function(a, b)
		return a.name < b.name
	end)
	return result
end

local v7 = nil

function Window:render()
	local root = getRoot()
	local _state = self._state
	local v8 = _state and _state:getCurrent()

	if self._wantsToRender and v8 then
		local formatted = `{tostring(v8)}:{v8._textIndex}:{v8._revealKey or v8._refreshKey or 0}`
		local _lastScreenProps = self._lastScreenProps
		local words, options, renderables

		if _lastScreenProps and _lastScreenProps.textKey == formatted then
			words = _lastScreenProps.words
			options = _lastScreenProps.options
			renderables = _lastScreenProps.renderables
		else
			words = Snapshot.wordSnapshots(v8:getCurrentText())
			renderables = Snapshot.renderableSnapshots(v8._renderables)
			options = {}

			for k, _option in v8._options do
				local v9 = {
					text = not _option._text and "?" or table.concat(_option._text, " "),
					words = 0,
					icon = 0,
					optionType = 0,
					effect = 0,
					locked = 0,
					isCancel = false,
					layoutOrder = 0,
					onHoverStateChanged = 0,
					onActivated = 0
				}
				local words2

				if _option._words and #_option._words > 0 then
					words2 = Snapshot.wordSnapshots(_option._words)
				end

				v9.words = words2
				local icon

				if not (_option._iconFromText and (_option._locked or _option._optionType == "Locked")) then
					icon = Snapshot.iconSnapshot(_option._icon)
				end

				v9.icon = icon
				v9.optionType = _option._optionType
				v9.effect = _option._effect
				v9.locked = _option._locked
				v9.layoutOrder = k
				v9.onHoverStateChanged = _option._hoverStateChangedFn
				local v12 = _option

				function v9.onActivated()
					if self._onSelect then
						self._onSelect(v12)
					end
				end

				table.insert(options, v9)
			end

			local cancelOption = v8:getCancelOption()

			if cancelOption then
				local text

				if cancelOption._text then
					text = table.concat(cancelOption._text, " ")
				end

				local words2

				if cancelOption._words and #cancelOption._words > 0 then
					words2 = Snapshot.wordSnapshots(cancelOption._words)
				end

				local v9 = {
					text = text,
					words = words2,
					icon = Snapshot.iconSnapshot(cancelOption._icon),
					optionType = cancelOption._optionType,
					effect = cancelOption._effect,
					locked = false,
					isCancel = true,
					layoutOrder = 9999,
					onHoverStateChanged = cancelOption._hoverStateChangedFn,
					onActivated = function()
						if self._onSelect then
							self._onSelect(cancelOption)
						end
					end
				}
				table.insert(options, v9)

				if v8._cancel.randomizeSwap and #v8._options == 1 and (v8._cancel.swapRoll or 0) > 0.5 then
					options[1].layoutOrder = 10000
					v9.layoutOrder = 1
				end
			end
		end

		local displayName = v8:getTitle()
		local lastScreenProps = {
			key = tostring(self),
			title = 0,
			titleSprite = 0,
			subtitle = 0,
			words = 0,
			renderables = 0,
			textKey = 0,
			optionsVisible = 0,
			options = 0,
			specialReactComponents = 0,
			hasNextText = 0,
			advanceDelay = 0,
			canAutoAdvance = 0,
			skippable = 0,
			skipReveal = 0,
			terminating = 0,
			slide = 0,
			entrance = 0,
			onAdvance = 0
		}

		if displayName == "" then
			displayName = Players.LocalPlayer.DisplayName
		end

		lastScreenProps.title = displayName
		lastScreenProps.titleSprite = _state:getTitleSprite()
		lastScreenProps.subtitle = v8:getSubtitle()
		lastScreenProps.words = words
		lastScreenProps.renderables = renderables
		lastScreenProps.textKey = formatted
		lastScreenProps.optionsVisible = v8:areOptionsVisible()
		lastScreenProps.options = options
		lastScreenProps.specialReactComponents = specialComponentSnapshots(v8._specialReactComponents)
		lastScreenProps.hasNextText = v8._textIndex < #v8._textGroups
		lastScreenProps.advanceDelay = v8._advanceDelay
		lastScreenProps.canAutoAdvance = v8._textIndex < #v8._textGroups or #options == 0
		lastScreenProps.skippable = v8._skippable
		lastScreenProps.skipReveal = v8._skipReveal
		lastScreenProps.terminating = self._terminating
		lastScreenProps.slide = self._slide
		lastScreenProps.entrance = not self._hasRendered

		function lastScreenProps.onAdvance()
			if self._onAdvance then
				self._onAdvance()
			end
		end

		self._hasRendered = true
		self._lastScreenProps = lastScreenProps
		v7 = self
		root:render(React.createElement(Screen, lastScreenProps))
	else
		local _lastScreenProps = self._lastScreenProps
		self._dismissToken += 1

		if not _lastScreenProps then
			root:render(nil)
			return
		end

		self._lastScreenProps = nil
		local clone = table.clone(_lastScreenProps)
		clone.slide = "hidden"
		v7 = self
		root:render(React.createElement(Screen, clone))
		local _dismissToken = self._dismissToken
		task.delay(0.5, function()
			if v7 == self and self._dismissToken == _dismissToken and not self._wantsToRender then
				root:render(nil)
			end
		end)
	end
end

return Window