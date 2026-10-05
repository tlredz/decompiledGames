local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Preloader = require(ReplicatedStorage._FRAMEWORK.Features.Preloader)
local SoundManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.SoundManager)
local create = Vide.create
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(180, 114, 255)
local uDim = UDim2.fromScale(0.5, 2)
local uDim2 = UDim2.fromScale(2, 0.5)
local tweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v = {
	Color3.fromRGB(180, 114, 255),
	Color3.fromRGB(203, 158, 255),
	Color3.fromRGB(150, 58, 255),
	Color3.fromRGB(160, 61, 190),
	Color3.fromRGB(134, 29, 255)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getBarProgress(p, callback, p2: number)
	return TweenService:GetValue(
		math.clamp((callback() - math.min(p.delay() + p2, 0.85)) / p.duration(), 0, 1),
		tweenInfo2.EasingStyle,
		tweenInfo2.EasingDirection
	)
end

local function createBarLayer(item, callback, p, p2: number?)
	local v2 = p2 ~= nil
	local v3 = not p2 and 0 or p2 * 0.035
	local v4 = create("Frame")
	local v5 = {
		Name = not p2 and "BlackBar" or `ColorTrail{p2}`,
		AnchorPoint = function()
			if item.exitsLeft() then
				return (Vector2.new(0, 0))
			end

			return (Vector2.new(1, 0))
		end,
		Position = function()
			return UDim2.fromScale(item.exitsLeft() and 0 or 1, item.yPosition)
		end,
		Size = function()
			local v8 = 1 - getBarProgress(item, callback, v3)
			local v9 = not v2 and 0 or v8 * 0.018
			return UDim2.fromScale(math.min(v8 + v9, 1), item.height)
		end,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Visible = 0,
		ZIndex = 0
	}
	local backgroundColor

	if p2 then
		backgroundColor = item.trailColors[p2]
	else
		backgroundColor = Color3.new(0, 0, 0)
	end

	v5.BackgroundColor3 = backgroundColor
	v5.BackgroundTransparency = v2 and function()
		return (math.clamp(getBarProgress(item, callback, v3) * 1.2, 0, 1))
	end or 0
	v5.Visible = not v2 or p
	v5.ZIndex = v2 and 2 or 3
	return v4(v5)
end

local function createGlitchBars(items, source, source2)
	local result = {}

	for _, item in items do
		table.insert(result, createBarLayer(item, source, source2, 3))
		table.insert(result, createBarLayer(item, source, source2, 2))
		table.insert(result, createBarLayer(item, source, source2, 1))
		table.insert(result, createBarLayer(item, source, source2, nil))
	end

	return result
end

local function randomizeBars(items, random)
	for _, item in items do
		item.delay(random:NextNumber(0, 0.28))
		item.duration(random:NextNumber(0.48, 0.72))
		item.exitsLeft(random:NextInteger(0, 1) == 0)
		item.trailColors[1](v[random:NextInteger(1, #v)])
		item.trailColors[2](v[random:NextInteger(1, #v)])
		item.trailColors[3](v[random:NextInteger(1, #v)])
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadFlareImage()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://112337977005460"
	Preloader.preload(imageLabel)
	imageLabel:Destroy()
end

return {
	mount = function(playerGui)
		SoundManager.preloadSound("AdminAbuse.FabAA.Transition.ON")
		SoundManager.preloadSound("AdminAbuse.FabAA.Transition.OFF")
		preloadFlareImage() -- equivalent call inferred; original call site unknown
		local source = Vide.source(1)
		local source2 = Vide.source(false)
		local source3 = Vide.source(color2)
		local source4 = Vide.source(uDim2)
		local source5 = Vide.source(1)
		local source6 = Vide.source(false)
		local source7 = Vide.source(false)
		local random = Random.new()
		local v2 = {}
		local v3 = nil
		local v4 = false
		local count = 0

		for i = 1, 23 do
			table.insert(v2, {
				yPosition = (i - 1) / 23,
				height = 0.04647826086956522,
				delay = Vide.source(0),
				duration = Vide.source(1),
				exitsLeft = Vide.source(i % 2 == 0),
				trailColors = { Vide.source(v[1]), Vide.source(v[2]), Vide.source(v[3]) }
			})
		end

		local v5 = Vide.mount(function()
			local v6 = create("Frame")({
				Name = "BlackScreen",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = source7,
				create("Frame")({
					Name = "BlackBackdrop",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = function()
						return (math.clamp(source() * 4, 0, 1))
					end,
					BorderSizePixel = 0,
					ZIndex = 1
				}),
				create("Frame")({
					Name = "EntranceFlareContainer",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Visible = source6,
					ZIndex = 4,
					create("UIAspectRatioConstraint")({
						AspectRatio = 1,
						DominantAxis = Enum.DominantAxis.Height
					}),
					create("ImageLabel")({
						Name = "EntranceFlare",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = source4,
						BackgroundTransparency = 1,
						Image = "rbxassetid://112337977005460",
						ImageColor3 = source3,
						ImageTransparency = source5,
						ScaleType = Enum.ScaleType.Stretch,
						ZIndex = 4
					})
				}),
				table.unpack((createGlitchBars(v2, source, source2)))
			})

			if playerGui:IsA("PlayerGui") then
				return create("ScreenGui")({
					Name = "FabBossEventTransition",
					ClipToDeviceSafeArea = false,
					DisplayOrder = 3000000,
					IgnoreGuiInset = true,
					ResetOnSpawn = false,
					ScreenInsets = Enum.ScreenInsets.None,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					Vide.action(function(p)
						v3 = p
					end),
					v6
				})
			end

			return create("Frame")({
				Name = "FabBossEventTransitionPreview",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ClipsDescendants = false,
				Vide.action(function(p)
					v3 = p
				end),
				v6
			})
		end, playerGui)
		return {
			setVisible = function(flag: boolean)
				if not v4 then
					count += 1
					local v6 = count

					if flag then
						SoundManager.playLocal("AdminAbuse.FabAA.Transition.ON", 2, 0)
						randomizeBars(v2, random)
						source2(false)
						source(0)
						source3(color)
						source4(uDim)
						source5(0)
						source6(true)
						source7(true)
						task.spawn(function()
							local lastTime = os.clock()

							while not v4 and v6 == count do
								local v7 = math.clamp((os.clock() - lastTime) / tweenInfo.Time, 0, 1)
								local value = TweenService:GetValue(
									v7,
									tweenInfo.EasingStyle,
									tweenInfo.EasingDirection
								)
								source3(color:Lerp(color2, value))
								source4(uDim:Lerp(uDim2, value))
								source5(value)

								if v7 >= 1 then
									source6(false)
									break
								else
									task.wait()
								end
							end
						end)
					else
						SoundManager.playLocal("AdminAbuse.FabAA.Transition.OFF", 1, 0)
						source6(false)
						source2(true)
						local v7 = source()
						local lastTime = os.clock()
						task.spawn(function()
							while not v4 and v6 == count do
								local v8 = math.clamp((os.clock() - lastTime) / tweenInfo2.Time, 0, 1)
								source(v7 + (1 - v7) * v8)

								if v8 >= 1 then
									source2(false)
									source7(false)
									break
								else
									task.wait()
								end
							end
						end)
					end
				end
			end,
			destroy = function()
				if not v4 then
					v4 = true
					count += 1
					v5()
					local v6 = v3

					if v6 then
						v6:Destroy()
						v3 = nil
					end
				end
			end
		}
	end
}