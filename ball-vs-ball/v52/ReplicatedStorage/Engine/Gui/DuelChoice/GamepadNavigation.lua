local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local GamepadNavigation = {}
GamepadNavigation.__index = GamepadNavigation

-- equivalent calls inferred from this helper; original call sites unknown
local function allowed(instance)
	return instance and instance.Parent and instance.Visible and instance.Active and instance.Interactable
end

function GamepadNavigation.new(options)
	local object = setmetatable({}, GamepadNavigation)
	object.options = options
	object.preferred = options.cards[2]
	object.lastPanel = nil
	object.ownsNavigation = false
	object.connections = {}
	GamepadPages.Observe(options.root, {
		available = options.canNavigate,
		defaultButton = options.cards[2]
	})
	GamepadSupport.WatchRoot(options.root)
	GuiService:AddSelectionParent("DuelChoiceGamepad", options.root)
	local total = 0
	table.insert(object.connections, RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= 0.08 then
			total = 0
			object:Refresh()
		end
	end))
	table.insert(object.connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:Refresh()
	end))
	table.insert(object.connections, GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		local selectedObject = GuiService.SelectedObject

		if selectedObject and selectedObject:IsDescendantOf(options.list) then
			object:ScrollTo(selectedObject)
		end
	end))
	return object
end

function GamepadNavigation:PreferCurrent()
	local selectedObject = GuiService.SelectedObject

	if selectedObject and selectedObject:IsDescendantOf(self.options.main) then
		self.preferred = selectedObject
	end
end

function GamepadNavigation:Prefer(preferred)
	self.preferred = preferred
	self:Refresh()
end

function GamepadNavigation:ScrollTo(p2)
	local list = self.options.list
	local v = p2.AbsolutePosition.Y - list.AbsolutePosition.Y
	local v2 = v + p2.AbsoluteSize.Y

	if not (v < 0) then
		v = not (list.AbsoluteWindowSize.Y < v2) and 0 or v2 - list.AbsoluteWindowSize.Y
	end

	if v ~= 0 then
		local v3 = math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)
		list.CanvasPosition = Vector2.new(list.CanvasPosition.X, (math.clamp(list.CanvasPosition.Y + v, 0, v3)))
	end
end

function GamepadNavigation:Release()
	local selectedObject = GuiService.SelectedObject

	if selectedObject and selectedObject:IsDescendantOf(self.options.root) then
		GuiService.SelectedObject = nil
	end

	if self.ownsNavigation then
		GuiService.GuiNavigationEnabled = self.previousNavigation
		GuiService.AutoSelectGuiEnabled = self.previousAutoSelect
		self.ownsNavigation = false
	end

	self.lastPanel = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function link(p, p2, p3, p4, p5)
	p.NextSelectionLeft = p2 or p
	p.NextSelectionRight = p3 or p
	p.NextSelectionUp = p4 or p
	p.NextSelectionDown = p5 or p
end

