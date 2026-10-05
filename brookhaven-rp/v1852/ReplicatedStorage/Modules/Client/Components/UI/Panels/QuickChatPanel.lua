local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local QuickChatController = require(ReplicatedStorage.Modules.Client.Player.QuickChatController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local QuickChatConfig = require(ReplicatedStorage.Modules.Shared.DB.QuickChat.QuickChatConfig)
local v = Component.new({
	Tag = "QuickChatPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self.OnFilterChanged = Signal.new()
	self._categoryLayoutOrderMap = {}
	self._Janitor:Add(self.OnFilterChanged)
end

function v:Build()
	local messages = QuickChatConfig.GetMessages()
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for k, message in messages do
		local v5 = (v2[message.Category] or 0) + 1
		v2[message.Category] = v5
		v3[message] = (self._categoryLayoutOrderMap[message.Category] or 1e999) * 1000 + v5
		v4[message] = k
	end

	table.sort(messages, function(a, b)
		local v5 = v3[a]
		local v6 = v3[b]

		if v5 == v6 then
			return v4[a] < v4[b]
		end

		return v5 < v6
	end)
	self._entries = messages

	for k, message in messages do
		local clone = self._templateButton:Clone()
		clone.Name = "QuickChat_" .. tostring(k)
		clone.LayoutOrder = k
		clone.Visible = true
		clone:SetAttribute("Category", message.Category)
		local text = message.Text
		local translated = QuickChatController.Translate(game, text)
		local textLabel = clone:FindFirstChild("TextLabel")
		textLabel.Text = translated

		if message.Category == "Emojis" then
			textLabel.Position = UDim2.fromScale(0, 0.085) + textLabel.Position
		end

		local v5 = message
		self._clickJanitor:Add(clone.Activated:Connect(function()
			self.tweenTime = 10
			local currentFilter = self.Instance:GetAttribute("CurrentFilter")

			if typeof(currentFilter) ~= "string" then
				currentFilter = nil
			end

			if not QuickChatController.Message(v5.Text, currentFilter) then
				self.tweenTime = 0
			end
		end))
		clone.Parent = self.scrollingFrame
	end

	local currentFilter = self.Instance:GetAttribute("CurrentFilter")

	if typeof(currentFilter) ~= "string" then
		currentFilter = nil
	end

	self:FilterGroup(currentFilter)
	self.OnFilterChanged:Fire()
end

function v:ClearList()
	for _, button in self.scrollingFrame:GetChildren() do
		if button:IsA("GuiButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	self._clickJanitor:Cleanup()
	self._entries = nil
end

function v:Start()
	self.scrollingFrame = self.Instance:WaitForChild("InsideBox"):WaitForChild("Frame"):WaitForChild("ScrollBoxFrame"):WaitForChild("ScrollingFrame")
	self._templateButton = self.scrollingFrame:WaitForChild("Template")
	self:SetupFilterButtons()
	local v2 = PanelController.WaitForPanel("MainGUIHandler", "QuickChatPanel")
	v2:RegisterListener(self, v2.Events.Opening, function()
		self:Build()
	end)

	if v2:IsOpen() then
		self:Build()
	end

	v2:RegisterListener(self, v2.Events.Closing, function()
		self:ClearList()
	end)
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt: number)
		if self.tweenTime == nil then
			return
		end

		for _, button in self.scrollingFrame:GetChildren() do
			if not (button:IsA("GuiButton") and button.Name ~= "Template") then
				continue
			end

			local fillBar = button:WaitForChild("FillBar")
			local v3 = math.max(0, self.tweenTime)

			if v3 == 0 then
				button.Interactable = true
				fillBar.Visible = false
			else
				local value = TweenService:GetValue(v3 / 10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				fillBar.Visible = true
				local size = fillBar.Size
				fillBar.Size = UDim2.new(value, size.X.Offset, size.Y.Scale, size.Y.Offset)
				button.Interactable = false
			end
		end

		if self.tweenTime <= 0 then
			self.tweenTime = nil
			return
		end

		self.tweenTime -= dt
	end))
end

function v:SetupFilterButtons()
	local insideBox = self.Instance:FindFirstChild("InsideBox")

	if insideBox == nil then
		return
	end

	local filters = insideBox:FindFirstChild("Filters")

	if filters == nil then
		return
	end

	self._categoryLayoutOrderMap = {}

	for _, button in filters:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		self._categoryLayoutOrderMap[button.Name] = button.LayoutOrder
		local checkmark = button:FindFirstChild("Checkmark")

		if checkmark and checkmark:IsA("GuiObject") then
			checkmark.Visible = false
		end
	end

	self.OnFilterChanged:Fire()
end

function v.FilterGamepasses(_)
	error("QuickChatPanel:FilterGamepasses is not implemented")
end

function v:GetFilters()
	local result = {}

	for _, v2 in self._entries or QuickChatConfig.GetMessages() do
		result[v2.Category] = true
	end

	return result
end

function v:FilterGroup(p2: string?)
	self.scrollingFrame.CanvasPosition = Vector2.new(0, 0)

	for _, button in self.scrollingFrame:GetChildren() do
		if not (button:IsA("GuiButton") and button.Name ~= "Template") then
			continue
		end

		if p2 == nil then
			button.Visible = true
		else
			button.Visible = button:GetAttribute("Category") == p2
		end
	end
end

function v:Stop()
	self._clickJanitor:Destroy()
	self._Janitor:Destroy()
end

return v