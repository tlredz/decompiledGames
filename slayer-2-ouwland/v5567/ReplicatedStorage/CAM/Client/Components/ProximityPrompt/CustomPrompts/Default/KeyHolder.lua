require(game.ReplicatedStorage.Packages.faye)
local Config = require(script.Parent.Parent.Config)
return function(object, p, p2, p3, object2)
	local value = object:Value(UDim2.fromScale(2, 2))
	local value2 = object:Value(Config.KeyHolder.Positions.p1)
	local value3 = object:Value(0)
	local value4 = object:Value(0.9)
	local v = nil
	local imageColor = object:Value(Color3.new(1, 1, 1))
	local value6 = object:Value(false)

	local function updState()
		local v2 = p.State:Get()
		local v3 = object2:Get()

		if v3 >= 2 then
			v2 = v3 + 1
		end

		if v == v2 then
			return
		end

		v = v2
		local v4 = nil

		if v2 == 2 then
			value:Set(UDim2.fromScale(1.5, 1.5))
			value2:Set(Config.KeyHolder.Positions.p2)
		elseif v2 >= 3 then
			v4 = true
			value4:Set(1)
			value3:Set(1)

			if v2 == 3 then
				value6:Set(true)
				imageColor:Set(Config.TriggeredColor)
			else
				imageColor:Reset()
				value6:Reset()
			end
		else
			value:Reset()
			value2:Reset()
		end

		if not v4 then
			value6:Reset()
			imageColor:Reset()
			value4:Reset()
			value3:Reset()
		end
	end

	updState()
	object2.Changed:Connect(updState)
	p.State.Changed:Connect(updState)
	return object:Create("Frame")({
		Size = UDim2.fromScale(0.7, 0.7),
		Instance.new("UIAspectRatioConstraint"),
		Name = "KeyHolder",
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "State1",
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			object:Create("ImageLabel")({
				Name = "Bg",
				Size = object:Animation(value, Config.TransitionInfo),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Image = "rbxassetid://93437195955932",
				ImageColor3 = Color3.new(),
				ZIndex = -1,
				ImageTransparency = object:Animation(value4, Config.TransitionInfo),
				BackgroundTransparency = 1
			}),
			Position = object:Animation(value2, Config.TransitionInfoSmooth),
			object:Create("ImageLabel")({
				Name = "BgEff",
				ZIndex = -1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageColor3 = Config.TriggeredColor,
				BackgroundTransparency = 1,
				Image = "rbxassetid://75277912225711",
				Size = UDim2.fromScale(1, 1),
				Rotation = -45,
				ImageTransparency = 1,
				object:Do(function(callback, object3, _)
					if callback(value6) then
						return {
							ImageTransparency = object3:Animation(1, Config.TransitionInfoLong, {
								From = 0.25
							}),
							Size = object3:Animation(UDim2.fromScale(1.5, 1.5), Config.TransitionInfoLong)
						}
					end

					return {
						Size = UDim2.fromScale(1, 1)
					}
				end)
			}),
			BackgroundTransparency = 1,
			object:State(function(callback, object3)
				local v2 = callback(p.State)
				local keyContent = Config.GetKeyContent(p2, p3)
				local v3

				if keyContent.Type == "Text" then
					local v4 = object3:Create("TextLabel")
					local v5 = {
						Size = v2 == 2 and UDim2.fromScale(1, 0.9) or UDim2.fromScale(1, 0.785),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						Text = keyContent.Content,
						TextTransparency = object3:Animation(value3, Config.TransitionInfoLong),
						Font = Enum.Font.SourceSansBold,
						TextScaled = true,
						TextColor3 = Color3.new(0.15, 0.15, 0.15),
						Rotation = 0
					}
					local rotation

					if v2 == 2 then
						rotation = object3:Animation(45, Config.TransitionInfoLong) or nil
					end

					v5.Rotation = rotation
					v3 = v4(v5)
				else
					local v4 = object3:Create("ImageLabel")
					local v5 = {
						Size = v2 == 2 and UDim2.fromScale(0.75, 0.75) or UDim2.fromScale(0.65, 0.65),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						ImageTransparency = object3:Animation(value3, Config.TransitionInfoLong),
						Image = keyContent.Content,
						ImageColor3 = Color3.new(),
						Rotation = 0
					}
					local rotation

					if v2 == 2 then
						rotation = object3:Animation(45, Config.TransitionInfoLong) or nil
					end

					v5.Rotation = rotation
					v3 = v4(v5)
				end

				if v2 == 1 then
					return object3:Create("ImageLabel")({
						Name = "NoneHolding",
						Size = object3:Animation(UDim2.fromScale(1, 1), Config.TransitionInfo, {
							From = UDim2.fromScale(0.75, 0.75)
						}),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ImageColor3 = object3:Animation(imageColor, Config.TransitionInfo),
						ImageTransparency = object3:Animation(value3, Config.TransitionInfo),
						BackgroundTransparency = 1,
						Image = "rbxassetid://16873598266",
						CleanDelay = Config.TransitionInfoLong.Time,
						OnClean = function(object4)
							return {
								Size = object4:Animation(UDim2.fromScale(), Config.TransitionInfo),
								ImageColor3 = object4:Animation(Config.TriggeredColor, Config.TransitionInfo)
							}
						end,
						v3
					})
				end

				return object3:Create("ImageLabel")({
					Name = "holding",
					Size = object3:Animation(UDim2.fromScale(0.65, 0.65), Config.TransitionInfo, {
						From = UDim2.fromScale(1, 1)
					}),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ImageColor3 = object3:Animation(imageColor, Config.TransitionInfo),
					Rotation = object3:Animation(-45, Config.TransitionInfoLong),
					BackgroundTransparency = 1,
					ImageTransparency = object3:Animation(value3, Config.TransitionInfoLong),
					Image = "rbxassetid://75277912225711",
					v3,
					CleanDelay = Config.TransitionInfoLong.Time,
					object3:Create("Frame")({
						Size = UDim2.fromScale(1.35, 1.35),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ZIndex = 2,
						BackgroundTransparency = 1,
						Name = "BarHolder",
						object3:Create("ImageLabel")({
							Name = "Bg",
							ImageColor3 = Color3.new(),
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Image = "rbxassetid://76111800658323",
							ImageTransparency = object3:Animation(value4, Config.TransitionInfo)
						}),
						object3:Create("Frame")({
							Size = UDim2.fromScale(0.5, 1),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.fromScale(0, 0.5),
							ClipsDescendants = true,
							ZIndex = 2,
							BackgroundTransparency = 1,
							object3:Create("ImageLabel")({
								Size = UDim2.fromScale(2, 1),
								BackgroundTransparency = 1,
								ImageColor3 = imageColor,
								Image = "rbxassetid://133881500323671",
								object3:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0),
										NumberSequenceKeypoint.new(0.499, 0),
										NumberSequenceKeypoint.new(0.501, 1),
										NumberSequenceKeypoint.new(1, 1)
									}),
									Rotation = object3:Do(function(callback2, _, _)
										return (math.clamp((1 - callback2(p.Rotation)) * 360 - 180, 0, 180))
									end)
								})
							})
						}),
						object3:Create("Frame")({
							Size = UDim2.fromScale(0.5, 1),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							ClipsDescendants = true,
							ZIndex = 2,
							BackgroundTransparency = 1,
							object3:Create("ImageLabel")({
								Size = UDim2.fromScale(2, 1),
								Position = UDim2.fromScale(-1, 0),
								BackgroundTransparency = 1,
								ImageColor3 = imageColor,
								Image = "rbxassetid://90063648650986",
								object3:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.499, 1),
										NumberSequenceKeypoint.new(0.501, 0),
										NumberSequenceKeypoint.new(1, 0)
									}),
									Rotation = object3:Do(function(callback2, _, _)
										return (math.clamp((1 - callback2(p.Rotation)) * 360, 0, 180))
									end)
								})
							})
						})
					}),
					OnClean = function(object4)
						return {
							Size = object4:Animation(UDim2.fromScale(), Config.TransitionInfoLong),
							ImageColor3 = object4:Animation(Config.TriggeredColor, Config.TransitionInfo)
						}
					end
				})
			end)
		})
	})
end