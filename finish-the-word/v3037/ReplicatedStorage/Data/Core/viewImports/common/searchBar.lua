local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model(basic.ImageLabel)

function model.init(data)
	return {
		ZIndex = data.ZIndex or 1
	}, {
		SearchInput = import.make("TextBox", {
			Position = data.InputPosition,
			Size = data.InputSize,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.65,
			PlaceholderText = data.PlaceholderText,
			PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			ZIndex = not data.ZIndex and 2 or data.ZIndex + 1 or 2,
			_Events = {
				Changed = function(p, p2)
					if p2 ~= "Text" then
						return
					end

					if data.OnKeyPress then
						data.OnKeyPress(p)
					end
				end,
				FocusLost = function(p, p2)
					if p2 and data.OnEnterPressed then
						data.OnEnterPressed(p)
					end
				end
			}
		})
	}
end

return {
	SearchBar = model
}