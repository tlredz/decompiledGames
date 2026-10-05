local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local MaskIcons = require(ReplicatedStorage.Modules.ClientUI.MaskIcons)
local MessagePacingCore = require(ReplicatedStorage.Modules.ClientUI.MessagePacingCore)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local sine = Enum.EasingStyle.Sine
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v = {
	Treat = {
		text = Color3.fromRGB(0, 255, 133),
		stroke = Color3.fromRGB(5, 48, 19)
	},
	Trick = {
		text = Color3.fromRGB(255, 67, 0),
		stroke = Color3.fromRGB(48, 7, 5)
	}
}
local tweenInfo5 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v2 = {
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 150, 40),
	Color3.fromRGB(255, 230, 50),
	Color3.fromRGB(60, 220, 90),
	Color3.fromRGB(60, 150, 255),
	Color3.fromRGB(110, 70, 230),
	Color3.fromRGB(200, 90, 255)
}
local tweenInfo7 = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.1)
local v3 = {
	{
		name = "MaskRevealPaper",
		soundId = "rbxassetid://114135412361443",
		volume = 0.25,
		lead = 0.3
	},
	{
		name = "MaskRevealBats",
		soundId = "rbxassetid://138813594792532",
		volume = 0.25,
		lead = 0.8
	}
}
local v4 = 0

for _, v5 in ipairs(v3) do
	local lead = v5.lead
	v4 = math.max(v4, lead)
end

local tweenInfo8 = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo9 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo10 = TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo11 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo12 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo13 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo14 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v5 = {
	StealthRank = "StealthFrame",
	StaminaRank = "StaminaFrame",
	SkillCheckRank = "SkillCheckFrame",
	DecodeRank = "DecodeSpeedFrame",
	SpeedRank = "SpeedFrame"
}
local count = 0
local object = setmetatable({}, {
	__mode = "k"
})

local function findTemplate(instance, childName, ancestor)
	local guiObjectsByChildName = object[instance]

	if not guiObjectsByChildName then
		guiObjectsByChildName = {}
		object[instance] = guiObjectsByChildName
	end

	local v6 = guiObjectsByChildName[childName]

	if v6 then
		return v6
	end

	local guiObject = instance:FindFirstChild(childName, true)

	if not guiObject then
		return nil
	end

	local v7

	if ancestor == nil then
		v7 = false
	else
		v7 = guiObject:IsDescendantOf(ancestor)
	end

	if guiObject:IsA("GuiObject") and not v7 then
		guiObject.Visible = false
	end

	guiObjectsByChildName[childName] = guiObject
	return guiObject
end

local function resolve()
	local trickOrTreatFeed = playerGui:FindFirstChild("TrickOrTreatFeed")
	local feed = trickOrTreatFeed and trickOrTreatFeed:FindFirstChild("Feed")

	if not feed then
		return nil
	end

	local v6 = object[trickOrTreatFeed]

	if not v6 then
		v6 = {}
		object[trickOrTreatFeed] = v6
	end

	local toast = v6.Toast

	if not toast then
		toast = trickOrTreatFeed:FindFirstChild("Toast", true)

		if toast then
			if toast:IsA("GuiObject") then
				toast.Visible = false
			end

			v6.Toast = toast
		else
			toast = nil
		end
	end

	if toast then
		return feed, toast
	end

	return nil
end

local v6 = {}

local function voteIconFor(toon)
	if type(toon) ~= "string" then
		return nil
	end

	if v6[toon] ~= nil then
		return v6[toon] or nil
	end

	local tower = TowerLUT:GetTower(toon)
	local success, result = pcall(require, tower)
	local v7 = v6
	local v8

	if success and type(result) == "table" then
		v8 = result.VoteIcon or false
	else
		v8 = false
	end

	v7[toon] = v8
	return v6[toon] or nil
end

local function marginScale(instance)
	local margin = instance:FindFirstChild("Margin", true) or instance
	local v7 = margin:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Parent = margin
	end

	return v7
end

