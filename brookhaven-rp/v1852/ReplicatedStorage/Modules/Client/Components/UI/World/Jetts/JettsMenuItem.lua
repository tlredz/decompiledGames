local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local JettsConfig = require(ReplicatedStorage.Modules.Shared.DB.World.JettsConfig)
local v = Component.new({
	Tag = "JettsMenuItem"
})

function v:GetReferences()
	if self.referencesInitialized then
		return
	end

	self.itemName = self.Instance:WaitForChild("ItemName")
	self.itemIcon = self.Instance:WaitForChild("ItemIcon")
	self.countContainer = self.Instance:WaitForChild("Count")
	self.countLabel = self.countContainer:WaitForChild("CountText")
	self.button = self.Instance
	self.cancel = self.Instance:WaitForChild("Cancel")
	self.referencesInitialized = true
end

function v:Initialize(data, jettsOrderMenu)
	self:GetReferences()
	self.jettsOrderMenu = jettsOrderMenu
	self.data = data

	if data.count then
		self:SetCount(data.count)
	else
		self:SetCount(0)
	end

	self.itemName.Text = data.name
	self.itemIcon.Image = data.image
end

function v:SetCount(MAX_ITEM_COUNT_ON_ORDER: number)
	local config = JettsConfig.GetConfig()

	if config.MAX_ITEM_COUNT_ON_ORDER < MAX_ITEM_COUNT_ON_ORDER then
		MAX_ITEM_COUNT_ON_ORDER = config.MAX_ITEM_COUNT_ON_ORDER
	end

	local currentCount = MAX_ITEM_COUNT_ON_ORDER < 0 and 0 or MAX_ITEM_COUNT_ON_ORDER
	self.currentCount = currentCount
	self.countLabel.Text = `{currentCount}x`
	self.countContainer.Visible = currentCount > 0
	self.cancel.Visible = currentCount > 0
end

function v:OnButtonActivated()
	if self.debounce then
		return
	end

	self.debounce = true
	task.delay(0.1, function()
		self.debounce = false
	end)
	self:SetCount(self.currentCount + 1)
	self.jettsOrderMenu:RefreshConfirmationButton()
end

function v:OnCancelActivated()
	if self.debounce then
		return
	end

	self.debounce = true
	task.delay(0.1, function()
		self.debounce = false
	end)
	self:SetCount(self.currentCount - 1)
	self.jettsOrderMenu:RefreshConfirmationButton()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.referencesInitialized = false
	self.currentCount = 0
end

function v:Start()
	self:GetReferences()
	self._Janitor:Add(self.button.Activated:Connect(function()
		self:OnButtonActivated()
	end))
	self._Janitor:Add(self.cancel.Activated:Connect(function()
		self:OnCancelActivated()
	end))
	self.debounce = false
end

function v:Stop()
	self._Janitor:Destroy()
end

return v