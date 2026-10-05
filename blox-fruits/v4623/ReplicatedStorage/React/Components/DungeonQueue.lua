local React = require(game.ReplicatedStorage.Packages.React)
local Header = require(game.ReplicatedStorage.React.Components.Inventory.Main.Header)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local color = Color3.new(0.188235, 0.188235, 0.188235)
local color2 = Color3.new(0.1, 0.1, 0.1)
local element = createElement("UIStroke", {
	Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE,
	Color = CONSTANTS.COLOR.PALETTE.BLACK,
	Transparency = CONSTANTS.ALPHA.OPAQUE,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border
})
return function(data)
	warn("render")
	local state, setState = React.useState(data.Party)
	local v = React.useMemo(function()
		return createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM
		})
	end, {})
	local ref = React.useRef(true)
	React.useMemo(function()
		if not state then
			return false
		end

		for _, player in pairs(state.Players) do
			if player.PlayerInstance == game.Players.LocalPlayer then
				return player.IsLeader == true
			end
		end

		return false
	end, { state })
	local v2 = React.useMemo(function()
		return createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Position = UDim2.new(0, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			RichText = true,
			TextWrapped = false,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
		})
	end, {})
	local element2 = createElement("UICorner", {
		CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG
	})
	local v3 = React.useMemo(function()
		warn("Rendering party memo")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getPlayerText(playerInstance)
			if not playerInstance then
				return "<font color=\"rgb(255, 171, 37)\"><s> Unknown Player </s></font>"
			end

			if playerInstance.Parent then
				return playerInstance.Name
			end

			return (`<font color="yellow"><s>{playerInstance.Name}</s></font>`)
		end

		local result = {}

		if not state then
			ref.current = false
			return result
		end

		assert(state)
		ref.current = true

		for _, player in pairs(state.Players) do
			local v6 = {
				Active = false,
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundColor3 = color2,
				BackgroundTransparency = 0.5,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Size = UDim2.new(0.95, 0, 0.15, 0)
			}
			local element3 = React.cloneElement(element)
			local element4 = React.cloneElement(element2)
			local cloneElement = React.cloneElement
			local playerText = getPlayerText(player.PlayerInstance) -- equivalent call inferred; original call site unknown
			local v7 = {
				element3,
				element4,
				v,
				cloneElement(v2, {
					Text = `{playerText}`
				})
			}
			table.insert(result, createElement("Frame", v6, v7))
		end

		return result
	end, { state })
	React.useEffect(function()
		local flag = false
		task.delay(2, function()
			if flag then
				return
			end

			table.insert(state.Players, {
				PlayerInstance = game.Players.LocalPlayer,
				IsReady = false,
				Issue = "ok",
				IsLeader = false
			})
			setState(table.clone(state))
			task.wait(1)

			if flag then
			end
		end)
		return function()
			flag = true
		end
	end, {})
	local v4 = React.useMemo(function()
		return createElement("UIPadding", {
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.MD
		})
	end, {})
	warn("redo")

	local function PartyFrame()
		return (createElement("Frame", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = color,
			BackgroundTransparency = 0.25,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.new(0.8, 0, 0.5, 0),
			Size = UDim2.new(0.38, 0, 0.94, 0),
			Visible = ref.current
		}, {
			createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
			}),
			createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				Color = CONSTANTS.COLOR.PALETTE.BLACK,
				Transparency = CONSTANTS.ALPHA.OPAQUE,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}),
			v4,
			createElement("UIListLayout", {
				Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.new(1, 0, 0.1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
			}, { createElement("UIListLayout", {
					Padding = UDim.new(0, 5),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}), createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.None,
					Size = UDim2.new(0.6, 0, 1, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					RichText = false,
					TextWrapped = false,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					Text = "Dungeon Party"
				}) }),
			unpack(v3)
		}))
	end

	local function WindowHeader()
		return (createElement(Header, {
			OnExit = data.OnExit,
			Title = "Dungeon Finder",
			ZIndex = (data.ZIndex or 0) + 2
		}))
	end

	local function MainFrame()
		return (createElement("Frame", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = color,
			BackgroundTransparency = 0.25,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Size = UDim2.new(1, 0, 0.6, 0)
		}, { React.useMemo(function()
				return createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					Color = CONSTANTS.COLOR.PALETTE.BLACK,
					Transparency = CONSTANTS.ALPHA.OPAQUE,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})
			end, {}), (PartyFrame()) }))
	end

	return (createElement("Frame", {
		[React.Tag] = data[React.Tag],
		Active = false,
		AnchorPoint = data.AnchorPoint,
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		LayoutOrder = data.LayoutOrder,
		Position = data.Position,
		Size = UDim2.new(0.6, 0, 0.4, 0),
		SizeConstraint = data.SizeConstraint,
		ZIndex = data.ZIndex
	}, {
		Layout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		createElement(Header, {
			OnExit = data.OnExit,
			Title = "Dungeon Finder",
			ZIndex = (data.ZIndex or 0) + 2
		}),
		(MainFrame())
	}))
end