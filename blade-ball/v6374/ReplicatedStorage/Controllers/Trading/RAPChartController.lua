local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v5 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v6 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.Shared.ItemInfo)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v8 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local playerGui = Players.LocalPlayer.PlayerGui
local boothInventory = playerGui:WaitForChild("BoothInventory")
local pages = boothInventory.MainFrame.Pages
local shop = playerGui:WaitForChild("Shop")
local index = playerGui:WaitForChild("Index")
local controllerShop = playerGui:WaitForChild("ControllerShop")
local v9 = {
	Booth = boothInventory.MainFrame.RapChart,
	Inventory = shop.Holder.RapChart,
	Index = index.Main.Left.MainLabel.RapChart,
	ControllerShop = controllerShop.Main.RapChart
}
local v10 = {
	Booth = v9.Booth.Frame.Chart.PointTemplate,
	Inventory = v9.Inventory.Frame.Chart.PointTemplate,
	Index = v9.Inventory.Frame.Chart.PointTemplate,
	ControllerShop = v9.ControllerShop.Frame.Chart.PointTemplate
}

for _, v11 in pairs(v10) do
	v11.Parent = script
end

local remoteFunction = v2:RemoteFunction("RequestRAPHistory")
local RAPChartController = {
	_breakdown = "Daily"
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Viewport_Size_Reference"
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui
local v11 = {
	Booth = nil,
	Inventory = nil,
	Index = nil,
	ControllerShop = nil
}

local function selectPoint(p: string, instance)
	local hoverInfo = v9[p].Frame.Chart.HoverInfo

	if instance then
		hoverInfo.List.RAP.Label.Text = instance:GetAttribute("RAP") or 0
		local count = instance:GetAttribute("Count") or 0
		hoverInfo.List.Count.Text = `{count} {count == "1" and "Sale" or "Sales"}`
		hoverInfo.List.Date.Text = instance:GetAttribute("Date") or ""
		local absoluteSize = screenGui.AbsoluteSize
		local scale = math.max((absoluteSize.X + absoluteSize.Y) / 3000, 0.5)
		hoverInfo.UIScale.Scale = scale
		hoverInfo.Position = UDim2.new(
			instance.Position.X.Scale,
			instance.Position.X.Offset + 2,
			instance.Position.Y.Scale,
			instance.Position.Y.Offset - scale * 25
		)
	end

	hoverInfo.Visible = instance ~= nil
	v11[p] = instance
end

local function toggleVisibility(p: string, visible: boolean)
	if p == "Booth" then
		for _, guiObject in pages:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
				continue
			end

			local searchFrame = guiObject:FindFirstChild("SearchFrame")

			if searchFrame then
				searchFrame.Visible = not visible
			end

			guiObject.List.Visible = not visible
		end
	elseif p == "Inventory" then
		shop.Holder.Pages.Visible = not visible
	elseif p == "Index" then
		if visible then
			if v7:GetCurrentPage() ~= "RapChart" then
				v7:SetPage("RapChart")
			end
		elseif v7:GetCurrentPage() == "RapChart" then
			v7:Back()
		end
	elseif p == "ControllerShop" then
		require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI.Variants.Console).FrameUIHiddenDynArgs:SetTag(
			"RAPChart",
			visible
		)
		controllerShop.Main.RapChart.Visible = visible
	end

	v9[p].Visible = visible
end

local function getExtrema(items)
	local v12 = 1e999
	local v13 = 0
	local v14 = 1e999
	local v15 = 0

	for _, item in items do
		local date = item.Date
		local RAP = item.RAP
		v12 = math.min(RAP, v12)
		v13 = math.max(RAP, v13)
		v14 = math.min(date.UnixTimestamp, v14)
		v15 = math.max(date.UnixTimestamp, v15)
	end

	return v14, v15, v12, v13
end

function RAPChartController:Open(p: string)
	if v9[p].Visible then
		return
	end

	toggleVisibility(p, true)
end

function RAPChartController:Close(p2: string)
	if not v9[p2].Visible then
		return
	end

	toggleVisibility(p2, false)
	self._renderedItemKey = nil