local function playGlow(parent, imageTransparency)
	local v7 = parent:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Parent = parent
	end

	parent.ImageTransparency = 1
	v7.Scale = 1
	local tween = TweenService:Create(parent, tweenInfo5, {
		ImageTransparency = imageTransparency
	})
	tween:Play()
	tween.Completed:Wait()

	if not parent.Parent then
		return
	end

	local tween2 = TweenService:Create(parent, tweenInfo6, {
		ImageTransparency = 1
	})
	tween2:Play()
	TweenService:Create(v7, tweenInfo6, {
		Scale = 1.5
	}):Play()
	tween2.Completed:Wait()
end

local function playRainbowGlow(glow, imageTransparency)
	glow.ImageTransparency = 1

	for i, imageColor in ipairs(v2) do
		local clone = glow:Clone()
		clone.Name = "RainbowGlow" .. i
		clone.ImageColor3 = imageColor
		clone.ImageTransparency = 1
		clone.Parent = glow.Parent
		task.delay((i - 1) * 0.07, function()
			if clone.Parent then
				playGlow(clone, imageTransparency)
			end

			clone:Destroy()
		end)
	end
end

local function flashGlow(instance, p)
	local glow = instance:FindFirstChild("Glow", true)

	if not (glow and glow:IsA("ImageLabel")) then
		return
	end

	local imageTransparency = glow.ImageTransparency

	if p == "Rainbow" then
		playRainbowGlow(glow, imageTransparency)
	else
		playGlow(glow, imageTransparency)
	end
end

local function offscreenShift(instance)
	local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")
	local currentCamera = workspace.CurrentCamera
	local v7

	if layerCollector then
		v7 = layerCollector.AbsoluteSize.X
	else
		v7 = not currentCamera and 1920 or currentCamera.ViewportSize.X
	end

	return math.max(v7 - instance.AbsolutePosition.X, 0) + 20
end

local function slideIn(clone, parent, tweenInfo15)
	clone:SetAttribute("SlideOut", true)
	clone.Parent = parent
	local position = clone.Position
	local layerCollector = clone:FindFirstAncestorWhichIsA("LayerCollector")
	local currentCamera = workspace.CurrentCamera
	local v7

	if layerCollector then
		v7 = layerCollector.AbsoluteSize.X
	else
		v7 = not currentCamera and 1920 or currentCamera.ViewportSize.X
	end

	clone.Position = position + UDim2.fromOffset(math.max(v7 - clone.AbsolutePosition.X, 0) + 20, 0)
	TweenService:Create(clone, tweenInfo15, {
		Position = position
	}):Play()
end

