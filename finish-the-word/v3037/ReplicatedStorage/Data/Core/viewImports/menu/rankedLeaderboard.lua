local import = _G.import("romodel")
local import2 = _G.import("event")
local UserInputService = game:GetService("UserInputService")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local ux = import3:get("ux")
local import4 = _G.import("iterator")
local popups = script.Parent.Parent.popups
local rankedCloseButton = require(popups.rankedCloseButton)
local closeButton = rankedCloseButton.CloseButton
local rankedBackdrop = require(popups.rankedBackdrop)
local ranked = require(script.Parent.ranked)
local leaderboardList = ranked.LeaderboardList
local v = {
	{
		Name = "OneVOne",
		Text = "2 PLR",
		ModeKey = "1v1"
	},
	{
		Name = "FourPlayer",
		Text = "4 PLR",
		ModeKey = "1v1v1v1"
	},
	{
		Name = "SixPlayer",
		Text = "6 PLR",
		ModeKey = "1v1v1v1v1v1"
	}
}
local model = import.model("ScrollingFrame")

function model.init(data)
	local leaderboardEntries = ranked.GetLeaderboardEntries(data)
	local canvasHeight = math.max(1, #leaderboardEntries * 0.22 + 0.15)
	return {
		AnchorPoint = data.AnchorPoint,
		Position = data.Position or UDim2.new(0, 0, 0, 0),
		Size = data.Size or UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollPosition = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasHeight = canvasHeight,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	}, {
		Inner = import.make(leaderboardList, {
			Entries = leaderboardEntries,
			Position = UDim2.new(0, 0, 0.15 / canvasHeight, 0),
			Size = UDim2.new(1, 0, 1 / canvasHeight, 0),
			RowSlot = 0.22,
			RowPadding = 0.011,
			ShowRankNumber = true
		})
	}
end

function model:prespawn()
	local canvasHeight = self.CanvasHeight
	local RunService = game:GetService("RunService")
	self.Con = RunService.RenderStepped:Connect(function()
		local absoluteSize = self.Instance.AbsoluteSize
		self.CanvasSize = UDim2.new(0, 0, 0, absoluteSize.Y * (canvasHeight or 1))
	end)
end

function model.despawn(p)
	p.Con:Disconnect()
end

local model2 = import.model(basic.EmptyElement)

function model2.init(data)
	return {
		Name = data.Name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = data.Selected and Color3.fromRGB(54, 62, 78) or Color3.fromRGB(20, 20, 24),
		CornerRadius = UDim.new(0.035, 0),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		StrokeTransparency = 0.72,
		Thickness = 0.0025,
		ClipsDescendants = true,
		Visible = data.Visible
	}, {
		Scroll = import.make(model, {
			Entries = data.Entries,
			ModeKey = data.ModeKey,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0)
		}),
		Scrollbar = import.make(import.wrap("ImageButton", basic.Corner), {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 12, 0.15, 0),
			BackgroundColor3 = Color3.fromRGB(5, 5, 5),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			CornerRadius = UDim.new(0.4, 0),
			ZIndex = 24
		})
	}
end

function model2:prespawn()
	local instance = self.Scroll.Instance
	local scale = instance.Position.Y.Scale
	local instance2 = self.Scrollbar.Instance
	local scale2 = instance2.Size.Y.Scale
	local v2 = 0.2 + scale
	local v3 = (1 - scale2) * 0.73
	self.DraggingScrollbar = false
	self.ScrollbarDownCon = instance2.MouseButton1Down:Connect(function()
		self.DraggingScrollbar = true
		self.ScrollbarDragOffset = UserInputService:GetMouseLocation().Y - instance2.AbsolutePosition.Y
	end)
	self.ScrollbarUpCon = instance2.MouseButton1Up:Connect(function()
		self.DraggingScrollbar = false
	end)
	self.InputEndedCon = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.DraggingScrollbar = false
		end
	end)
	local RunService = game:GetService("RunService")
	self.Con = RunService.RenderStepped:Connect(function()
		local v4 = instance.AbsoluteCanvasSize.Y - instance.AbsoluteWindowSize.Y
		local v5

		if self.DraggingScrollbar then
			local v6 = (UserInputService:GetMouseLocation().Y - (self.ScrollbarDragOffset or 0) - self.Instance.AbsolutePosition.Y) / self.Instance.AbsoluteSize.Y
			v5 = v3 > 0 and math.clamp((v6 - v2) / v3, 0, 1) or 0
			instance.CanvasPosition = Vector2.new(instance.CanvasPosition.X, v4 * v5)
		else
			v5 = v4 > 0 and instance.CanvasPosition.Y / v4 or 1
		end

		instance2.Position = UDim2.new(1, 0, v2 + v5 * v3, 0)
	end)
