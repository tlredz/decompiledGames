local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local parent = script.Parent.Parent
local parent2 = parent.Parent
local State = require(parent.State)
local shared = parent2.Shared
local React = require(shared.React)
local Backend = require(shared.Backend)
require(shared.Bundles)
local Ownership = require(shared.Ownership)
local GamePasses = require(shared.GamePasses)
local ModelSquash = require(shared.ModelSquash)
local Marketplace = require(shared.Marketplace)
local components = parent.Components
local DraggableList = require(components.DraggableList)
local hooks = parent.Hooks
local useSignal = require(hooks.useSignal)
local useAttribute = require(hooks.useAttribute)
local useOwnership = require(hooks.useOwnership)
local useGamePasses = require(hooks.useGamePasses)
local useBoomboxData = require(hooks.useBoomboxData)
local useBulkOwnership = require(hooks.useBulkOwnership)

local function GamePassInfo(props)
	local v = props.Lookup[props.Id]

	if not v then
		return nil
	end

	local name = v.Name
	local sourceIds = v.SourceIds
	local color = Color3.new(1, 1, 1)

	if sourceIds.Asset == 0 or sourceIds.Asset == nil then
		name = "⚠️" .. name
		color = Color3.new(1, 0.7, 0)
	end

	if props.Active == props.Id then
		color = Color3.new(1, 1, 0)
	end

	return React.createElement("TextLabel", {
		BackgroundTransparency = 1,
		TextColor3 = color,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(3, 0.8),
		TextScaled = true,
		Text = name
	})
end

local function PlayerInfo(props)
	local v = props.Lookup[props.Id]
	local color = Color3.new(1, 1, 1)

	if props.Active == props.Id then
		color = Color3.new(1, 1, 0)
	end

	return React.createElement("TextLabel", {
		BackgroundTransparency = 1,
		TextColor3 = color,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(3, 0.8),
		TextScaled = true,
		Text = v.Name
	})
end

