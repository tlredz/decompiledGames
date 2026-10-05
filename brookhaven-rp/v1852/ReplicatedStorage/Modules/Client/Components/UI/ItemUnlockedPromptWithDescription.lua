local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "ItemUnlockedPromptWithDescription"
})

function v:SetData(data)
	self.DisplayName = data.title
	self.TopIcon = data.topIcon
	self.Icon = data.icon
	self.Description = data.description
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local contentBox = self.Instance:WaitForChild("OuterBox"):WaitForChild("ContentBox")
	local topImage = self.Instance:WaitForChild("OuterBox"):WaitForChild("TopImage")
	local icon = topImage:WaitForChild("Icon")
	local title = contentBox:WaitForChild("Title")
	local item = contentBox:WaitForChild("ItemPaddingBox"):WaitForChild("Item")
	local icon2 = item:WaitForChild("IconBox"):WaitForChild("Icon")
	local text = item:WaitForChild("TextBox"):WaitForChild("Text")
	local v2 = PanelController.WaitForPanel("MainGUIHandler", "ItemUnlockedPromptWithDescription")

	local function fn(_)
		if self.DisplayName == nil or self.Icon == nil then
			v2:Close()
			return
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()

		if self.TopIcon then
			icon.Image = self.TopIcon
			topImage.Visible = true
		else
			topImage.Visible = false
		end

		title.Text = self.DisplayName
		icon2.Image = self.Icon
		text.Text = self.Description
	end

	v2:RegisterListener(self, v2.Events.Opening, fn)

	if v2:IsOpen() then
		fn()
	end

	v2:RegisterListener(self, v2.Events.Closing, function(_)
		if not v2:IsOpen() then
			return
		end

		self.Icon = nil
		self.DisplayName = nil
		icon2.Image = ""
		title.Text = ""
		text.Text = ""
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v