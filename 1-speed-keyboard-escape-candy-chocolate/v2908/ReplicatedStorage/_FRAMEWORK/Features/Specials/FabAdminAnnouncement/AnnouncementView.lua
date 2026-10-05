local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local SoundManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.SoundManager)
require(script.Parent.Types)
local create = Vide.create
local color = Color3.fromRGB(10, 10, 14)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(252, 139, 252)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(216, 62, 255))
})
local color2 = Color3.new(0.247059, 0.172549, 0.266667)
local rbxassetfontsfamiliesGothamSSmjson = Font.new(
	"rbxasset://fonts/families/GothamSSm.json",
	Enum.FontWeight.ExtraBold
)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.2, 0.25),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.8, 0.25),
	NumberSequenceKeypoint.new(1, 1)
})
local numberRange = NumberRange.new(1, 1.1)
local AnnouncementView = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function playDialogVoice()
	local v = (numberRange.Min + numberRange.Max) / 2 - 1
	local v2 = (numberRange.Max - numberRange.Min) / 2
	SoundManager.playLocal("AdminAbuse.FabAA.Voice", v, v2, 1.35)
end

local function preloadDialogVoices()
	for _, v in SoundManager.getAllSoundPaths() do
		if string.find(v, "AdminAbuse.FabAA.Voice.", 1, true) == 1 then
			SoundManager.preloadSound(v)
		end
	end
end

function createAnnouncement(text: string, maxVisibleGraphemes, callback2, callback3)
	return create("Frame")({
		Name = "Announcement",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = function()
			return UDim2.new(0.5, 0, 0, callback3())
		end,
		Size = UDim2.new(0.58, 0, 1, 0),
		BackgroundColor3 = color,
		BackgroundTransparency = function()
			return 0.5 + 0.5 * (1 - callback2())
		end,
		BorderSizePixel = 0,
		create("UISizeConstraint")({
			MinSize = Vector2.new(300, 0),
			MaxSize = Vector2.new(900, 1000000)
		}),
		create("UIGradient")({
			Color = ColorSequence.new(color),
			Transparency = numberSequence
		}),
		create("TextLabel")({
			Name = "Text",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.6),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			MaxVisibleGraphemes = maxVisibleGraphemes,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextTransparency = function()
				return 1 - callback2()
			end,
			TextTruncate = Enum.TextTruncate.None,
			TextWrapped = false,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			create("UIStroke")({
				Color = color2,
				Thickness = 0.1,
				Transparency = function()
					return 0 + 1 * (1 - callback2())
				end,
				StrokeSizingMode = 1
			}),
			create("UIGradient")({
				Color = colorSequence,
				Rotation = 90
			})
		})
	})
end

function createStack(callback)
	return create("Frame")({
		Name = "AnnouncementStack",
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 1, -22),
		BackgroundTransparency = 1,
		Vide.action(function(p)
			callback(p)
		end),
		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
end

function mountAnnouncement(p, data, layoutOrder: number, callback)
	local source = Vide.source(0)
	local source2 = Vide.source(-16)
	local source3 = Vide.source(-1)
	local v = utf8.len(data.text) or #data.text
	local v2 = math.clamp(data.typewriterDuration or 0.25, 0, 2)
	local v3 = false
	local v4 = nil
	source3(v2 == 0 and -1 or 0)
	local v5 = Vide.mount(function()
		return create("Frame")({
			Name = "AnnouncementSlot",
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 0.06, 0),
			BackgroundTransparency = 1,
			Vide.action(function(p3)
				v4 = p3
			end),
			create("UISizeConstraint")({
				MinSize = Vector2.new(0, 42),
				MaxSize = Vector2.new(1000000, 72)
			}),
			createAnnouncement(data.text, source3, source, source2)
		})
	end, p)
	task.defer(function()
		local lastTime = os.clock()

		while not v3 and source() < 1 do
			local v6 = math.clamp((os.clock() - lastTime) / 0.22, 0, 1)
			source(1 - (1 - v6) ^ 2)
			source2((1 - v6) * -16)
			task.wait()
		end

		if v2 > 0 and v > 0 then
			local now = os.clock()
			local v6 = 0
			local v7 = -1e999

			while not v3 do
				local now2 = os.clock()
				local v8 = math.clamp((now2 - now) / v2, 0, 1)
				local v9 = math.ceil(v * v8)
				source3(v9)

				if v6 < v9 and now2 - v7 >= 0.06 then
					playDialogVoice() -- equivalent call inferred; original call site unknown
					v7 = now2
				end

				if v8 >= 1 then
					break
				end

				task.wait()
				v6 = v9
			end
		end

		task.wait((math.max(data.duration or 6, 0)))

		if not v3 then
			local lastTime2 = os.clock()

			while not v3 and source() > 0 do
				local v6 = math.clamp((os.clock() - lastTime2) / 0.28, 0, 1)
				source(1 - v6 ^ 2)
				source2(v6 * 20)
				task.wait()
			end

			if not v3 then
				callback()
			end
		end
	end)
	return function()
		if not v3 then
			v3 = true
			v5()
			local v6 = v4

			if v6 then
				v6:Destroy()
				v4 = nil
			end
		end
	end
end

function AnnouncementView.mount(playerGui)
	preloadDialogVoices()
	local v = nil
	local v2 = nil
	local v3 = false
	local count = 0
	local v4 = {}
	local v5 = Vide.mount(function()
		local stack = createStack(function(p)
			v = p
		end)

		if playerGui:IsA("PlayerGui") then
			return create("ScreenGui")({
				Name = "FabAdminAnnouncement",
				DisplayOrder = 29000,
				IgnoreGuiInset = false,
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Vide.action(function(p)
					v2 = p
				end),
				stack
			})
		end

		v2 = stack
		return stack
	end, playerGui)
	return {
		show = function(p)
			local v6 = v

			if not v3 and v6 then
				count += 1
				local v7 = nil
				v7 = mountAnnouncement(v6, p, count, function()
					v4[v7] = nil
					v7()
				end)
				v4[v7] = true
			end
		end,
		destroy = function()
			if not v3 then
				v3 = true

				for k in v4 do
					k()
				end

				table.clear(v4)
				v5()
				local v6 = v2

				if v6 then
					v6:Destroy()
					v2 = nil
				end
			end
		end
	}
end

return AnnouncementView