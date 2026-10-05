local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.Util.Maid)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
require(game.ReplicatedStorage.Spritesheets)
local BoxWithHeader = require(game.ReplicatedStorage.DungeonClient.Interface.BoxWithHeader)
local createElement = React.createElement
return function()
	local state, setState = React.useState(false)
	local returnToHub = game.ReplicatedStorage.DungeonShared:FindFirstChild("ReturnToHub")
	local v = useAttribute(returnToHub, "PlayersSkipped") or 0
	return createElement(BoxWithHeader, {
		headerText = "Returning with party..",
		Position = UDim2.fromScale(0.5, 0.2),
		Size = UDim2.fromScale(0.4, 0.1),
		AspectRatio = 8,
		headerMaxY = 40
	}, { React.useMemo(function()
			return createElement(function()
				local v6 = useAttribute(returnToHub, "Timer") or 0
				return createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
					Position = UDim2.fromScale(0.475, 0.5),
					Size = UDim2.fromScale(0.9, 0.7),
					Text = v6 == false and "Returning to hub..." or `Returning to hub: {v6}`,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end, {})
		end), createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(0, 137, 14),
			Position = UDim2.fromScale(0.9, 0.84),
			Size = UDim2.fromScale(0.15, 0.65),
			BackgroundTransparency = state and 1 or 0,
			AutoButtonColor = not state,
			Text = not state and "Skip" or `{v}/{#game.Players:GetPlayers()}`,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			[ReactRoblox.Event.Activated] = function()
				setState(true)
				game.ReplicatedStorage.DungeonShared.ReturnToHub:FireServer()
			end
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0.15, 0),
				PaddingRight = UDim.new(0.15, 0)
			})
		}) })
end