end

function RAPChartController:Render(p: string, renderedItemType, p2: string)
	if not (renderedItemType and p2) then
		return false
	end

	local v12 = v9[p]
	local frame = v12.Frame
	local chart = frame.Chart
	frame.Loading.Visible = true
	frame.NoData.Visible = false
	self:Open(p)
	local keyToItem = client:KeyToItem(p2)

	if not keyToItem then
		warn((`Invalid ItemKey: {p2}`))
		return false
	end

	local itemToKey = client:ItemToKey(renderedItemType, keyToItem, v4._IGNORE_ATTRIBUTES)
	local itemInfo = v5:GetItemInfo(renderedItemType, keyToItem.Name)

	if not itemInfo then
		warn((`INVALID ITEM COULD NOT BE FOUND: {renderedItemType} called "{keyToItem.Name}"`))
		return false
	end

	frame.Top.ItemName.Text = `"{itemInfo.DisplayName or itemInfo.Name}" RAP History`
	local itemFrame = frame.Top.ItemFrame
	itemFrame.Vector.Image = itemInfo.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
	local v13 = itemInfo.Rarity and v6.SlotColors[itemInfo.Rarity] or v6.SlotColors.Default
	itemFrame.Image = v13.Image
	itemFrame.HoverImage = v13.HoverImage

	if self._renderedItemKey == itemToKey and self._breakdown == self._renderedBreakdown then
		frame.Loading.Visible = false
		return true
	end

	local v14 = 6

	if p == "Index" then
		v14 -= 1
	end

	local now = DateTime.now()
	local dateTime = DateTime.fromUnixTimestamp(now.UnixTimestamp - v14 * 86400)
	local v15, v16 = remoteFunction:InvokeServer(renderedItemType, itemToKey, dateTime, now)

	if not (v15 and v16) then
		warn((`Failed to load RAP History for item: {itemToKey}`))
		return false
	end

	for _, child in chart:GetChildren() do
		if not ((child:IsA("GuiObject") or child:IsA("Path2D")) and child.Name ~= "HoverInfo") then
			continue
		end

		child:Destroy()
	end

	local now2 = DateTime.now()
	local v17 = {}
	local v18 = {}

	for _, v19 in v16 do
		local universalTime = v19.Date:ToUniversalTime()
		local dateTime2 = DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day)
		local dateTime3 = DateTime.fromUniversalTime(
			universalTime.Year,
			universalTime.Month,
			universalTime.Day,
			universalTime.Hour
		)
		local unixTimestamp

		if self._breakdown == "Daily" then
			unixTimestamp = dateTime2.UnixTimestamp
		else
			unixTimestamp = dateTime3.UnixTimestamp
		end

		if not v17[unixTimestamp] then
			v17[unixTimestamp] = {}
		end

		table.insert(v17[unixTimestamp], {
			RAP = v19.RAP,
			Count = v19.Count
		})
	end

	for k, v19 in v17 do
		local total = 0
		local total2 = 0

		for _, v20 in v19 do
			total += v20.RAP
			total2 += v20.Count
		end

		table.insert(v18, {
			Date = DateTime.fromUnixTimestamp(k),
			RAP = total / #v19,
			Count = total2
		})
	end

	table.sort(v18, function(a, b)
		return a.Date.UnixTimestamp > b.Date.UnixTimestamp
	end)
	local _, _, _, v19 = getExtrema(v18)
	local universalTime = now2:ToUniversalTime()
	local unixTimestamp = DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day).UnixTimestamp
	local universalTime2 = dateTime:ToUniversalTime()
	local v20 = DateTime.fromUniversalTime(universalTime2.Year, universalTime2.Month, universalTime2.Day).UnixTimestamp + 86400

	for i = v14, 1, -1 do
		local child = frame.XAxis:FindFirstChild((`Label{v14 - i + 1}`))

		if child then
			child.Text = DateTime.fromUnixTimestamp(unixTimestamp - (i - 1) * 86400):FormatUniversalTime(
				"MMM D",
				LocalizationService.SystemLocaleId
			)
		end
	end

	local v21 = v19 * 0.85
	local v22 = 10 ^ math.round((math.log10(v21 / 7)))

	while v22 * 6 < v21 do
		v22 *= 2
	end

	local v23 = math.ceil(v22)

	for i = 1, 7 do
		local child = frame.YAxis:FindFirstChild((`Label{7 - i + 1}`))

		if not child then
			continue
		end

		local v24 = math.round(v23 * (i - 1))
		local text

		if v24 >= 100000 then
			text = v3.ValueConvertor:ShrinkNumber(v24)
		else
			text = v3.ValueConvertor:AddCommas(v24)
		end

		child.Text = text
	end

	local path2DControlPoints = {}

	for _, v24 in v18 do
		if v24.Date.UnixTimestamp < v20 then
			continue
		end

		local v25 = (v24.Date.UnixTimestamp - v20) / (unixTimestamp - v20)
		local v26 = v25 ~= v25 and 1 or v25
		local v27 = v24.RAP / (v23 * 7)
		local clone = v10[p]:Clone()
		clone.Position = UDim2.fromScale(math.clamp(v26, 0, 1), (math.clamp(1 - v27, 0, 1)))
		clone.Name = v24.Date.UnixTimestamp
		local text = v3.ValueConvertor:AddCommas((math.round(v24.RAP)))
		clone.Circle.Amount.Text = text
		clone.Circle.Amount.Visible = false
		clone:SetAttribute("Date", v24.Date:FormatUniversalTime("l", LocalizationService.SystemLocaleId))
		clone:SetAttribute("Count", v3.ValueConvertor:AddCommas(v24.Count))
		clone:SetAttribute("RAP", text)
		clone.MouseEnter:Connect(function()
			selectPoint(p, clone)
		end)
		clone.MouseLeave:Connect(function()
			local v30 = p
			v9[v30].Frame.Chart.HoverInfo.Visible = false
			v11[v30] = nil
		end)
		clone.Parent = chart
		table.insert(path2DControlPoints, Path2DControlPoint.new(clone.Position))
	end

	frame.NoData.Visible = #v18 < 1

	if #path2DControlPoints > 1 then
		local path2D = Instance.new("Path2D")
		path2D.Color3 = Color3.fromRGB(255, 255, 255)
		path2D.Thickness = 5
		path2D.Visible = true
		path2D.ZIndex = 10
		path2D:SetControlPoints(path2DControlPoints)
		path2D.Parent = chart
	end

	frame.Loading.Visible = false
	self._renderedItemKey = itemToKey
	self._renderedItemType = renderedItemType
	self._renderedBreakdown = self._breakdown
	local timePeriod = v12.Frame:FindFirstChild("TimePeriod", true)

	if timePeriod then
		timePeriod.TextLabel.Text = self._breakdown
	end

	return true
end

function RAPChartController:Start()
	for k, v12 in pairs(v9) do
		local backButton = v12.Frame:FindFirstChild("BackButton", true)

		if backButton then
			local v13 = k
			backButton.Activated:Connect(function()
				self:Close(v13)
			end)
			local timePeriod = v12.Frame:FindFirstChild("TimePeriod", true)

			if timePeriod then
				local hasPermission = v8:HasPermission("RAPHistory.ViewHourly")
				timePeriod.Visible = hasPermission

				if not hasPermission then
					continue
				end

				local v14 = timePeriod
				local v15 = k
				timePeriod.Activated:Connect(function()
					self._breakdown = self._breakdown == "Daily" and "Hourly" or "Daily"
					v14.TextLabel.Text = self._breakdown

					if self._renderedItemKey and self._renderedItemType then
						self:Render(v15, self._renderedItemType, self._renderedItemKey)
					end
				end)
			end

			self:Close(k)
		else
			warn((`Failed to find BackButton for {k} RAPChart`))
		end
	end

	v.WindowFocusReleased:Connect(function()
		for k, _ in v9 do
			v9[k].Frame.Chart.HoverInfo.Visible = false
			v11[k] = nil
		end
	end)
end

return RAPChartController