end

function model2.despawn(data)
	data.Con:Disconnect()
	data.ScrollbarDownCon:Disconnect()
	data.ScrollbarUpCon:Disconnect()
	data.InputEndedCon:Disconnect()
end

local function selectPage(ui, modeKey)
	for _, guiObject in pairs(ui.RankedLeaderboardPages._Children) do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == modeKey
		end
	end

	for _, button in pairs(ui.RankedLeaderboardTopBar.Tabs._Children) do
		if button:IsA("GuiButton") then
			button.BackgroundColor3 = button.ModeKey == modeKey and Color3.fromRGB(43.2, 49.6, 62.4) or Color3.fromRGB(
				20,
				20,
				24
			)
		end
	end
end

local model3 = import.model("ImageButton", basic.Corner, ux.Button)

function model3.init(data)
	return {
		Name = data.Name,
		Size = UDim2.new(0.28, 0, 0.72, 0),
		LayoutOrder = data.LayoutOrder,
		AutoButtonColor = false,
		BackgroundColor3 = data.Selected and Color3.fromRGB(43.2, 49.6, 62.4) or Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		CornerRadius = UDim.new(0.15, 0),
		ModeKey = data.ModeKey,
		ZIndex = 25,
		MouseButton1Down = data.MouseButton1Down
	}, {
		Label = import.make(basic.TextLabel, {
			Size = UDim2.new(0.86, 0, 0.72, 0),
			Location = "Center",
			Text = data.Text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			StrokeWidth = 1,
			ZIndex = 26
		})
	}
end

local model4 = import.model(basic.EmptyElement, basic.Global)

function model4.init(p)
	return {
		Name = "RankedLeaderboardPages",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 2
	}, import4.fromArray(v):map(function(p2, p3)
		return p3.Name, import.make(model2, {
			Name = p3.Name,
			Entries = p.LeaderboardEntries,
			ModeKey = p3.ModeKey,
			Visible = p2 == 1
		})
	end):dict()
end

local model5 = import.model(basic.EmptyElement, basic.Global)

function model5.init(_)
	return {
		Name = "RankedLeaderboardTopBar",
		Size = UDim2.new(1, 0, 0.15, 0),
		BackgroundTransparency = 1,
		ZIndex = 25
	}, {
		Tabs = import.make(basic.EmptyList, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.76, 0, 0.75, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.025, 0)
		}, import4.fromArray(v):map(function(layoutOrder, p2)
			return p2.Name, import.make(model3, {
				Name = p2.Name,
				Text = p2.Text,
				ModeKey = p2.Name,
				LayoutOrder = layoutOrder,
				Selected = layoutOrder == 1,
				MouseButton1Down = function(p3)
					selectPage(p3.Ui, p3.ModeKey)
				end
			})
		end):dict()),
		CloseButton = import.make(closeButton, {
			Position = UDim2.new(0.98, 0, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			Scale = 0.09,
			ZIndex = 25,
			OnClose = function()
				import2.fire("openMenu", "Ranked")
			end
		})
	}
end

local model6 = import.model(basic.EmptyElement, basic.Global)

function model6.init(_)
	return {
		Name = "RankedLeaderboardContent",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}
end

local model7 = import.model("ScreenGui", basic.Ui)

function model7.init(options)
	local v2 = options or {}
	local props = rankedBackdrop.props(v2)
	props.Background2.RankedLeaderboardPages = import.make(model4, v2)
	props.Background2.RankedLeaderboardTopBar = import.make(model5, v2)
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = v2.DisplayOrder or 5,
		Name = "RankedLeaderboardOverlay",
		Location = "Center",
		AspectRatio = 1.777,
		Scale = v2.Scale or 1,
		Background = props.Background,
		Background2 = props.Background2,
		Content = v2.Content or {
			Content = import.make(model6, v2)
		}
	}
end

return {
	RankedLeaderboard = model7
}