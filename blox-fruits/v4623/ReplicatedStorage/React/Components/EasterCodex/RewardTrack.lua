local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local EasterEggs = require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local useTotalEggs = require(game.ReplicatedStorage.React.Hooks.Easter.useTotalEggs)
local useRewardsChanged = require(game.ReplicatedStorage.React.Hooks.Easter.useRewardsChanged)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useTotalEggs()
	local v2 = useRewardsChanged()
	local state, setState = React.useState({})
	local state2, setState2 = React.useState(nil)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local state3, setState3 = React.useState(UDim2.new())
	local ref3 = React.useRef(nil)
	local state4, setState4 = React.useState(tick())
	local state5, setState5 = React.useState(1)
	React.useEffect(function()
		if GlobalUtil.FFlags.IsUnitTest == true then
			setState5(math.random(1, 3))
		else
			setState5((math.min(3, Realm.getCurrentRealmDifficultyAsync())))
		end
	end, {})
	React.useEffect(function()
		local highestUnclaimedIndex = nil
		local v4 = nil
		local highestClaimedIndex = 0
		local v6 = {}

		for i = 1, #EasterEggs.Rewards do
			local v7 = math.clamp(v / EasterEggs.Rewards[i].Milestone, 0, 1)

			if table.find(v2, EasterEggs.Rewards[i].StorageName) then
				highestClaimedIndex = i
				v4 = highestClaimedIndex
				highestClaimedIndex = v4
			else
				if highestUnclaimedIndex == nil and v < EasterEggs.Rewards[i].Milestone then
					highestUnclaimedIndex = i
				end

				if v7 == 1 and v4 == nil then
					v4 = i
				end
			end
		end

		local v7 = math.min(highestClaimedIndex + 1, #EasterEggs.Rewards)
		local lowestUnclaimedIndex = v4 or 1

		for i = 1, #EasterEggs.Rewards do
			local isClaimed = table.find(v2, EasterEggs.Rewards[i].StorageName) ~= nil
			local progress = math.clamp(v / EasterEggs.Rewards[i].Milestone, 0, 1)

			if v7 < i and progress < 1 then
				progress = not EasterEggs.Rewards[i - 1] and 0 or math.clamp(
					v / EasterEggs.Rewards[i - 1].Milestone,
					0,
					1
				) < 1 and 0 or progress
			end

			table.insert(v6, {
				Index = i,
				IsClaimed = isClaimed,
				Progress = progress,
				LowestUnclaimedIndex = lowestUnclaimedIndex,
				HighestClaimedIndex = highestClaimedIndex,
				HighestUnclaimedIndex = highestUnclaimedIndex,
				CanClaim = false
			})
		end

		for _, v9 in pairs(v6) do
			if not (v9.IsClaimed == false and v9.Progress == 1) then
				continue
			end

			v9.CanClaim = true
			break
		end

		setState(v6)
	end, { v, v2 })
	local thickness = React.useMemo(function()
		return math.clamp(workspace.CurrentCamera.ViewportSize.X / 1000, 2, 10) * 0.6
	end, { workspace.CurrentCamera.ViewportSize })
	local v4 = React.useMemo(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function layoutOrder()
			local v5 = 0
			return function()
				v5 -= 1
				return v5
			end
		end

		local v5 = layoutOrder() -- equivalent call inferred; original call site unknown
		local result = {
			UIListLayout = createElement("UIListLayout", {
				ref = ref,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalFlex = Enum.UIFlexAlignment.SpaceAround
			})
		}

		for i = 1, #state do
			local reward = EasterEggs.Rewards[i]
			assert(result[reward.StorageName] == nil)
			local sea = reward.Seas[state5]
			local id = ItemId.getId(sea.Name, sea.Type)

			if id:isErr() then
				id:inspectErr(warn)
			else
				local unwrapped = ItemConfig.match(id:unwrap()):unwrap()
				local progress = state[i].Progress
				local v6 = 1 / (EasterEggs.Total - 3)
				local element = createElement("Frame", {
					BackgroundTransparency = i == 1 and 1 or 0.75,
					BackgroundColor3 = Color3.fromRGB(255, 234, 0),
					LayoutOrder = v5(),
					Size = UDim2.new(0.15, 0, i == 1 and 0.03 or v6, 0),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					ZIndex = CONSTANTS.LAYER.CONTENT
				}, {
					Fill = createElement("Frame", {
						BackgroundTransparency = i == 1 and 1 or 0,
						Position = UDim2.fromScale(0.5, 1),
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundColor3 = Color3.fromRGB(255, 234, 0),
						Size = UDim2.fromScale(1, progress)
					})
				})
				result[`Segment_{i}`] = element
				local isClaimed = state[i].IsClaimed
				local canClaim = state[i].CanClaim
				local formatted = `{reward.Milestone} Eggs`

				if i == state[i].HighestUnclaimedIndex then
					formatted = `{math.clamp(v, 0, reward.Milestone)}/{reward.Milestone} Eggs`
				end

				local ref4

				if i == state[i].LowestUnclaimedIndex then
					ref4 = ref3
				end

				local v9 = {
					ref = ref4,
					LayoutOrder = v5(),
					Size = UDim2.fromScale(0.95, 0.95),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					ZIndex = CONSTANTS.LAYER.RAISED
				}
				local children = {
					UIAspectRatio = createElement("UIAspectRatioConstraint"),
					UICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					Tile = 0,
					UIStroke = 0,
					ProgressText = 0,
					ClaimedCover = 0
				}
				local v13 = {
					Size = UDim2.fromScale(1, 1),
					Selectable = canClaim == true
				}
				local v15 = reward

				v13[React.Event.Activated] = function()
					if canClaim then
						setState4(tick() + 2)
						p.OnClaim(v15.StorageName)
					end
				end

				v13.Variant = "Display"
				v13.IsSelected = canClaim
				v13.DrawContext = "Default"
				v13.Quantity = sea.Quantity
				v13.IsEquipped = false
				v13.IsPermanent = false
				v13.Rarity = unwrapped.Quality.Rarity
				v13.Overlays = unwrapped.Inventory.TileOverlays
				v13.Title = unwrapped.Display.Title or ""
				v13.Category = unwrapped.Display.Category
				v13.Icon = unwrapped.Display.Sprite
				v13.IconBorderThickness = unwrapped.Display.SpriteBorderThickness
				v13.OutlineIcon = unwrapped.Display.OutlineSprite
				v13.CornerIcon = unwrapped.Display.CornerIcon
				v13.WasRecentlyReceived = canClaim
				children.Tile = createElement(Tile, v13)
				children.UIStroke = createElement("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = thickness
				})
				children.ProgressText = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 1.06926),
					Size = UDim2.new(1, 0, 0.3, 0)
				}, {
					UIGradient = React.createElement("UIGradient", {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.198007, 0),
							NumberSequenceKeypoint.new(0.800747, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					}),
					TextLabel = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 0.95),
						Text = formatted,
						TextColor3 = isClaimed and Color3.fromRGB(38, 255, 0) or CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextStrokeTransparency = CONSTANTS.ALPHA.MID,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Bottom,
						ZIndex = CONSTANTS.LAYER.OVERLAY
					})
				})
				local claimedCover

				if isClaimed then
					claimedCover = createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1)
					}, {
						UICorner = React.createElement("UICorner", {
							CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
						}),
						Glow = React.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://98629857383584",
							ImageTransparency = CONSTANTS.ALPHA.HALF,
							ImageColor3 = Color3.fromRGB(0, 227, 4),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1.35, 1.35)
						}),
						Checkmark = React.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
							Image = "rbxassetid://105017710071760",
							Position = UDim2.fromScale(1, 0),
							ScaleType = Enum.ScaleType.Fit,
							Size = UDim2.fromScale(0.3, 0.3),
							ZIndex = CONSTANTS.LAYER.RAISED
						})
					})
				end

				children.ClaimedCover = claimedCover
				local v17 = createElement("Frame", v9, children)
				result[reward.StorageName] = v17
			end
		end

		return result
	end, { state })
	React.useEffect(function()
		if not (ref2.current and ref.current) then
			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			setState3(UDim2.new(0, 0, 0, ref.current.AbsoluteContentSize.Y))
		end

		fn() -- equivalent call inferred; original call site unknown
		local absoluteContentSizeChangedConnection = ref.current:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn)
		return function()
			absoluteContentSizeChangedConnection:Disconnect()
		end
	end, { ref2.current, ref.current })
	React.useEffect(function()
		if not (ref2.current and ref3.current and state4 - tick() < 0) then
			return function() end
		end

		local thread = nil
		setState2(Vector2.zero)
		thread = task.defer(function()
			thread = nil
			local v5 = ref3.current.AbsoluteSize.Y / 2
			local v6 = ref3.current.AbsolutePosition.Y - (ref2.current.AbsoluteSize.Y / 2 + v5) - ref2.current.AbsolutePosition.Y
			setState2(Vector2.new(0, v6))
		end)
		return function()
			if thread then
				task.cancel(thread)
				thread = nil
			end
		end
	end, {
		state3,
		ref2.current,
		ref3.current,
		state4
	})
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}, {
		Header = createElement("Frame", {
			Visible = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.033),
			Size = UDim2.fromScale(1.2, 0.055),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.7, 0.85),
				Text = "Rewards",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					LineJoinMode = Enum.LineJoinMode.Miter,
					Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE
				})
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.240349, 0.3),
					NumberSequenceKeypoint.new(0.501868, 0),
					NumberSequenceKeypoint.new(0.863014, 0.3),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		Rewards = createElement("ScrollingFrame", {
			ref = ref2,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 0.92),
			CanvasSize = state3,
			CanvasPosition = state2,
			ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.NONE,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, v4)
	})
end