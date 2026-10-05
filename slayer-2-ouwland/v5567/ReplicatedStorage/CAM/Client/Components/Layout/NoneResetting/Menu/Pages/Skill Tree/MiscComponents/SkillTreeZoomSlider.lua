local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local uidragger = require(ReplicatedStorage.Packages.uidragger)

local function keyHint(maid, name: string, point: Vector2, p2: number)
	return maid:Create("Frame")({
		Name = name,
		AnchorPoint = point,
		Position = UDim2.fromScale(p2, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.fromScale(0.8, 0.8),
		BackgroundTransparency = 1,
		function(instance)
			instance:SetAttribute("OnlyOn", "Xbox,Playstation")
			instance:AddTag("UIkey")
		end
	})
end

return function(maid, object)
	local v = maid:Add(uidragger.new())
	v.Changed:Connect(function(p, p2)
		if p2 ~= nil then
			return
		end

		local v2 = (p.X - v.CurrentValues.Position.X) / v.CurrentValues.Size.X
		object:Set((math.clamp(v2, 0, 1)))
	end)
	return {
		keyHint(maid, "Zoom_Out", Vector2.new(1, 0.5), -0.05),
		keyHint(maid, "Zoom_In", Vector2.new(0, 0.5), 1.28),
		maid:Create("TextButton")({
			ZIndex = 2,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.1, 1.5),
			AutoButtonColor = false,
			MouseButton1Down = function(UI)
				v.UI = UI
				local v2, v3 = v:Start()

				if v3 ~= nil then
					return
				end

				local v4 = (v2.X - v.CurrentValues.Position.X) / v.CurrentValues.Size.X
				object:Set((math.clamp(v4, 0, 1)))
			end
		}),
		maid:Create("TextLabel")({
			Size = UDim2.fromScale(0.45, 0.76),
			Position = UDim2.fromScale(0, -0.1),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			Text = maid:Do(function(callback, _, _)
				return (`{math.floor(callback(object) * 100)}%`)
			end)
		}),
		maid:Create("ImageLabel")({
			Size = UDim2.fromScale(0.2, 1),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			Image = "rbxassetid://107407898800229",
			Position = UDim2.fromScale(1.015)
		}),
		maid:Create("ImageLabel")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://77927274401557",
			ImageTransparency = 0,
			ImageColor3 = Color3.new(0.25, 0.25, 0.25),
			maid:Create("ImageLabel")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://77927274401557",
				maid:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.495, 0),
						NumberSequenceKeypoint.new(0.505, 1),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Offset = maid:Do(function(callback, _, _)
						return Vector2.new(callback(object) - 0.5, 0)
					end)
				})
			})
		})
	}
end