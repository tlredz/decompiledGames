local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.fromRGB(170, 190, 215)
local color2 = Color3.fromRGB(215, 130, 130)
local info = faye.Info(0.5)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.3),
	NumberSequenceKeypoint.new(0.7, 0.6),
	NumberSequenceKeypoint.new(1, 0.85)
})
return function(object)
	local value = object:Value("")
	local text = object:Value("Create Faction")
	local value3 = object:Value(color)
	local flag = false
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.075, 0),
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		object:Create("TextLabel")({
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.9, 0.15),
			BackgroundTransparency = 1,
			TextScaled = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Text = "Create a faction below, or ask a faction admin to invite you to their faction!",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.SourceSansSemibold,
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1)
			})
		}),
		object:Create("Frame")({
			Name = "NameBox",
			LayoutOrder = 2,
			object:Create("TextLabel")({
				Name = "LengthHint",
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, -0.15),
				Size = UDim2.fromScale(1, 0.6),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = `Faction names are {gameSettings.minFactionNameLength} to {gameSettings.maxFactionNameLength} characters long`,
				TextColor3 = Color3.new(1, 1, 1),
				TextTransparency = 0.25,
				Font = Enum.Font.SourceSansSemibold
			}),
			Size = UDim2.fromScale(0.75, 0.08),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("UIStroke")({
				Transparency = 0.95,
				Color = Color3.new(1, 1, 1)
			}),
			object:Create("Frame")({
				Name = "Textboxholder",
				Size = UDim2.fromScale(0.9, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				object:Create("TextBox")({
					Name = "Textbox",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					TextScaled = true,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					PlaceholderText = "Faction name here!",
					ClearTextOnFocus = false,
					TextOnChanged = function(_, p: string)
						value:Set(p)
					end
				})
			})
		}),
		object:Create("Frame")({
			Name = "CreateHolder",
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.3, 0.08),
			BackgroundTransparency = 1,
			GradientButton(object, {
				Text = text,
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				BgColor = object:Animation(value3, info),
				GradientTransparency = numberSequence,
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5)
				},
				Clicked = function()
					if flag then
						return
					end

					local v = value:Get()
					local v2 = #v < gameSettings.minFactionNameLength and "Too short" or #v > gameSettings.maxFactionNameLength and "Too long" or nil

					if v2 == nil then
						flag = true
						local v3 = PopUpCreator.new({
							Type = "LoadingFull"
						})
						SignalFunction.ToServer("Create Faction", v)
						v3:Destroy()
						flag = false
					else
						flag = true
						text:Set(v2)
						value3:Set(color2)
						local clone = ReplicatedStorage.Assets.Sounds.Misc.denied:Clone()
						clone.Parent = script
						clone:Play()
						DebrisModule:AddItem(clone, clone.TimeLength)
						object:Delay(0.5, function()
							value3:Reset()
						end)
						object:Delay(1, function()
							text:Reset()
							flag = false
						end)
					end
				end
			})
		})
	})
end