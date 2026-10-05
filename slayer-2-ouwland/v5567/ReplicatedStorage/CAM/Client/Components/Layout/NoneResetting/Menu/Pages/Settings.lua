local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CategoryBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.CategoryBrowser)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local faye = require(ReplicatedStorage.Packages.faye)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Reset = require(script.Reset)
local Sections = require(script.Sections)
local Row = require(script.Row)
local v = Platform_Handler.Platform.Value == "Mobile"
local v2 = v and 1.0530000000000002 or 0.78
local v3 = v and 0.138 or 0.115
local color = Color3.new(0.32, 0.32, 0.32)
local color2 = Color3.new(1, 1, 1)
local info = faye.Info(0.15)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.fromRGB(150, 235, 160)
local color5 = Color3.fromRGB(255, 130, 130)
local color6 = Color3.new(0, 0, 0)
local info2 = faye.Info(0.3, Enum.EasingStyle.Back)
return function(object, instance)
	local isGamepad = Platform_Handler.IsGamepad()
	local v4 = Sections.Build()
	local names = {}

	for _, v5 in v4 do
		table.insert(names, v5.Name)
	end

	local value = object:Value(names[1])

	-- equivalent calls inferred from this helper; original call sites unknown
	local function entriesOf(p)
		for _, v5 in v4 do
			if v5.Name == p then
				return v5.Entries
			end
		end

		return {}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	local value2 = object:Value(0)
	local canvasSize = object:Value(UDim2.new())
	local value4 = object:Value("")
	local v5 = {}
	local value5 = object:Value("Asking")

	local function applyRecording()
		local done = v5.Done

		if done ~= nil then
			done()
		end
	end

	local function closeRecording()
		local cancel = v5.Cancel

		if cancel ~= nil then
			cancel()
		end
	end

	return object:Create("Frame")({
		Name = "Settings",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		object:Create("UIGradient")({
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(1, 0.95)
			})
		}),
		Size = object:Animation(UDim2.fromScale(v2, v2), object.Info(0.35, Enum.EasingStyle.Back), {
			From = UDim2.fromScale(v2 * 0.9, v2 * 0.9)
		}),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 1.3
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.02)
		}),
		CategoryBrowser(object, instance, value, names, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.06, 0.5),
			Size = UDim2.fromScale(0.1716, 0.86),
			TabHeight = 0.07800000000000001,
			Uniform = true,
			Overscan = 0
		}),
		object:Create("CanvasGroup")({
			Name = "ListMask",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.97, 0.5),
			Size = UDim2.fromScale(0.7083999999999999, 0.88),
			BackgroundTransparency = 1,
			object:Create("UIGradient")({
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.04, 0),
					NumberSequenceKeypoint.new(0.92, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("ScrollingFrame")({
				Name = "List",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ScrollBarThickness = 0,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				CanvasSize = canvasSize,
				ClipsDescendants = false,
				AbsoluteSizeOnChangedInit = function(_, point: Vector2)
					if point.X <= 0 then
						return
					end

					value2:Set(point.X * v3 / uiScale())
				end,
				object:State(function(callback, object2)
					local v7 = entriesOf(callback(value)) -- equivalent call inferred; original call site unknown
					local overhang = Row.Overhang(v7)
					return object2:Create("Frame")({
						Name = "Rows",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						object2:Create("UIListLayout")({
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 6),
							AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
								canvasSize:Set(UDim2.fromOffset(0, (point.Y / uiScale() + overhang) * 1.06))
							end
						}),
						object2:Iterate(v7, function(p: number, p2, p3)
							return Row.Build(p3, p2, value2, p, value4, uiScale, v5, value5)
						end)
					})
				end)
			})
		}),
		object:State(function(callback, object2)
			local v6 = callback(value4)

			if type(v6) ~= "string" or v6 == "" then
				return
			end

			local v7

			if not isGamepad then
				v7 = object2:Create("TextButton")({
					Name = "Click",
					AutoButtonColor = false,
					Selectable = false,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					MouseButton1Click = closeRecording
				})
			end

			local flag = false
			return object2:Create("Frame")({
				Name = "RecordPrompt",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1,
				ZIndex = 1000,
				CleanDelay = 0.15,
				CleanFunction = function(object3)
					return {
						Position = object3:Animation(UDim2.fromScale(0, 0.03), info)
					}
				end,
				object2:Create("Frame")({
					Name = "Cover",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(4, 4),
					ZIndex = 1000,
					CleanDelay = 0.15,
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = object2:Animation(0.55, info, {
						From = 1
					}),
					CleanFunction = function(object3)
						return {
							BackgroundTransparency = object3:Animation(1, info)
						}
					end,
					v7
				}),
				object2:Create("TextButton")({
					Name = "Prompt",
					AutoButtonColor = false,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 1.025),
					Size = object2:Animation(UDim2.fromScale(0.42, 0.08), info2, {
						From = UDim2.fromScale(0.378, 0.07200000000000001)
					}),
					ZIndex = 1001,
					CleanDelay = 0.15,
					BackgroundColor3 = object2:Do(function(callback2)
						local v8 = callback2(value5)
						local v9

						if v8 == "Refused" then
							v9 = color5
						elseif v8 == "Taken" then
							v9 = color4
						else
							v9 = color3
						end

						if flag then
							return object2:Animation(v9, info)
						end

						flag = true
						return v9
					end),
					BackgroundTransparency = object2:Animation(0, info, {
						From = 1
					}),
					CleanFunction = function(object3)
						return {
							BackgroundTransparency = object3:Animation(1, info)
						}
					end,
					object2:Create("UICorner")({
						CornerRadius = UDim.new(0.35)
					}),
					object2:Create("TextLabel")({
						Name = "Ask",
						Text = "Click me to apply",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.9, 0.5),
						ZIndex = 1002,
						CleanDelay = 0.15,
						BackgroundTransparency = 1,
						TextColor3 = color6,
						TextTransparency = object2:Animation(0, info, {
							From = 1
						}),
						Font = Enum.Font.SourceSansBold,
						TextScaled = true,
						CleanFunction = function(object3)
							return {
								TextTransparency = object3:Animation(1, info)
							}
						end
					}),
					MouseButton1Click = applyRecording
				})
			})
		end),
		GradientButton(object, {
			Text = "Reset",
			BgColor = color,
			FgColor = color2,
			GradientRotation = -90,
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(1, 0.75)
			}),
			CornerRadius = UDim.new(0.25),
			StrokeClick = true,
			Font = Enum.Font.SourceSansBold,
			Clicked = function()
				task.spawn(Reset.All)
			end,
			Properties = {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0.06, 0.95),
				Size = UDim2.fromScale(0.1111968, 0.04829760000000001)
			}
		})
	})
end