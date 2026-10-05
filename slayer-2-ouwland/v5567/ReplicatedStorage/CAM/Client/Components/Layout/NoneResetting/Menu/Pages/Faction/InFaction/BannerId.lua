local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EditIcon = require(script.Parent.EditIcon)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2, Enum.EasingStyle.Back)
local info2 = faye.Info(0.2)
return function(object, p)
	local value = object:Value(false)
	local value2 = object:Value("")

	local function complete()
		local v = value2:Get()

		if v == "" then
			return
		end

		local v2 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		pcall(SignalFunction.ToServer, "Set Faction Banner", v)
		v2:Destroy()
	end

	return { object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0, 4)
		}), object:Create("Frame")({
			Name = "AButtonHolder",
			Size = UDim2.fromScale(1, 1),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			object:State(function(callback, p2)
				if p == nil or callback(p) == true then
					return EditIcon(p2, value, complete)
				end
			end)
		}), object:State(function(callback, object2)
			if callback(value) then
				return object2:Create("CanvasGroup")({
					Name = "0IdBox",
					Size = object2:Animation(UDim2.fromScale(0.5, 0.8), info, {
						From = UDim2.fromScale(0.4, 0.8)
					}),
					BackgroundColor3 = Color3.new(1, 1, 1),
					OnClean = {
						GroupTransparency = object2:Animation(1, info2),
						Size = object2:Animation(UDim2.fromScale(0.4, 0.8), info2)
					},
					object2:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					object2:Create("TextBox")({
						Name = "Textbox",
						Size = UDim2.new(1, -8, 0.7),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextColor3 = Color3.new(0, 0, 0),
						PlaceholderColor3 = Color3.new(0.266667, 0.239216, 0.239216),
						Font = Enum.Font.SourceSans,
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderText = "Paste the Banner image id here!",
						ClearTextOnFocus = false,
						FocusLost = function(p2)
							value2:Set(p2.Text)
						end
					})
				})
			end

			return nil
		end) }
end