local import = _G.import("romodel")
local GuiService = game:GetService("GuiService")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local barPanel = import2:get("afkBarPanel").BarPanel
local middleBottomPanel = import2:get("afkMiddleBottomPanel").MiddleBottomPanel
local middleLeftPanel = import2:get("afkMiddleLeftPanel").MiddleLeftPanel
local bottomRightPanel = import2:get("afkBottomRightPanel").BottomRightPanel
local _ = import2:get("afkRewardPanel").RewardPanel
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local model = import.model("ScreenGui", basic.Resizable)

function model.init()
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Name = "Hud"
	}, {
		TitleLabel = import.make(import.wrap(basic.TextLabel), {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.04, GuiService:GetGuiInset().Y),
			Size = UDim2.new(0.35, 0, 0.1, 0),
			Text = "AFK WORLD",
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Color3.new(1, 1, 0.25098),
			StrokeWidth = 3,
			ZIndex = 21
		}, {
			Subtitle = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0.4, 0),
				Text = "AFK for rewards!",
				TextXAlignment = Enum.TextXAlignment.Center,
				StrokeWidth = 2,
				ZIndex = 5
			})
		}),
		Background = import.make("ImageLabel", {
			ZIndex = -1,
			Location = "Center",
			Image = "rbxassetid://75856173505971"
		}),
		BarPanel = import.make(barPanel),
		MiddleBottomPanel = import.make(middleBottomPanel),
		MiddleLeftPanel = import.make(middleLeftPanel),
		BottomRightPanel = import.make(bottomRightPanel)
	}
end

function model.resize(p)
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local v = viewportSize.X / viewportSize.Y
	p.Background.Size = v > 1.777 and UDim2.new(0, viewportSize.X, 0, viewportSize.X / 1.777) or UDim2.new(
		0,
		viewportSize.Y * 1.777,
		0,
		viewportSize.Y
	)
end

return {
	Hud = model
}