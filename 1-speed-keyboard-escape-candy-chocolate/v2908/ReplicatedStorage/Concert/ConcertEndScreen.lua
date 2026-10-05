local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local ConcertCountdown = require(script.Parent.ConcertCountdown)
local create = Vide.create
local ConcertEndScreen = {}

local function StableUsernameHash(value: string)
	local v = 5381

	for i = 1, #value do
		v = (v * 33 + string.byte(value, i)) % 2147483647
	end

	return v
end

local function DefaultMorphIcon(data, p: number)
	local v = math.clamp(p / 0.5833333333333334 % 1, 0, 1)
	local v2 = math.sign(p / 1.1666666666666667 % 2 - 1) * (data.Side == "Left" and 1 or -1)
	data.Scale.Scale = 1 + (1 - TweenService:GetValue(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)) * 0.25
	data.Image.Rotation = v2 * 15 * (1 - math.clamp(p / 1.1666666666666667 % 1, 0, 1))
end

ConcertEndScreen.Content = {
	Title = "THE BBNO$ CONCERT",
	Sections = {
		{
			Category = "Team Lead",
			Names = { "Chichine" }
		},
		{
			Category = "Coordinator",
			Names = { "ev1", "RELICSxyz" }
		},
		{
			Category = "Lead Builder/Modeler",
			Names = { "Nextune_Dev" }
		},
		{
			Category = "Concert Builder/Modeller",
			Names = { "EternityReality" }
		},
		{
			Category = "Lead Concert Programmer",
			Names = { "Fabuss254" }
		},
		{
			Category = "Concert Programmers",
			Names = { "ev1", "andourys" }
		},
		{
			Category = "Concert Animators",
			Names = { "EternityReality", "aloneluvsya", "andourys" }
		},
		{
			Category = "Lead World Programmer",
			Names = { "Lyzrinn" }
		},
		{
			Category = "World Programmers",
			Names = { "Homemade_Sano", "FoeCakes", "Leorizoto" }
		},
		{
			Category = "World Builders/Modelers",
			Names = { "BuiltByMarKy", "Plur0ue", "Ectomilas" }
		},
		{
			Category = "Mocap Artists",
			Names = { "tommy.", "Kreifish" }
		},
		{
			Category = "Mocap Studio ( XR Studios )",
			Names = { "Andy Martin", "Fraser Maxwell" }
		},
		{
			Category = "Artists",
			Names = { "Gelatinium3", "AltiWyre", "Sorcerise" }
		},
		{
			Category = "Sound Designer",
			Names = { "X3ll3n" }
		},
		{
			Category = "UGC Animators",
			Names = { "denysdevs", "Immortion" }
		},
		{
			Category = "Character Artist",
			Names = { "Topcat" }
		},
		{
			Category = "And the bbno$ Team 🙏",
			Names = {}
		}
	}
}
ConcertEndScreen.Config = {
	FadeToBlackDuration = 1.25,
	FadeFromBlackDuration = 1,
	TitleFadeInDuration = 0.8,
	DelayBeforeScroll = 2,
	ScrollScreenWidthPercentPerSecond = 0.15,
	IconSizeScale = 0.3,
	IconNameOffsetScale = 0.1,
	IconTextOffsetScale = 0.05,
	CategoryUsernameSpacingScale = 0.1,
	UsernamePaddingScale = 0.012,
	IconUsernamePaddingScale = 0.1,
	UserIcons = {
		Chichine = "rbxassetid://75517415055443",
		ev1 = "rbxassetid://135580393356104",
		Plur0ue = "rbxassetid://113340347502621",
		Nextune_Dev = "rbxassetid://128832820623753",
		EternityReality = "rbxassetid://135427321913527",
		Fabuss254 = "rbxassetid://112018530300593",
		andourys = "rbxassetid://138186512897083",
		aloneluvsya = "rbxassetid://104517706073885",
		Lyzrinn = "rbxassetid://107021587919463",
		Homemade_Sano = "rbxassetid://129493113979338",
		FoeCakes = "rbxassetid://115052533712186",
		Leorizoto = "rbxassetid://82738998507613",
		BuiltByMarKy = "rbxassetid://132498012426690",
		RELICSxyz = "rbxassetid://125513348880903",
		Ectomilas = "rbxassetid://137737284128763",
		Gelatinium3 = "rbxassetid://115568623739122"
	},
	MorphIcon = DefaultMorphIcon,
	Music = {
		SoundId = "rbxassetid://72232639688738",
		Volume = 1,
		Looped = true,
		PlaybackSpeed = 1
	}
}
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(245, 245, 245)
Color3.fromRGB(190, 190, 198)
local color3 = Color3.fromRGB(255, 95, 190)
local rbxassetfontsfamiliesMontserratjson = Font.new(
	"rbxasset://fonts/families/Montserrat.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local rbxassetfontsfamiliesMontserratjson2 = Font.new(
	"rbxasset://fonts/families/Montserrat.json",
	Enum.FontWeight.Heavy,
	Enum.FontStyle.Normal
)
local v = nil
local count = 0
local v2 = false
local connection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function EaseInOutSine(value: number)
	return -(math.cos(3.141592653589793 * math.clamp(value, 0, 1)) - 1) / 2
