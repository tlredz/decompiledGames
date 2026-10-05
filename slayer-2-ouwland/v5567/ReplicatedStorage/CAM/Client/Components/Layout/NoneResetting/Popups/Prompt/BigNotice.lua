local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
local info2 = faye.Info(0.25)
local info3 = faye.Info(0.3, Enum.EasingStyle.Back)
local color = Color3.new(0.85, 0.85, 0.85)
local color2 = Color3.new(1, 1, 1)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })

local function ListLine(object, p, layoutOrder: number, color3: Color3, value)
	local text

	if typeof(p) == "table" then
		text = tostring(p.Text)
	else
		text = tostring(p)
	end

	local icon

	if typeof(p) == "table" and type(p.Icon) == "string" and p.Icon ~= "" then
		icon = p.Icon
	end

	local v = object:Create("Frame")
	local v2 = {
		Name = `Line{layoutOrder}`,
		LayoutOrder = layoutOrder,
		Size = object:Do(function(callback)
			return UDim2.new(1, 0, 0, callback(value) * 0.045)
		end),
		BackgroundTransparency = 1
	}
	local v3 = object:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8)
	})
	local v4

	if icon == nil then
		v4 = object:Create("Frame")({
			Name = "Bullet",
			LayoutOrder = 0,
			Size = UDim2.fromScale(0.45, 0.45),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Name = "Outer",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.7, 0.7),
				Rotation = 45,
				BackgroundColor3 = color3,
				BackgroundTransparency = 0.25,
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.2, 0)
				}),
				object:Create("UIStroke")({
					Color = Color3.new(),
					Transparency = 0.85
				})
			})
		})
	else
		v4 = object:Create("ImageLabel")({
			Name = "Bullet",
			LayoutOrder = 0,
			Size = UDim2.fromScale(0.75, 0.75),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = icon,
			ScaleType = Enum.ScaleType.Fit
		})
	end

	do local _values = table.pack(v3, v4, object:Create("TextLabel")({
	Name = "Txt",
	LayoutOrder = 1,
	Size = UDim2.fromScale(2, 0.9),
	BackgroundTransparency = 1,
	Text = text,
	RichText = true,
	TextScaled = true,
	Font = Enum.Font.SourceSansSemibold,
	TextColor3 = Color3.new(1, 1, 1),
	TextTransparency = 0.1,
	TextXAlignment = Enum.TextXAlignment.Left,
	object:Create("UIStroke")({
		Thickness = 1.5,
		Color = Color3.new(),
		Transparency = 0.35
	}),
	TextBoundsOnChangedInit = function(state)
		if state.TextBounds.X > 0 and state.Parent ~= nil and state.Parent.AbsoluteSize.X > 0 then
			state.Size = UDim2.fromScale(math.min(state.TextBounds.X / state.Parent.AbsoluteSize.X, 0.9), 0.9)
		end
	end
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end

local v = {
	Type = "BigNotice",
	Content = {
		Text = "Update 335",
		Paragraph = "The biggest update yet. Two whole regions open this week, each with its own bosses, trainers and quest lines to work through, and the demon art trials have been rebuilt from the ground up. Codes and announcements now live in the main menu.",
		List = { "Iceveil Valley", "Mistfall Harbor", "Codes and announcements" },
		Close = "Got it"
	}
}
return function(object, parent, p2, value: number?)
	local v2 = p2 or v
	local v3 = value or -1
	local content

	if typeof(v2.Content) == "table" then
		content = v2.Content
	else
		content = {
			Text = v2.Content
		}
	end

	local text = type(content.Text) ~= "string" and "" or content.Text
	local paragraph

	if type(content.Paragraph) == "string" then
		paragraph = content.Paragraph
	else
		paragraph = nil
	end

	local v5 = typeof(content.List) ~= "table" and {} or content.List
	local text2 = (type(content.Close) ~= "string" or content.Close == "") and "Close" or content.Close
	local color3 = v2.Color or Color3.new(1, 1, 1)
	local Y = GuiService:GetGuiInset().Y
	local value2 = object:Value(parent.AbsoluteSize.Y)
	local flag = false
	local onClose

	if type(v2.OnClose) == "function" then
		onClose = v2.OnClose
	else
		onClose = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dismissed()
		if flag then
			return
		end

		flag = true

		if onClose ~= nil then
			task.spawn(onClose)
		end
	end

	object:Add(dismissed)

	local function close()
		dismissed() -- equivalent call inferred; original call site unknown
		PopUpCreator.signal:Fire(v3)
	end

	object:Create("TextButton")({
		Parent = parent,
		Name = "Cover",
		Size = UDim2.new(1, 0, 1, Y),
		Position = UDim2.fromOffset(0, -Y),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = object:Animation(v2.BackgroundTransparency or 0.2, info, {
			From = 1
		}),
		AutoButtonColor = false,
		OnClean = function()
			return {
				BackgroundTransparency = object:Animation(1, info2)
			}
		end,
		[object:GetSignal("GetPropertyChangedSignal", "AbsoluteSize", true)] = function(p3)
			value2:Set(p3.AbsoluteSize.Y - Y)
		end,
		object:Create("CanvasGroup")({
			Name = "Column",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, Y / 2),
			Size = UDim2.fromScale(0.6, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			GroupTransparency = object:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					GroupTransparency = object:Animation(1, info2)
				}
			end,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10)
			}),
			object:Create("TextLabel")({
				Name = "Header",
				LayoutOrder = 0,
				Size = object:Do(function(callback)
					return UDim2.new(1, 0, 0, callback(value2) * 0.09)
				end),
				BackgroundTransparency = 1,
				Text = text,
				RichText = true,
				TextScaled = true,
				TextWrapped = false,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = color3,
				object:Create("UIScale")({
					Scale = object:Animation(1, info3, {
						From = 1.5
					})
				}),
				object:Create("UIStroke")({
					Color = color3,
					Thickness = 1,
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = -90
					})
				}),
				object:Create("UIShadow")({
					Name = "UiShadow",
					Color = color3,
					BlurRadius = UDim.new(0.5, 0),
					Transparency = object:Animation(0.5, info3, {
						From = 1
					})
				}),
				After = {
					TextBoundsOnChangedInit = function(p3, p4)
						p3.UiShadow.Spread = UDim2.new(-1, p4.X, -0.6, 0)
					end
				}
			}),
			function()
				if paragraph == nil then
					return
				else
					return object:Create("TextLabel")({
						Name = "Paragraph",
						LayoutOrder = 1,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Text = paragraph,
						RichText = true,
						TextWrapped = true,
						TextSize = object:Do(function(callback)
							return (math.max(callback(value2) * 0.031, 1))
						end),
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = 0.1,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Top,
						object:Create("UIStroke")({
							Thickness = 1.5,
							Color = Color3.new(),
							Transparency = 0.35
						})
					})
				end
			end,
			function()
				if #v5 == 0 then
					return
				else
					return object:Create("Frame")({
						Name = "List",
						LayoutOrder = 2,
						Size = object:Do(function(callback)
							return UDim2.new(1, 0, 0, callback(value2) * 0.045 * #v5)
						end),
						BackgroundTransparency = 1,
						object:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						object:Iterate(v5, function(layoutOrder: number, p4, p5)
							return ListLine(p5, p4, layoutOrder, color3, value2)
						end)
					})
				end
			end,
			object:Create("Frame")({
				Name = "CloseHolder",
				LayoutOrder = 3,
				Size = object:Do(function(callback)
					local v9 = callback(value2)
					return UDim2.fromOffset(v9 * 0.18 * 2, v9 * 0.07)
				end),
				BackgroundTransparency = 1,
				GradientButton(object, {
					GradientRotation = -90,
					Text = text2,
					BgColor = color,
					ContentColor = color2,
					Font = Enum.Font.SourceSansBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					StrokeClick = true,
					GradientTransparency = numberSequence,
					Properties = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5)
					},
					Clicked = close
				})
			})
		})
	})
end