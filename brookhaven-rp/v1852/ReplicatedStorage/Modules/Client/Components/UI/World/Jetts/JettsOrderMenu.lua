local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local JettsMenuItem = require(ReplicatedStorage.Modules.Client.Components.UI.World.Jetts.JettsMenuItem)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local JettsController = require(ReplicatedStorage.Modules.Client.World.JettsController)
require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local JettsMenuConstants = require(ReplicatedStorage.Modules.Shared.Game.JettsMenuConstants)
local v = Component.new({
	Tag = "JettsOrderMenu"
})
local JETTS_MENU_ITEMS = JettsMenuConstants.JETTS_MENU_ITEMS
local JETTS_MENU_ITEMS_CONES = JettsMenuConstants.JETTS_MENU_ITEMS_CONES
local JETTS_MENU_ITEMS_OTHERS = JettsMenuConstants.JETTS_MENU_ITEMS_OTHERS
local color = Color3.fromRGB(38, 171, 26)
local color2 = Color3.fromRGB(255, 246, 182)

function v:Construct()
	self._Janitor = Janitor.new()
	self.menuItems = {}
end

function v:Reset(source: string)
	for _, menuItem in self.menuItems do
		menuItem:SetCount(0)
	end

	self.source = source
	self:RefreshConfirmationButton()
end

function v:RefreshConfirmationButton()
	local v2 = false

	for _, menuItem in self.menuItems do
		if not (menuItem.currentCount > 0) then
			continue
		end

		v2 = true
		break
	end

	self.confirmationButton.BackgroundColor3 = v2 and color or color2
	self.confirmationButton.BackgroundTransparency = v2 and 0 or 0.3
end

function v:Start()
	self.confirmationButton = self.Instance:WaitForChild("ConfirmationButton"):WaitForChild("ConfirmationButton")
	self._Janitor:Add(self.confirmationButton.Activated:Connect(function()
		self:ConfirmOrder()
	end))
	local menu = self.Instance:WaitForChild("Menu")
	local menuItem = menu:WaitForChild("MenuItem")

	for _, v2 in JETTS_MENU_ITEMS do
		local clone = menuItem:Clone()
		clone.Name = v2.toolName
		clone.Parent = menu
		local component = ComponentUtil.GetComponentFromInstance(clone, JettsMenuItem)
		component:Initialize(v2, self)
		table.insert(self.menuItems, component)
	end

	local menuCones = self.Instance:WaitForChild("MenuCones")

	for _, v2 in JETTS_MENU_ITEMS_CONES do
		local clone = menuItem:Clone()
		clone.Name = v2.toolName
		clone.Parent = menuCones
		local component = ComponentUtil.GetComponentFromInstance(clone, JettsMenuItem)
		component:Initialize(v2, self)
		table.insert(self.menuItems, component)
	end

	local menuOthers = self.Instance:WaitForChild("MenuOthers")

	for _, v2 in JETTS_MENU_ITEMS_OTHERS do
		local clone = menuItem:Clone()
		clone.Name = v2.toolName
		clone.Parent = menuOthers
		local component = ComponentUtil.GetComponentFromInstance(clone, JettsMenuItem)
		component:Initialize(v2, self)
		table.insert(self.menuItems, component)
	end

	menuItem.Visible = false
	self.Visible = true
end

function v:ConfirmOrder()
	local v2 = {}

	for _, menuItem in self.menuItems do
		if menuItem.currentCount > 0 then
			table.insert(v2, {
				toolName = menuItem.data.toolName,
				count = menuItem.currentCount,
				name = menuItem.data.name,
				image = menuItem.data.image
			})
		end
	end

	JettsController:ConfirmOrder(v2, self.source)
	PanelController.Close("Jetts", "JettsOrderMenu")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v