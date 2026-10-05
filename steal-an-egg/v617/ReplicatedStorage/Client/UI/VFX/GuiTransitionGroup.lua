local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	{
		property = "BackgroundTransparency",
		classes = { "GuiObject" }
	},
	{
		property = "GroupTransparency",
		classes = { "CanvasGroup" }
	},
	{
		property = "ImageTransparency",
		classes = { "ImageLabel", "ImageButton" }
	},
	{
		property = "TextTransparency",
		classes = { "TextLabel", "TextButton", "TextBox" }
	},
	{
		property = "TextStrokeTransparency",
		classes = { "TextLabel", "TextButton", "TextBox" }
	},
	{
		property = "Transparency",
		classes = { "UIStroke" }
	}
}
local GuiTransitionGroup = {}
GuiTransitionGroup.__index = GuiTransitionGroup
GuiTransitionGroup.__class = "GuiTransitionGroup"

local function isAnyOf(instance, items)
	local v2 = false

	for _, className in items do
		v2 = v2 or instance:IsA(className)
	end

	return v2
end

local function captureFade(descendant)
	local properties = {}
	local restingAlpha = {}

	for _, v3 in v do
		local v4 = false

		for _, className in v3.classes do
			v4 = v4 or descendant:IsA(className)
		end

		if not v4 then
			continue
		end

		properties[#properties + 1] = v3.property
		restingAlpha[v3.property] = descendant[v3.property]
	end

	if properties[1] then
		return {
			element = descendant,
			properties = properties,
			restingAlpha = restingAlpha
		}
	end

	return nil
end

local function raised(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale, udim.X.Offset, udim.Y.Scale - p, udim.Y.Offset)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function schedule(tweens, element, p, p2)
	local tween = TweenService:Create(element, p, p2)
	tweens[#tweens + 1] = tween
	tween:Play()
end

local function placeSlides(p, flag: boolean)
	for _, slide in p.slides do
		local element = slide.element
		local position

		if flag then
			position = slide.homePosition
		else
			position = slide.liftedPosition
		end

		element.Position = position
	end
end

local function drift(data, p, flag: boolean)
	for _, fade in data.fades do
		local v2 = {}

		for _, property in fade.properties do
			v2[property] = not flag and 1 or fade.restingAlpha[property]
		end

		schedule(data.running, fade.element, p, v2) -- equivalent call inferred; original call site unknown
	end

	for _, slide in data.slides do
		local homePosition

		if flag then
			homePosition = slide.homePosition
		else
			homePosition = slide.liftedPosition
		end

		schedule(data.running, slide.element, p, {
			Position = homePosition
		}) -- equivalent call inferred; original call site unknown
	end
end

function GuiTransitionGroup.new(folder, instance, p: number)
	t.strict(t.Instance)(folder)
	t.strict(t.Instance)(instance)
	t.strict(t.number)(p)
	local object = setmetatable({}, GuiTransitionGroup)
	object.running = {}
	object.fades = {}
	object.slides = {}

	for _, descendant in folder:GetDescendants() do
		local v2 = captureFade(descendant)

		if v2 ~= nil then
			object.fades[#object.fades + 1] = v2
		end
	end

	for _, guiObject in instance:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local position = guiObject.Position
		object.slides[#object.slides + 1] = {
			element = guiObject,
			homePosition = position,
			liftedPosition = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale - p, position.Y.Offset)
		}
	end

	return object
end

function GuiTransitionGroup.Halt(p)
	for _, v2 in p.running do
		v2:Cancel()
	end

	table.clear(p.running)
end

function GuiTransitionGroup.SnapHidden(p)
	for _, fade in p.fades do
		local element = fade.element

		for _, property in fade.properties do
			element[property] = 1
		end
	end

	for _, slide in p.slides do
		slide.element.Position = slide.liftedPosition
	end
end

function GuiTransitionGroup.Reveal(p, p2)
	drift(p, p2, true)
end

function GuiTransitionGroup.Conceal(p, p2)
	drift(p, p2, false)
end

function GuiTransitionGroup.Rehome(p)
	for _, slide in p.slides do
		slide.element.Position = slide.homePosition
	end
end

return GuiTransitionGroup