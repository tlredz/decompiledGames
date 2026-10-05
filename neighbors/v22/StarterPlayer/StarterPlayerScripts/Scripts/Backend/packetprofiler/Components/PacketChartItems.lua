local TweenService = game:GetService("TweenService")
local parent = script.Parent.Parent
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local StudioTheme = require(components.StudioTheme)

local function GetSizeUnit(dataSize: number)
	if dataSize < 1000 then
		return dataSize, "bytes"
	end

	if dataSize < 1000000 then
		return dataSize / 1000, "kilobytes"
	end

	return dataSize / 1000000, "megabytes"
end

local extended = Roact.Component:extend("DataChartItem")

function extended:init()
	local binding, showRemoteData = Roact.createBinding(false)
	self.RemoteData = binding
	self.ShowRemoteData = showRemoteData
	local binding2, setSize = Roact.createBinding(Vector2.zero)
	self.Size = binding2
	self.SetSize = setSize
	local binding3, setHighlightTransparency = Roact.createBinding(1)
	self.HighlightTransparency = binding3
	self.SetHighlightTransparency = setHighlightTransparency
	self.HighlightFrame = Roact.createRef()
	self.FadeInTween = nil
	self.FadeOutTween = nil
	self.HighlightTask = nil
end

function extended:didMount()
	if self.props.OnArcClicked then
		self.ArcClickConnection = self.props.OnArcClicked:Connect(function(p)
			if p == self.props.Arc.Name then
				self.ShowRemoteData(true)

				if self.FadeInTween then
					self.FadeInTween:Cancel()
				end

				if self.FadeOutTween then
					self.FadeOutTween:Cancel()
				end

				if self.HighlightTask then
					task.cancel(self.HighlightTask)
				end

				local value = self.HighlightFrame:getValue()

				if value then
					value.BackgroundTransparency = 1
					self.FadeInTween = TweenService:Create(
						value,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = 0.7
						}
					)
					self.FadeInTween:Play()
					self.HighlightTask = task.delay(0.25, function()
						self.FadeOutTween = TweenService:Create(
							value,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								BackgroundTransparency = 1
							}
						)
						self.FadeOutTween:Play()
					end)
				end
			end
		end)
	end
end

function extended.willUnmount(data)
	if data.ArcClickConnection then
		data.ArcClickConnection:Disconnect()
	end

	if data.FadeInTween then
		data.FadeInTween:Cancel()
	end

	if data.FadeOutTween then
		data.FadeOutTween:Cancel()
	end

	if data.HighlightTask then
		task.cancel(data.HighlightTask)
	end
end

function extended.render(data)
	local arc = data.props.Arc
	local v = {}

	for k, v2 in data.props.RemoteData do
		local v3 = k
		local v4 = v2
		local text = v2.Packet
		v[k] = StudioTheme(function(object)
			local layoutOrder = v3 * 2
			local layoutOrder2 = v3 * 2 + 1
			local v9 = { Roact.createElement("TextButton", {
					AutoLocalize = false,
					LayoutOrder = layoutOrder,
					Font = Enum.Font.SourceSans,
					Text = v4.Name,
					RichText = true,
					TextColor3 = object:GetColor("BrightText"),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Visible = data.RemoteData,
					Selectable = false
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 4)
					})
				}), (Roact.createElement("ScrollingFrame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					LayoutOrder = layoutOrder2,
					BackgroundColor3 = object:GetColor("ScrollBarBackground"),
					Position = UDim2.fromOffset(0, 20),
					Size = UDim2.new(1, -12, 0, 0),
					ClipsDescendants = true,
					BorderSizePixel = 0,
					ScrollBarImageColor3 = object:GetColor("ScrollBar"),
					ScrollBarThickness = 4,
					ScrollingDirection = Enum.ScrollingDirection.X,
					Visible = data.RemoteData,
					[Roact.Ref] = function(parent2)
						if parent2 ~= nil then
							task.delay(0.1, function()
								local uICorner = Instance.new("UICorner")
								uICorner.CornerRadius = UDim.new(0, 4)
								uICorner.Parent = parent2
							end)
						end
					end
				}, {
					UIStroke = Roact.createElement("UIStroke", {
						Color = object:GetColor("DropShadow"),
						LineJoinMode = Enum.LineJoinMode.Round,
						Transparency = 0.5
					}),
					Text = Roact.createElement("TextLabel", {
						AutoLocalize = false,
						Font = Enum.Font.Code,
						RichText = true,
						Text = text,
						TextColor3 = object:GetColor("BrightText"),
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						ClipsDescendants = true
					}, {
						Padding = Roact.createElement("UIPadding", {
							PaddingBottom = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
							PaddingLeft = UDim.new(0, 4),
							PaddingTop = UDim.new(0, 4)
						})
					})
				})) }
			return Roact.createFragment(v9)
		end)
	end

	return StudioTheme(function(object)
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			AutomaticSize = Enum.AutomaticSize.Y
		}, {
			HighlightEffect = Roact.createElement("Frame", {
				BackgroundColor3 = arc.Color,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				ZIndex = 1,
				BorderSizePixel = 0,
				[Roact.Ref] = data.HighlightFrame
			}),
			Information = Roact.createElement("TextButton", {
				AutoLocalize = false,
				Font = Enum.Font.SourceSans,
				Text = string.format(
					"<font color=\"#%s\"><b>%s</b></font>: %.1f%%, %d %s",
					arc.Color:ToHex(),
					arc.Name,
					arc.Percent,
					GetSizeUnit(arc.DataSize)
				),
				RichText = true,
				TextColor3 = object:GetColor("BrightText"),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -18, 0, 20),
				Position = UDim2.fromOffset(18, 0),
				ZIndex = 3,
				[Roact.Event.Activated] = function()
					data.ShowRemoteData(not data.RemoteData:getValue())
				end
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 4)
				})
			}),
			Chevron = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = data.RemoteData:map(function(p)
					if p then
						return "rbxassetid://18699144520"
					end

					return "rbxassetid://18699113012"
				end),
				ImageColor3 = object:GetColor("BrightText"),
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromOffset(0, 2),
				ZIndex = 3
			}),
			Container = Roact.createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = data.props.ScrollBarChanged:map(function(p)
					return UDim2.new(1, p.Visible and -12 or 0, 0, 0)
				end),
				Position = UDim2.fromOffset(8, 24),
				Transparency = 1,
				[Roact.Change.AbsoluteSize] = function(p)
					data.SetSize(p.AbsoluteSize)
				end
			}, {
				RemoteData = Roact.createFragment(v),
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 0)
				})
			}),
			Divider = Roact.createElement("Frame", {
				BackgroundColor3 = object:GetColor("DropShadow"),
				Transparency = 0.5,
				BorderSizePixel = 0,
				Size = data.Size:map(function(p)
					return UDim2.new(0, 1, 0, p.Y)
				end),
				Position = UDim2.fromOffset(0, 26),
				ZIndex = 2
			})
		})
	end)
end

local function DataChartItems(props)
	local v = 0
	local children = {}

	for _, arc in props.Arcs do
		v -= arc.Percent
		children[v] = Roact.createElement(extended, {
			Arc = arc,
			RemoteData = arc.RemoteData,
			ScrollBarChanged = props.ScrollBarChanged,
			OnArcClicked = props.OnArcClicked
		})
	end

	return Roact.createFragment(children)
end

return DataChartItems