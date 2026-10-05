local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Party = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Party.Party)
local RepeatableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.RepeatableDevProducts)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = nil
local v2 = Component.new({
	Tag = "PartyStart"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:Start()
	self.button = self.Instance:WaitForChild("OuterBox"):WaitForChild("ButtonBox"):WaitForChild("Invite")
	local v3 = v.WaitForPanel("MainGUIHandler", "PartyStart")
	v3:RegisterListener(self, v3.Events.Opening, function(_)
		v.LoadLazy("MainGUIHandler", "PartySelect", false)
		self.openJanitor = Janitor.new()

		if not self.rendered then
			self.rendered = true
			self:Render()
		end
	end)
	v3:RegisterListener(self, v3.Events.Closing, function(_)
		if self.selectedButton then
			self.selectedButton.Frame.Checkmark.Visible = false
		end

		self.selectedButton = nil
		self.partyData = nil
		self.button.TextInfo.Text.TextTransparency = 0.5
		self.button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.button.Interactable = false
		local scrollingFrame = self.Instance:WaitForChild("OuterBox"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
		scrollingFrame.CanvasPosition = Vector2.new(0, 0)

		if self.openJanitor then
			self.openJanitor:Destroy()
			self.openJanitor = nil
		end
	end)
	self._Janitor:Add(self.button.Activated:Connect(function()
		local expect = ComponentUtil.FindAndWaitForComponentByTag(nil, "PartySelect", false):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("PartySelect")):expect()
		expect:SetPreviousPanel("PartyStart")
		expect:SetData(self.partyData.Name, self.partyData.Id, self.partyData.Product)
		v.OpenPanelByContext("MainGUIHandler", "PartySelect")
	end))
end

function v2:Render()
	local scrollingFrame = self.Instance:WaitForChild("OuterBox"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
	local buttonTemplate = scrollingFrame:WaitForChild("ButtonTemplate")
	buttonTemplate.Visible = false
	local separatorTemplate = scrollingFrame:WaitForChild("SeparatorTemplate")
	separatorTemplate.Visible = false
	self.buttonToParty = {}

	for k, v3 in Party.All do
		local clone = buttonTemplate:Clone()
		clone.Visible = true
		clone.LayoutOrder = k * 2
		local imageLabel = clone:WaitForChild("ImageLabel")
		imageLabel.Image = v3.Image
		local title = clone:WaitForChild("Frame"):WaitForChild("Title")
		title.Text = v3.Name
		local description = clone:WaitForChild("Frame"):WaitForChild("Description")
		description.Text = v3.Description

		if v3.Product == nil then
			local cost_2 = clone:WaitForChild("Frame"):WaitForChild("Cost")
			cost_2.Text = "FREE"
		else
			local cost = clone:WaitForChild("Frame"):WaitForChild("Cost")
			cost.Text = ""
			local v4 = v3
			self._Janitor:Add(task.spawn(function()
				local v6, v7 = GetProductInfo(RepeatableDevProducts.GetId(v4.Product), Enum.InfoType.Product, 2)

				if v6 then
					cost.Text = "" .. v7.PriceInRobux
				else
					cost.Text = "?"
				end
			end), true)
		end

		clone.Parent = scrollingFrame
		local partyData = v3
		self._Janitor:Add(clone.Activated:Connect(function()
			if self.selectedButton then
				self.selectedButton.Frame.Checkmark.Visible = false
			end

			clone.Frame.Checkmark.Visible = true
			self.partyData = partyData
			self.selectedButton = clone
			self.button.TextInfo.Text.TextTransparency = 0
			self.button.BackgroundColor3 = Color3.fromRGB(133, 255, 80)
			self.button.Interactable = true
			Platform.Select(self.Instance:WaitForChild("OuterBox"):WaitForChild("ButtonBox"))
		end))
		local clone2 = separatorTemplate:Clone()
		clone2.Visible = true
		clone2.LayoutOrder = k * 2 + 1
		clone2.Parent = scrollingFrame
	end
end

function v2:Stop()
	if self.openJanitor then
		self.openJanitor:Destroy()
		self.openJanitor = nil
	end

	self._Janitor:Destroy()
end

return v2