local function GamePassMigrator(p)
	local gamePass = p.GamePass or {}
	local ref = React.useRef()
	local state, setState = React.useState(gamePass.SourceIds.Asset or 0)
	local state2, setState2 = React.useState(gamePass.RawMetadata or "{}")
	local state3, setState3 = React.useState(true)
	local v = React.useMemo(function()
		return HttpService:JSONDecode(gamePass.RawMetadata or "{}")
	end, { gamePass })
	local configuration, v2 = React.useMemo(function()
		local deserialized = nil
		local v3 = nil

		if type(v) == "table" then
			local model = v.Model

			if model then
				deserialized = ModelSquash.Deserialize(model)
				v.Model = nil
			end

			v3 = v
		elseif type(v) == "buffer" then
			deserialized = ModelSquash.Deserialize(v)
			v3 = {}
		end

		return deserialized or Instance.new("Configuration"), v3 or {}
	end, { gamePass })
	React.useEffect(function()
		if configuration:IsA("Configuration") and #configuration:GetChildren() == 0 then
			local gamePass2 = p.GamePass.SourceIds.GamePass
			local attributes = configuration:GetAttributes()
			attributes.ProductId = state
			attributes.ProductType = "Asset"

			for k, v3 in pairs(v2) do
				attributes[k] = v3
			end

			if gamePass2 then
				if gamePass2 > 0 and gamePass2 ~= state then
					attributes.LegacyIds = `{gamePass2}:GamePass`
				else
					attributes.ProductId = nil
				end
			end

			setState2(HttpService:JSONEncode(attributes))
		else
			local clone = configuration:Clone()
			local gamePass2 = p.GamePass.SourceIds.GamePass

			if state3 then
				clone:SetAttribute("ProductId", state)
				clone:SetAttribute("ProductType", "Asset")

				if gamePass2 and gamePass2 > 0 and gamePass2 ~= state then
					clone:SetAttribute("LegacyIds", (`{gamePass2}:GamePass`))
				end

				setState2(HttpService:JSONEncode(ModelSquash.Serialize(clone)))
			elseif next(v2) then
				v2.ProductId = state
				v2.ProductType = "Asset"
				clone:SetAttribute("LegacyIds", nil)
				clone:SetAttribute("ProductId", nil)
				clone:SetAttribute("ProductType", nil)

				if gamePass2 then
					if gamePass2 > 0 and gamePass2 ~= state then
						v2.LegacyIds = `{gamePass2}:GamePass`
					else
						v2.ProductId = nil
					end
				end

				v2.Model = ModelSquash.Serialize(clone)
				setState2(HttpService:JSONEncode(v2))
			else
				local v3 = {
					ProductId = state,
					ProductType = "Asset"
				}

				if gamePass2 then
					if gamePass2 > 0 and gamePass2 ~= state then
						v3.LegacyIds = `{gamePass2}:GamePass`
					else
						v3.ProductId = nil
					end
				end

				v3.Model = ModelSquash.Serialize(clone)
				setState2(HttpService:JSONEncode(v3))
			end
		end
	end, { configuration, state, state3 })
	React.useEffect(function()
		local jSONDecode = HttpService:JSONDecode(state2)
		xpcall(function()
			if type(jSONDecode) == "table" and jSONDecode.Model then
				ModelSquash.Deserialize(jSONDecode.Model)
			elseif type(jSONDecode) == "buffer" then
				ModelSquash.Deserialize(jSONDecode)
			end
		end, function(p2)
			warn("Failed to deserialize current model:", p2)
		end)
	end, { state2 })
	return React.createElement(React.Fragment, {}, {
		List = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true
		}),
		Padding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}),
		Frame = React.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 1)
		}, {
			Flex = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill
			}),
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			IdInput = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Size = UDim2.new(1, 0, 0, 20),
				Text = "New UGC AssetId:",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1
			}),
			ProductId = React.createElement("TextBox", {
				BackgroundColor3 = Color3.fromRGB(63, 63, 63),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				PlaceholderColor3 = Color3.fromRGB(173, 173, 173),
				PlaceholderText = "000000000000",
				Size = UDim2.new(1, 0, 0, 20),
				Text = tostring(state),
				TextColor3 = Color3.new(1, 1, 1),
				LayoutOrder = 2,
				TextSize = 14,
				[React.Change.Text] = function(p2)
					local text = tonumber(p2.Text)

					if text and text > 0 then
						setState(text)
					end
				end,
				[React.Event.FocusLost] = function(p2)
					local text = tonumber(p2.Text)

					if text and text > 0 then
						setState(text)
					else
						p2.Text = tostring(state)
					end
				end
			}, {
				UICorner = React.createElement("UICorner")
			}),
			GeneratedMetadataLabel = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Size = UDim2.new(1, 0, 0, 20),
				Text = "Generated Metadata:",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			LegacySwitch = React.createElement("TextButton", {
				LayoutOrder = 3,
				Font = Enum.Font.RobotoMono,
				Size = UDim2.new(1, 0, 0, 20),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Text = (state3 and "[X]" or "[ ]") .. [[
 Use Backwards Compatible Metadata Format
    (for games that had aura/skin gamepasses already)]],
				[React.Event.Activated] = function()
					setState3(not state3)
				end
			}),
			GeneratedMetadata = React.createElement("TextBox", {
				BackgroundColor3 = Color3.new(),
				BorderColor3 = Color3.new(),
				ClearTextOnFocus = false,
				LayoutOrder = 4,
				FontFace = Font.new("rbxassetid://12187362578", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				MultiLine = true,
				PlaceholderColor3 = Color3.fromRGB(127, 127, 127),
				Size = UDim2.fromScale(1, 0.4),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = state2,
				TextColor3 = Color3.fromRGB(255, 255, 0),
				TextSize = 8,
				TextTruncate = Enum.TextTruncate.SplitWord,
				TextWrapped = true,
				ref = ref
			}),
			SelectAll = React.createElement("TextButton", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderColor3 = Color3.new(),
				BorderSizePixel = 0,
				FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Size = UDim2.fromScale(1, 0.1),
				Style = Enum.ButtonStyle.RobloxRoundDefaultButton,
				Text = "Click to Select All",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 14,
				LayoutOrder = 5,
				[React.Event.Activated] = function()
					local current = ref.current

					if current then
						current:CaptureFocus()
						current.SelectionStart = 0
						current.CursorPosition = #current.Text + 1
					end
				end
			}),
			CopyHint = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Size = UDim2.fromScale(1, 0.1),
				Text = "CTRL+C to copy",
				TextColor3 = Color3.fromRGB(127, 127, 127),
				TextSize = 14,
				LayoutOrder = 6
			})
		})
	})
