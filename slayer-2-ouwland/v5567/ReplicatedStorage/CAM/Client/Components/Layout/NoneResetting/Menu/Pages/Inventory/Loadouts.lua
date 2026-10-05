local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = ReplicatedStorage.Packages.faye
require(faye)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Individual = require(script.Individual)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local shopSettings = require(ReplicatedStorage.CAM.Global.shopSettings)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local vector = Vector2.new(0.3, 0.5)
local name = shopSettings.Loadouts.ExtraLoadout.Name
return function(object, p)
	local value = object:Value("")
	local flag = false

	local function buySlot()
		if flag then
			return
		end

		flag = true
		local v = PopUpCreator.new({
			Type = "LoadingFull"
		})
		local success, result = pcall(SignalFunction.ToServer, "PurchaseFromShop", name, 1)
		v:Destroy()
		flag = false
		local v2 = success and result == true and "Money_Kaching" or "denied_old"
		local clone = ReplicatedStorage.Assets.Sounds.Misc[v2]:Clone()
		clone.Parent = script
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end

	local space = object:Space(function(state)
		local lastState = value:Compare(state.Name) and 1 or state.In and 2 or 0

		if lastState ~= state.LastState then
			state.LastState = lastState

			if lastState == 1 then
				state.Color:Set(Color3.new(0.235, 0.235, 0.235))
				state.TextColor:Reset()
				state.StrokeTransparency:Set(0.5)
				state.StrokeSize:Set(UDim2.new(1, -8, 1, -8))
				state.AspectRatio:Set(state.EquippedAspect)
				state.Editable:Set(true)
				state.ButtonEnabled:Set(false)
				state.TextPosition:Set(UDim2.fromScale(0.5, -0.5))
			elseif lastState == 2 then
				state.Color:Set(Color3.new(1, 1, 1))
				state.TextColor:Set(Color3.new())
				state.AspectRatio:Reset()
				state.TextPosition:Reset()
				state.Editable:Reset()
				state.ButtonEnabled:Reset()
			else
				state.TextColor:Reset()
				state.Color:Reset()
				state.AspectRatio:Reset()
				state.StrokeSize:Reset()
				state.StrokeTransparency:Reset()
				state.TextPosition:Reset()
				state.Editable:Reset()
				state.ButtonEnabled:Reset()
			end
		end
	end)
	space:Connect(value.Changed)
	local v2 = vector * (Platform_Handler.Platform.Value == "Mobile" and 1.5 or 1)
	return object:Create("Frame")({
		Name = "Loadout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(-0.05, 0.55 - (v2.Y - vector.Y)),
		Size = object:Animation(UDim2.fromScale(v2.X, v2.Y), object.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(v2.X * 0.8, v2.Y * 0.8)
		}),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.Name,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),
		GradientButton(object, {
			Properties = {
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.fromScale(0.8, 0.065)
			},
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.75, 0.5),
				NumberSequenceKeypoint.new(1, 0.5)
			}),
			TextXAlignment = Enum.TextXAlignment.Center,
			Clicked = buySlot,
			Text = "Add more",
			BgColor = Color3.new(0.627451, 1, 0.466667)
		}),
		object:Create("ScrollingFrame")({
			Name = "AScrollingFrame",
			Size = UDim2.fromScale(1, 0.935),
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			object:Create("UIListLayout")({
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.Name,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
					local absoluteContentSize = p2.AbsoluteContentSize
					p2.Parent.CanvasSize = UDim2.fromOffset(absoluteContentSize.X, absoluteContentSize.Y)
				end
			}),
			object:AdvancedIterate(p, function(_, p2, p3)
				return Individual(p3, space, value, p2)
			end)
		})
	})
end