local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GUI = require(ReplicatedStorage.Client.GUI)
require(ReplicatedStorage.Client.Types.GUI)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local shop = GUI.Shop()
local scrollingFrame = shop.Frame.ScrollingFrame
local buttonsHolder = shop.Frame.ButtonsHolder
local maid = Trove.new()
local extended = maid:Extend()
local v = nil
local color = Color3.fromRGB(255, 230, 80)
local v2 = {
	Featured = scrollingFrame.FeaturedSectionTitle,
	Speed = scrollingFrame.SpeedSectionTitle,
	SpeedProducts = scrollingFrame.Speed,
	Money = scrollingFrame.Money
}
local v3 = {
	{
		section = "Featured",
		button = buttonsHolder.Featured,
		anchor = v2.Featured,
		color = buttonsHolder.Featured.SectionTitle.TextColor3
	},
	{
		section = "Speed",
		button = buttonsHolder.Speed,
		anchor = v2.Speed,
		color = buttonsHolder.Speed.SectionTitle.TextColor3
	},
	{
		section = "Money",
		button = buttonsHolder.Money,
		anchor = v2.Money,
		color = buttonsHolder.Money.SectionTitle.TextColor3
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function maximumScroll()
	return (math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y))
end

local function updateSection()
	local section = "Featured"
	local v4 = scrollingFrame.AbsolutePosition.Y + 12
	local v5 = maximumScroll() -- equivalent call inferred; original call site unknown
	local v6

	if v5 > 0 then
		local Y = scrollingFrame.CanvasPosition.Y
		v6 = v5 - 2 <= Y
	else
		v6 = false
	end

	for _, v7 in v3 do
		if v7.anchor.Visible and (v7.anchor.AbsolutePosition.Y <= v4 or v6) then
			section = v7.section
		end
	end

	for _, v7 in v3 do
		local v8 = v7.section == section
		local sectionTitle = v7.button.SectionTitle
		local textColor

		if v8 then
			textColor = color
		else
			textColor = v7.color
		end

		sectionTitle.TextColor3 = textColor
		v7.button:SetAttribute("SelectedSection", v8)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTween()
	if v then
		v:Cancel()
		v = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopScrolling()
	extended:Clean()
	cancelTween() -- equivalent call inferred; original call site unknown
end

local function scrollTo(p)
	local v4 = v2[p.section]

	if not v4.Visible then
		return
	end

	cancelTween() -- equivalent call inferred; original call site unknown
	local v5 = v4.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y + scrollingFrame.CanvasPosition.Y - 6
	local vector = Vector2.new(
		0,
		(math.clamp(v5, 0, (math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y))))
	)

	if p.animated then
		v = TweenService:Create(scrollingFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = vector
		})
		v:Play()
	else
		scrollingFrame.CanvasPosition = vector
		updateSection()
	end
end

local v4 = {
	Open = function(section: string)
		stopScrolling() -- equivalent call inferred; original call site unknown

		if Tabs.Activate("Shop") then
			extended:AddPromise(Promise.delay(0.22):andThen(function()
				if Tabs.IsActive("Shop") then
					scrollTo({
						section = section,
						animated = false
					})
				end
			end))
		else
			scrollTo({
				section = section,
				animated = false
			})
		end
	end
}
maid:AttachToInstance(shop)
maid:Add(stopScrolling)

for _, v5 in v3 do
	v5.button.Active = true
	v5.button.Selectable = true
	local v6 = v5
	maid:Add(ButtonFX(v5.button, 1.08, function()
		stopScrolling() -- equivalent call inferred; original call site unknown
		scrollTo({
			section = v6.section,
			animated = true
		})
	end))
	maid:Add(v5.anchor:GetPropertyChangedSignal("Visible"):Connect(updateSection))
end

maid:Add(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateSection))
maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateSection))
maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateSection))
maid:Add(scrollingFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		stopScrolling() -- equivalent call inferred; original call site unknown
	end
end))
maid:Add(scrollingFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		stopScrolling() -- equivalent call inferred; original call site unknown
	end
end))
maid:Add(Tabs.Deactivated:Connect(function(p: string)
	if p == "Shop" then
		stopScrolling() -- equivalent call inferred; original call site unknown
	end
end))

for _, childName in { "OldRobuxShop", "SpeedShop", "RobuxShopOLD" } do
	local screenGui = GUI.PlayerGui():FindFirstChild(childName)

	if screenGui and screenGui:IsA("ScreenGui") then
		screenGui.Enabled = false
	end
end

shop.ResetOnSpawn = false
scrollingFrame.CanvasPosition = Vector2.zero
updateSection()
return table.freeze(v4)