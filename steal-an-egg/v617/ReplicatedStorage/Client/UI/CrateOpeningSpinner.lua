local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Confetti = require(ReplicatedStorage.Client.UI.VFX.Confetti)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasite2 = require(ReplicatedStorage.Shared.Types.MonsterParasite)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local rarities = Rarity.Rarities
local Spring = require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
local _ = {
	Fallback = "rbxassetid://116351329433541",
	Glow = "rbxassetid://109516122757226",
	GlowScale = 1.1,
	GlowTransparency = 0.45,
	CenterY = 0.3,
	Size = 0.54
}
local random = Random.new()
local v = assert(Players.LocalPlayer, "Crate spinner requires a local player")
local flag = false

local function waitForChild(instance, childName: string)
	local child = instance:WaitForChild(childName, 5)
	assert(child ~= nil, (`{instance:GetFullName()}.{childName} did not load`))
	return child
end

local function getView()
	local v3 = v
	local playerGui = v3:WaitForChild("PlayerGui", 5)
	assert(playerGui ~= nil, (`{v3:GetFullName()}.PlayerGui did not load`))
	local crateOpeningPopUpFrame = playerGui:WaitForChild("CrateOpeningPopUpFrame", 5)
	assert(crateOpeningPopUpFrame ~= nil, (`{playerGui:GetFullName()}.CrateOpeningPopUpFrame did not load`))
	assert(crateOpeningPopUpFrame:IsA("ScreenGui"), "CrateOpeningPopUpFrame must be a ScreenGui")
	local crateOpeningPopUp = crateOpeningPopUpFrame:WaitForChild("CrateOpeningPopUp", 5)
	assert(crateOpeningPopUp ~= nil, (`{crateOpeningPopUpFrame:GetFullName()}.CrateOpeningPopUp did not load`))
	assert(crateOpeningPopUp:IsA("GuiObject"), "CrateOpeningPopUp must be a GuiObject")
	local main = crateOpeningPopUp:WaitForChild("Main", 5)
	assert(main ~= nil, (`{crateOpeningPopUp:GetFullName()}.Main did not load`))
	assert(main:IsA("Frame"), "CrateOpeningPopUp.Main must be a Frame")
	local holder = main:WaitForChild("Holder", 5)
	assert(holder ~= nil, (`{main:GetFullName()}.Holder did not load`))
	assert(holder:IsA("Frame"), "CrateOpeningPopUp.Main.Holder must be a Frame")
	local genericFrameTemplate = holder:WaitForChild("GenericFrameTemplate", 5)
	assert(genericFrameTemplate ~= nil, (`{holder:GetFullName()}.GenericFrameTemplate did not load`))
	assert(genericFrameTemplate:IsA("Frame"), "GenericFrameTemplate must be a Frame")
	local specialFrameTemplate = holder:WaitForChild("SpecialFrameTemplate", 5)
	assert(specialFrameTemplate ~= nil, (`{holder:GetFullName()}.SpecialFrameTemplate did not load`))
	assert(specialFrameTemplate:IsA("Frame"), "SpecialFrameTemplate must be a Frame")
	local uIListLayout = holder:WaitForChild("UIListLayout", 5)
	assert(uIListLayout ~= nil, (`{holder:GetFullName()}.UIListLayout did not load`))
	assert(uIListLayout:IsA("UIListLayout"), "Holder.UIListLayout must be a UIListLayout")
	local uIPadding = holder:WaitForChild("UIPadding", 5)
	assert(uIPadding ~= nil, (`{holder:GetFullName()}.UIPadding did not load`))
	assert(uIPadding:IsA("UIPadding"), "Holder.UIPadding must be a UIPadding")
	local skip = crateOpeningPopUp:WaitForChild("Skip", 5)
	assert(skip ~= nil, (`{crateOpeningPopUp:GetFullName()}.Skip did not load`))
	assert(skip:IsA("ImageButton"), "CrateOpeningPopUp.Skip must be an ImageButton")
	local arrow = crateOpeningPopUp:WaitForChild("Arrow", 5)
	assert(arrow ~= nil, (`{crateOpeningPopUp:GetFullName()}.Arrow did not load`))
	assert(arrow:IsA("ImageLabel"), "CrateOpeningPopUp.Arrow must be an ImageLabel")
	local rewardTitleFrame = crateOpeningPopUp:WaitForChild("RewardTitleFrame", 5)
	assert(rewardTitleFrame ~= nil, (`{crateOpeningPopUp:GetFullName()}.RewardTitleFrame did not load`))
	assert(rewardTitleFrame:IsA("Frame"), "RewardTitleFrame must be a Frame")
	local rewardName = rewardTitleFrame:WaitForChild("RewardName", 5)
	assert(rewardName ~= nil, (`{rewardTitleFrame:GetFullName()}.RewardName did not load`))
	assert(rewardName:IsA("TextLabel"), "RewardTitleFrame.RewardName must be a TextLabel")
	local v4

	if uIListLayout.FillDirection == Enum.FillDirection.Horizontal and uIListLayout.SortOrder == Enum.SortOrder.LayoutOrder then
		v4 = not uIListLayout.Wraps
	else
		v4 = false
	end

	assert(v4, "Holder.UIListLayout must be a single horizontal row sorted by LayoutOrder")
	return {
		Arrow = arrow,
		GenericTemplate = genericFrameTemplate,
		Holder = holder,
		Layout = uIListLayout,
		Main = main,
		Padding = uIPadding,
		Popup = crateOpeningPopUp,
		RewardName = rewardName,
		RewardTitle = rewardTitleFrame,
		Screen = crateOpeningPopUpFrame,
		Skip = skip,
		SpecialTemplate = specialFrameTemplate
	}
