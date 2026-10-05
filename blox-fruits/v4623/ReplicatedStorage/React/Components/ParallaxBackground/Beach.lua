local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getDriftX(p: number, p2: number, p3: number)
	return 1.1 - (p * p2 + p3) % 1.2000000000000002
end

local function getDriftFade(p: number, value: number?)
	local v = value or 0.1

	if p >= 0.85 then
		return (p - 0.85) / 0.2500000000000001
	end

	if p <= v then
		return (v - p) / (v - -0.1)
	end

	return 0
end

local function getFlightProgress(p: number, p2: number, p3: number)
	return (p * p2 + p3) % 1
end

local function getSeagullPosition(p: number, p2: number)
	local v = p * -1.3 + 1.2
	local v2 = p * -1.2000000000000002 + 1.1 + p2
	return UDim2.fromScale(v, v2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getSeagullFade(p: number)
	if p < 0.12 then
		return 1 - p / 0.12
	end

	if p > 0.88 then
		return (p - 0.88) / 0.12
	end

	return 0
end

local createElement = React.createElement
return function()
	local v, v2 = React.useBinding(0)
	local v3, v4 = React.useBinding(false)
	local v5, v6 = React.useBinding(0)
	local v7, v8 = React.useBinding(0)
	React.useEffect(function()
		local flag = false
		task.spawn(function()
			local total = 0

			while flag == false do
				local v9 = task.wait()

				if flag then
					break
				end

				total += v9
				local value = v7:getValue()

				if value > 0 then
					v8((math.max(value - v9, 0)))
				end

				v2(total)
			end
		end)
		return function()
			flag = true
		end
	end, {})
	return createElement(React.Fragment, {}, {
		bottomRight = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.660671, 0.529306),
			ZIndex = -9999
		}, {
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://96772976207126",
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			}, {
				uIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 112, 227)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 208, 255))
					}),
					Rotation = 90
				})
			}),
			sandBeach = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://75647669161889",
				ImageColor3 = Color3.fromRGB(231, 231, 231),
				Position = UDim2.fromScale(1, 1),
				Size = UDim2.fromScale(0.706149, 0.322107)
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 4.64234
				})
			}),
			crab = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://130384283105131",
				ImageColor3 = Color3.fromRGB(212, 212, 212),
				Position = v:map(function(p: number)
					local uDim = UDim2.fromScale(0.564291, 0.814556)
					local uDim2 = UDim2.fromScale(0.709, 0.721)
					local v14 = p % 16
					local v15 = 0

					if v14 >= 2 and v14 <= 5 then
						v15 = (v14 - 2) / 3
					elseif v14 > 5 and v14 < 10 then
						v15 = 1
					elseif v14 >= 10 and v14 <= 13 then
						v15 = 1 - (v14 - 10) / 3
					end

					return uDim:Lerp(uDim2, v15)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.105094, 0.150386)
			}),
			sandCastle = createElement("ImageButton", {
				Active = false,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://97802959782489",
				ImageColor3 = Color3.fromRGB(212, 212, 212),
				ImageRectSize = Vector2.new(300, 305),
				ImageRectOffset = v3:map(function(flag: boolean)
					if flag then
						return (Vector2.new(300, 0))
					end

					return Vector2.zero
				end),
				Rotation = v7:map(function(p: number)
					local v16 = 1 - p / 0.5
					return math.sin(v16 * 25) * 5 * (1 - v16)
				end),
				Position = UDim2.fromScale(0.805, 0.49),
				Selectable = false,
				Size = UDim2.fromScale(0.192649, 0.399371),
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.MouseButton1Click] = function()
					if v3:getValue() == false then
						local value = v5:getValue()

						if value < 2 then
							v6(value + 1)
							v8(0.5)
						elseif value == 2 then
							v6(0)
							v8(0.5)
							task.delay(0.15, v4, true)
							task.delay(3, v4, false)
						end
					end
				end
			})
		}),
		topRight = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ClipsDescendants = true,
			Position = UDim2.fromScale(1, 0.0940001),
			Size = UDim2.fromScale(0.623085, 0.555291),
			ZIndex = -9999
		}, {
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://70789151946758",
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			}, {
				uIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 112, 227)),
						ColorSequenceKeypoint.new(0.360967, Color3.fromRGB(49, 209, 255)),
						ColorSequenceKeypoint.new(0.671848, Color3.fromRGB(247, 253, 255)),
						ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PALETTE.WHITE)
					}),
					Rotation = 90
				})
			}),
			seagull2 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://95630211844564",
				ImageColor3 = Color3.fromRGB(5, 30, 50),
				ImageTransparency = v:map(function(p: number)
					return getSeagullFade((p * 0.08 + 0.4) % 1)
				end),
				Position = v:map(function(p: number)
					return getSeagullPosition((p * 0.08 + 0.4) % 1, -0.18)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.0850761, 0.122458),
				ZIndex = 999
			}),
			seagull3 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://140241424960821",
				ImageColor3 = Color3.fromRGB(7, 44, 75),
				ImageTransparency = v:map(function(p: number)
					return getSeagullFade((p * 0.05 + 0.7) % 1)
				end),
				Position = v:map(function(p: number)
					return getSeagullPosition((p * 0.05 + 0.7) % 1, 0.2)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.149356, 0.122458),
				ZIndex = 999
			}),
			cloud1 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://123844062188147",
				ImageTransparency = v:map(function(p: number)
					local driftX = getDriftX(p, 0.05, 0)

					if driftX >= 0.85 then
						return (driftX - 0.85) / 0.2500000000000001
					end

					if driftX <= 0.55 then
						return (0.55 - driftX) / 0.65
					end

					return 0
				end),
				Position = v:map(function(p: number)
					return UDim2.fromScale(getDriftX(p, 0.05, 0), -0.242962)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.502894, 0.428604),
				ZIndex = -2
			}, {
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0)
					})
				})
			}),
			windLine1 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://77467881234417",
				ImageTransparency = v:map(function(p: number)
					local driftX = getDriftX(p, 0.18, 0)
					local v16

					if driftX >= 0.85 then
						v16 = (driftX - 0.85) / 0.2500000000000001
					else
						v16 = not (driftX <= 0.1) and 0 or (0.1 - driftX) / 0.2
					end

					return v16 * 0.39 + 0.61
				end),
				Position = v:map(function(p: number)
					return UDim2.fromScale(getDriftX(p, 0.18, 0), 0.0402939)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.533144, 0.244917),
				ZIndex = -2
			}),
			windLine12 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://137321152518752",
				ImageTransparency = v:map(function(p: number)
					local driftX = getDriftX(p, 0.18, 0.6)
					local v16

					if driftX >= 0.85 then
						v16 = (driftX - 0.85) / 0.2500000000000001
					else
						v16 = not (driftX <= 0.1) and 0 or (0.1 - driftX) / 0.2
					end

					return v16 * 0.39 + 0.61
				end),
				Position = v:map(function(p: number)
					return UDim2.fromScale(getDriftX(p, 0.18, 0.6), 0.187964)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.533144, 0.244917),
				ZIndex = -2
			}),
			palmTreeGroup = createElement("CanvasGroup", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
			}, {
				palmTreePivot = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(1.07, 1.057977),
					Size = UDim2.fromScale(0.546756, 1.041616),
					ZIndex = 10,
					Rotation = v:map(function(p: number)
						return (math.sin(p * 0.2 + 0.15) * 0.3 + 0.7) * 3 * (math.sin(p * 1 + 0.15) * 0.6 + math.sin(p * 2.3 + 0.255) * 0.3 + math.sin(p * 4.7 + 0.075) * 0.1)
					end)
				}, {
					palmTree = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(1, 1),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://139722472654485",
						ImageColor3 = Color3.fromRGB(193, 223, 255),
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromScale(1, 1),
						ZIndex = CONSTANTS.LAYER.RAISED
					}, {
						uIGradient = createElement("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.75, 0),
								NumberSequenceKeypoint.new(0.9, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						})
					}),
					coconut = createElement("ImageLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://126922505797346",
						ImageColor3 = Color3.fromRGB(197, 197, 197),
						ImageTransparency = v:map(function(p: number)
							local v16 = p % 5

							if v16 >= 2.3 and v16 < 2.6 then
								return (v16 - 2.3) / 0.30000000000000027
							end

							if v16 >= 2.6 and v16 < 4 then
								return 1
							end

							if v16 >= 4 and v16 < 4.5 then
								return 1 - (v16 - 4) / 0.5
							end

							return 0
						end),
						Position = v:map(function(p: number)
							local v16 = p % 5

							if v16 < 2 or v16 >= 2.6 then
								return UDim2.fromScale(-0.17098, -0.20779)
							end

							local v17 = (v16 - 2) / 0.6000000000000001
							return UDim2.fromScale(-0.17098, v17 * 0.70779 * v17 + -0.20779)
						end),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromScale(0.169433, 0.169433),
						ZIndex = CONSTANTS.LAYER.CONTENT
					}),
					coconut2 = createElement("ImageLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://126922505797346",
						ImageColor3 = Color3.fromRGB(197, 197, 197),
						Position = UDim2.fromScale(-0.0393, -0.28844),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromScale(0.169433, 0.169433),
						ZIndex = CONSTANTS.LAYER.CONTENT
					})
				})
			}),
			cloud2 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://87892047073172",
				ImageTransparency = v:map(function(p: number)
					local driftX = getDriftX(p, 0.035, 0.95)
					local v16

					if driftX >= 0.85 then
						v16 = (driftX - 0.85) / 0.2500000000000001
					else
						v16 = not (driftX <= 0.85) and 0 or (0.85 - driftX) / 0.95
					end

					return v16 * 0.7 + 0.3
				end),
				Position = v:map(function(p: number)
					return UDim2.fromScale(getDriftX(p, 0.035, 0.95), 0.2)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.281696, 0.262925),
				ZIndex = -2
			}, {
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0)
					})
				})
			}),
			seagull1 = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://105116914942539",
				ImageColor3 = Color3.fromRGB(5, 30, 50),
				ImageTransparency = v:map(function(p: number)
					return getSeagullFade((p * 0.06 + 0) % 1)
				end),
				Position = v:map(function(p: number)
					return getSeagullPosition((p * 0.06 + 0) % 1, 0)
				end),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.160699, 0.118857),
				ZIndex = -10
			})
		})
	})
end