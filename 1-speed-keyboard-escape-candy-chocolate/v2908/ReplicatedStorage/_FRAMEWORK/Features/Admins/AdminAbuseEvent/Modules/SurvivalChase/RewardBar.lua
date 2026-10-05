local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 96, 64)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 90))
})
local color = Color3.fromRGB(30, 14, 16)
local color2 = Color3.fromRGB(255, 120, 120)

local function formatSurvivedTime(p: number)
	local v = math.floor((math.max(0, p)))
	return string.format("%d:%02d", v // 60, v % 60)
end

return {
	mount = function(p)
		local source = Vide.source(0)
		local source2 = Vide.source(1)
		local source3 = Vide.source(0)
		local source4 = Vide.source(false)
		local v = nil
		local v2 = Vide.mount(function()
			local v3 = create("ScreenGui")({
				Name = "SurvivalChaseReward",
				DisplayOrder = 21,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Enabled = source4,
				create("Frame")({
					Name = "Container",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 110),
					Size = UDim2.new(0.42, 0, 0, 44),
					BackgroundTransparency = 1,
					create("Frame")({
						Name = "Bar",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundColor3 = color,
						BackgroundTransparency = 0.15,
						BorderSizePixel = 0,
						create("UICorner")({
							CornerRadius = UDim.new(0.5, 0)
						}),
						create("UIStroke")({
							Color = color2,
							Thickness = 2,
							Transparency = 0.2
						}),
						create("Frame")({
							Name = "Fill",
							Size = function()
								return UDim2.fromScale(source(), 1)
							end,
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							create("UICorner")({
								CornerRadius = UDim.new(0.5, 0)
							}),
							create("UIGradient")({
								Color = colorSequence
							})
						}),
						create("TextLabel")({
							Name = "Title",
							Position = UDim2.new(0, 14, 0, 0),
							Size = UDim2.new(0.4, -14, 1, 0),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson,
							Text = "SURVIVE",
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 5
						}),
						create("TextLabel")({
							Name = "SurvivedTime",
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0),
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson,
							Text = function()
								return formatSurvivedTime(source3())
							end,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.5,
							ZIndex = 5
						}),
						create("TextLabel")({
							Name = "Streak",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -14, 0, 0),
							Size = UDim2.new(0.3, -14, 1, 0),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson,
							Text = function()
								return (`x{source2()}`)
							end,
							TextColor3 = Color3.fromRGB(255, 220, 120),
							TextScaled = true,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Right,
							ZIndex = 5
						})
					})
				})
			})
			v = v3
			return v3
		end, p)
		local v3 = false
		return {
			update = function(value: number, p2: number, p3: number, flag: boolean)
				if not v3 then
					source((math.clamp(value, 0, 1)))
					source2(p2)
					source3(p3)
					source4(flag)
				end
			end,
			destroy = function()
				if not v3 then
					v3 = true
					v2()

					if v then
						v:Destroy()
						v = nil
					end
				end
			end
		}
	end
}