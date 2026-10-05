local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EditIcon = require(script.Parent.EditIcon)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2, Enum.EasingStyle.Back)
local info2 = faye.Info(0.2)
local info3 = faye.Info(info2.Time, nil, nil, nil, nil, info2.Time)
return function(object, text: string, p2)
	local value = object:Value(false)
	local value2 = object:Value(text)

	local function complete()
		local v = value2:Get()

		if v == "" or v == text then
			return
		end

		local v2 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		pcall(SignalFunction.ToServer, "Rename Faction", v)
		v2:Destroy()
	end

	return { object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0, 4)
		}), object:State(function(callback, object2)
			if callback(value) then
				return object2:Create("CanvasGroup")({
					Name = "0Name",
					Size = object2:Animation(UDim2.fromScale(0.5, 0.8), info, {
						From = UDim2.fromScale(0.4, 0.8)
					}),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Visible = object2:DelayProperty(true, info2.Time, false),
					GroupTransparency = object2:Animation(0, info3, {
						From = 1
					}),
					OnClean = {
						GroupTransparency = object2:Animation(1, info2),
						Size = object2:Animation(UDim2.fromScale(0.4, 0.8), info2)
					},
					object2:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					object2:Create("TextBox")({
						Name = "Textbox",
						Size = UDim2.new(1, -8, 0.7, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						TextScaled = true,
						Text = text,
						TextColor3 = Color3.new(0, 0, 0),
						PlaceholderColor3 = Color3.new(0.266667, 0.239216, 0.239216),
						Font = Enum.Font.SourceSansBold,
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderText = "Faction name here!",
						ClearTextOnFocus = false,
						TextOnChanged = function(p3, value3: string)
							if #value3 > gameSettings.maxFactionNameLength then
								p3.Text = string.sub(value3, 1, gameSettings.maxFactionNameLength)
							end
						end,
						FocusLost = function(p3)
							value2:Set(p3.Text)
						end
					})
				})
			end

			return object2:Create("CanvasGroup")({
				Name = "0Name",
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundTransparency = 1,
				Visible = object2:DelayProperty(true, info2.Time, false),
				GroupTransparency = object2:Animation(0, info3, {
					From = 1
				}),
				OnClean = {
					GroupTransparency = object2:Animation(1, info2)
				},
				object2:Create("TextLabel")({
					Name = "Text",
					Size = UDim2.fromScale(100, 1),
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					TextBoundsOnChangedInit = function(p3)
						if p3.TextBounds.X > 0 then
							p3.Parent.Size = UDim2.new(0, p3.TextBounds.X, 1, 0)
						end
					end
				})
			})
		end), object:Create("Frame")({
			Name = "AButtonHolder",
			Size = UDim2.fromScale(1, 1),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			object:State(function(callback, p3)
				if p2 == nil or callback(p2) == true then
					return EditIcon(p3, value, complete)
				end
			end)
		}) }
end