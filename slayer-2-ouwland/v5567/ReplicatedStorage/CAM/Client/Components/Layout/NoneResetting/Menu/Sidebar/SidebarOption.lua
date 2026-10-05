local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Onboarding = require(ReplicatedStorage.CAM.Client.Modules.Onboarding)
local springInfo = faye.SpringInfo(0.4, 0.85, 0.4)
local springInfo2 = faye.SpringInfo(0.2)
return function(maid, layoutOrder: number, p2: string, object, object2)
	local visible = maid:Value(Platform_Handler.IsGamepad())
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		visible:Set(Platform_Handler.IsGamepad())
	end)
	local imageColor = maid:Value(Color3.new(1, 1, 1))
	local value3 = maid:Value(1)
	local imageTransparency = maid:Value(0.5)
	local value5 = maid:Value(UDim2.fromScale(0.2, 0.5))
	local flag = false
	local v = {
		In = false,
		LastState = nil
	}
	local v2 = object2:Add({
		v,
		p2.Name,
		imageColor,
		value3,
		imageTransparency,
		value5
	}):Call()
	local v3 = p2.Name == "Inventory" or p2.Name == "Close"

	if v3 then
		maid:Add(function()
			Onboarding.Set(p2.Name, nil)
		end)
	end

	local v4 = maid:Create("TextButton")
	local v5 = {
		Name = tostring(layoutOrder) .. p2.Name,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		After = function(p3)
			if v3 then
				Onboarding.Set(p2.Name, p3)
			end
		end,
		MouseEnter = function()
			v.In = true
			v2:Call()
		end,
		MouseLeave = function()
			v.In = false
			v2:Call()
		end,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()

			if p2.Name == "Close" then
				object:Set("")
				return
			end

			if p2.Name ~= "Back To Main Menu" then
				object:Set(p2.Name)
				return
			end

			if flag then
				return
			end

			flag = true
			task.spawn(function()
				local v6 = PopUpCreator.new({
					Type = "Question",
					Content = "Go back to the main menu?"
				}):WaitResult()
				flag = false

				if v6 ~= "Yes" then
					return
				end

				Teleporter.Request({
					placeId = Worlds.ByName["Main Menu"].Id
				})
			end)
		end
	}
	local v6 = maid:Create("Frame")({
		Name = "Bg",
		Size = UDim2.fromScale(1, 1),
		ZIndex = -2,
		BackgroundColor3 = maid:Animation(imageColor, springInfo2),
		BackgroundTransparency = maid:Animation(value3, springInfo2),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		maid:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.225, 0.45),
				NumberSequenceKeypoint.new(0.5, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	local v7 = maid:Create("ImageLabel")({
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.1, 0.53),
		Size = UDim2.fromScale(0.2, 0.8),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		Image = p2.Icon,
		ImageColor3 = imageColor,
		ImageTransparency = imageTransparency
	})
	local v8 = maid:Create("TextLabel")
	local v9 = {
		Name = "Text",
		Size = UDim2.fromScale(2, 0.7),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = maid:Animation(value5, springInfo),
		BackgroundTransparency = 1,
		Text = p2.Name,
		TextTransparency = maid:Animation(imageTransparency, springInfo2),
		TextColor3 = maid:Animation(imageColor, springInfo2),
		TextScaled = true,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextBoundsOnChangedInit = p2.Name == "Close" and function(instance, point: Vector2)
			local menu_Close = instance:FindFirstChild("Menu_Close")

			if menu_Close ~= nil then
				menu_Close.Position = UDim2.new(0, point.X + 10, 0.44, 0)
			end
		end or nil
	}
	local v10

	if p2.Name == "Close" then
		v10 = Utility.AddTag(maid:Create("Frame")({
			Name = "Menu_Close",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.44, 0),
			Size = UDim2.fromScale(0.6, 0.6),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Visible = visible
		}), "UIkey")
	end

	v9[1] = v10
	do local _values = table.pack(v6, v7, v8(v9)); for _k = 1, _values.n do v5[_k] = _values[_k] end end
	return v4(v5)
end