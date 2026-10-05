local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local NumberLib = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.NumberLib)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 65, 184)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(133, 40, 220))
})

local function phaseMarker(p: number, text: string)
	return create("Frame")({
		Name = `{text}Marker`,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(p, 0.5),
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = Color3.fromRGB(235, 210, 255),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 4,
		create("TextLabel")({
			Name = "Label",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, 5),
			Size = UDim2.fromOffset(70, 18),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = text,
			TextColor3 = Color3.fromRGB(235, 220, 245),
			TextScaled = true,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0.4,
			ZIndex = 4
		})
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function modulateFakeWinCycle(p: number, p2: number)
	return p + p2 * 0.3 * math.sin(p * 3.141592653589793 * 2) / 6.283185307179586
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getPhaseWeightedProgress(p: number)
	if p < 0.33 then
		return p / 0.33 * 0.5
	end

	if p < 0.75 then
		return (p - 0.33) / 0.42 * 0.30000000000000004 + 0.5
	end

	return (p - 0.75) / 0.25 * 0.19999999999999996 + 0.8
end

local function getFakeWinProgress(value: number)
	local v = math.clamp(value, 0, 1)

	if v >= 1 then
		return 1
	end

	local v2 = getPhaseWeightedProgress(v) * 20
	local v3 = math.floor(v2)
	local v4 = v2 - v3
	local v5 = v3 % 2 == 0 and 1 or -1
	local v6 = modulateFakeWinCycle(v4, v5) -- equivalent call inferred; original call site unknown

	if v4 >= 0.58 and v4 < 0.66 then
		v6 = 0.58 + v5 * 0.3 * -0.481753674101715 / 6.283185307179586
	elseif v4 < 0.78 and v4 >= 0.66 then
		local v7 = (v4 - 0.66) / 0.12
		local v8 = 0.58 + v5 * 0.3 * -0.481753674101715 / 6.283185307179586
		v6 = v8 + v7 * (0.78 + v5 * 0.3 * -0.9822872507286887 / 6.283185307179586 - v8)
	end

	return (v3 + v6) / 20
end

return {
	mount = function(p)
		local source = Vide.source(0)
		local source2 = Vide.source(false)
		local v = nil
		local v2 = Vide.mount(function()
			local v3 = create("ScreenGui")({
				Name = "SummerBossProgress",
				DisplayOrder = 20,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Enabled = source2,
				create("Frame")({
					Name = "Container",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 48),
					Size = UDim2.new(0.58, 0, 0, 52),
					BackgroundTransparency = 1,
					create("Frame")({
						Name = "Bar",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 0, 0, 34),
						BackgroundColor3 = Color3.fromRGB(20, 16, 30),
						BackgroundTransparency = 0.15,
						BorderSizePixel = 0,
						create("UICorner")({
							CornerRadius = UDim.new(0.5, 0)
						}),
						create("UIStroke")({
							Color = Color3.fromRGB(219, 135, 255),
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
						phaseMarker(0.5, "PHASE 2"),
						phaseMarker(0.8, "PHASE 3"),
						create("ImageLabel")({
							Name = "BossIcon",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0),
							Size = UDim2.fromOffset(54, 54),
							BackgroundColor3 = Color3.fromRGB(20, 16, 30),
							BorderSizePixel = 0,
							Image = "rbxassetid://74389556285578",
							ZIndex = 5,
							create("UICorner")({
								CornerRadius = UDim.new(1, 0)
							}),
							create("UIStroke")({
								Color = Color3.fromRGB(236, 148, 255),
								Thickness = 2
							})
						}),
						create("TextLabel")({
							Name = "BossName",
							Position = UDim2.new(0, 36, 0, 0),
							Size = UDim2.new(0.55, -36, 1, 0),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson2,
							Text = "WIN COUNT",
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 6
						}),
						create("TextLabel")({
							Name = "FakeWinCount",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.98, 0),
							Size = UDim2.fromScale(0.27, 1),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson2,
							Text = function()
								local v4 = math.floor(source() * 333000000000000)
								return (`{NumberLib.toShort(v4)} / {NumberLib.toShort(333000000000000)}`)
							end,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Right,
							ZIndex = 6
						})
					})
				})
			})
			v = v3
			return v3
		end, p)
		local flag = false
		return {
			update = function(p2: number, flag2: boolean)
				if flag then
					return
				end

				source((getFakeWinProgress(p2)))
				source2(flag2)
			end,
			destroy = function()
				if flag then
					return
				end

				flag = true
				v2()

				if v then
					v:Destroy()
					v = nil
				end
			end
		}
	end
}