end

local function MigrationTab()
	local v = useGamePasses({
		IncludeExpired = true,
		IncludeInactive = true
	})
	local lookup, items = React.useMemo(function()
		local result = {}
		local result2 = {}

		for k, v4 in v do
			local formatted = `{v4.Name} [{k}]`
			table.insert(result, formatted)
			result2[formatted] = v4
		end

		table.sort(result)
		return result2, result
	end, { v })
	local state, setState = React.useState()
	local gamePass = state and lookup[state]
	local createElement = React.createElement
	local v6 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local children = {
		Refresh = React.createElement("TextButton", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			Position = UDim2.fromScale(0.001, 0),
			AnchorPoint = Vector2.xAxis / 1000,
			Size = UDim2.fromScale(0.5, 0.1),
			Style = Enum.ButtonStyle.RobloxRoundDefaultButton,
			Text = "Refresh Game Passes",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			LayoutOrder = -1000,
			[React.Event.Activated] = function()
				GamePasses._internal.GamePassRefresh:Client():Fire()
			end
		}),
		GamePasses = React.createElement(DraggableList, {
			InnerComponent = GamePassInfo,
			InnerProps = {
				Lookup = lookup
			},
			Size = UDim2.fromScale(0.5, 0.9),
			Position = UDim2.fromScale(0.001, 0.1),
			AnchorPoint = Vector2.xAxis / 1000,
			OnActivated = setState,
			ActiveItem = state,
			Items = items
		})
	}
	local v8

	if gamePass then
		v8 = React.createElement(GamePassMigrator, {
			GamePass = gamePass,
			key = gamePass.Id
		})
	end

	children[1] = v8
	return createElement("Frame", v6, children)
end

local function ProductCell(p)
	local v = useOwnership({ p })
	local infoType = p.InfoType or Enum.InfoType.Asset
	return React.createElement("TextButton", {
		BackgroundColor3 = v and Color3.new(0, 1, 0) or Color3.new(1, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = `{infoType.Name}: {p.Id}`,
		TextColor3 = Color3.new(),
		TextWrapped = true,
		TextSize = 10,
		[React.Event.Activated] = function()
			Marketplace.PromptPurchase(p.Id, p.InfoType)
		end
	})
end

local function ProductColumn(props)
	local v = useOwnership(props.Ownership)
	local children = {}
	table.insert(children, React.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		SortOrder = Enum.SortOrder.LayoutOrder
	}))
	table.insert(children, React.createElement("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4)
	}))
	table.insert(children, React.createElement("TextLabel", {
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Size = UDim2.fromScale(0.25, 1),
		Text = props.Name,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	}))

	for _, v2 in props.Ownership do
		table.insert(children, React.createElement(ProductCell, v2))
	end

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = v and Color3.fromRGB(0, 127, 0) or Color3.fromRGB(127, 0, 0),
		BorderSizePixel = 0,
		LayoutOrder = tonumber(props.key) or 0
	}, children)
end

local function MockPurchaseTab()
	local v = useGamePasses({
		IncludeExpired = true,
		IncludeInactive = true
	})
	local v2 = useBoomboxData()
	local v3, v4 = React.useMemo(function()
		local result = {}
		local result2 = {}

		for _, v5 in v do
			local id = v5.Id
			local v6 = Ownership.Get(v5)

			for _, v7 in v6 do
				v7.Key = id
				table.insert(result, v7)
			end

			result2[id] = v6
		end

		if not v2 then
			return result, result2
		end

		local boombox = Ownership.Get(v2)

		for _, v6 in boombox do
			v6.Key = "Boombox"
			table.insert(result, v6)
		end

		result2.Boombox = boombox
		return result, result2
	end, { v2, v })
	local v5 = { useBulkOwnership(v3), v }
	local v6 = React.useMemo(function()
		local children = {}

		if v2 then
			table.insert(children, React.createElement(ProductColumn, {
				Name = "[MAIN BOOMBOX]",
				Ownership = v4.Boombox
			}))
		end

		for k, v7 in v do
			table.insert(children, React.createElement(ProductColumn, {
				Name = v7.Name,
				Ownership = v4[k] or {}
			}))
		end

		return children
	end, v5)
	return React.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, {
		List = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 4),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}, v6)
