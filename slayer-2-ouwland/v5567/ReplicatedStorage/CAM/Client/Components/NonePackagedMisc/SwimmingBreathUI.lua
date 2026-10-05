local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
local spritesheetplayer = require(ReplicatedStorage.Packages.spritesheetplayer)
local v = { 5, 2 }
local v2 = v[1] * v[2]
return function(parent, p2)
	local v3 = faye.new()
	local v4 = not p2 and 1 or p2.ratio or 1
	local bubbles = p2 and p2.bubbles or {
		true,
		true,
		true,
		true,
		true
	}
	local value = v3:Value(v4)
	local value2 = v3:Value(1 - v4)
	local value3 = v3:Value(UDim2.fromScale(v4, 2))
	local value4 = v3:Value(0)
	local v5 = {
		v3:Value(bubbles[1] ~= false),
		v3:Value(bubbles[2] ~= false),
		v3:Value(bubbles[3] ~= false),
		v3:Value(bubbles[4] ~= false),
		(v3:Value(bubbles[5] ~= false))
	}
	v3:Create("Frame")({
		Parent = parent,
		Name = "BreathBar",
		Size = UDim2.fromScale(0.25, 0.225),
		BackgroundTransparency = 1,
		CleanDelay = info.Time,
		v3:Create("Frame")({
			Size = UDim2.fromScale(0.7, 0.1),
			AnchorPoint = Vector2.new(0.5, 1),
			Name = "Bg",
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = v3:Do(function(callback)
				local v6 = callback(value)

				if callback(value4) ~= 1 or not (v6 < 0.35) then
					return UDim2.fromScale(0.5, 1)
				end

				local v7 = 1 - v6 / 0.35
				return UDim2.fromScale(0.5, 1) + UDim2.fromOffset(math.random(-6, 6) * v7, math.random(-3, 3) * v7)
			end),
			v3:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			BackgroundTransparency = v3:Animation(0.35, info, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = v3:Animation(1, info)
				}
			end,
			v3:Create("UIStroke")({
				Thickness = 2,
				Color = Color3.new(1, 1, 1),
				Transparency = v3:Animation(0.8, info, {
					From = 1
				}),
				OnClean = function()
					return {
						Transparency = v3:Animation(1, info)
					}
				end
			}),
			v3:Create("Frame")({
				Size = v3:Animation(value3, info),
				Name = "Bar",
				v3:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.new(0.305882, 0.745098, 1),
				BackgroundTransparency = v3:Animation(0, info, {
					From = 1
				}),
				OnClean = function()
					return {
						BackgroundTransparency = v3:Animation(1, info)
					}
				end
			}),
			v3:Create("Frame")({
				Size = UDim2.fromScale(0.5, 10),
				Instance.new("UIAspectRatioConstraint"),
				Position = UDim2.fromScale(0.5, -4.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Name = "Bubble",
				v3:Create("UIListLayout")({
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(-0.4, 0)
				}),
				v3:Iterate(v5, function(_, p3, object, p4)
					local v6 = spritesheetplayer.new(v, "rbxassetid://96728660702021", p4)

					local function refresh()
						if p3.Value then
							v6:PlayBackwards()
						else
							v6:Play(-1)
						end
					end

					v3:Configure((v6:GetUI():FindFirstChild("Image")))({
						ImageTransparency = v3:Animation(0, info, {
							From = 1
						}),
						OnClean = function()
							return {
								ImageTransparency = v3:Animation(1, info)
							}
						end
					})

					if p3.Value then
						v6:To(1)
					else
						v6:To(v2 + 1)
					end

					object:Connect(p3.Changed, refresh)
				end)
			})
		})
	})
	return function()
		v3:Destroy()
	end, value, value2, value3, value4, v5
end