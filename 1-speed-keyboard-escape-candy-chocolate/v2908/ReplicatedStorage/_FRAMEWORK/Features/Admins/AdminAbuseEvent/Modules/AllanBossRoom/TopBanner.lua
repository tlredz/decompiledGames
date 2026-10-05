local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberLib = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.NumberLib)
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local color = Color3.fromRGB(69, 137, 255)
local color2 = Color3.fromRGB(0, 91, 187)
local color3 = Color3.fromRGB(12, 20, 38)
local colorSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2) })

-- equivalent calls inferred from this helper; original call sites unknown
local function modulatePacingCycle(p: number, p2: number)
	return p + p2 * 0.3 * math.sin(p * 3.141592653589793 * 2) / 6.283185307179586
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getPhaseWeightedProgress(p: number)
	if p < 0.3333333333333333 then
		return p / 0.3333333333333333 * 0.5
	end

	if p < 0.6666666666666666 then
		return (p - 0.3333333333333333) / 0.3333333333333333 * 0.30000000000000004 + 0.5
	end

	return (p - 0.6666666666666666) / 0.33333333333333337 * 0.19999999999999996 + 0.8
end

local function getFakeWinsProgress(value: number)
	local v = math.clamp(value, 0, 1)

	if v >= 1 then
		return 1
	end

	local v2 = getPhaseWeightedProgress(v) * 20
	local v3 = math.floor(v2)
	local v4 = v2 - v3
	local v5 = v3 % 2 == 0 and 1 or -1
	local v6 = modulatePacingCycle(v4, v5) -- equivalent call inferred; original call site unknown

	if v4 >= 0.58 and v4 < 0.66 then
		v6 = 0.58 + v5 * 0.3 * -0.481753674101715 / 6.283185307179586
	elseif v4 >= 0.66 and v4 < 0.78 then
		local v7 = (v4 - 0.66) / 0.12
		local v8 = 0.58 + v5 * 0.3 * -0.481753674101715 / 6.283185307179586
		v6 = v8 + v7 * (0.78 + v5 * 0.3 * -0.9822872507286887 / 6.283185307179586 - v8)
	end

	return (v3 + v6) / 20
end

return {
	mount = function(playerGui, p)
		local source = Vide.source(false)
		local source2 = Vide.source(0)
		local v = nil
		local v2 = Vide.mount(function()
			local spring = Vide.spring(source2, 0.5, 1)

			local function fn()
				local v3 = math.floor(math.clamp(spring(), 0, 1) * 667000000000000)
				return (`{NumberLib.toShort(v3)} / {NumberLib.toShort(667000000000000)}`)
			end

			local v3 = create("Frame")({
				Name = "Banner",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 24),
				Size = UDim2.fromOffset(420, 54),
				BackgroundTransparency = 1,
				create("Frame")({
					Name = "ProgressBar",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = color3,
					BackgroundTransparency = 0.15,
					BorderSizePixel = 0,
					create("UICorner")({
						CornerRadius = UDim.new(0.5, 0)
					}),
					create("UIStroke")({
						Color = color,
						Thickness = 2.5,
						Transparency = 0.2
					}),
					create("CanvasGroup")({
						Name = "FillMask",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						create("UICorner")({
							CornerRadius = UDim.new(0.5, 0)
						}),
						create("Frame")({
							Name = "Fill",
							Position = UDim2.fromOffset(-34, 0),
							Size = function()
								return UDim2.new(math.clamp(spring(), 0, 1), 34, 1, 0)
							end,
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							create("UIGradient")({
								Color = colorSequence
							})
						})
					}),
					create("ImageLabel")({
						Name = "BossIcon",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.fromOffset(54, 54),
						BackgroundColor3 = color3,
						BorderSizePixel = 0,
						Image = p.icon,
						ScaleType = Enum.ScaleType.Fit,
						ZIndex = 5,
						create("UICorner")({
							CornerRadius = UDim.new(1, 0)
						}),
						create("UIStroke")({
							Color = color,
							Thickness = 2
						})
					}),
					create("TextLabel")({
						Name = "Reward",
						Position = UDim2.new(0, 40, 0, 0),
						Size = UDim2.new(0.5, -40, 1, 0),
						BackgroundTransparency = 1,
						FontFace = rbxassetfontsfamiliesGothamSSmjson,
						Text = "HELP PINPIN",
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						TextStrokeColor3 = Color3.new(0, 0, 0),
						TextStrokeTransparency = 0.35,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 6
					}),
					create("Frame")({
						Name = "Counter",
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -14, 0, 0),
						Size = UDim2.new(0.4, 0, 1, 0),
						BackgroundTransparency = 1,
						ZIndex = 5,
						create("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 6),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						create("ImageLabel")({
							Name = "Trophy",
							LayoutOrder = 1,
							Size = UDim2.fromOffset(20, 20),
							BackgroundTransparency = 1,
							Image = "rbxassetid://15540211845",
							ScaleType = Enum.ScaleType.Fit,
							ZIndex = 5
						}),
						create("TextLabel")({
							Name = "Wins",
							LayoutOrder = 2,
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, 24),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson,
							Text = fn,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 16,
							TextStrokeColor3 = Color3.new(0, 0, 0),
							TextStrokeTransparency = 0.35,
							ZIndex = 5
						})
					})
				})
			})

			if playerGui:IsA("PlayerGui") then
				return create("ScreenGui")({
					Name = "AllanBossRoomTopBanner",
					DisplayOrder = 20,
					IgnoreGuiInset = true,
					ResetOnSpawn = false,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					Enabled = source,
					Vide.action(function(p2)
						v = p2
					end),
					v3
				})
			end

			return create("Frame")({
				Name = "AllanBossRoomTopBannerPreview",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = source,
				Vide.action(function(p2)
					v = p2
				end),
				v3
			})
		end, playerGui)
		local flag = false
		return {
			update = function(p2: number, flag2: boolean)
				if flag then
					return
				end

				source2((getFakeWinsProgress(p2)))
				source(flag2)
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