function GamepadNavigation:Refresh()
	local options = self.options
	local canNavigate = options.canNavigate()
	options.root:SetAttribute("GamepadPromptsEnabled", canNavigate)

	if not (GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(options.root) and canNavigate) then
		self:Release()
		return
	end

	if GamepadSupport.IsBlocked() or not GamepadPages.CanRestoreFocus(options.root) then
		return
	end

	if not self.ownsNavigation then
		self.previousNavigation = GuiService.GuiNavigationEnabled
		self.previousAutoSelect = GuiService.AutoSelectGuiEnabled
		GuiService.GuiNavigationEnabled = true
		GuiService.AutoSelectGuiEnabled = false
		self.ownsNavigation = true
	end

	local visible = options.panel.Visible
	local panel

	if visible then
		panel = options.panel
	else
		panel = options.main
	end

	local cards = {}
	local v = {}
	local buttons = {}
	local v2 = {}

	for _, card in options.cards do
		card.Selectable = not visible and allowed(card)

		if card.Selectable then
			table.insert(cards, card)
		end
	end

	for _, v3 in { options.pick, options.reroll } do
		v3.Selectable = not visible and allowed(v3)

		if v3.Selectable then
			table.insert(v, v3)
		end
	end

	for _, button in options.list:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		button.Selectable = visible and allowed(button)

		if button.Selectable then
			table.insert(buttons, button)
		end
	end

	table.sort(buttons, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	for _, v3 in { options.back, options.confirm } do
		v3.Selectable = visible and allowed(v3)
	end

	if visible then
		local uIGridLayout = options.list:FindFirstChildOfClass("UIGridLayout")
		local v3 = not uIGridLayout and 1 or math.max(1, uIGridLayout.AbsoluteCellCount.X)

		for k, v4 in buttons do
			local v5 = (k - 1) % v3
			local back = buttons[k + v3]

			if not back then
				if v5 < v3 / 2 or not options.confirm.Selectable then
					back = options.back
				else
					back = options.confirm
				end
			end

			local v6

			if v5 > 0 then
				v6 = buttons[k - 1]
			else
				v6 = v4
			end

			local v7

			if v5 < v3 - 1 then
				v7 = buttons[k + 1] or v4
			else
				v7 = v4
			end

			link(v4, v6, v7, buttons[k - v3], back) -- equivalent call inferred; original call site unknown
			table.insert(v2, v4)
		end

		local v4 = math.floor(math.max(0, #buttons - 1) / v3) * v3 + 1
		local back = options.back
		local back2 = options.back
		local confirm

		if options.confirm.Selectable then
			confirm = options.confirm
		else
			confirm = options.back
		end

		link(back, back2, confirm, buttons[v4], options.back) -- equivalent call inferred; original call site unknown
		link(options.confirm, options.back, options.confirm, buttons[#buttons], options.confirm) -- equivalent call inferred; original call site unknown

		if options.back.Selectable then
			table.insert(v2, options.back)
		end

		if options.confirm.Selectable then
			table.insert(v2, options.confirm)
		end
	else
		for k, nextSelectionUp in cards do
			local v4 = cards[k - 1]
			local v5 = cards[k + 1]
			local v6

			if k == #cards then
				v6 = v[#v]
			else
				v6 = v[1]
			end

			nextSelectionUp.NextSelectionLeft = v4 or nextSelectionUp
			nextSelectionUp.NextSelectionRight = v5 or nextSelectionUp
			nextSelectionUp.NextSelectionUp = nextSelectionUp
			nextSelectionUp.NextSelectionDown = v6 or nextSelectionUp
			table.insert(v2, nextSelectionUp)
		end

		for k, nextSelectionDown in v do
			local v4 = v[k - 1]
			local v5 = v[k + 1]
			local v6 = cards[math.min(k + 1, #cards)]
			nextSelectionDown.NextSelectionLeft = v4 or nextSelectionDown
			nextSelectionDown.NextSelectionRight = v5 or nextSelectionDown
			nextSelectionDown.NextSelectionUp = v6 or nextSelectionDown
			nextSelectionDown.NextSelectionDown = nextSelectionDown
			table.insert(v2, nextSelectionDown)
		end
	end

	if self.lastPanel ~= visible then
		if visible then
			self.preferred = buttons[1] or options.back
		elseif self.lastPanel == true then
			self.preferred = options.pick
		end

		self.lastPanel = visible
	end

	local selectedObject = GuiService.SelectedObject

	if self.preferred then
		local preferred = self.preferred

		if preferred.Parent and preferred.Visible and preferred:IsDescendantOf(panel) then
			if not allowed(preferred) then
				return
			end

			if preferred:IsDescendantOf(options.list) then
				self:ScrollTo(preferred)
			end

			GuiService.SelectedObject = preferred
			self.preferred = nil
			return
		else
			self.preferred = nil
		end
	end

	if not (selectedObject and selectedObject:IsDescendantOf(panel) and selectedObject.Selectable) then
		local selectedObject2

		if visible then
			selectedObject2 = v2[1]
		elseif allowed(options.cards[2]) then
			selectedObject2 = options.cards[2]
		else
			selectedObject2 = v2[1]
		end

		if selectedObject2 then
			if selectedObject2:IsDescendantOf(options.list) then
				self:ScrollTo(selectedObject2)
			end

			GuiService.SelectedObject = selectedObject2
		elseif selectedObject and selectedObject:IsDescendantOf(options.root) then
			GuiService.SelectedObject = nil
		end
	end

	GamepadSupport.Refresh()
end

function GamepadNavigation:Destroy()
	self:Release()

	for _, connection in self.connections do
		connection:Disconnect()
	end

	ContextActionService:UnbindAction("DuelChoiceBack")
	ContextActionService:UnbindAction("DuelChoiceShortcuts")
	GuiService:RemoveSelectionGroup("DuelChoiceGamepad")
end

return GamepadNavigation