local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "EmotesList"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local v2 = false
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local FilterableItem = require(ReplicatedStorage.Modules.Shared.Item.FilterableItem)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	local EmotesConfig = require(ReplicatedStorage.Modules.Shared.DB.Emotes.EmotesConfig)
	v2 = EmotesConfig
end

function v:Build(items)
	for k, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = item.Name
		clone.Label.Text = item.Name
		clone.Repeat.Value = item.Repeat
		clone.Speed.Value = item.Speed
		clone.LayoutOrder = k
		clone:SetAttribute("Filter", item.Filter)
		clone:SetAttribute("Item", item.Item)
		clone.HasVFXStroke.Enabled = item.HasVFX

		if item.BorderColor ~= nil then
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Name = "BorderStroke"
			uIStroke.Parent = clone
			uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
			uIStroke.LineJoinMode = Enum.LineJoinMode.Round
			uIStroke.Thickness = 3
			uIStroke.Transparency = 0.25
			uIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
			uIStroke.Color = Color3.fromRGB(item.BorderColor[1], item.BorderColor[2], item.BorderColor[3])
		end

		if item.Item then
			local item2 = ItemRegistry.GetItem(item.Item, Item)

			if item2 == nil then
				error((`rendering item: {item.Item}: not found`))
			elseif not ItemRenderer.Render(ItemRenderer.EMOTES_CONTEXT, clone, item2) then
				clone.Visible = false
			end
		end

		if item.IsVip then
			local vipIcon = clone:FindFirstChild("VipIcon")
			vipIcon.Visible = true
		elseif item.Icon then
			local vipIcon_2 = clone:FindFirstChild("VipIcon")
			vipIcon_2.Image = item.Icon
			local vipIcon_3 = clone:FindFirstChild("VipIcon")
			vipIcon_3.Visible = true
		elseif not clone:FindFirstChild("VipIcon").Visible then
			Debris:AddItem(clone:FindFirstChild("VipIcon"), 0.1)
		end

		if self.BreadcrumbsFilter ~= nil and not self.BreadcrumbsFilter(clone) then
			clone.Visible = false
		end

		if self.Filter ~= nil and not self.Filter(clone) then
			clone.Visible = false
		end

		local v4 = item
		self._clickJanitor:Add(clone.Activated:Connect(function()
			TelemetryController.SendClientInteraction("filterClick", {
				filter = self.Instance:GetAttribute("CurrentFilter"),
				itemType = self.Instance:GetAttribute("ItemType"),
				name = clone.Name
			})
			EmotesController.PlayEmote(v4, true)
		end))
		clone.Parent = self.Instance
	end

	self.Instance.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.Instance.AutomaticCanvasSize = Enum.AutomaticSize.Y
end

function v:ClearList()
	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self._clickJanitor:Cleanup()
	self.Instance.AutomaticCanvasSize = Enum.AutomaticSize.None
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.GetConfig()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	waitForAncestorComponent:RegisterListener(self, waitForAncestorComponent.Events.Opening, function(_)
		self:Build(config)
	end)
	waitForAncestorComponent:RegisterListener(self, waitForAncestorComponent.Events.Closing, function(_)
		self:ClearList()
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

function v:RefreshFilter()
	for _, button in self.Instance:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		if self.BreadcrumbsFilter == nil or self.BreadcrumbsFilter(button) then
			if self.Filter == nil or self.Filter(button) then
				button.Visible = true
			else
				button.Visible = false
			end
		else
			button.Visible = false
		end
	end
end

function v:SetFilter(breadcrumbsFilter)
	self.BreadcrumbsFilter = breadcrumbsFilter
	self:RefreshFilter()
end

function v:FilterGamepasses()
	self.Instance.CanvasPosition = Vector2.new(0, 0)

	function self.Filter(instance)
		local item = instance:GetAttribute("Item")

		if item then
			local item2 = ItemRegistry.GetItem(item, FilterableItem)

			if item2 ~= nil then
				return item2:IsPaid()
			end
		end

		return instance:FindFirstChild("VipIcon") and instance.VipIcon.Visible and instance.VipIcon.Image == "rbxassetid://18248037214"
	end

	self:RefreshFilter()
end

function v:FilterGroup(p)
	self.Instance.CanvasPosition = Vector2.new(0, 0)

	if p == nil then
		self.Filter = nil
	else
		function self.Filter(instance)
			local filter = instance:GetAttribute("Filter")
			local item = instance:GetAttribute("Item")

			if filter == nil and item then
				local item2 = ItemRegistry.GetItem(item, FilterableItem)

				if item2 ~= nil then
					filter = item2:GetFilter()
				end
			end

			if filter == nil then
				return false
			end

			if typeof(filter) == "string" then
				return filter == p
			end

			return table.find(filter, p) ~= nil
		end
	end

	self:RefreshFilter()
end

return v