local function dissolve(clone)
	if clone:GetAttribute("Leaving") or not clone.Parent then
		return
	end

	clone:SetAttribute("Leaving", true)

	if clone:GetAttribute("SlideOut") then
		local position = clone.Position
		local layerCollector = clone:FindFirstAncestorWhichIsA("LayerCollector")
		local currentCamera = workspace.CurrentCamera
		local v7

		if layerCollector then
			v7 = layerCollector.AbsoluteSize.X
		else
			v7 = not currentCamera and 1920 or currentCamera.ViewportSize.X
		end

		local tween = TweenService:Create(clone, tweenInfo3, {
			Position = position + UDim2.fromOffset(math.max(v7 - clone.AbsolutePosition.X, 0) + 20, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		clone:Destroy()
	else
		local margin = clone:FindFirstChild("Margin", true) or clone
		local v7 = margin:FindFirstChildOfClass("UIScale")

		if not v7 then
			v7 = Instance.new("UIScale")
			v7.Parent = margin
		end

		if v7 then
			local tween = TweenService:Create(v7, tweenInfo4, {
				Scale = 0
			})
			tween:Play()
			tween.Completed:Wait()
		end

		clone:Destroy()
	end
end

local function liveToasts(feed)
	local children = {}

	for _, child in ipairs(feed:GetChildren()) do
		if child.Name:sub(1, 6) ~= "Toast_" or child:GetAttribute("Leaving") then
			continue
		end

		table.insert(children, child)
	end

	table.sort(children, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	return children
end

local function push(data)
	if type(data) ~= "table" or type(data.label) ~= "string" then
		return
	end

	local v7 = data.pool == "Trick" and "Trick" or "Treat"
	local trickOrTreatFeed = playerGui:FindFirstChild("TrickOrTreatFeed")
	local feed = trickOrTreatFeed and trickOrTreatFeed:FindFirstChild("Feed")
	local toast

	if feed then
		local v8 = object[trickOrTreatFeed]

		if not v8 then
			v8 = {}
			object[trickOrTreatFeed] = v8
		end

		toast = v8.Toast

		if not toast then
			toast = trickOrTreatFeed:FindFirstChild("Toast", true)

			if toast then
				if toast:IsA("GuiObject") then
					toast.Visible = false
				end

				v8.Toast = toast
			else
				toast = nil
			end
		end

		if not toast then
			feed = nil
			toast = nil
		end
	else
		feed = nil
	end

	if not feed then
		warn("[TrickOrTreatFeed] PlayerGui.TrickOrTreatFeed is missing its Feed or Toast template")
		return
	end

	count += 1
	local clone = toast:Clone()
	clone.Name = ("%s%06d"):format("Toast_", count)
	clone.LayoutOrder = count
	clone.Visible = true
	local outcome = clone:FindFirstChild("Outcome", true)

	if outcome and outcome:IsA("TextLabel") then
		local v8 = v[v7]
		local label = tostring(data.label)
		outcome.Text = ("%s! %s%s"):format(v7, label, label:match("[!?.]$") and "" or "!")
		outcome.TextColor3 = v8.text
		local uIStroke = outcome:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Color = v8.stroke
		end
	end

	local voteIcon = clone:FindFirstChild("VoteIcon", true)

	if voteIcon and voteIcon:IsA("ImageLabel") then
		local v8 = voteIconFor(data.toon)
		voteIcon.Image = v8 or ""
		voteIcon.Visible = v8 ~= nil
	end

	local margin = clone:FindFirstChild("Margin", true) or clone
	local v8 = margin:FindFirstChildOfClass("UIScale")

	if not v8 then
		v8 = Instance.new("UIScale")
		v8.Parent = margin
	end

	if v8 then
		v8.Scale = 0
	end

	clone.Parent = feed

	if v8 then
		TweenService:Create(v8, tweenInfo, {
			Scale = 1
		}):Play()
	end

	task.spawn(flashGlow, clone, data.glow)
	local v9 = liveToasts(feed)

	for i = 1, #v9 - 3 do
		task.spawn(dissolve, v9[i])
	end

	task.delay(6, dissolve, clone)
end

local clones = {}

local function fillStarBar(instance, p)
	local starBar = instance and instance:FindFirstChild("StarBar")

	if not starBar then
		return
	end

	local images = {}

	for _, image in ipairs(starBar:GetChildren()) do
		if image:IsA("ImageLabel") then
			table.insert(images, image)
		end
	end

	table.sort(images, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	for i, v7 in ipairs(images) do
		v7.Visible = i <= p
	end
end

local function fillStats(instance, p)
	if type(p.stars) == "table" then
		for _, star in ipairs(p.stars) do
			local v7

			if type(star) == "table" then
				v7 = v5[star.key]
			else
				v7 = false
			end

			if v7 then
				fillStarBar(instance:FindFirstChild(v7, true), tonumber(star.to) or 0)
			end
		end
	end

	fillStarBar(instance:FindFirstChild("HealthFrame", true), tonumber(p.health) or 0)
end

local function swipeMask(p)
	local v7 = p - 0.06
	local v8 = p + 0.06

	local function at(p2)
		if p2 <= v7 then
			return 0
		end

		if v8 <= p2 then
			return 1
		end

		return (p2 - v7) / (v8 - v7)
	end

	local numberSequenceKeypoints = { NumberSequenceKeypoint.new(
			0,
			v7 >= 0 and 0 or v8 <= 0 and 1 or (0 - v7) / (v8 - v7)
		) }

	for _, v9 in ipairs({ v7, v8 }) do
		if v9 > 0 and v9 < 1 then
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(v9, v9 <= v7 and 0 or v8 <= v9 and 1 or (v9 - v7) / (v8 - v7))
			)
		end
	end

	table.insert(
		numberSequenceKeypoints,
		NumberSequenceKeypoint.new(1, v7 >= 1 and 0 or v8 <= 1 and 1 or (1 - v7) / (v8 - v7))
	)
	return NumberSequence.new(numberSequenceKeypoints)
end

local function swipeTarget(parent)
	local uIGradient = parent:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		local v7 = {
			Transparency = uIGradient.Transparency,
			Rotation = uIGradient.Rotation,
			Offset = uIGradient.Offset
		}
		uIGradient.Rotation = 0
		uIGradient.Offset = Vector2.zero
		return uIGradient, function()
			for k, v8 in pairs(v7) do
				uIGradient[k] = v8
			end
		end
	else
		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Name = "VerseSwipe"
		uIGradient2.Color = ColorSequence.new(Color3.new(1, 1, 1))
		uIGradient2.Parent = parent
		return uIGradient2, function()
			uIGradient2:Destroy()
		end
	end
end

local function prepareVerseSwipe(outcome)
	local v7 = { outcome, (outcome:FindFirstChildOfClass("UIStroke")) }
	local v8 = {}

	for _, v9 in ipairs(v7) do
		local gradient, restore = swipeTarget(v9)
		gradient.Transparency = swipeMask(-0.12)
		table.insert(v8, {
			gradient = gradient,
			restore = restore
		})
	end

	return function()
		local lastTime = os.clock()
		local time = tweenInfo10.Time

		while true do
			local v9 = math.min((os.clock() - lastTime) / time, 1)
			local transparency = swipeMask(-0.12 + TweenService:GetValue(
				v9,
				tweenInfo10.EasingStyle,
				tweenInfo10.EasingDirection
			) * 1.24)

			for _, v11 in ipairs(v8) do
				if v11.gradient.Parent then
					v11.gradient.Transparency = transparency
				end
			end

			if v9 >= 1 or not outcome.Parent then
				for _, v11 in ipairs(v8) do
					v11.restore()
				end

				break
			else
				RunService.RenderStepped:Wait()
			end
		end
	end
end

local function unfoldBackground(background)
	local size = background.Size
	local position = background.Position
	local v7 = 0.5 - background.AnchorPoint.X
	local v8 = size.X.Scale * 0.96
	local uDim = UDim2.new(size.X.Scale, size.X.Offset, 1, size.Y.Offset)
	background.Size = UDim2.new(size.X.Scale - v8, size.X.Offset, 1, size.Y.Offset)
	background.Position = UDim2.new(position.X.Scale + v8 * v7, position.X.Offset, position.Y.Scale, position.Y.Offset)
	TweenService:Create(background, tweenInfo7, {
		Size = uDim,
		Position = position
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRevealSound(data)
	local success, result = pcall(function()
		local sound = Instance.new("Sound")
		sound.Name = data.name
		sound.SoundId = data.soundId
		sound.Volume = data.volume
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		sound:Play()
		Debris:AddItem(sound, 30)
	end)

	if not success then
		warn("[TrickOrTreatFeed] reveal sound " .. data.name .. " failed: " .. tostring(result))
	end
end

local function playRevealSoundsNow(soundsPlayed)
	for _, v7 in ipairs(v3) do
		if soundsPlayed[v7.name] then
			continue
		end

		soundsPlayed[v7.name] = true
		task.delay(v4 - v7.lead, playRevealSound, v7)
	end
end

local function burstParticles(folder)
	local emitters = {}

	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		table.insert(emitters, emitter)
	end

	if #emitters == 0 then
		return
	end

	task.delay(0.6, function()
		for _, v7 in ipairs(emitters) do
			if v7.Parent then
				v7.Enabled = false
			end
		end
	end)
end

local function colorIn(image, p)
	if not image:IsA("ImageLabel") then
		return
	end

	local imageColor = p or image.ImageColor3
	image.ImageColor3 = Color3.new(0, 0, 0)
	TweenService:Create(image, tweenInfo9, {
		ImageColor3 = imageColor
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function swingMask(maskSwing)
	maskSwing.Rotation = -22
	TweenService:Create(maskSwing, tweenInfo8, {
		Rotation = 20
	}):Play()
end

local function popIn(instance, name)
	count += 1
	local clone = instance:Clone()
	clone.Name = name
	clone.LayoutOrder = count
	clone.Visible = true
	return clone
end

local function allStars(folder)
	local images = {}

	for _, image in ipairs(folder:GetDescendants()) do
		local parent = image.Parent

		if image:IsA("ImageLabel") and parent and parent.Name == "StarBar" then
			table.insert(images, image)
		end
	end

	return images
end

local function heartsPastCap(canvasGroup)
	local healthFrame = canvasGroup:FindFirstChild("HealthFrame", true)
	local starBar = healthFrame and healthFrame:FindFirstChild("StarBar")

	if not starBar then
		return {}
	end

	local images = {}

	for _, image in ipairs(starBar:GetChildren()) do
		if image:IsA("ImageLabel") then
			table.insert(images, image)
		end
	end

	table.sort(images, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	local result = {}

	for i = 4, #images do
		result[images[i]] = true
	end

	return result
end

local function startPossession(canvasGroup)
	local v7 = heartsPastCap(canvasGroup)
	local imageTransparencies = {}
	local v8 = {}

	for _, v9 in ipairs((allStars(canvasGroup))) do
		if v7[v9] then
			v9.Visible = false
		else
			imageTransparencies[v9] = v9.ImageTransparency
			v9.Visible = true
			table.insert(v8, v9)
		end
	end

	local v9 = canvasGroup:IsA("CanvasGroup") and canvasGroup or nil

	if v9 then
		v9.GroupTransparency = 1
		TweenService:Create(v9, tweenInfo13, {
			GroupTransparency = 0.5
		}):Play()
	end

	local v10 = true
	task.spawn(function()
		while v10 and canvasGroup.Parent do
			for _, v11 in ipairs(v8) do
				v11.ImageTransparency = not (math.random() < 0.5) and 1 or imageTransparencies[v11]
			end

			if v9 then
				local v11 = math.random(35, 110)
				v9.GroupColor3 = Color3.fromRGB(v11, v11, v11)
			end

			task.wait(0.07)
		end
	end)
	return function()
		if not v10 then
			return
		end

		v10 = false

		for _, v11 in ipairs(v8) do
			v11.ImageTransparency = imageTransparencies[v11]
		end
	end
end

local function settleStats(canvasGroup, p)
	local margin = canvasGroup:FindFirstChild("Margin", true) or canvasGroup
	local v7 = margin:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Parent = margin
	end

	local scale = v7.Scale
	local tween = TweenService:Create(v7, tweenInfo11, {
		Scale = scale * 1.15
	})
	tween:Play()
	tween.Completed:Wait()
	fillStats(canvasGroup, p)
	TweenService:Create(v7, tweenInfo12, {
		Scale = scale
	}):Play()

	if canvasGroup:IsA("CanvasGroup") then
		TweenService:Create(canvasGroup, tweenInfo14, {
			GroupColor3 = Color3.fromRGB(255, 255, 255),
			GroupTransparency = 0
		}):Play()
	end
end

local function possessThenSettle(p, p2, callback)
	local v7 = startPossession(p)
	local v8 = os.clock() + 1.3

	while os.clock() < v8 and callback() do
		task.wait(0.07)
	end

	v7()

	if callback() then
		settleStats(p, p2)
	else
		fillStats(p, p2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showPopped(clone, parent)
	local margin = clone:FindFirstChild("Margin", true) or clone
	local v7 = margin:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Parent = margin
	end

	v7.Scale = 0
	clone.Parent = parent
	TweenService:Create(v7, tweenInfo, {
		Scale = 1
	}):Play()
end

local function clearLiveMaskFrames()
	for _, v7 in ipairs(clones) do
		task.spawn(dissolve, v7)
	end

	table.clear(clones)
end

local v7 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function dropPendingStats()
	if not v7 then
		return
	end

	v7.stop()
	task.spawn(dissolve, v7.stats)
	v7 = nil
end

local function pushMaskIntro(p)
	local trickOrTreatFeed = playerGui:FindFirstChild("TrickOrTreatFeed")
	local maskResult

	if trickOrTreatFeed then
		local v8 = object[trickOrTreatFeed]

		if not v8 then
			v8 = {}
			object[trickOrTreatFeed] = v8
		end

		maskResult = v8.MaskResult

		if not maskResult then
			maskResult = trickOrTreatFeed:FindFirstChild("MaskResult", true)

			if maskResult then
				if maskResult:IsA("GuiObject") then
					maskResult.Visible = false
				end

				v8.MaskResult = maskResult
			else
				maskResult = nil
			end
		end
	else
		maskResult = trickOrTreatFeed
	end

	local stats

	if trickOrTreatFeed then
		local v8 = object[trickOrTreatFeed]

		if not v8 then
			v8 = {}
			object[trickOrTreatFeed] = v8
		end

		stats = v8.Stats

		if not stats then
			stats = trickOrTreatFeed:FindFirstChild("Stats", true)

			if stats then
				local v9

				if maskResult == nil then
					v9 = false
				else
					v9 = stats:IsDescendantOf(maskResult)
				end

				if stats:IsA("GuiObject") and not v9 then
					stats.Visible = false
				end

				v8.Stats = stats
			else
				stats = nil
			end
		end
	else
		stats = trickOrTreatFeed
	end

	if not stats or maskResult and stats:IsDescendantOf(maskResult) then
		return
	end

	clearLiveMaskFrames()
	dropPendingStats() -- equivalent call inferred; original call site unknown
	local v8 = math.max(tonumber(p.seconds) or tweenInfo2.Time, tweenInfo2.Time)
	count += 1
	local clone = stats:Clone()
	clone.Name = "MaskStats_Live"
	clone.LayoutOrder = count
	clone.Visible = true
	slideIn(clone, stats.Parent, TweenInfo.new(v8, sine, Enum.EasingDirection.Out))
	local v9 = {
		stats = clone,
		stop = startPossession(clone),
		arrivesAt = os.clock() + v8
	}
	v7 = v9
	v9.soundsPlayed = {}

	for _, v10 in ipairs(v3) do
		local v11 = v10
		task.delay(math.max(v8 - v10.lead, 0), function()
			if clone.Parent and not (clone:GetAttribute("Leaving") or v9.soundsPlayed[v11.name]) then
				v9.soundsPlayed[v11.name] = true
				playRevealSound(v11) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	print(("[TrickOrTreatFeed] mask intro: stats possessed for the %.2fs spin"):format(v8))
	local v10 = v8 + 3
	task.delay(v10, function()
		if v7 == v9 then
			warn("[TrickOrTreatFeed] mask intro had no reveal after " .. v10 .. "s; clearing the stats")
			dropPendingStats() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function pushMask(p)
	local trickOrTreatFeed = playerGui:FindFirstChild("TrickOrTreatFeed")
	local maskResult

	if trickOrTreatFeed then
		local v8 = object[trickOrTreatFeed]

		if not v8 then
			v8 = {}
			object[trickOrTreatFeed] = v8
		end

		maskResult = v8.MaskResult

		if not maskResult then
			maskResult = trickOrTreatFeed:FindFirstChild("MaskResult", true)

			if maskResult then
				if maskResult:IsA("GuiObject") then
					maskResult.Visible = false
				end

				v8.MaskResult = maskResult
			else
				maskResult = nil
			end
		end
	else
		maskResult = trickOrTreatFeed
	end

	if maskResult then
		local v8 = object[trickOrTreatFeed]

		if not v8 then
			v8 = {}
			object[trickOrTreatFeed] = v8
		end

		local stats = v8.Stats

		if not stats then
			stats = trickOrTreatFeed:FindFirstChild("Stats", true)

			if stats then
				local v9

				if maskResult == nil then
					v9 = false
				else
					v9 = stats:IsDescendantOf(maskResult)
				end

				if stats:IsA("GuiObject") and not v9 then
					stats.Visible = false
				end

				v8.Stats = stats
			else
				stats = nil
			end
		end

		clearLiveMaskFrames()
		local v9 = v7
		v7 = nil
		local v10

		if v9 then
			local v11 = v9.arrivesAt - os.clock()

			if v11 > 0 then
				task.wait(v11)
			end

			if v9.stats.Parent then
				v10 = v9
			end
		else
			v10 = v9
		end

		count += 1
		local clone = maskResult:Clone()
		clone.Name = "MaskResult_Live"
		clone.LayoutOrder = count
		clone.Visible = true

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local outcome = clone:FindFirstChild("Outcome", true)
		local text = type(p.verse) ~= "string" and "" or p.verse or ""
		local v12 = nil

		if outcome and outcome:IsA("TextLabel") then
			outcome.Text = text
			outcome.Visible = text ~= ""

			if text ~= "" then
				v12 = prepareVerseSwipe(outcome)
			end
		end

		local stats2 = clone:FindFirstChild("Stats", true)
		local clone2 = nil

		if stats2 and v10 then
			v10.stop()
			task.spawn(dissolve, v10.stats)
			v10 = nil
		elseif stats2 or not v10 then
			if not stats2 and stats then
				count += 1
				clone2 = stats:Clone()
				clone2.Name = "MaskStats_Live"
				clone2.LayoutOrder = count
				clone2.Visible = true
				stats2 = clone2
			end
		else
			clone2 = v10.stats
			stats2 = clone2
		end

		if not stats2 then
			warn("[TrickOrTreatFeed] PlayerGui.TrickOrTreatFeed is missing its Stats template")
		end

		local background = clone:FindFirstChild("Background", true)

		if background and background:IsA("GuiObject") then
			unfoldBackground(background)
			colorIn(background, MaskIcons.backgroundColorFor(p.mask))
			MaskIcons.applyBackgroundGradient(background, p.mask)
		end

		local maskSwing = clone:FindFirstChild("MaskSwing", true)

		if maskSwing and maskSwing:IsA("GuiObject") then
			MaskIcons.apply(maskSwing, p.mask)
			swingMask(maskSwing) -- equivalent call inferred; original call site unknown
			colorIn(maskSwing)
		end

		showPopped(clone, maskResult.Parent) -- equivalent call inferred; original call site unknown
		table.insert(clones, clone)

		if clone2 then
			if not v10 then
				slideIn(clone2, stats.Parent, tweenInfo2)
			end

			table.insert(clones, clone2)
		end

		task.spawn(flashGlow, clone)
		burstParticles(clone)
		playRevealSoundsNow(v9 and v9.soundsPlayed or {})
		print(("[TrickOrTreatFeed] mask reveal: %s (%d verse chars)"):format(tostring(p.mask), #text))

		local function alive()
			return clone.Parent ~= nil and not clone:GetAttribute("Leaving")
		end

		if v10 then
			v10.stop()
			task.spawn(settleStats, stats2, p)
		elseif stats2 then
			task.spawn(possessThenSettle, stats2, p, alive)
		end

		task.spawn(function()
			task.wait(tweenInfo7.DelayTime + tweenInfo7.Time)

			if v12 then
				local v13

				if clone.Parent == nil then
					v13 = false
				else
					v13 = not clone:GetAttribute("Leaving")
				end

				if v13 then
					v12()
				end
			end

			task.wait(MessagePacingCore.holdSeconds(text))
			local v13

			if clone.Parent == nil then
				v13 = false
			else
				v13 = not clone:GetAttribute("Leaving")
			end

			if not v13 then
				return
			end

			if clone2 then
				task.spawn(dissolve, clone2)
			end

			dissolve(clone)
		end)
	else
		warn("[TrickOrTreatFeed] PlayerGui.TrickOrTreatFeed is missing its MaskResult template")
		dropPendingStats() -- equivalent call inferred; original call site unknown
	end
end

ReplicatedStorage:WaitForChild("Events"):WaitForChild("TrickOrTreatFeed", 1e999).OnClientEvent:Connect(function(p)
	local kind

	if type(p) == "table" then
		kind = p.kind or nil
	end

	local v8

	if kind == "Mask" then
		v8 = pushMask
	elseif kind == "MaskIntro" then
		v8 = pushMaskIntro
	else
		v8 = push
	end

	local success, result = pcall(v8, p)

	if not success then
		warn("[TrickOrTreatFeed] toast failed: " .. tostring(result))
	end
end)