local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Shared.Eggs.Types)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(166, 255, 111)
local tweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPulse(state)
	local pulseTween = state.PulseTween
	state.PulseTween = nil

	if pulseTween ~= nil then
		pulseTween:Cancel()
		pulseTween:Destroy()
	end

	state.HatchButton.BackgroundColor3 = state.OriginalHatchColor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startPulse(state)
	if state.PulseTween ~= nil then
		return
	end

	local tween = TweenService:Create(state.HatchButton, tweenInfo, {
		BackgroundColor3 = color
	})
	state.PulseTween = tween
	tween:Play()
end

local function updateButtonState(state, flag: boolean, flag2: boolean)
	if state.HatchButton == state.GrowButton then
		local growButton = state.GrowButton
		growButton.Visible = flag or flag2
		growButton.Active = flag or flag2
	else
		state.GrowButton.Visible = not flag and flag2
		state.GrowButton.Active = not flag and flag2
		state.HatchButton.Visible = flag
		state.HatchButton.Active = flag
	end

	state.Ready = flag

	if flag then
		startPulse(state) -- equivalent call inferred; original call site unknown
	else
		stopPulse(state) -- equivalent call inferred; original call site unknown
	end
end

local GrowingEggListRow = {}

function GrowingEggListRow.Mount(instance, parent, name: string, callback, callback2)
	local clone = instance:Clone()
	clone.Name = name
	clone.Visible = true
	clone.Parent = parent
	local skip = clone.Spacer.Skip
	local open = clone.Spacer:FindFirstChild("Open") or skip
	skip.Selectable = true
	open.Selectable = true

	if open ~= skip then
		open.Visible = false
	end

	local maid = Trove.new()
	local v = {
		Uid = name,
		Root = clone,
		GrowButton = skip,
		HatchButton = open,
		OriginalHatchColor = open.BackgroundColor3,
		PulseTween = nil,
		Ready = false,
		Trove = maid
	}
	maid:Add(clone)
	maid:Add(function()
		stopPulse(v) -- equivalent call inferred; original call site unknown
	end)

	if open == skip then
		maid:Connect(skip.Activated, function()
			if v.Ready then
				callback2(name)
			else
				callback(name)
			end
		end)
		return v
	end

	maid:Connect(skip.Activated, function()
		callback(name)
	end)
	maid:Connect(open.Activated, function()
		callback2(name)
	end)
	return v
end

function GrowingEggListRow.Update(p, image: string, p2: number, text: string, flag: boolean, flag2: boolean)
	local spacer = p.Root.Spacer
	spacer.Icon.Image = image
	spacer.Progress.Fill.Size = UDim2.fromScale(p2, 1)
	spacer.Progress.TextLabel.Text = text
	spacer.Progress.Visible = not flag
	updateButtonState(p, flag, flag2)
end

function GrowingEggListRow:Destroy()
	self.Trove:Destroy()
end

return GrowingEggListRow