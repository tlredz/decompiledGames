local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local t = require(ReplicatedStorage.Packages.t)
local AssetGender = require(ReplicatedStorage.Shared.Util.AssetGender)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local AssetRuntime = require(ReplicatedStorage.Shared.Types.AssetRuntime)
local GUI = require(ReplicatedStorage.Client.GUI)
local HoverHighlight = require(ReplicatedStorage.Client.WorldFX.HoverHighlight)
local ModelHover = require(ReplicatedStorage.Client.UI.ModelHover)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {}
local v2 = {}
local v3 = nil
local key = nil
local v4 = nil
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function getKey(record)
	return (`{record.OwnerUserId}:{record.UID}`)
end

local function bindGui()
	local v6 = v3

	if v6 ~= nil then
		return v6
	end

	local screenGui = GUI.AssetHoverData()
	assert(screenGui:IsA("ScreenGui"), "PlayerGui.AssetHoverData must be a ScreenGui")
	local frame = screenGui.Frame
	assert(frame:IsA("GuiObject"), "AssetHoverData.Frame must be a GuiObject")
	local canvasGroup = frame.CanvasGroup
	assert(canvasGroup:IsA("CanvasGroup"), "AssetHoverData.Frame.CanvasGroup must be a CanvasGroup")
	local weight = canvasGroup.Weight
	assert(weight:IsA("TextLabel"), "AssetHoverData.Frame.CanvasGroup.Weight must be a TextLabel")
	local gender = canvasGroup.Gender
	assert(gender:IsA("ImageLabel"), "AssetHoverData.Frame.CanvasGroup.Gender must be an ImageLabel")
	local v7 = {
		Root = screenGui,
		Frame = frame,
		CanvasGroup = canvasGroup,
		Weight = weight,
		Gender = gender
	}
	v3 = v7
	screenGui.Enabled = false
	frame.Visible = false
	canvasGroup.GroupTransparency = 1
	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveHighlight()
	local v6 = v4
	v4 = nil

	if v6 ~= nil then
		HoverHighlight.FadeOut(v6, 0.2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateFramePosition(p, point: Vector2)
	p.Frame.Position = UDim2.fromOffset(point.X, point.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStaticContent(p, p2)
	p.Weight.Text = AssetItems.WeightLabel(p2.Record.ItemData)
	p.Gender.Image = AssetGender.BadgeImage(AssetGender.Settle(p2.Record.ItemData.Category, p2.Record.ItemData.Gender))
end

local function setActiveEntry(p, mouseLocation: Vector2)
	if p == nil then
		if key == nil then
			return
		end

		local v6 = bindGui()
		updateFramePosition(v6, mouseLocation) -- equivalent call inferred; original call site unknown
		key = nil
		count += 1
		local v7 = count
		clearActiveHighlight() -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(v6.CanvasGroup, tweenInfo, {
			GroupTransparency = 1
		})
		tween.Completed:Once(function(p2)
			if p2 == Enum.PlaybackState.Completed and key == nil and count == v7 then
				v6.Frame.Visible = false
				v6.Root.Enabled = false
			end
		end)
		tween:Play()
	else
		local v6 = bindGui()
		updateFramePosition(v6, mouseLocation) -- equivalent call inferred; original call site unknown
		count += 1
		v6.Root.Enabled = true
		v6.Frame.Visible = true

		if key ~= p.Key then
			key = p.Key
			clearActiveHighlight() -- equivalent call inferred; original call site unknown
			v4 = HoverHighlight.FadeIn(p.Model, "AssetHoverHighlight", 0.2)
			updateStaticContent(v6, p) -- equivalent call inferred; original call site unknown
			v6.CanvasGroup.GroupTransparency = 1
			TweenService:Create(v6.CanvasGroup, tweenInfo, {
				GroupTransparency = 0
			}):Play()
		end
	end
end

local function updateHover()
	local mouseLocation = UserInputService:GetMouseLocation()
	local keyUnderCursor = ModelHover.KeyUnderCursor(v2, mouseLocation, 200)
	local v6

	if keyUnderCursor ~= nil then
		v6 = v[keyUnderCursor]
	end

	setActiveEntry(v6, mouseLocation)
end

local v5 = {
	SetEntry = function(p)
		assert(AssetRuntime.SchemaValidation.RuntimeAssetRecord(p.Record), "Invalid runtime asset record")
		t.strict(t.instanceIsA("Model"))(p.Model)
		local key2 = getKey(p.Record) -- equivalent call inferred; original call site unknown
		v[key2] = {
			Key = key2,
			Record = p.Record,
			Model = p.Model
		}
		v2[key2] = p.Model
	end,
	RemoveEntry = function(p: number, p2: string)
		t.strict(t.number)(p)
		t.strict(t.string)(p2)
		local formatted = `{p}:{p2}`
		v[formatted] = nil
		v2[formatted] = nil

		if key == formatted then
			local mouseLocation = UserInputService:GetMouseLocation()

			if key == nil then
				return
			end

			local v6 = bindGui()
			updateFramePosition(v6, mouseLocation) -- equivalent call inferred; original call site unknown
			key = nil
			count += 1
			local v7 = count
			clearActiveHighlight() -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(v6.CanvasGroup, tweenInfo, {
				GroupTransparency = 1
			})
			tween.Completed:Once(function(p3)
				if p3 == Enum.PlaybackState.Completed and key == nil and count == v7 then
					v6.Frame.Visible = false
					v6.Root.Enabled = false
				end
			end)
			tween:Play()
		end
	end,
	DestroyOwner = function(p: number)
		t.strict(t.number)(p)

		for k, v6 in pairs(v) do
			if v6.Record.OwnerUserId ~= p then
				continue
			end

			v[k] = nil
			v2[k] = nil

			if key ~= k then
				continue
			end

			local mouseLocation = UserInputService:GetMouseLocation()

			if key == nil then
				continue
			end

			local v7 = bindGui()
			updateFramePosition(v7, mouseLocation) -- equivalent call inferred; original call site unknown
			key = nil
			count += 1
			local v8 = count
			clearActiveHighlight() -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(v7.CanvasGroup, tweenInfo, {
				GroupTransparency = 1
			})
			tween.Completed:Once(function(p2)
				if p2 == Enum.PlaybackState.Completed and key == nil and count == v8 then
					v7.Frame.Visible = false
					v7.Root.Enabled = false
				end
			end)
			tween:Play()
		end
	end
}
RunService.RenderStepped:Connect(updateHover)
return table.freeze(v5)