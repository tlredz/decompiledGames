local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.Types.AssetItem)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local Trove = require(ReplicatedStorage.Packages.Trove)
local AssetBillboardController = {}
AssetBillboardController.__index = AssetBillboardController

local function isHiddenByDefault(parent, folder)
	while parent ~= nil and parent ~= folder do
		if parent:IsA("GuiObject") and not parent.Visible then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addChannel(list, original: number, fn)
	if original >= 1 then
		return
	end

	table.insert(list, {
		Original = original,
		Apply = fn
	})
end

local function addTextLabelChannels(list, descendant)
	local function fn(textTransparency2: number)
		descendant.TextTransparency = textTransparency2
	end

	addChannel(list, descendant.TextTransparency, fn) -- equivalent call inferred; original call site unknown

	local function fn2(textStrokeTransparency2: number)
		descendant.TextStrokeTransparency = textStrokeTransparency2
	end

	addChannel(list, descendant.TextStrokeTransparency, fn2) -- equivalent call inferred; original call site unknown
end

local function addTextButtonChannels(list, descendant)
	local function fn(textTransparency2: number)
		descendant.TextTransparency = textTransparency2
	end

	addChannel(list, descendant.TextTransparency, fn) -- equivalent call inferred; original call site unknown

	local function fn2(textStrokeTransparency2: number)
		descendant.TextStrokeTransparency = textStrokeTransparency2
	end

	addChannel(list, descendant.TextStrokeTransparency, fn2) -- equivalent call inferred; original call site unknown
end