end

local function BooleanButton(props)
	local value = props.Value
	local setValue = props.SetValue
	local createElement = React.createElement
	local v2 = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Size = UDim2.fromScale(0.75, 0.1)
	}
	local style

	if value then
		style = Enum.ButtonStyle.RobloxRoundDefaultButton
	else
		style = Enum.ButtonStyle.RobloxRoundButton
	end

	v2.Style = style
	v2.Text = (value and "Disable" or "Enable") .. " " .. props.Label
	v2.TextColor3 = Color3.new(1, 1, 1)
	v2.TextSize = 14

	v2[React.Event.Activated] = function()
		setValue(not value)
	end

	return createElement("TextButton", v2)
end

local function TestFlagsTab()
	local v = useAttribute(Players.LocalPlayer, "RELICSxyz_MockFreemium", function(p)
		return p and true or false
	end)
	React.useState(function()
		Backend.MockFreemium:Client():Fire(v)
	end, { v })
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}, {
		MockFreemium = React.createElement(BooleanButton, {
			Label = "Mock Freemium",
			Value = v,
			SetValue = function(p)
				Backend.MockFreemium:Client():Fire(p)
			end
		})
	})
end

local function GiftingTab()
	local state, setState = React.useState(Players:GetPlayers())
	local v = useGamePasses()
	local state2, setState2 = React.useState()
	local state3, setState3 = React.useState()
	local v2, v3 = React.useBinding(0)
	local v4, v5 = React.useBinding(false)
	useSignal(Players.PlayerAdded, function()
		setState(Players:GetPlayers())
	end, {})
	useSignal(Players.PlayerRemoving, function()
		setState(Players:GetPlayers())
	end, {})
	local lookup, items = React.useMemo(function()
		local names = {}
		local result = {}

		for _, v8 in v do
			if not v8.GiftProductId then
				continue
			end

			local name = v8.Name
			table.insert(names, name)
			result[name] = v8
		end

		table.sort(names)
		return result, names
	end, { v })
	local lookup2, items2 = React.useMemo(function()
		local names = {}
		local result = {}

		for _, v10 in state do
			local name = v10.Name
			table.insert(names, name)
			result[name] = v10
		end

		table.sort(names)
		return result, names
	end, { state })
	local v10 = state2 and state3 and true or false
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}, {
		List = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 4),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		TargetGamePass = React.createElement("Frame", {
			Size = UDim2.fromScale(0.35, 1),
			BackgroundTransparency = 1
		}, {
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Header = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.RobotoMono,
				Text = "Target Product:",
				Size = UDim2.fromScale(1, 0.1),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				LayoutOrder = -1
			}),
			GamePasses = React.createElement(DraggableList, {
				InnerComponent = GamePassInfo,
				InnerProps = {
					Lookup = lookup,
					Active = state3
				},
				OnActivated = setState3,
				ActiveItem = state3,
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				Items = items
			})
		}),
		TargetPlayer = React.createElement("Frame", {
			Size = UDim2.fromScale(0.35, 1),
			BackgroundTransparency = 1
		}, {
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Header = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.RobotoMono,
				Text = "Target Recipient:",
				Size = UDim2.fromScale(1, 0.1),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				LayoutOrder = -1
			}),
			Players = React.createElement(DraggableList, {
				InnerComponent = PlayerInfo,
				InnerProps = {
					Lookup = lookup2,
					Active = state2
				},
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				Items = items2,
				OnActivated = setState2,
				ActiveItem = state2
			})
		}),
		Actions = React.createElement("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundTransparency = 1,
			LayoutOrder = 100
		}, {
			Flex = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill
			}),
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0.1, 0),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			GiftButton = React.createElement("TextButton", {
				BackgroundColor3 = Color3.new(0, 1, 0),
				BorderColor3 = Color3.new(),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0.3),
				TextColor3 = Color3.new(),
				Text = "Send Gift",
				TextScaled = true,
				Active = v10,
				AutoButtonColor = v10,
				BackgroundTransparency = v10 and 0 or 0.5,
				[React.Event.Activated] = function()
					if state3 and state2 then
						local v15 = lookup[state3]
						local v16 = lookup2[state2]

						if v15 and v16 then
							GamePasses.PerformGiftTransaction(v15.Id, v16)
						end
					end
				end
			}),
			ClearGifts = React.createElement("TextButton", {
				BackgroundTransparency = state2 and 0 or 0.5,
				AutoButtonColor = state2 and true or false,
				Active = state2 and true or false,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderColor3 = Color3.new(),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0.2),
				TextColor3 = Color3.new(),
				Text = "DEBUG: Clear Target Recipient's Gifts\n(Hold to Confirm)",
				LayoutOrder = 100,
				TextScaled = true,
				[React.Event.InputBegan] = state2 and function(_, p)
					if p.UserInputType == Enum.UserInputType.MouseButton1 then
						v5(true)

						while v4:getValue() do
							local v16 = task.wait(0.016666666666666666) / 2
							local v17 = math.clamp(v2:getValue() + v16, 0, 1)
							v3(v17)

							if v17 < 1 then
								continue
							end

							local v18 = state2 and lookup2[state2]
							local client = GamePasses._internal.ClearGifts:Client()

							if not v18 then
								break
							end

							client:Fire(v18)
							break
						end

						v3(0)
					end
				end or nil,
				[React.Event.InputEnded] = state2 and function(_, p)
					if p.UserInputType == Enum.UserInputType.MouseButton1 then
						v3(0)
						v5(false)
					end
				end or nil
			}, {
				Gradient = React.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.new(1, 0, 0)),
						ColorSequenceKeypoint.new(0.501, Color3.new(1, 1, 0)),
						ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))
					}),
					Offset = v2:map(function(p)
						return Vector2.new(-0.5 + p, 0)
					end),
					Rotation = 180
				})
			})
		})
	})
