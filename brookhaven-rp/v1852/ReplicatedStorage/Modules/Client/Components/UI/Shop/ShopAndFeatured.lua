local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ShopAndFeatured"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.SelectLayout = Signal.new()
	self.Closed = Signal.new()
end

local v2 = {
	AllGamepasses = "GamepassButton"
}
local v3 = {
	AllGamepasses = "AllGamepasses"
}

function v:Select(p)
	for _, child in self.Instance:WaitForChild("OuterBox"):WaitForChild("Layouts"):GetChildren() do
		if p == child.Name then
			self.currentLayout = child
			self.SelectLayout:Fire(child)
			child.Visible = true
		else
			child.Visible = false
		end
	end
end

function v:Start()
	local layouts = self.Instance:WaitForChild("OuterBox"):WaitForChild("Layouts")
	self.allName = "AllGamepasses"

	for childName, _ in v2 do
		local child = layouts:WaitForChild(childName)

		if childName == self.allName then
			child:AddTag(v3[self.allName])
		end
	end

	local waitForChild = layouts:WaitForChild(self.allName)
	waitForChild.Visible = true
	local v4 = PanelController.WaitForPanel("MainGUIHandler", "ShopAndFeatured")
	v4:RegisterListener(self, v4.Events.Opening, function(_)
		ComponentUtil.FindAndWaitForComponentByTag(
			Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient"),
			"GiftSelectRecipient",
			false
		):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient")):expect():SetPreviousPanel("ShopAndFeatured")

		if self.currentLayout == nil then
			self:Select(self.allName)
		else
			self.SelectLayout:Fire(self.currentLayout)
		end
	end)
	v4:RegisterListener(self, v4.Events.Closing, function(_)
		self.Closed:Fire(self.currentLayout)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v