local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local v2 = Component.new({
	Tag = "ItemUnlockedPrompt"
})

function v2:SetData(data)
	self.DisplayName = data.title
	self.TopIcon = data.topIcon
	self.Icon = data.icon
end

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:Start()
	local contentBox = self.Instance:WaitForChild("OuterBox"):WaitForChild("ContentBox")
	local topImage = self.Instance:WaitForChild("OuterBox"):WaitForChild("TopImage")
	local text = contentBox:WaitForChild("Text")
	local imageLabel = contentBox:WaitForChild("ItemPaddingBox"):WaitForChild("Item"):WaitForChild("ImageLabel")
	local v3 = v.WaitForPanel("MainGUIHandler", "ItemUnlockedPrompt")

	local function fn(_)
		if self.DisplayName == nil or self.Icon == nil then
			v3:Close()
			return
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()

		if self.TopIcon then
			topImage.Image = self.TopIcon
			topImage.Visible = true
		else
			topImage.Visible = false
		end

		text.Text = self.DisplayName
		imageLabel.Image = self.Icon
	end

	v3:RegisterListener(self, v3.Events.Opening, fn)

	if v3:IsOpen() then
		fn()
	end

	v3:RegisterListener(self, v3.Events.Closing, function(_)
		if not v3:IsOpen() then
			return
		end

		self.Icon = nil
		self.DisplayName = nil
		imageLabel.Image = ""
		text.Text = ""
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2