end

local function NormalizeAssetId(value: string)
	if value == "" or string.find(value, "://", 1, true) then
		return value
	end

	if tonumber(value) then
		return (`rbxassetid://{value}`)
	end

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyScreen(p)
	if p.Sound then
		p.Sound:Stop()
	end

	p.Destroy()
	ConcertCountdown.SetSuppressed(false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyActiveImmediately()
	local v3 = v
	v = nil

	if v3 then
		DestroyScreen(v3) -- equivalent call inferred; original call site unknown
	end
end

local function Animate(p, p2: number, p3: number, fn)
	local v3 = math.max(p3, 0)

	if v3 == 0 then
		fn(1)
		return count == p2 and v == p
	else
		local total = 0

		while total < v3 do
			if count ~= p2 or v ~= p then
				return false
			end

			total += RunService.Heartbeat:Wait()
			fn(EaseInOutSine(total / v3))
		end

		fn(1)
		return count == p2 and v == p
	end
end

local function WaitForDuration(p, p2: number, delayBeforeScroll: number)
	local total = 0

	while total < math.max(delayBeforeScroll, 0) do
		if count ~= p2 or v ~= p then
			return false
		end

		total += RunService.Heartbeat:Wait()
	end

	return count == p2 and v == p
end

local textBoundsAsyncsByText = {}

local function HasConfiguredIcon(p, p2: string)
	local v3 = p.UserIcons[p2] or ""

	if v3 ~= "" and not string.find(v3, "://", 1, true) and tonumber(v3) then
		v3 = `rbxassetid://{v3}`
	end

	return v3 ~= ""
end

local function GetUsernameTextBounds(text: string)
	local v3 = textBoundsAsyncsByText[text]

	if v3 then
		return v3
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text
	getTextBoundsParams.Font = rbxassetfontsfamiliesMontserratjson
	getTextBoundsParams.Size = 100
	getTextBoundsParams.Width = 1000000
	local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
	getTextBoundsParams:Destroy()

	if not (success and textBoundsAsync.Y > 0) then
		textBoundsAsync = Vector2.new(math.max(#text * 100 * 0.6, 1), 100)
	end

	textBoundsAsyncsByText[text] = textBoundsAsync
	return textBoundsAsync
end

local function GetUsernamePaddingScale(data, p: string, p2: string)
	local v3 = data.UserIcons[p] or ""

	if v3 ~= "" and not string.find(v3, "://", 1, true) and tonumber(v3) then
		v3 = `rbxassetid://{v3}`
	end

	if v3 ~= "" then
		return data.IconUsernamePaddingScale
	end

	local v4 = data.UserIcons[p2] or ""

	if v4 ~= "" and not string.find(v4, "://", 1, true) and tonumber(v4) then
		v4 = `rbxassetid://{v4}`
	end

	if v4 == "" then
		return data.UsernamePaddingScale
	end

	return data.IconUsernamePaddingScale
end

local function GetRollHeightScale(p, data)
	local v3 = 0.93

	for _, section in p.Sections do
		local v4 = v3 + 0.15

		if #section.Names > 0 then
			v4 += data.CategoryUsernameSpacingScale
		end

		for k, name in section.Names do
			v4 += 0.13

			if not (k < #section.Names) then
				continue
			end

			local name2 = section.Names[k + 1]
			local v5 = data.UserIcons[name] or ""

			if v5 ~= "" and not string.find(v5, "://", 1, true) and tonumber(v5) then
				v5 = `rbxassetid://{v5}`
			end

			local iconUsernamePaddingScale

			if v5 ~= "" then
				iconUsernamePaddingScale = data.IconUsernamePaddingScale
			else
				local v6 = data.UserIcons[name2] or ""

				if v6 ~= "" and not string.find(v6, "://", 1, true) and tonumber(v6) then
					v6 = `rbxassetid://{v6}`
				end

				if v6 ~= "" then
					iconUsernamePaddingScale = data.IconUsernamePaddingScale
				else
					iconUsernamePaddingScale = data.UsernamePaddingScale
				end
			end

			v4 += iconUsernamePaddingScale
		end

		v3 = v4 + 0.3
	end

	return v3
end

local function CreditNameComponent(name: string, count2: number, data, side: string, p2: number, p3: number, p4: number, callback)
	local image = data.UserIcons[name] or ""

	if image ~= "" and not string.find(image, "://", 1, true) and tonumber(image) then
		image = `rbxassetid://{image}`
	end

	local v4 = image ~= ""
	local v5 = nil
	local usernameTextBounds = GetUsernameTextBounds(name)
	local v7 = 0.13 * (usernameTextBounds.X / usernameTextBounds.Y) / 0.9
	local iconNameOffsetScale

	if v4 then
		if side == "Left" then
			iconNameOffsetScale = data.IconNameOffsetScale
		else
			iconNameOffsetScale = -data.IconNameOffsetScale
		end
	else
		iconNameOffsetScale = 0
	end

	local v8 = iconNameOffsetScale + 0.5
	local v9 = math.max(data.IconSizeScale, 0.001) / 0.9
	local v10 = math.max(data.IconSizeScale, 0.001) / p3
	local v11

	if side == "Left" then
		v11 = v8 - v7 / 2 - v9 / 2 - data.IconTextOffsetScale
	else
		v11 = v8 + v7 / 2 + v9 / 2 + data.IconTextOffsetScale
	end

	local v12 = create("Frame")
	local v13 = {
		Name = `Name{count2}`,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Interactable = false,
		Position = UDim2.fromScale(0.5, p2 / p4),
		Selectable = false,
		Size = UDim2.fromScale(1, p3 / p4)
	}
	local v14 = create("TextLabel")({
		Name = "Username",
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesMontserratjson,
		Interactable = false,
		Position = UDim2.fromScale(v8, 0.5),
		Selectable = false,
		Size = UDim2.fromScale(v7, 0.13 / p3),
		Text = name,
		TextColor3 = color2,
		TextSize = 100,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Vide.action(function(instance)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function UpdateTextSize()
				if instance.AbsoluteSize.Y <= 0 then
					return
				end

				instance.TextSize = math.max(
					1,
					(math.floor(100 * instance.AbsoluteSize.Y / usernameTextBounds.Y + 0.5))
				)
			end

			instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTextSize)
			UpdateTextSize() -- equivalent call inferred; original call site unknown
		end)
	})
	local v15

	if v4 then
		v15 = create("ImageLabel")({
			Name = `Icon_{name}`,
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = image,
			Interactable = false,
			Position = UDim2.fromScale(v11, 0.5),
			Selectable = false,
			Size = UDim2.fromScale(v9, v10),
			create("UIScale")({ Vide.action(function(p5)
					v5 = p5
				end) }),
			Vide.action(function(image2)
				callback({
					Username = name,
					Side = side,
					Image = image2,
					Scale = assert(v5),
					Sound = nil
				})
			end)
		})
	end

	v13[1], v13[2] = v14, v15
	return (v12(v13))
end

local function CreditRollComponent(p, data, callback, textTransparency, visible, fn, fn2)
	local rollHeightScale = GetRollHeightScale(p, data)
	local v4 = { create("TextLabel")({
			Name = "Title",
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesMontserratjson2,
			Interactable = false,
			Position = UDim2.fromScale(0.5, 0),
			Selectable = false,
			Size = UDim2.fromScale(1, 0.4 / rollHeightScale),
			Text = p.Title,
			TextColor3 = color2,
			TextScaled = true,
			TextTransparency = textTransparency,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		}) }
	local v5 = 0.93
	local count2 = 0
	local count3 = 0

	for k, section in p.Sections do
		table.insert(v4, create("TextLabel")({
			Name = `Category{k}`,
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesMontserratjson2,
			Interactable = false,
			Position = UDim2.fromScale(0.5, v5 / rollHeightScale),
			Selectable = false,
			Size = UDim2.fromScale(1.4, 0.15 / rollHeightScale),
			Text = section.Category,
			TextColor3 = color3,
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		}))
		local v6 = v5 + 0.15

		if #section.Names > 0 then
			v6 += data.CategoryUsernameSpacingScale
		end

		for k2, name in section.Names do
			count2 += 1
			local v7 = data.UserIcons[name] or ""

			if v7 ~= "" and not string.find(v7, "://", 1, true) and tonumber(v7) then
				v7 = `rbxassetid://{v7}`
			end

			local v8

			if v7 ~= "" then
				count3 += 1

				if count3 % 2 == 1 then
					v8 = "Left"
				else
					v8 = "Right"
				end
			else
				v8 = "Left"
			end

			table.insert(v4, (CreditNameComponent(name, count2, data, v8, v6, 0.13, rollHeightScale, fn)))
			v6 += 0.13

			if not (k2 < #section.Names) then
				continue
			end

			local name2 = section.Names[k2 + 1]
			local v9 = data.UserIcons[name] or ""

			if v9 ~= "" and not string.find(v9, "://", 1, true) and tonumber(v9) then
				v9 = `rbxassetid://{v9}`
			end

			local iconUsernamePaddingScale

			if v9 ~= "" then
				iconUsernamePaddingScale = data.IconUsernamePaddingScale
			else
				local v10 = data.UserIcons[name2] or ""

				if v10 ~= "" and not string.find(v10, "://", 1, true) and tonumber(v10) then
					v10 = `rbxassetid://{v10}`
				end

				if v10 ~= "" then
					iconUsernamePaddingScale = data.IconUsernamePaddingScale
				else
					iconUsernamePaddingScale = data.UsernamePaddingScale
				end
			end

			v6 += iconUsernamePaddingScale
		end

		v5 = v6 + 0.3
	end

	return (create("Frame")({
		Name = "CreditRoll",
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Interactable = false,
		Position = function()
			return UDim2.fromScale(0.5, callback())
		end,
		Selectable = false,
		Size = UDim2.fromScale(0.9, rollHeightScale),
		Visible = visible,
		v4,
		Vide.action(function(p4)
			fn2(p4)
		end)
	}))
end

function ConcertEndScreen.GetRollHeightScale(p, p2)
	return (GetRollHeightScale(p or ConcertEndScreen.Content, p2 or ConcertEndScreen.Config))
end

function ConcertEndScreen.PreviewComponent(options)
	local v3 = options or {}
	local content = v3.Content or ConcertEndScreen.Content
	local config = v3.Config or ConcertEndScreen.Config
	local scrollScale = v3.ScrollScale or Vide.source(0.3)
	local titleTransparency = v3.TitleTransparency or Vide.source(0)
	local visible = v3.Visible or Vide.source(true)
	local v4 = {}
	local v5 = create("Frame")({
		Name = "ConcertEndScreenPreview",
		Active = false,
		BackgroundColor3 = color,
		BackgroundTransparency = v3.BackgroundTransparency or 0,
		ClipsDescendants = false,
		Interactable = false,
		Selectable = false,
		Size = UDim2.fromScale(1, 1),
		create("Frame")({
			Name = "SquareContent",
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Interactable = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Selectable = false,
			Size = UDim2.fromScale(1, 1),
			create("UIAspectRatioConstraint")({
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height
			}),
			(CreditRollComponent(content, config, scrollScale, titleTransparency, visible, function(p)
				table.insert(v4, p)
			end, function(_) end))
		})
	})
	local morphIcon = config.MorphIcon

	if morphIcon then
		local lastTime = os.clock()
		local flag = false
		Vide.cleanup(RunService.Heartbeat:Connect(function()
			if flag then
				return
			end

			local v6 = os.clock() - lastTime

			for _, v7 in v4 do
				local success, result = pcall(morphIcon, v7, v6)

				if success then
					continue
				end

				flag = true
				warn((`[ConcertEndScreen] Preview MorphIcon failed for {v7.Username}: {result}`))
				break
			end
		end))
	end

	return v5
end

local function MountScreens(playerGui, p, config, source, source2, source3, source4)
	for _, childName in { "ConcertEndBackground", "ConcertEndCredits" } do
		local child = playerGui:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = {}
	return Vide.mount(function()
		local v7 = { create("ScreenGui")({
				Name = "ConcertEndBackground",
				ClipToDeviceSafeArea = false,
				DisplayOrder = 2000000,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ScreenInsets = Enum.ScreenInsets.None,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				create("Frame")({
					Name = "Black",
					Active = false,
					BackgroundColor3 = color,
					BackgroundTransparency = source,
					BorderSizePixel = 0,
					Interactable = false,
					Selectable = false,
					Size = UDim2.fromScale(1, 1)
				}),
				Vide.action(function(p2)
					v3 = p2
				end)
			}), create("ScreenGui")({
				Name = "ConcertEndCredits",
				ClipToDeviceSafeArea = false,
				DisplayOrder = 2000001,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ScreenInsets = Enum.ScreenInsets.None,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				create("Frame")({
					Name = "SquareContent",
					Active = false,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					Interactable = false,
					Position = UDim2.fromScale(0.5, 0.5),
					Selectable = false,
					Size = UDim2.fromScale(1, 1),
					create("UIAspectRatioConstraint")({
						AspectRatio = 1,
						AspectType = Enum.AspectType.ScaleWithParentSize,
						DominantAxis = Enum.DominantAxis.Height
					}),
					CreditRollComponent(p, config, source3, source2, source4, function(p2)
						table.insert(v6, p2)
					end, function(p2)
						v5 = p2
					end),
					Vide.action(function(p2)
						v4 = p2
					end)
				})
			}) }
		Vide.cleanup(function()
			for _, v8 in v7 do
				v8:Destroy()
			end
		end)
		return v7
	end, playerGui), assert(v3), assert(v4), assert(v5), v6
end

local function CreateCreditSound(parent, config)
	local music = config.Music

	if not music then
		return nil
	end

	local soundId = music.SoundId

	if soundId ~= "" and not string.find(soundId, "://", 1, true) and tonumber(soundId) then
		soundId = `rbxassetid://{soundId}`
	end

	if soundId == "" then
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Name = "ConcertEndCreditMusic"
	sound.Looped = music.Looped
	sound.PlaybackSpeed = math.max(music.PlaybackSpeed, 0.01)
	sound.SoundId = soundId
	sound.Volume = math.clamp(music.Volume, 0, 10)
	sound.Parent = parent
	return sound
end

local function WaitForLayout(p, p2: number, p3, p4)
	local v3 = os.clock() + 5

	while count == p2 and v == p do
		if p3.AbsoluteSize.Y > 0 and p4.AbsoluteSize.Y > 0 then
			return true
		end

		RunService.Heartbeat:Wait()

		if not (v3 <= os.clock()) then
			continue
		end

		warn("[ConcertEndScreen] Credits layout did not resolve within 5 seconds.")
		return false
	end

	return false
end

local function FadeBackToGame(data, p: number, fadeFromBlackDuration: number)
	data.RollVisible(false)
	local backgroundTransparency = data.BackgroundTransparency()
	local v3 = not data.Sound and 0 or data.Sound.Volume
	return (Animate(data, p, fadeFromBlackDuration, function(p2)
		data.BackgroundTransparency(backgroundTransparency + (1 - backgroundTransparency) * p2)

		if data.Sound then
			data.Sound.Volume = v3 * (1 - p2)
		end
	end))
end

function ConcertEndScreen.IsVisible()
	return v ~= nil
end

function ConcertEndScreen.Hide(flag: boolean?)
	local v3 = v

	if not v3 or v3.Hiding and not flag then
		return
	end

	count += 1
	local v4 = count

	if flag then
		v = nil
		DestroyScreen(v3) -- equivalent call inferred; original call site unknown
	else
		v3.Hiding = true
		task.spawn(function()
			FadeBackToGame(v3, v4, ConcertEndScreen.Config.FadeFromBlackDuration)

			if v == v3 then
				v = nil
				DestroyScreen(v3) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

function ConcertEndScreen.Show(p)
	if not RunService:IsClient() then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
	count += 1
	local v3 = count
	DestroyActiveImmediately() -- equivalent call inferred; original call site unknown
	ConcertCountdown.SetSuppressed(true)
	local source = Vide.source(1)
	local source2 = Vide.source(1)
	local source3 = Vide.source(0)
	local source4 = Vide.source(false)
	local config = ConcertEndScreen.Config
	local destroy, parent, v6, v7, v8 = MountScreens(
		playerGui,
		p or ConcertEndScreen.Content,
		config,
		source,
		source2,
		source3,
		source4
	)
	local v9 = {
		Destroy = destroy,
		BackgroundTransparency = source,
		TitleTransparency = source2,
		RollVisible = source4,
		Sound = CreateCreditSound(parent, config),
		Hiding = false
	}
	v = v9
	local lastTime = os.clock()

	for _, v10 in v8 do
		v10.Sound = v9.Sound
	end

	if config.MorphIcon and #v8 > 0 then
		task.spawn(function()
			local morphIcon = config.MorphIcon

			while morphIcon and count == v3 and v == v9 do
				local timePosition

				if v9.Sound then
					timePosition = v9.Sound.TimePosition
				else
					timePosition = os.clock() - lastTime
				end

				for _, v10 in v8 do
					local success, result = pcall(morphIcon, v10, timePosition)

					if success then
						continue
					end

					warn((`[ConcertEndScreen] MorphIcon failed for {v10.Username}: {result}`))
					return
				end

				RunService.Heartbeat:Wait()
			end
		end)
	end

	task.spawn(function()
		if not Animate(v9, v3, config.FadeToBlackDuration, function(p2)
			source(1 - p2)
		end) then
			return
		end

		if WaitForLayout(v9, v3, v6, v7) then
			source3(0.3)
			source4(true)

			if v9.Sound then
				v9.Sound:Play()
			end

			if not Animate(v9, v3, config.TitleFadeInDuration, function(p2)
				source2(1 - p2)
			end) then
				return
			end

			if not WaitForDuration(v9, v3, config.DelayBeforeScroll) then
				return
			end

			local scrollScreenWidthPercentPerSecond = config.ScrollScreenWidthPercentPerSecond

			while source3() + v7.Size.Y.Scale > 0 do
				if count ~= v3 or v ~= v9 then
					return
				end

				local v10 = RunService.Heartbeat:Wait()
				source3(source3() - scrollScreenWidthPercentPerSecond * v10)
			end

			if not FadeBackToGame(v9, v3, config.FadeFromBlackDuration) then
				return
			end

			if v == v9 then
				v = nil
				DestroyScreen(v9) -- equivalent call inferred; original call site unknown
			end
		elseif v == v9 then
			v = nil
			DestroyScreen(v9) -- equivalent call inferred; original call site unknown
		end
	end)
end

function ConcertEndScreen.Start(instance, attributeName: string, attributeName2: string)
	if v2 or not RunService:IsClient() then
		return
	end

	v2 = true
	local v3 = instance:GetAttribute(attributeName) == true
	connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
		local v4 = instance:GetAttribute(attributeName) == true

		if v3 and not v4 then
			if instance:GetAttribute(attributeName2) == true then
				ConcertEndScreen.Show()
			end
		elseif v4 and ConcertEndScreen.IsVisible() then
			ConcertEndScreen.Hide(true)
		end

		v3 = v4
	end)
end

return ConcertEndScreen