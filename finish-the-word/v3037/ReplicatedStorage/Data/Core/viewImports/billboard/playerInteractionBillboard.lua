local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("iterUtil")
local import4 = _G.import("dictUtil")
local basic = _G.import("viewImports"):get("basic")
local BUTTONS = {
	{
		Label = "View Profile",
		Callback = function(character)
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

			if not playerFromCharacter then
				return
			end

			local userId = playerFromCharacter.UserId
			import2.fire("openMenu", "Profile", {
				TargetUserId = userId
			})
		end
	},
	{
		Label = "Steal",
		Key = "E",
		Callback = function(character)
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

			if not playerFromCharacter then
				return
			end

			local userId = playerFromCharacter.UserId
			import2.remoteFire("steal", userId)
		end
	}
}
local model = import.model(basic.ImageButton, basic.Corner)

function model.init(player)
	return {
		Size = UDim2.new(1, 0, 0.3, 0),
		BackgroundTransparency = 0.3,
		BackgroundColor3 = Color3.fromRGB(),
		CornerRadius = UDim.new(0.3, 0),
		NoAspectRatio = true,
		_Events = {
			MouseButton1Down = function()
				player.Callback(player.Character)
			end
		}
	}, {
		KeyBadge = import.make(import.wrap(basic.ConstrainedElement, basic.Corner), {
			Position = UDim2.new(0.025, 0, 0.5, 0),
			Size = UDim2.new(0.2, 0, 0.8, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			CornerRadius = UDim.new(0.25, 0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		}, {
			KeyLabel = player.Key and import.make(basic.TextLabel, {
				Location = "Center",
				Size = UDim2.new(0.7, 0, 0.7, 0),
				StrokeWidth = 4,
				Text = "E"
			}) or import.make(basic.ImageLabel, {
				Location = "Center",
				Size = UDim2.new(0.7, 0, 0.7, 0),
				Image = "rbxassetid://1013090763"
			})
		}),
		TitleLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.25, 0, 0.5, 0),
			Size = UDim2.new(0.7, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeWidth = 4,
			Text = player.Label,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init(player)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.025, 0)
	}, import3.toDict(BUTTONS, function(layoutOrder, p2)
		return layoutOrder, import.make(model, import4.merge(p2, {
			LayoutOrder = layoutOrder,
			Character = player.Character
		}))
	end)
end

local model3 = import.model("BillboardGui")

function model3.init(player)
	return {
		Name = "PlayerInteractionBillboard",
		Size = UDim2.new(5, 0, 4, 0),
		AlwaysOnTop = true,
		MaxDistance = 40,
		Active = true
	}, {
		List = import.make(model2, {
			Character = player.Character
		})
	}
end

return {
	PlayerInteractionBillboard = model3,
	BUTTONS = BUTTONS
}