end

local v = {
	{
		Name = "Test Flags",
		Component = TestFlagsTab
	},
	{
		Name = "Migration",
		Component = MigrationTab
	},
	{
		Name = "Purchases",
		Component = MockPurchaseTab
	},
	{
		Name = "Gifting",
		Component = GiftingTab
	}
}

local function DevTools()
	local v2 = React.useContext(State.Context)

	if not Backend.IsRelicsDev(Players.LocalPlayer) then
		v2.WidgetReturn()
		return
	end

	local state, setState = React.useState("Migration")
	local v3, v4 = React.useMemo(function()
		local children = {}
		local component = nil

		for k, v5 in v do
			local robloxRoundButton = Enum.ButtonStyle.RobloxRoundButton

			if v5.Name == state then
				component = v5.Component
				robloxRoundButton = Enum.ButtonStyle.RobloxRoundDefaultButton
			end

			local createElement = React.createElement
			local v6 = {
				Size = UDim2.fromScale(0, 1),
				TextColor3 = Color3.new(1, 1, 1),
				Style = robloxRoundButton,
				Text = v5.Name,
				LayoutOrder = k
			}
			local v7 = v5

			v6[React.Event.Activated] = function()
				setState(v7.Name)
			end

			table.insert(children, createElement("TextButton", v6, {
				Flex = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Fill
				})
			}))
		end

		return component, children
	end, { state })
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}, {
		Tabs = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1
		}, v4, {
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceAround,
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}),
		Container = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.9),
			Position = UDim2.fromScale(0, 0.1),
			BackgroundTransparency = 1
		}, {
			Component = v3 and React.createElement(v3)
		})
	})
end

return DevTools