end

local function pickRewardId()
	local number = random:NextNumber(0, 100)
	local total = 0

	for _, reward in MonsterParasite.Rewards do
		total += reward.Weight

		if number <= total then
			return reward.Id
		end
	end

	return MonsterParasite.Rewards[#MonsterParasite.Rewards].Id
end

local function buildRewardIds(id, integer: number)
	local result = table.create(36)

	for i = 1, 36 do
		local v3

		if i == integer then
			v3 = id
		else
			v3 = pickRewardId()
		end

		result[i] = v3
	end

	return result
end

local function ensureCardImage(parent, name: string, zIndex: number, p: number, scaleType)
	local image = parent:FindFirstChild(name)

	if image ~= nil and image:IsA("ImageLabel") then
		return image
	end

	if image ~= nil then
		image:Destroy()
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.fromScale(0.5, 0.3)
	imageLabel.ScaleType = scaleType
	imageLabel.Size = UDim2.fromScale(p, p)
	imageLabel.ZIndex = zIndex
	imageLabel.Parent = parent
	return imageLabel
end

local function setFrameText(clone, p)
	local itemName = clone:FindFirstChild("ItemName")
	assert(itemName and itemName:IsA("TextLabel"), "Reward frame requires ItemName")
	local rarityLabel = clone:FindFirstChild("RarityLabel")
	assert(rarityLabel and rarityLabel:IsA("TextLabel"), "Reward frame requires RarityLabel")
	local reward = MonsterParasite.GetReward(p)
	itemName.Text = MonsterParasite.RewardLabel(reward)
	local rarity = reward.Rarity
	rarityLabel.Text = rarity
	local v3 = p == MonsterParasite2.RewardIds.MonsterEgg and "Prismatic" or rarity
	local v4 = assert(rarities[v3], (`Unknown Monster Chest rarity: {v3}`))
	SwapGradient(rarityLabel, v4.RarityGradient)
	local uIStroke = rarityLabel:FindFirstChildOfClass("UIStroke")

	if uIStroke ~= nil then
		SwapGradient(uIStroke, v4.RarityGradient)
	end

	local cardImage = ensureCardImage(clone, "Glow", 2, 0.5940000000000001, Enum.ScaleType.Stretch)
	cardImage.Image = "rbxassetid://109516122757226"
	cardImage.ImageTransparency = 0.45
	cardImage.ImageColor3 = v4.RarityGradient.Color.Keypoints[1].Value
	cardImage.Visible = true
	local cardImage2 = ensureCardImage(clone, "Icon", 3, 0.54, Enum.ScaleType.Fit)
	local fallbackIcon = clone:GetAttribute("FallbackIcon")
	cardImage2.Image = reward.Icon or typeof(fallbackIcon) ~= "string" and "rbxassetid://116351329433541" or fallbackIcon
	cardImage2.Visible = true
end

local function buildFrames(data, maid, rewardIds, p: number)
	local result = table.create(#rewardIds)
	local monsterEgg = MonsterParasite2.RewardIds.MonsterEgg

	for k, v3 in rewardIds do
		local specialTemplate

		if v3 == monsterEgg then
			specialTemplate = data.SpecialTemplate
		else
			specialTemplate = data.GenericTemplate
		end

		local frame = Instance.new("Frame")
		frame.Name = `RewardSlot{k}`
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.LayoutOrder = k
		frame.Size = UDim2.fromOffset(p, p)
		frame.Parent = data.Holder
		maid:Add(frame)
		local clone = specialTemplate:Clone()
		clone.Name = `RewardFrame{k}`
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Position = UDim2.fromScale(0.5, 0.5)
		clone.Size = UDim2.fromScale(1, 1)
		clone.Visible = true
		setFrameText(clone, v3)
		local uIScale = clone:FindFirstChildOfClass("UIScale")
		assert(uIScale ~= nil, "Reward frame requires UIScale")
		uIScale.Scale = 0.7
		clone.Parent = frame
		result[k] = {
			Scale = uIScale,
			Slot = frame
		}
	end

	return result
end

local function spinCurve(p: number)
	if p < 0.055 then
		local v3 = p / 0.055
		return v3 ^ 2 * (v3 * 0.6772486772486772 + 0.3227513227513228) * 0.08
	else
		return (1 - (1 - (p - 0.055) / 0.945) ^ 4) * 0.92 + 0.08
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatReward(data)
	if data.Id == MonsterParasite2.RewardIds.MonsterEgg and data.Egg ~= nil then
		return (`x1 {Mutations.LabelOf(data.Egg.Mutation)} {data.Egg.AssetCategory}`)
	end

	return data.DisplayName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween.Completed:Wait()
end

local function runPresentation(view, p, maid)
	local v3 = assert(p.Reward, "Successful Monster Chest result requires a reward")
	view.Screen.DisplayOrder = math.max(view.Screen.DisplayOrder, 200)
	view.Screen.ResetOnSpawn = false
	view.Popup.Visible = false
	view.Main.Visible = false
	view.RewardTitle.Visible = false
	view.Skip.Visible = true
	view.Skip.Active = true
	view.GenericTemplate.Visible = false
	view.SpecialTemplate.Visible = false
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "CrateOpeningRuntimeScale"
	uIScale.Scale = 1
	uIScale.Parent = view.Popup
	maid:Add(uIScale)
	RunService.Heartbeat:Wait()
	local v4 = math.max(view.Main.AbsoluteSize.X, 1)
	local v5 = math.max(view.Main.AbsoluteSize.Y, 1)
	local v6 = v4 * 0.176
	local v7 = v4 * 0.01
	local v8 = math.max(8, v4 * 0.01)
	local integer = random:NextInteger(29, 33)
	local rewardIds = buildRewardIds(v3.Id, integer)
	view.Layout.Padding = UDim.new(0, v7)
	view.Padding.PaddingLeft = UDim.new(0, v8)
	view.Padding.PaddingRight = UDim.new(0, v8)
	view.Holder.Size = UDim2.fromOffset(v8 * 2 + v6 * 36 + v7 * 35, v5)
	view.Holder.Position = UDim2.fromOffset(0, 0)
	local frames = buildFrames(view, maid, rewardIds, v6)
	RunService.Heartbeat:Wait()
	local v9 = view.Arrow.AbsolutePosition.X + view.Arrow.AbsoluteSize.X * 0.5
	local slot = frames[integer].Slot
	local v10 = v9 - (slot.AbsolutePosition.X + slot.AbsoluteSize.X * 0.5)
	local selectedObject = GuiService.SelectedObject
	local active = view.Popup.Active
	local zIndex = view.Popup.ZIndex
	local selectionGroup = view.Popup.SelectionGroup
	local selectionBehaviorDown = view.Popup.SelectionBehaviorDown
	local selectionBehaviorLeft = view.Popup.SelectionBehaviorLeft
	local selectionBehaviorRight = view.Popup.SelectionBehaviorRight
	local selectionBehaviorUp = view.Popup.SelectionBehaviorUp
	local active2 = view.Main.Active
	local selectable = view.RewardTitle.Selectable
	local modal = view.Skip.Modal
	local selectable2 = view.Skip.Selectable
	maid:Add(function()
		if GuiService.SelectedObject == view.Skip then
			GuiService.SelectedObject = selectedObject
		end

		view.Popup.Active = active
		view.Popup.ZIndex = zIndex
		view.Popup.SelectionGroup = selectionGroup
		view.Popup.SelectionBehaviorDown = selectionBehaviorDown
		view.Popup.SelectionBehaviorLeft = selectionBehaviorLeft
		view.Popup.SelectionBehaviorRight = selectionBehaviorRight
		view.Popup.SelectionBehaviorUp = selectionBehaviorUp
		view.Main.Active = active2
		view.RewardTitle.Selectable = selectable
		view.Skip.Modal = modal
		view.Skip.Selectable = selectable2
	end)
	local textButton = Instance.new("TextButton")
	textButton.Name = "CrateOpeningInputBlocker"
	textButton.Active = true
	textButton.AutoButtonColor = false
	textButton.BackgroundTransparency = 1
	textButton.Modal = true
	textButton.Selectable = false
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.Text = ""
	textButton.ZIndex = 1
	textButton.Parent = view.Screen
	maid:Add(textButton)
	view.Popup.Active = true
	view.Popup.ZIndex = math.max(2, zIndex)
	view.Popup.SelectionGroup = true
	view.Popup.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	view.Popup.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	view.Popup.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	view.Popup.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	view.Main.Active = true
	view.RewardTitle.Selectable = false
	view.Skip.Modal = true
	view.Skip.Selectable = true

	if not MenuNavigation.IsCursorActive() then
		GuiService.SelectedObject = view.Skip
	end

	uIScale.Scale = 0.86
	view.Popup.Visible = true
	view.Main.Visible = true
	TweenService:Create(uIScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	local flag2 = false
	MenuNavigation.SetOverride("CrateOpening", view.Popup, view.Skip, function()
		flag2 = true
		view.Skip.Active = false
	end, 2000, true)
	maid:Add(function()
		MenuNavigation.SetOverride("CrateOpening", nil)
	end)
	maid:Connect(view.Skip.Activated, function()
		flag2 = true
		view.Skip.Active = false
	end)
	local rotation = view.Arrow.Rotation
	local v11 = Spring.new(0)
	v11.Speed = 19
	v11.Damper = 0.58
	local v12 = table.create(#frames)

	local function renderOffset(p2: number, flag3: boolean)
		view.Holder.Position = UDim2.fromOffset(p2, 0)

		for k, frame in frames do
			local v13 = view.Arrow.AbsolutePosition.X + view.Arrow.AbsoluteSize.X * 0.5
			local v14 = frame.Slot.AbsolutePosition.X + frame.Slot.AbsoluteSize.X * 0.5
			local scale = math.lerp(
				1,
				0.7,
				(math.clamp(math.abs(v14 - v13) / math.max(view.Main.AbsoluteSize.X * 0.5, 1), 0, 1))
			)
			frame.Scale.Scale = scale
			local v16 = v14 - frame.Slot.AbsoluteSize.X * scale * 0.5

			if flag3 then
				local v17 = v12[k]

				if v17 and v13 < v17 and v16 <= v13 then
					Audio.Play("rbxassetid://137872392480008", script, {
						PlaybackSpeed = { 0.97, 1.03 },
						Volume = 0.72
					})
					v11:Impulse(24 * v11.Speed)
				end
			end

			v12[k] = v16
		end

		view.Arrow.Rotation = rotation + math.clamp(v11.Position, -24, 24)
	end

	renderOffset(0, false)
	local v13 = random:NextNumber() < 0.5 and -1 or 1
	local v14 = v10 + v6 * random:NextNumber(0.1, 0.19) * v13
	local number = random:NextNumber(3, 6)
	local now = os.clock()
	local v15 = nil
	local v16 = 0
	local v17 = 0

	while true do
		local now2 = os.clock()

		if flag2 and v15 == nil then
			v16 = v17
			v15 = now2
		end

		local v18

		if v15 then
			local v19 = math.clamp((now2 - v15) / 0.55, 0, 1)
			v17 = math.lerp(v16, v14, 1 - (1 - v19) ^ 5)
			v18 = v19 >= 1
		else
			local v19 = math.clamp((now2 - now) / number, 0, 1)
			local v21

			if v19 < 0.055 then
				local v22 = v19 / 0.055
				v21 = v22 ^ 2 * (v22 * 0.6772486772486772 + 0.3227513227513228) * 0.08
			else
				v21 = (1 - (1 - (v19 - 0.055) / 0.945) ^ 4) * 0.92 + 0.08
			end

			v17 = math.lerp(0, v14, v21)

			if v19 >= 1 then
				v18 = true
			else
				v18 = false
			end
		end

		renderOffset(v17, true)

		if v18 then
			task.wait(0.1)
			local v19 = view.Arrow.AbsolutePosition.X + view.Arrow.AbsoluteSize.X * 0.5
			local v20 = slot.AbsolutePosition.X + slot.AbsoluteSize.X * 0.5
			local v21 = v17 + v19 - v20
			local lastTime = os.clock()

			while true do
				local v22 = math.clamp((os.clock() - lastTime) / 0.48, 0, 1)
				renderOffset(
					math.lerp(v14, v21, (TweenService:GetValue(v22, Enum.EasingStyle.Back, Enum.EasingDirection.Out))),
					false
				)

				if v22 >= 1 then
					break
				end

				RunService.RenderStepped:Wait()
			end

			renderOffset(v21, false)
			view.Skip.Visible = false
			local rewardName = view.RewardName
			local text = formatReward(v3) -- equivalent call inferred; original call site unknown
			rewardName.Text = text
			view.RewardTitle.Visible = true
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Scale = 0.55
			uIScale2.Parent = view.RewardTitle
			maid:Add(uIScale2)
			local scale = frames[integer].Scale
			scale.Scale = 1
			local tween = TweenService:Create(
				uIScale2,
				TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Scale = 1
				}
			)
			tween:Play()
			TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1.16
			}):Play()
			tween.Completed:Wait()
			Confetti.Burst()
			playTween(scale, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1.04
			}) -- equivalent call inferred; original call site unknown
			task.wait(0.85)
			playTween(uIScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0.9
			}) -- equivalent call inferred; original call site unknown
			view.Arrow.Rotation = rotation
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

local v2 = {
	Play = function(p)
		assert(p.Success and p.Reward ~= nil, "Crate spinner requires a successful reward")

		if flag then
			return
		end

		flag = true
		local v3 = Trove.new()
		local v4 = nil
		local rotation = nil
		local v5, v6 = xpcall(function()
			local view = getView()
			v4 = view
			rotation = view.Arrow.Rotation
			runPresentation(view, p, v3)
		end, debug.traceback)

		if v4 ~= nil then
			v4.Popup.Visible = false
			v4.Main.Visible = false
			v4.RewardTitle.Visible = false
			v4.Skip.Active = false

			if rotation ~= nil then
				v4.Arrow.Rotation = rotation
			end
		end

		v3:Destroy()
		flag = false

		if not v5 then
			error(v6, 2)
		end
	end
}
return table.freeze(v2)