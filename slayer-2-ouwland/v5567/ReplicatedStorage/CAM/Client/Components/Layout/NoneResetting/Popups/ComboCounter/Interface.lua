local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.3, Enum.EasingStyle.Back)
local info2 = faye.Info(0.425, Enum.EasingStyle.Back)
local info3 = faye.Info(0.15)
local info4 = faye.Info(0.2)
local info5 = faye.Info(0.1)
local clock = os.clock
return function(object, parent, text)
	local value = object:Value(false)
	local v = {
		Position = object:Value(UDim2.fromScale(0.5, 0.5)),
		Size = object:Value(UDim2.fromScale(0.23, 0.23)),
		TextSize = object:Value(UDim2.fromScale(1, 0.55))
	}
	local v2 = {
		Left = object:Value(180),
		Right = object:Value(180)
	}
	local v3 = 0

	local function upd()
		local v4 = math.random()
		v3 = v4
		local v5 = text.Value > 0
		value:Set(v5)
		v.Size:Refresh()
		v.Position:Set(v.Position.Initial + UDim2.fromScale(math.random() * 0.1 - 0.05, math.random() * 0.1 - 0.05))

		if v5 then
			object:Spawn(function()
				local now = clock()

				while v3 == v4 do
					local v6 = math.min((clock() - now) / 3.5, 1)
					local v7 = 360 - v6 * 360
					v2.Right:Set((math.min(v7, 180)))
					v2.Left:Set((math.max(v7 - 180, 0)))

					if v6 == 1 then
						break
					else
						task.wait()
					end
				end
			end)
		end
	end

	upd()
	object:Connect(text.Changed, upd)
	object:Create("Frame")({
		Parent = parent,
		Name = "Container",
		Position = UDim2.fromScale(0.255, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		object:State(function(callback, object2)
			if callback(value) == true then
				return object2:Create("Frame")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = v.Position,
					Size = object2:Animation(v.Size, info, {
						AlwaysFrom = UDim2.fromScale(v.Size.Initial.X.Scale * 0.75, v.Size.Initial.Y.Scale * 0.75)
					}),
					BackgroundTransparency = 1,
					CleanDelay = 0.2,
					object2:Create("ImageLabel")({
						Name = "Bg",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = object2:Animation(UDim2.fromScale(2.391, 0.797), info3, {
							From = UDim2.fromScale(2.391, 0)
						}),
						BackgroundTransparency = 1,
						Image = "http://www.roblox.com/asset/?id=11932306250",
						CleanFunction = function()
							return {
								Size = object2:Animation(UDim2.fromScale(2.391, 0), info3),
								ImageTransparency = object2:Animation(1, info4)
							}
						end
					}),
					object2:Create("TextLabel")({
						Name = "Dmg",
						Position = UDim2.fromScale(0.15, 0.4),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = object2:Animation(v.TextSize, info2, {
							AlwaysFrom = UDim2.fromScale(
								v.TextSize.Initial.X.Scale * 0.25,
								v.TextSize.Initial.Y.Scale * 0.25
							)
						}),
						BackgroundTransparency = 1,
						Text = text,
						TextScaled = true,
						TextColor3 = Color3.new(1, 1, 1),
						Font = Enum.Font.Arcade,
						object2:Create("UIGradient")({
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.new(1, 0.8, 0.07)),
								ColorSequenceKeypoint.new(0.25, Color3.new(1, 0.8, 0.07)),
								ColorSequenceKeypoint.new(0.8, Color3.new(1, 1, 1)),
								ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
							}),
							Rotation = -90
						}),
						object2:Create("UIStroke")({
							Thickness = 2,
							CleanFunction = function()
								return {
									Transparency = object2:Animation(1, info5)
								}
							end
						}),
						CleanFunction = function()
							return {
								TextTransparency = object2:Animation(1, info5)
							}
						end
					}),
					object2:Create("Frame")({
						Size = UDim2.fromScale(0.4, 1),
						Instance.new("UIAspectRatioConstraint"),
						Position = UDim2.fromScale(0.8, 0.41),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						object2:Create("ImageLabel")({
							Image = "http://www.roblox.com/asset/?id=11934690085",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Name = "Bg",
							ImageColor3 = Color3.new(),
							CleanFunction = function()
								return {
									ImageTransparency = object2:Animation(1, info5)
								}
							end
						}),
						object2:Create("Frame")({
							Name = "Left",
							Size = UDim2.fromScale(0.5, 1),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							object2:Create("ImageLabel")({
								Size = UDim2.fromScale(2, 1),
								BackgroundTransparency = 1,
								Image = "http://www.roblox.com/asset/?id=11934655911",
								ImageColor3 = Color3.fromRGB(255, 209, 26),
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.4975, 1),
										NumberSequenceKeypoint.new(0.5025, 0),
										NumberSequenceKeypoint.new(1, 0)
									}),
									Rotation = v2.Left
								}),
								CleanFunction = function()
									return {
										ImageTransparency = object2:Animation(1, info5)
									}
								end
							})
						}),
						object2:Create("Frame")({
							Name = "Left",
							Size = UDim2.fromScale(0.5, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0),
							ClipsDescendants = true,
							object2:Create("ImageLabel")({
								Size = UDim2.fromScale(2, 1),
								Position = UDim2.fromScale(-1, 0),
								BackgroundTransparency = 1,
								Image = "http://www.roblox.com/asset/?id=11934655911",
								ImageColor3 = Color3.fromRGB(255, 209, 26),
								Rotation = -180,
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.4975, 1),
										NumberSequenceKeypoint.new(0.5025, 0),
										NumberSequenceKeypoint.new(1, 0)
									}),
									Rotation = v2.Right
								}),
								CleanFunction = function()
									return {
										ImageTransparency = object2:Animation(1, info5)
									}
								end
							})
						})
					})
				})
			end
		end)
	})
end