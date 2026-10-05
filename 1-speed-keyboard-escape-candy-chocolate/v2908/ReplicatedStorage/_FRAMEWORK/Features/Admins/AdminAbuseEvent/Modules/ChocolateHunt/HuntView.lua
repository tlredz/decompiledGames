local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Config = require(script.Parent.Config)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local colorSequence = ColorSequence.new(Color3.fromRGB(121, 73, 43), Color3.fromRGB(69, 37, 25))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 214, 120), Color3.fromRGB(214, 111, 38))

local function createMilestones(callback)
	local result = {}

	for _, milestone in Config.milestones do
		local v = milestone.progress / Config.goal
		local v2 = milestone
		local v3 = milestone
		table.insert(result, create("Frame")({
			Name = `Milestone{milestone.multiplier}`,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(v, 0.5),
			Size = UDim2.fromScale(0.083, 1.08),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
			create("Frame")({
				Name = "Marker",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.08, 1),
				BackgroundColor3 = function()
					if callback() >= v2.progress then
						return (Color3.fromRGB(255, 232, 145))
					end

					return (Color3.fromRGB(82, 52, 38))
				end,
				BorderSizePixel = 0,
				ZIndex = 4,
				create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				})
			}),
			create("TextLabel")({
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, -0.25),
				Size = UDim2.fromScale(1, 0.68),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = `x{milestone.multiplier}`,
				TextColor3 = function()
					if callback() >= v3.progress then
						return (Color3.fromRGB(255, 225, 120))
					end

					return (Color3.fromRGB(205, 185, 175))
				end,
				TextScaled = true,
				ZIndex = 5,
				create("UIStroke")({
					Color = Color3.fromRGB(28, 16, 12),
					Thickness = 0.07,
					StrokeSizingMode = 1
				})
			})
		}))
	end

	return result
end

return {
	mount = function(playerGui)
		local source = Vide.source(0)
		local source2 = Vide.source(Config.defaultDurationSeconds)
		local v = nil
		local isA = playerGui:IsA("PlayerGui")
		local v2 = Vide.mount(function()
			local v3 = create(isA and "ScreenGui" or "Frame")
			local v4 = {
				Name = "ChocolateHuntProgress",
				DisplayOrder = isA and 28600 or nil,
				IgnoreGuiInset = not isA and nil,
				ResetOnSpawn = not isA and nil
			}
			local size

			if not isA then
				size = UDim2.fromScale(1, 1)
			end

			v4.Size = size
			v4.BackgroundTransparency = not isA and 1 or nil
			do local _values = table.pack(Vide.action(function(p)
	v = p
end), create("TextLabel")({
	Name = "Timer",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.012),
	Size = UDim2.fromScale(0.067, 0.03),
	BackgroundColor3 = Color3.fromRGB(83, 47, 31),
	BorderSizePixel = 0,
	FontFace = rbxassetfontsfamiliesGothamSSmjson,
	Text = function()
		local v8 = math.max(0, (math.ceil((source2()))))
		return string.format("%02d:%02d", math.floor(v8 / 60), v8 % 60)
	end,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	ZIndex = 3,
	create("UIAspectRatioConstraint")({
		AspectRatio = 4
	}),
	create("UICorner")({
		CornerRadius = UDim.new(0.35, 0)
	}),
	create("UIStroke")({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(255, 232, 155),
		Thickness = 0.055,
		StrokeSizingMode = 1
	})
}), create("Frame")({
	Name = "Shadow",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.502, 0.05),
	Size = UDim2.fromScale(0.339, 0.096),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	create("UIAspectRatioConstraint")({
		AspectRatio = 6.25
	}),
	create("UICorner")({
		CornerRadius = UDim.new(0.12, 0)
	})
}), create("Frame")({
	Name = "Card",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.046),
	Size = UDim2.fromScale(0.339, 0.096),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
	create("UIAspectRatioConstraint")({
		AspectRatio = 6.25
	}),
	create("UICorner")({
		CornerRadius = UDim.new(0.12, 0)
	}),
	create("UIGradient")({
		Color = colorSequence,
		Rotation = 90
	}),
	create("UIStroke")({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.new(1, 1, 1),
		Thickness = 0.018,
		StrokeSizingMode = 1
	}),
	create("TextLabel")({
		Position = UDim2.fromScale(0.035, 0.08),
		Size = UDim2.fromScale(0.93, 0.25),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Text = "CHOCOLATE HUNT",
		TextColor3 = Color3.fromRGB(255, 232, 155),
		TextScaled = true,
		create("UIStroke")({
			Color = Color3.fromRGB(35, 19, 13),
			Thickness = 0.055,
			StrokeSizingMode = 1
		})
	}),
	create("Frame")({
		Name = "ProgressBar",
		Position = UDim2.fromScale(0.055, 0.52),
		Size = UDim2.fromScale(0.89, 0.25),
		BackgroundColor3 = Color3.fromRGB(45, 25, 20),
		BackgroundTransparency = 0.12,
		ClipsDescendants = false,
		create("UICorner")({
			CornerRadius = UDim.new(0.5, 0)
		}),
		create("Frame")({
			Name = "Fill",
			Size = function()
				return UDim2.fromScale(math.clamp(source() / Config.goal, 0, 1), 1)
			end,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			create("UICorner")({
				CornerRadius = UDim.new(0.5, 0)
			}),
			create("UIGradient")({
				Color = colorSequence2,
				Rotation = 90
			})
		}),
		create("TextLabel")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson2,
			Text = function()
				return (`{source()} / {Config.goal}`)
			end,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			ZIndex = 6,
			create("UIStroke")({
				Color = Color3.fromRGB(30, 15, 10),
				Thickness = 0.055,
				StrokeSizingMode = 1
			})
		}),
		(createMilestones(source))
	})
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
			return v3(v4)
		end, playerGui)
		return {
			update = function(p: number, _: number)
				source(p)
			end,
			updateTimer = function(p: number)
				source2(p)
			end,
			destroy = function()
				v2()

				if v then
					v:Destroy()
					v = nil
				end
			end
		}
	end
}