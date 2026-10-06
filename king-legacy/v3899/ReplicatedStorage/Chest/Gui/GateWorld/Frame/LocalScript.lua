local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local modules = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
local WorldsId = require(modules.WorldsId)
local GateWorldList = require(modules.GateWorldList)
local IslandInfo = require(modules.IslandInfo)
local parent = script.Parent
local firstSea = parent:WaitForChild("FirstSea")

if game.PlaceId == WorldsId.KingLegacy.SecondSea or game.PlaceId == WorldsId.Testing.SecondSea then
	firstSea = parent:WaitForChild("SecondSea")
elseif game.PlaceId == WorldsId.KingLegacy.ThirdSea or game.PlaceId == WorldsId.Testing.ThirdSea then
	firstSea = parent:WaitForChild("ThirdSea")
end

firstSea.Visible = true
local uIGridLayout = firstSea:WaitForChild("UIGridLayout")

if _G.IsMobile then
	local extendMobileGUI = _G.ExtendMobileGUI
	parent.Size = UDim2.new(0.4 * extendMobileGUI, 0, 0.5 * extendMobileGUI, 0)
end

function UpdateGrid()
	uIGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	uIGridLayout.CellSize = UDim2.new(
		0,
		(firstSea.AbsoluteSize.X - firstSea.ScrollBarThickness - 20) / 3,
		0,
		(firstSea.AbsoluteSize.Y - 30) / 4
	)
	firstSea.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)

	for _, button in pairs(firstSea:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local islandName = button:FindFirstChild("IslandName")

		if islandName then
			islandName.Text = IslandInfo[button.Name] and IslandInfo[button.Name].Name or button.Name
		end

		local islandInfo = button:FindFirstChild("IslandInfo")

		if islandInfo then
			islandInfo.Text = not IslandInfo[button.Name] and "" or IslandInfo[button.Name].InfoText or ""

			if GateWorldList[firstSea.Name] and GateWorldList[firstSea.Name][button.Name] and GateWorldList[firstSea.Name][button.Name].InfoText then
				islandInfo.Text = GateWorldList[firstSea.Name][button.Name].InfoText
			end

			local text = islandInfo.Text
			local v = string.match(text, "%d+")

			if v then
				button.LayoutOrder = tonumber(v)
			else
				button.LayoutOrder = 100000
			end
		end

		local imageLabel = button:FindFirstChild("ImageLabel")

		if imageLabel then
			imageLabel.Image = GateWorldList[firstSea.Name] and GateWorldList[firstSea.Name][button.Name] and GateWorldList[firstSea.Name][button.Name].Image or ""
		end
	end
end

UpdateGrid()
firstSea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateGrid()
end)
local closeButton = parent.CloseButton
closeButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
end)
closeButton.MouseEnter:Connect(function()
	closeButton.Size = UDim2.new(0.081, 0, 0.124, 0)
	TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.09315, 0, 0.14259999999999998, 0)
	}):Play()
end)
closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.081, 0, 0.124, 0)
	}):Play()
end)