local function addTextBoxChannels(list, descendant)
	local function fn(textTransparency2: number)
		descendant.TextTransparency = textTransparency2
	end

	addChannel(list, descendant.TextTransparency, fn) -- equivalent call inferred; original call site unknown

	local function fn2(textStrokeTransparency2: number)
		descendant.TextStrokeTransparency = textStrokeTransparency2
	end

	addChannel(list, descendant.TextStrokeTransparency, fn2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addImageLabelChannel(list, descendant)
	local function fn(imageTransparency2: number)
		descendant.ImageTransparency = imageTransparency2
	end

	addChannel(list, descendant.ImageTransparency, fn) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addImageButtonChannel(list, descendant)
	local function fn(imageTransparency2: number)
		descendant.ImageTransparency = imageTransparency2
	end

	addChannel(list, descendant.ImageTransparency, fn) -- equivalent call inferred; original call site unknown
end

local function captureFadeChannels(folder)
	local v = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if isHiddenByDefault(descendant, folder) then
			continue
		end

		if descendant:IsA("GuiObject") then
			local v2 = descendant

			local function fn(backgroundTransparency2: number)
				v2.BackgroundTransparency = backgroundTransparency2
			end

			addChannel(v, descendant.BackgroundTransparency, fn) -- equivalent call inferred; original call site unknown

			if descendant:IsA("TextLabel") then
				addTextLabelChannels(v, descendant)
			elseif descendant:IsA("TextButton") then
				addTextButtonChannels(v, descendant)
			elseif descendant:IsA("TextBox") then
				addTextBoxChannels(v, descendant)
			elseif descendant:IsA("ImageLabel") then
				addImageLabelChannel(v, descendant) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("ImageButton") then
				addImageButtonChannel(v, descendant) -- equivalent call inferred; original call site unknown
			end

			if descendant:IsA("CanvasGroup") then
				local v3 = descendant

				local function fn2(groupTransparency2: number)
					v3.GroupTransparency = groupTransparency2
				end

				addChannel(v, descendant.GroupTransparency, fn2) -- equivalent call inferred; original call site unknown
			end
		elseif descendant:IsA("UIStroke") then
			local v2 = descendant

			local function fn(transparency2: number)
				v2.Transparency = transparency2
			end

			addChannel(v, descendant.Transparency, fn) -- equivalent call inferred; original call site unknown
		end
	end

	return v
end

local function resolveTransparency(p: number, p2: number)
	return 1 - p2 * (1 - p)
end

local function applyFadeAlpha(p)
	for _, channel in ipairs(p.Channels) do
		local original = channel.Original
		local v = 1 - p.Alpha * (1 - original)
		channel.Apply(v)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyEntryTargetVisible(state)
	local targetVisible = state.RangeVisible and state.SuppressCount <= 0
	state.TargetVisible = targetVisible

	if targetVisible then
		state.Billboard.Enabled = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEntryRangeVisible(_entry, rangeVisible: boolean)
	_entry.RangeVisible = rangeVisible
	applyEntryTargetVisible(_entry) -- equivalent call inferred; original call site unknown
end

local function stepEntryFade(_entry, dt: number)
	local v = _entry.TargetVisible and 1 or 0

	if _entry.Alpha ~= v then
		local v2 = dt / 0.2

		if _entry.Alpha < v then
			_entry.Alpha = math.min(_entry.Alpha + v2, v)
		else
			_entry.Alpha = math.max(_entry.Alpha - v2, v)
		end

		applyFadeAlpha(_entry)
	end

	if _entry.TargetVisible then
		_entry.Billboard.Enabled = true
	elseif _entry.Alpha <= 0 then
		_entry.Billboard.Enabled = false
	end
end

function AssetBillboardController.new()
	local object = setmetatable({}, AssetBillboardController)
	object._trove = Trove.new()
	object._entries = {}
	object._elapsed = 0
	object._trove:Add(RunService.Heartbeat:Connect(function(dt: number)
		object._elapsed += dt
		local v2 = object._elapsed >= 0.15

		if v2 then
			object._elapsed = 0
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
			humanoidRootPart = nil
		end

		for k, _entry in pairs(object._entries) do
			if v2 then
				local primaryPart = k.PrimaryPart

				if primaryPart == nil or k.Parent == nil or humanoidRootPart == nil then
					setEntryRangeVisible(_entry, false) -- equivalent call inferred; original call site unknown
				else
					local v3 = primaryPart.Position - humanoidRootPart.Position
					setEntryRangeVisible(
						_entry,
						Vector2.new(v3.X, v3.Z).Magnitude <= ItemDisplay.GetDataBillboardMaxDistance()
					) -- equivalent call inferred; original call site unknown
				end
			end

			stepEntryFade(_entry, dt)
		end
	end))
	return object
end

function AssetBillboardController:Add(model, p3, p4: number)
	local dataBillboard = ItemDisplay.CreateDataBillboard(model, p3.Category, p3, p4)
	assert(dataBillboard ~= nil, (`Asset model {model.Name} must expose CENTER for its data billboard`))
	dataBillboard.MaxDistance = 100000
	local v = {
		Model = model,
		Billboard = dataBillboard,
		Channels = captureFadeChannels(dataBillboard),
		Alpha = 0,
		RangeVisible = false,
		SuppressCount = 0,
		TargetVisible = false
	}
	applyFadeAlpha(v)
	dataBillboard.Enabled = false
	self._entries[model] = v
end

function AssetBillboardController:UpdateMoneyPerSecond(p2, p3: number)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} must have a data billboard before its MPS can update`))
	ItemDisplay.SetDataBillboardMoneyPerSecond(_entry.Billboard, p3)
end

function AssetBillboardController:SetSuppressed(p2, flag: boolean)
	local _entry = self._entries[p2]

	if _entry == nil then
		return
	end

	if flag then
		_entry.SuppressCount += 1
	elseif _entry.SuppressCount > 0 then
		_entry.SuppressCount -= 1
	end

	applyEntryTargetVisible(_entry) -- equivalent call inferred; original call site unknown
end

function AssetBillboardController:Remove(p2)
	local _entry = self._entries[p2]

	if _entry ~= nil then
		_entry.Billboard:Destroy()
		self._entries[p2] = nil
	end
end

function AssetBillboardController:Destroy()
	for k in pairs(self._entries) do
		self:Remove(k)
	end

	self._trove:Destroy()
end

return AssetBillboardController