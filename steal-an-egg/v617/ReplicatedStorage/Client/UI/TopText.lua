local Debris = game:GetService("Debris")
local GamepadService = game:GetService("GamepadService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local v = {
	Response_UI = true,
	Talk_UI = true
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local talk_UI = ReplicatedStorage.Assets.UI.Npcs.Talk_UI
local response_UI = ReplicatedStorage.Assets.UI.Npcs.Response_UI
local option_UI = ReplicatedStorage.Assets.UI.Npcs.Option_UI
local response_Text = SoundService.Response_Text
local TopText = {}
task.wait(1)

local function jitter(p: number)
	return 1 + math.random(-p, p) / 100
end

local function eachScript(folder, callback)
	for _, baseScript in folder:GetDescendants() do
		if baseScript:IsA("BaseScript") then
			callback(baseScript)
		end
	end
end

local function switchOn(p)
	p.Enabled = true
end

local function discard(instance)
	instance:Destroy()
end

local function revealNpcText(textLabel, childName: string?)
	local v2 = string.len((textLabel.Text:gsub("<.->", "")))
	local v3 = childName and SoundService.NPC_SFX:FindFirstChild(childName) or SoundService.NPC_Text
	textLabel.MaxVisibleGraphemes = 0

	while v2 >= 1 do
		task.wait()

		if v3.TimePosition > 0.07 or v3.Playing == false then
			v3.TimePosition = 0
			v3.Playing = true
			v3.PlaybackSpeed = 1 + math.random(-5, 5) / 100
		end

		v2 -= 1
		textLabel.MaxVisibleGraphemes += 1
	end
end

local function revealPlayerText(textLabel)
	local v2 = string.len((textLabel.Text:gsub("<.->", "")))
	textLabel.MaxVisibleGraphemes = 0
	local v3 = v2

	while v3 >= 1 do
		task.wait()

		if math.floor(v3 / 3) * 3 == v3 or v3 == v2 then
			local clone = response_Text:Clone()
			clone.Parent = SoundService
			clone.Name = "SFX"
			clone.PlaybackSpeed = 1 + math.random(-15, 15) / 100
			clone.Playing = true
			Debris:AddItem(clone, clone.TimeLength * clone.PlaybackSpeed)
		end

		v3 -= 1
		textLabel.MaxVisibleGraphemes += 1
	end
end

local function restockScripts(folder, folder2, flag: boolean)
	for _, baseScript in folder:GetDescendants() do
		if not baseScript:IsA("BaseScript") then
			continue
		end

		for _, descendant in folder2:GetDescendants() do
			if descendant.Name ~= baseScript.Parent.Name then
				continue
			end

			if flag then
				baseScript.Enabled = false
			end

			local clone = baseScript:Clone()
			clone.Parent = descendant
			clone.Enabled = true
		end
	end
end

local function raiseBubble(instance, p, text: string, flag: boolean?, flag2: boolean, p2: string?, flag3: boolean)
	local head = p.Head
	local child = head:FindFirstChild(talk_UI.Name)
	local v2 = flag == true
	local clone

	if child == nil then
		clone = instance:Clone()
		clone.Parent = head
	else
		if v2 then
			eachScript(child, discard)
		end

		clone = child
	end

	clone.TextLabel.Text = text

	if flag2 then
		revealNpcText(clone.TextLabel, p2)
	else
		revealPlayerText(clone.TextLabel)
	end

	if v2 and child == nil then
		eachScript(clone, switchOn)
		return clone
	end

	if v2 then
		restockScripts(instance, clone, flag3)
	end

	return clone
end

local function clearSideFrame(p)
	for _, child in p.PlayerGui.Billboard_UI:GetChildren() do
		if child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end
end

function TopText.Speak(p, text: string, flag: boolean?)
	return (raiseBubble(talk_UI, p, text, flag, true, p.Name, false))
end

function TopText.Reply(p, text: string, flag: boolean?)
	return (raiseBubble(talk_UI, p, text, flag, true, nil, true))
end

function TopText.Echo(p, text: string, flag: boolean?)
	if text == nil then
		return
	else
		return (raiseBubble(response_UI, p, text, flag, false, nil, true))
	end
end

function TopText.OfferChoices(p, items)
	local count = 0
	local clones = {}

	for _, item in pairs(items) do
		count += 1
		local clone = option_UI:Clone()
		clone.Parent = p.PlayerGui.Billboard_UI
		clone.Frame.Frame.Text_Element.Text = item
		clone.Frame.Frame.TextLabel.Text = tostring(count) .. "."
		local uIPadding = clone.Frame.Frame.Text_Element.UIPadding
		uIPadding.PaddingLeft = UDim.new(string.len(item) * 0.001 + 0.04, 0)
		local tween = TweenService:Create(uIPadding, tweenInfo, {
			PaddingLeft = UDim.new(0, 0)
		})
		tween:Play()
		Debris:AddItem(tween, tweenInfo.Time)
		table.insert(clones, clone)
		clone.Frame.Frame.Text_Element:SetAttribute("Text", item)
		task.wait(0.075)
	end

	if clones[1] then
		GamepadService:EnableGamepadCursor(clones[1])
	end

	return clones
end

function TopText.FadeOut(p, p2)
	clearSideFrame(p2)

	for _, billboardGui in p.Head:GetChildren() do
		if not (billboardGui:IsA("BillboardGui") and v[billboardGui.Name]) then
			continue
		end

		for _, guiObject in billboardGui:GetChildren() do
			if guiObject:IsA("TextLabel") then
				TweenService:Create(guiObject, tweenInfo2, {
					TextTransparency = 1
				}):Play()
			elseif guiObject:IsA("ImageLabel") then
				TweenService:Create(guiObject, tweenInfo2, {
					ImageTransparency = 1
				}):Play()
			end
		end

		Debris:AddItem(billboardGui, tweenInfo2.Time)
	end
end

function TopText.ClearChoices(p)
	clearSideFrame(p)
	GamepadService:DisableGamepadCursor()
end

return TopText