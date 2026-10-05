local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientOvalButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientOvalButton)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
require(ReplicatedStorage.Packages.faye)
local partyInfo = Utility.GetData(Players.LocalPlayer, true).Parent.Parent.partyInfo
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0.5, 0.5)
local v = {
	pvp = {
		Text = "PVP",
		Signal = "Change Pvp",
		Value = partyInfo.pvp.Current,
		States = {
			[true] = "rbxassetid://104031883855826",
			[false] = "rbxassetid://116773900855235"
		},
		Colors = {
			[true] = color2,
			[false] = color
		}
	},
	invite = {
		Text = "Invites",
		Signal = "Change Invites",
		Value = partyInfo.invites,
		States = {
			[true] = "rbxassetid://88776810243509",
			[false] = "rbxassetid://119190400474351"
		},
		Colors = {
			[false] = color2,
			[true] = color
		}
	}
}
local flag = false
return function(object, p: number, p2)
	local v2 = v

	if p2 ~= nil then
		v2 = {}

		for k, v3 in v do
			if p2[k] then
				v2[k] = v3
			end
		end
	end

	return object:Create("Frame")({
		Name = "AAAAAAAA000Topbar",
		Size = UDim2.new(1, 0, 0, p * 0.9),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3)
		}),
		object:Iterate(v2, function(_, data, p3, _)
			local image = object:Value()
			local contentColor = object:Value()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update(value3)
				contentColor:Set(data.Colors[value3])
				image:Set(data.States[value3])
			end

			update(data.Value.Value) -- equivalent call inferred; original call site unknown
			object:Connect(data.Value.Changed, update)
			return object:Create("Frame")({
				Size = UDim2.fromScale(0.2, 1),
				BackgroundTransparency = 1,
				GradientOvalButton(p3, {
					Image = image,
					Text = data.Text,
					ContentColor = contentColor,
					TextStrokeTransparency = 0.7,
					ImageSize = UDim2.fromScale(0.875, 0.875),
					Font = Enum.Font.SourceSansBold,
					FitWidth = true,
					Clicked = function()
						if flag then
							return
						end

						flag = true
						local v3 = PopUpCreator.new({
							Type = "LoadingFull"
						})
						SignalFunction.ToServer(data.Signal)
						v3:Destroy()
						flag = false
					end
				})
			})
		end)
	})
end