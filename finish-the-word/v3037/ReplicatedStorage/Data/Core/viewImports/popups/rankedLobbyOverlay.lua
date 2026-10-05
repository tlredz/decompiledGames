local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local menu = import3:get("menu")
local model = import.model(basic.EmptyList)

function model.init()
	return {
		Position = UDim2.new(0.5, 0, 0.9, 0),
		Size = UDim2.new(0.7, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.025, 0)
	}, {
		ReturnButton = import.make(menu.Button, {
			Size = UDim2.new(0.2, 0, 0.7, 0),
			Color = Color3.fromRGB(255, 33, 34),
			BackgroundColor3 = Color3.fromRGB(164, 53, 41),
			Text = "Return",
			LayoutOrder = 1,
			Visible = false,
			MouseButton1Down = function()
				import2.fire("teleport", "Normal")
			end
		})
	}
end

local model2 = import.model("ScreenGui", basic.Ui)

function model2.init(_)
	local lobbyTimeRemaining = workspace:GetAttribute("LobbyTimeRemaining")
	return {
		Name = "RankedLobbyOverlay",
		ResetOnSpawn = false,
		Location = "Center",
		Scale = 0.85,
		Content = {
			CountdownLabel = import.make(basic.TextLabel, {
				Size = UDim2.new(1, 0, 0.075, 0),
				Text = "Waiting for players " .. (lobbyTimeRemaining or 30) .. "s",
				TextColor3 = Color3.fromRGB(255, 80, 80),
				Visible = lobbyTimeRemaining ~= nil,
				StrokeWidth = 2
			}),
			ButtonList = import.make(model)
		}
	}
end

function model2.spawn(p)
	workspace:GetAttributeChangedSignal("LobbyTimeRemaining"):Connect(function()
		local lobbyTimeRemaining = workspace:GetAttribute("LobbyTimeRemaining")
		p.Content.CountdownLabel.Visible = lobbyTimeRemaining ~= nil

		if not lobbyTimeRemaining then
			return
		end

		p.Content.CountdownLabel.Text = "Waiting for players " .. lobbyTimeRemaining .. "s"
	end)
	import2.remoteConnect("autoRequeue", function()
		p.Content.ButtonList.ReturnButton.Visible = true
	end)
end

return {
	RankedLobbyOverlay = model2
}