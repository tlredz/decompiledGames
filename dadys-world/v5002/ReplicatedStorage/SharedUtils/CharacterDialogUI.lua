local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local vector = Vector2.new(0.5, 1)
local uDim = UDim2.new(0.5, 0, 0.93, 0)
local uDim2 = UDim2.new(0.55, 0, 0.16, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function getPartsFolder()
	return (ReplicatedStorage:WaitForChild("Parts"))
end

local function getTemplate(p: string?)
	local partsFolder = getPartsFolder() -- equivalent call inferred; original call site unknown

	if p then
		local billboardGui = partsFolder:FindFirstChild("TextBox" .. p)

		if billboardGui and billboardGui:IsA("BillboardGui") then
			return billboardGui
		end
	end

	local textBox = partsFolder:FindFirstChild("TextBox")

	if textBox and textBox:IsA("BillboardGui") then
		return textBox
	end

	return nil
end

local v = {}

local function gatherFadeTargets(folder)
	local v2 = v[folder]

	if v2 then
		return v2
	end

	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Frame") then
			if descendant.BackgroundTransparency < 1 then
				table.insert(result, {
					instance = descendant,
					property = "BackgroundTransparency",
					visibleValue = descendant.BackgroundTransparency
				})
			end
		elseif descendant:IsA("ImageLabel") then
			table.insert(result, {
				instance = descendant,
				property = "ImageTransparency",
				visibleValue = descendant.ImageTransparency
			})
		elseif descendant:IsA("UIStroke") then
			table.insert(result, {
				instance = descendant,
				property = "Transparency",
				visibleValue = descendant.Transparency
			})
		elseif descendant:IsA("TextLabel") then
			table.insert(result, {
				instance = descendant,
				property = "TextTransparency",
				visibleValue = descendant.TextTransparency
			})
			table.insert(result, {
				instance = descendant,
				property = "TextStrokeTransparency",
				visibleValue = descendant.TextStrokeTransparency
			})
		end
	end

	v[folder] = result
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTargetsTransparency(items, p: number)
	for _, item in items do
		item.instance[item.property] = p
	end
end

local CharacterDialogUI = {
	create = function(_, p: string?)
		local template = getTemplate(p)

		if not template then
			warn("[CharacterDialogUI] create: no TextBox template found in ReplicatedStorage.Parts (variant: " .. tostring(p) .. ")")
			return nil
		end

		local frame = template:FindFirstChild("Frame")

		if not (frame and frame:IsA("Frame")) then
			warn("[CharacterDialogUI] create: template missing inner Frame")
			return nil
		end

		local clone = frame:Clone()
		clone.Name = "CharacterDialog"
		clone.AnchorPoint = vector
		clone.Position = uDim
		clone.Size = uDim2
		setTargetsTransparency(gatherFadeTargets(clone), 1) -- equivalent call inferred; original call site unknown
		return clone
	end,
	setText = function(self, instance, text: string)
		local dialogueBox = instance:FindFirstChild("DialogueBox")

		if dialogueBox and dialogueBox:IsA("TextLabel") then
			dialogueBox.Text = text
		end
	end
}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTween(instance)
	if instance then
		instance:Cancel()
		instance:Destroy()
	end
end

local function cancelState(state)
	if not state then
		return
	end

	for _, fadeIn in state.fadeIns do
		cancelTween(fadeIn) -- equivalent call inferred; original call site unknown
	end

	for _, fadeOut in state.fadeOuts do
		cancelTween(fadeOut) -- equivalent call inferred; original call site unknown
	end

	state.fadeIns = {}
	state.fadeOuts = {}
end

function CharacterDialogUI:show(parent, p: string, options)
	local v3 = options or {}
	local duration = v3.duration or 3
	local color = v3.color
	local font = v3.font
	local fontFace = v3.fontFace
	local soundId = v3.soundId
	local soundVolume = v3.soundVolume or 1
	local soundPlaybackSpeed = v3.soundPlaybackSpeed or 1
	local silent = v3.silent == true
	local dialogueBox = parent:FindFirstChild("DialogueBox")

	if not (dialogueBox and dialogueBox:IsA("TextLabel")) then
		warn("[CharacterDialogUI] show: frame is missing DialogueBox child")
		return
	end

	local v4 = gatherFadeTargets(parent)
	cancelState(v2[parent])
	local v5 = {
		fadeIns = {},
		fadeOuts = {}
	}
	v2[parent] = v5

	if soundId then
		Audio:Play(soundId, {
			Volume = soundVolume,
			PlaybackSpeed = soundPlaybackSpeed,
			Parent = parent
		})
	elseif not silent then
		local parts = ReplicatedStorage:FindFirstChild("Parts")
		local dialogue = parts and parts:FindFirstChild("Dialogue")

		if dialogue and dialogue:IsA("Sound") then
			local clone = dialogue:Clone()
			clone.PlaybackSpeed *= math.random(95, 105) / 100
			clone.Parent = parent
			clone:Play()
			Debris:AddItem(clone, math.max(clone.TimeLength, 0.1) + 0.5)
		end
	end

	self:setText(parent, p)

	if color then
		dialogueBox.TextColor3 = color
	end

	if fontFace then
		dialogueBox.FontFace = fontFace
	elseif font then
		dialogueBox.Font = font
	end

	setTargetsTransparency(v4, 1) -- equivalent call inferred; original call site unknown

	for _, v6 in v4 do
		local v9 = TweenService:Create(v6.instance, tweenInfo, {
			[v6.property] = v6.visibleValue
		})
		v9:Play()
		table.insert(v5.fadeIns, v9)
	end

	task.delay(duration, function()
		if v2[parent] ~= v5 then
			return
		end

		for _, fadeIn in v5.fadeIns do
			cancelTween(fadeIn) -- equivalent call inferred; original call site unknown
		end

		v5.fadeIns = {}

		for _, v6 in v4 do
			local v10 = TweenService:Create(v6.instance, tweenInfo2, {
				[v6.property] = 1
			})
			v10:Play()
			table.insert(v5.fadeOuts, v10)
		end
	end)
end

return CharacterDialogUI