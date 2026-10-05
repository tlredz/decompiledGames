local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local Trove = require(ReplicatedStorage.packages.Trove)
local Net = require(ReplicatedStorage.packages.Net)
local patch = require(ReplicatedStorage.packages.patch)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local itemDisplayInfo = require(ReplicatedStorage.client.modules.ui.Backpack.itemDisplayInfo)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local replicated = ReplicatedStorage.resources.replicated
local anno_localthoughtbig = ReplicatedStorage.events.anno_localthoughtbig
local remoteEvent = Net:RemoteEvent("Tutorial/Skip")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tutorialBeam = script:WaitForChild("TutorialBeam")
local tutorialOverlay = script:WaitForChild("TutorialOverlay")
local tutorialLabel = script:WaitForChild("TutorialLabel")
local pointAt = script:WaitForChild("PointAt")
local glow = script:WaitForChild("Glow")
local openArrow = script:WaitForChild("openArrow")
local v = game.PlaceId == 140688791331730
local v2 = {
	rod = Color3.fromRGB(153, 185, 255),
	green = Color3.fromRGB(161, 255, 169),
	bait = Color3.fromRGB(162, 234, 166),
	crab = Color3.fromRGB(192, 135, 198),
	boat = Color3.fromRGB(214, 142, 255),
	roslit = Color3.fromRGB(255, 172, 133),
	appraise = Color3.fromRGB(255, 191, 80),
	important = Color3.fromRGB(255, 234, 130)
}
local v3 = { 4, 2, 5 }
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v4 = "pc"
local v5 = nil
local currentguidelevel = nil
local rod = nil
local maid = Trove.new()
local thread = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function updateInputUI()
	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		v4 = "console"
	elseif UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
		v4 = "pc"
	elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		v4 = "mobile"
	else
		v4 = "pc"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pressWord()
	if v4 == "mobile" then
		return "Tap"
	end

	return "Click"
end

local v6 = {}

local function hl(p: string, p2: string)
	local v7 = v6[p]

	if not v7 then
		v7 = v2[p]:ToHex()
		v6[p] = v7
	end

	return (`<font color="#{v7}">{p2}</font>`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function animateLabel(label)
	label:SetAttribute("Nudge", true)
end

local function slideLabel(label, p: number)
	TweenService:Create(label, tweenInfo, {
		Position = UDim2.fromScale(0.5, p)
	}):Play()
end

local function readTime(p)
	return (math.max(3.5, #p.ContentText / 14))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onStage(p: number, p2: number)
	return v5.Value == p and currentguidelevel.Value + 1 == p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function currentLevel()
	return currentguidelevel.Value + 1
end

local function isStateValid()
	local v7 = v3[v5.Value]

	if not v7 then
		return false
	end

	local v8 = currentLevel() -- equivalent call inferred; original call site unknown
	return v8 >= 1 and v8 <= v7
end

local function waitForLevelChange(p: number?)
	local value = currentguidelevel.Value
	local value2 = v5.Value

	while currentguidelevel.Parent and v5.Value == value2 do
		if p then
			if p <= currentguidelevel.Value then
				break
			else
				task.wait()
			end
		elseif currentguidelevel.Value == value then
			task.wait()
		else
			break
		end
	end
end

local function beamTo(part, cFrame: CFrame?)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if part then
		if part:IsA("BasePart") then
			local attachment = Instance.new("Attachment")
			attachment.Name = "BeamAttachment"

			if cFrame then
				attachment.CFrame = cFrame
			end

			attachment.Parent = part
			maid:Add(attachment)
			part = attachment
		end

		local clone = tutorialBeam:Clone()
		maid:Add(clone)
		clone.Parent = humanoidRootPart
		clone.Attachment0 = part
		clone.Attachment1 = humanoidRootPart:FindFirstChild("RootAttachment")
		clone.Enabled = true

		if not clone:HasTag("IgnorePerformance") then
			clone:AddTag("IgnorePerformance")
		end

		return clone
	else
		for _, child in humanoidRootPart:GetChildren() do
			if child.Name == "TutorialBeam" then
				child:Destroy()
			end
		end
	end
end

local function npcAttachment(p: string, p2: string)
	if not v and p then
		p2 = p
	end

	local function findNpc()
		for _, tag in { "NewNpc", "LegacyNpc" } do
			for _, v7 in CollectionService:GetTagged(tag) do
				if v7.Name == p2 then
					return v7
				end
			end
		end

		return nil
	end

	local npc = findNpc()

	while not npc do
		task.wait()
		npc = findNpc()
	end

	return npc:WaitForChild("HumanoidRootPart"):FindFirstChild("RootAttachment"), npc
end

local function guideToNpc(p, p2, p3, text: string, text2: string)
	local character = p.character
	local label = p.label
	local value = v5.Value
	local value2 = currentguidelevel.Value

	local function actionDone()
		return not currentguidelevel.Parent or v5.Value ~= value or currentguidelevel.Value ~= value2
	end

	local function isNear()
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		return humanoidRootPart ~= nil and p2 ~= nil and (humanoidRootPart.Position - p2.WorldPosition).Magnitude <= 15
	end

	local function isInteracting()
		local dialoglink = character:FindFirstChild("dialoglink")

		if dialoglink and dialoglink.Value == p3 then
			return true
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		return humanoidRootPart ~= nil and humanoidRootPart:FindFirstChild("Anchor") ~= nil
	end

	local v7 = beamTo(p2)

	while currentguidelevel.Parent and v5.Value == value and currentguidelevel.Value == value2 do
		local dialoglink = character:FindFirstChild("dialoglink")
		local v8

		if dialoglink and dialoglink.Value == p3 then
			v8 = true
		else
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil then
				v8 = false
			else
				v8 = humanoidRootPart:FindFirstChild("Anchor") ~= nil
			end
		end

		if not v8 then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local v9

			if humanoidRootPart == nil or p2 == nil then
				v9 = false
			else
				v9 = (humanoidRootPart.Position - p2.WorldPosition).Magnitude <= 15
			end

			if not v9 then
				label.Text = text
				animateLabel(label) -- equivalent call inferred; original call site unknown

				while true do
					task.wait()

					if not currentguidelevel.Parent or v5.Value ~= value or currentguidelevel.Value ~= value2 then
						break
					end

					local dialoglink2 = character:FindFirstChild("dialoglink")
					local v10

					if dialoglink2 and dialoglink2.Value == p3 then
						v10 = true
					else
						local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 == nil then
							v10 = false
						else
							v10 = humanoidRootPart2:FindFirstChild("Anchor") ~= nil
						end
					end

					if v10 then
						break
					end

					local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
					local v11

					if humanoidRootPart2 == nil or p2 == nil then
						v11 = false
					else
						v11 = (humanoidRootPart2.Position - p2.WorldPosition).Magnitude <= 15
					end

					if v11 then
						break
					end
				end
			end

			if currentguidelevel.Parent and v5.Value == value and currentguidelevel.Value == value2 then
				local dialoglink2 = character:FindFirstChild("dialoglink")
				local v10

				if dialoglink2 and dialoglink2.Value == p3 then
					v10 = true
				else
					local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 == nil then
						v10 = false
					else
						v10 = humanoidRootPart2:FindFirstChild("Anchor") ~= nil
					end
				end

				if not v10 then
					label.Text = text2
					animateLabel(label) -- equivalent call inferred; original call site unknown

					while true do
						task.wait()

						if not currentguidelevel.Parent or v5.Value ~= value or currentguidelevel.Value ~= value2 then
							break
						end

						local dialoglink3 = character:FindFirstChild("dialoglink")
						local v11

						if dialoglink3 and dialoglink3.Value == p3 then
							v11 = true
						else
							local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart2 == nil then
								v11 = false
							else
								v11 = humanoidRootPart2:FindFirstChild("Anchor") ~= nil
							end
						end

						if v11 then
							break
						end
					end
				end
			end
		end

		label.Text = ""

		while true do
			task.wait()

			if not currentguidelevel.Parent or v5.Value ~= value or currentguidelevel.Value ~= value2 then
				break
			end

			local dialoglink2 = character:FindFirstChild("dialoglink")
			local v9

			if dialoglink2 and dialoglink2.Value == p3 then
				v9 = true
			else
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart == nil then
					v9 = false
				else
					v9 = humanoidRootPart:FindFirstChild("Anchor") ~= nil
				end
			end

			if not v9 then
				break
			end
		end

		local lastTime = os.clock()

		repeat
			task.wait()
		until not currentguidelevel.Parent or v5.Value ~= value or currentguidelevel.Value ~= value2 or os.clock() - lastTime >= 1
	end

	label.Text = ""

	if v7 then
		v7:Destroy()
	end
end

local function pointInInventory(p: string, value: string?, p2: string?)
	local function foundSlot(data)
		if data.Name ~= "ItemTemplate" then
			return
		end

		if p == "rod" and data.ImageLabel.Image == itemDisplayInfo.DisplayImages.rod then
			return data
		end

		if p == "item" and value and string.lower(data.ItemName.Text) == string.lower(value) then
			return data
		end

		return nil
	end

	local clone = pointAt:Clone()
	maid:Add(clone)
	clone.Label.Text = p2 or value == "Equipment Bag" and ("%* to open your equipment bag!"):format(pressWord()) or `{pressWord()} to equip{p == "rod" and " your rod" or ""}!`
	local parent = nil

	for _, guiObject in playerGui.backpack.hotbar:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
			continue
		end

		parent = foundSlot(guiObject)

		if parent then
			break
		end
	end

	if parent then
		clone.Parent = parent
		return clone
	end

	for _, child in playerGui.backpack.inventory.itemContainer:GetChildren() do
		parent = foundSlot(child)

		if parent then
			break
		end
	end

	if not parent then
		clone:Destroy()
		return nil
	end

	clone.Label:Destroy()
	clone.Arrow:Destroy()
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.fromScale(0.5, 0.5)
	clone.Size = UDim2.fromScale(1, 1)
	local clone2 = glow:Clone()
	clone2.Parent = clone
	clone2.StrokePulseEffect.Enabled = true
	clone.Parent = parent
	task.spawn(function()
		local clone3 = openArrow:Clone()
		clone3.Visible = false
		clone3.Parent = playerGui.backpack.hotbar.Folder

		while clone.Parent and clone:IsDescendantOf(playerGui.backpack) do
			task.wait()
			clone3.Visible = not playerGui.backpack.inventory.Visible
		end

		clone3:Destroy()
	end)
	return clone
end

local v7 = 4

local function forceIntoHotbar(p: string)
	if not (Backpack and Backpack.forceItemIntoHotbar and Backpack.isRodHotbarSlot) then
		return false
	end

	local v8 = math.max(Backpack.getHotbarSize(), 4)

	if v7 < 4 or v8 < v7 then
		v7 = 4
	end

	for _ = 4, v8 do
		local v9 = v7
		v7 += 1

		if v8 < v7 then
			v7 = 4
		end

		if Backpack.forceItemIntoHotbar(p, v9) then
			return true
		end

		if not Backpack.isRodHotbarSlot(v9) then
			return false
		end
	end

	return false
end

local function findItemId(p: string)
	if not Backpack then
		return nil
	end

	local v8 = Backpack._getTools and Backpack._getTools()

	if v8 then
		for k, v9 in v8 do
			if v9.Name == p then
				return k
			end
		end
	end

	local _, _, v9 = DataController.HasItem(p, nil, true)
	return v9
end

local function forceItemNameIntoHotbar(p: string)
	local itemId = findItemId(p)

	if itemId then
		return (forceIntoHotbar(itemId))
	end

	return false
end

local function makeContext(instance, clone, clone2)
	local function ctxSpawn(callback)
		local thread2 = task.spawn(callback)
		maid:Add(function()
			pcall(task.cancel, thread2)
		end)
		return thread2
	end

	local function ctxDelay(duration: number, callback)
		local thread2 = task.spawn(function()
			task.wait(duration)
			callback()
		end)
		maid:Add(function()
			pcall(task.cancel, thread2)
		end)
		return thread2
	end

	local function showLabel(text: string)
		local clone3 = tutorialLabel:Clone()
		clone3.Text = text
		clone3.Parent = clone
		local v8 = nil
		local text2 = text
		local count = 0
		clone3:GetPropertyChangedSignal("Text"):Connect(function()
			count += 1
			local v9 = count

			if v8 then
				v8:Cancel()
				v8 = nil
			end

			local v10

			if text2 == "" then
				v10 = false
			else
				v10 = clone3.MaxVisibleGraphemes ~= 0
			end

			if v10 then
				local clone4 = clone3:Clone()
				clone4.Text = text2
				clone4.Parent = clone
				local tween = TweenService:Create(clone4, tweenInfo2, {
					Position = clone4.Position - UDim2.fromScale(0, 0.05),
					TextTransparency = 1,
					TextStrokeTransparency = 1
				})
				tween.Completed:Once(function()
					clone4:Destroy()
				end)
				tween:Play()

				for _, uIStroke in clone4:GetDescendants() do
					if uIStroke:IsA("UIStroke") then
						TweenService:Create(uIStroke, tweenInfo2, {
							Transparency = 1
						}):Play()
					end
				end
			end

			text2 = clone3.Text
			clone3.MaxVisibleGraphemes = 0
			task.delay(not v10 and 0 or tweenInfo2.Time, function()
				if count ~= v9 or not clone3.Parent or clone3.Text == "" then
					return
				end

				if clone3:GetAttribute("Nudge") then
					clone3:SetAttribute("Nudge", nil)
					local position = clone3.Position
					clone3.Position = position + UDim2.fromScale(0, 0.025)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
						{
							Position = position
						}
					):Play()
				end

				local tween = TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
					MaxVisibleGraphemes = #clone3.ContentText
				})
				v8 = tween
				tween:Play()
			end)
		end)
		return clone3
	end

	local function spotlight(instance2, udim: UDim2?)
		local v8 = udim or UDim2.new()
		local frame = Instance.new("Frame")
		frame.Name = "Spotlight"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.ZIndex = 10
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 200
		numberValue.Parent = frame
		TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			Value = 0
		}):Play()
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 2000
		uIStroke.Color = Color3.fromRGB(0, 0, 0)
		uIStroke.Transparency = 0.2
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Parent = frame
		frame.Parent = clone2
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local parent = instance2.Parent

			if not (parent and parent:IsA("GuiObject")) then
				return
			end

			local absolutePosition = parent.AbsolutePosition
			local absoluteSize = parent.AbsoluteSize
			local absoluteSize2 = instance2.AbsoluteSize
			local v9 = absolutePosition.X + instance2.Position.X.Scale * absoluteSize.X + instance2.Position.X.Offset + (0.5 - instance2.AnchorPoint.X) * absoluteSize2.X
			local v10 = absolutePosition.Y + instance2.Position.Y.Scale * absoluteSize.Y + instance2.Position.Y.Offset + (0.5 - instance2.AnchorPoint.Y) * absoluteSize2.Y
			local screenGui = instance2:FindFirstAncestorOfClass("ScreenGui")

			if screenGui and screenGui.IgnoreGuiInset then
				v10 += GuiService:GetGuiInset().Y
			end

			frame.Size = UDim2.fromOffset(absoluteSize2.X, absoluteSize2.Y) + UDim2.fromOffset(
				numberValue.Value,
				numberValue.Value
			) + v8
			frame.Position = UDim2.fromOffset(v9, v10)
		end)
		frame.Destroying:Connect(function()
			renderSteppedConnection:Disconnect()
		end)
		return frame
	end

	return {
		character = instance,
		label = nil,
		trove = maid,
		showLabel = showLabel,
		spotlight = spotlight,
		spawn = ctxSpawn,
		delay = ctxDelay
	}
end

local v8 = {
	{
		name = "catch_fish",
		gate = function()
			local v9

			if v5.Value == 1 then
				v9 = currentguidelevel.Value + 1 == 1
			else
				v9 = false
			end

			if v9 then
				return v9
			end

			if v5.Value == 1 then
				v9 = currentguidelevel.Value + 1 == 2
			else
				v9 = false
			end

			if not v9 then
				if v5.Value == 1 then
					return currentguidelevel.Value + 1 == 3
				else
					return false
				end
			end

			return v9
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local tutorialArea = workspace:WaitForChild("active"):FindFirstChild("TutorialArea")

			if not tutorialArea then
				tutorialArea = replicated.fishing.TutorialArea:Clone()
				tutorialArea.Parent = workspace:WaitForChild("active")
				maid:Add(tutorialArea)
			end

			local v9 = beamTo(tutorialArea.Area:FindFirstChild("Attachment"))
			local v10 = nil
			local flag2 = false
			data.spawn(function()
				-- equivalent calls inferred from this helper; original call sites unknown
				local function equippedRod()
					return character:FindFirstChild(rod.Value)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function activeBobber()
					local v11 = equippedRod() -- equivalent call inferred; original call site unknown
					return v11 and v11:FindFirstChild("bobber")
				end

				while not flag2 and task.wait() do
					if character:FindFirstChild(rod.Value) then
						label.Text = ("%* and hold!"):format(pressWord())

						while true do
							task.wait()

							if flag2 or not character:FindFirstChild(rod.Value) or activeBobber() then
								break
							end
						end

						label.Text = ""

						while true do
							task.wait()

							if flag2 or (not activeBobber() or playerGui:FindFirstChild("shakeui") or playerGui:FindFirstChild("reel")) then
								break
							end
						end

						if playerGui:FindFirstChild("shakeui") then
							label.Text = ("%* \"SHAKE\" to speed up fishing!"):format(pressWord())

							while true do
								task.wait()

								if flag2 or (not activeBobber() or playerGui:FindFirstChild("reel")) then
									break
								end
							end

							label.Text = ""
						end

						local reel = playerGui:FindFirstChild("reel")

						if reel then
							local bar = reel:FindFirstChild("bar")

							if bar then
								bar.mobile.Size = UDim2.fromScale(0.3, 2.5)
								bar.pc.Size = UDim2.new(0.24, 0, 0, 60)
							end

							repeat
								task.wait()
							until flag2 or not reel.Parent

							local lastTime = os.clock()

							repeat
								task.wait()
							until flag2 or os.clock() - lastTime >= 1
						end
					else
						label.Text = ""
						v10 = pointInInventory("rod")

						if v10 then
							local parent = v10.Parent

							repeat
								task.wait()
							until flag2 or character:FindFirstChild(rod.Value) or not parent.Parent or parent.ImageLabel.Image ~= itemDisplayInfo.DisplayImages.rod or not parent:IsDescendantOf(playerGui.backpack)

							if v10 then
								v10:Destroy()
								v10 = nil
							end
						end
					end
				end

				label.Text = ""
			end)
			waitForLevelChange(3)
			flag2 = true

			if v10 then
				v10:Destroy()
				v10 = nil
			end

			if v9 then
				v9:Destroy()
			end

			if tutorialArea.Parent then
				tutorialArea:Destroy()
			end
		end
	},
	{
		name = "merchant",
		gate = function()
			return onStage(1, 4)
		end,
		run = function(p)
			local v9, v10 = npcAttachment("Marc Merchant", "Test Merchant")
			local rod2 = v6.rod

			if not rod2 then
				rod2 = v2.rod:ToHex()
				v6.rod = rod2
			end

			guideToNpc(
				p,
				v9,
				v10,
				"Follow the path to meet the Merchant!",
				`Talk to the Merchant to sell your {`<font color="#{rod2}">fish</font>`}!`
			)
		end
	},
	{
		name = "bait_crates",
		gate = function()
			return onStage(2, 1)
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local green = v6.green

			if not green then
				green = v2.green:ToHex()
				v6.green = green
			end

			label.Text = `Here, have some {`<font color="#{green}">Bait Crates</font>`}. Lets open them!`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			local itemId = findItemId("Bait Crate")

			if itemId then
				forceIntoHotbar(itemId)
			end

			data.spawn(function()
				while task.wait() do
					local v10

					if v5.Value == 2 then
						v10 = currentguidelevel.Value + 1 == 1
					else
						v10 = false
					end

					if not v10 then
						break
					end

					if character:FindFirstChild("Bait Crate") then
						continue
					end

					local label2 = label
					local green2 = v6.green

					if not green2 then
						green2 = v2.green:ToHex()
						v6.green = green2
					end

					label2.Text = `Here, have some {`<font color="#{green2}">Bait Crates</font>`}. Lets open them!`
					local v13 = pointInInventory("item", "Bait Crate")

					if not v13 then
						continue
					end

					local parent = v13.Parent

					while true do
						task.wait()

						if character:FindFirstChild("Bait Crate") or not parent or parent.ItemName.Text ~= "Bait Crate" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack)) then
							break
						end

						local v14

						if v5.Value == 2 then
							v14 = currentguidelevel.Value + 1 == 1
						else
							v14 = false
						end

						if not v14 then
							break
						end
					end

					v13:Destroy()

					while task.wait() and character:FindFirstChild("Bait Crate") do
						label.Text = ("%* to open!"):format(pressWord())

						repeat
							task.wait()
						until not character:FindFirstChild("Bait Crate") or currentguidelevel.Value + 1 ~= 1

						label.Text = ""

						if currentguidelevel.Value + 1 ~= 1 then
							break
						end
					end

					if currentguidelevel.Value + 1 ~= 1 then
						break
					end
				end
			end)

			repeat
				task.wait()
				local v10

				if v5.Value == 2 then
					v10 = currentguidelevel.Value + 1 == 1
				else
					v10 = false
				end
			until not v10
		end
	},
	{
		name = "equip_bait",
		gate = function()
			return onStage(2, 2)
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local green = v6.green

			if not green then
				green = v2.green:ToHex()
				v6.green = green
			end

			label.Text = `Now that you've opened your {`<font color="#{green}">Bait Crates</font>`}, let's equip some bait from it!`
			slideLabel(label, 0.05)
			local baits = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("equipment"):WaitForChild("Right"):WaitForChild("Container"):WaitForChild("Baits")
			local itemId = findItemId("Equipment Bag")

			if itemId then
				forceIntoHotbar(itemId)
			end

			data.spawn(function()
				while task.wait() do
					local v10

					if v5.Value == 2 then
						v10 = currentguidelevel.Value + 1 == 2
					else
						v10 = false
					end

					if not v10 then
						break
					end

					if character:FindFirstChild("Equipment Bag") then
						continue
					end

					local label2 = label
					local green2 = v6.green

					if not green2 then
						green2 = v2.green:ToHex()
						v6.green = green2
					end

					label2.Text = `Now that you've opened your {`<font color="#{green2}">Bait Crates</font>`}, let's equip some bait from it!`
					local v13 = pointInInventory("item", "Equipment Bag")

					if not v13 then
						continue
					end

					local parent = v13.Parent

					while true do
						task.wait()

						if character:FindFirstChild("Equipment Bag") then
							break
						end

						local v14

						if v5.Value == 2 then
							v14 = currentguidelevel.Value + 1 == 2
						else
							v14 = false
						end

						if not v14 or not parent or parent.ItemName.Text ~= "Equipment Bag" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack)) then
							break
						end
					end

					v13:Destroy()

					while task.wait() and character:FindFirstChild("Equipment Bag") do
						if not baits.Visible then
							local label3 = label
							local bait = v6.bait

							if not bait then
								bait = v2.bait:ToHex()
								v6.bait = bait
							end

							label3.Text = `Click the {`<font color="#{bait}">Baits</font>`} button on the right side of the Equipment Bag`
						end

						repeat
							task.wait()
						until not character:FindFirstChild("Equipment Bag") or baits.Visible

						local label4 = label
						local bait = v6.bait

						if not bait then
							bait = v2.bait:ToHex()
							v6.bait = bait
						end

						label4.Text = `{`<font color="#{bait}">[Equip]</font>`} any of the Baits on the right side of the Equipment Bag`
						local layoutOrder = 1e999
						local v16 = nil

						for _, frame in baits.ScrollingFrame:GetChildren() do
							if not (frame:IsA("Frame") and frame.LayoutOrder < layoutOrder) then
								continue
							end

							layoutOrder = frame.LayoutOrder
							v16 = frame
						end

						local v17

						if v16 then
							v17 = data.spotlight(v16.Equip, UDim2.fromOffset(30, 30))
						end

						repeat
							task.wait()
						until not character:FindFirstChild("Equipment Bag") or not baits.Visible or currentguidelevel.Value + 1 ~= 2

						if v17 then
							v17:Destroy()
						end

						label.Text = ""

						if currentguidelevel.Value + 1 ~= 2 then
							break
						end
					end

					if currentguidelevel.Value + 1 ~= 2 then
						break
					end
				end
			end)

			while true do
				task.wait()
				local v10

				if v5.Value == 2 then
					v10 = currentguidelevel.Value + 1 == 2
				else
					v10 = false
				end

				if v10 then
					continue
				end

				while character:FindFirstChild("Equipment Bag") and task.wait() do
					label.Text = ("%* the Equipment Bag again to close!"):format(pressWord())
					local v11 = pointInInventory("item", "Equipment Bag", ("%* again to close!"):format(pressWord()))

					if not v11 then
						continue
					end

					local parent = v11.Parent

					repeat
						task.wait()
					until not character:FindFirstChild("Equipment Bag") or not parent or parent.ItemName.Text ~= "Equipment Bag" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack))

					v11:Destroy()
				end

				local bait = v6.bait

				if not bait then
					bait = v2.bait:ToHex()
					v6.bait = bait
				end

				label.Text = `{`<font color="#{bait}">Baits</font>`} are a way to enhance & improve your fishing experience!`
				slideLabel(label, 0.6)
				task.wait((math.max(3.5, #label.ContentText / 14)))
				break
			end
		end
	},
	{
		name = "crab_cage",
		gate = function()
			return onStage(3, 1)
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local crab = v6.crab

			if not crab then
				crab = v2.crab:ToHex()
				v6.crab = crab
			end

			label.Text = `Next, is {`<font color="#{crab}">Crab Cages</font>`}. Hold out one to start.`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			local itemId = findItemId("Crab Cage")

			if itemId then
				forceIntoHotbar(itemId)
			end

			while task.wait() do
				local v10

				if v5.Value == 3 then
					v10 = currentguidelevel.Value + 1 == 1
				else
					v10 = false
				end

				if not v10 or character:FindFirstChild("Crab Cage") then
					break
				end

				local v11 = pointInInventory("item", "Crab Cage")

				if not v11 then
					continue
				end

				local parent = v11.Parent

				while true do
					task.wait()

					if character:FindFirstChild("Crab Cage") then
						break
					end

					local v12

					if v5.Value == 3 then
						v12 = currentguidelevel.Value + 1 == 1
					else
						v12 = false
					end

					if not v12 or not parent or parent.ItemName.Text ~= "Crab Cage" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack)) then
						break
					end
				end

				v11:Destroy()

				if character:FindFirstChild("Crab Cage") then
					break
				end
			end

			local crab2 = v6.crab

			if not crab2 then
				crab2 = v2.crab:ToHex()
				v6.crab = crab2
			end

			label.Text = `You can place {`<font color="#{crab2}">Crab Cages</font>`} on water. Be patient, it takes a while for fish to appear in it!`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			data.delay(math.max(3.5, #label.ContentText / 14), function()
				local v11

				if v5.Value == 3 then
					v11 = currentguidelevel.Value + 1 == 1
				else
					v11 = false
				end

				if not v11 then
					return
				end

				slideLabel(label, 0.05)
				task.wait(2)
				local v12

				if v5.Value == 3 then
					v12 = currentguidelevel.Value + 1 == 1
				else
					v12 = false
				end

				if not v12 then
					return
				end

				local label2 = label
				local crab3 = v6.crab

				if not crab3 then
					crab3 = v2.crab:ToHex()
					v6.crab = crab3
				end

				label2.Text = `For the Tutorial, the first {`<font color="#{crab3}">Crab Cage</font>`} catches a fish really fast! So don't get used to it...`
				animateLabel(label) -- equivalent call inferred; original call site unknown
			end)

			while true do
				task.wait()
				local v11

				if v5.Value == 3 then
					v11 = currentguidelevel.Value + 1 == 1
				else
					v11 = false
				end

				if v11 then
					continue
				end

				local crab3 = v6.crab

				if not crab3 then
					crab3 = v2.crab:ToHex()
					v6.crab = crab3
				end

				local formatted = `<font color="#{crab3}">Crab Cages</font>`
				local important = v6.important

				if not important then
					important = v2.important:ToHex()
					v6.important = important
				end

				local formatted2 = `<font color="#{important}">important</font>`
				local bait = v6.bait

				if not bait then
					bait = v2.bait:ToHex()
					v6.bait = bait
				end

				label.Text = `{formatted} are an {formatted2} part of Fisch! You can even use {`<font color="#{bait}">Bait</font>`} on them.`
				slideLabel(label, 0.6)
				task.wait((math.max(3.5, #label.ContentText / 14)))
				local important2 = v6.important

				if not important2 then
					important2 = v2.important:ToHex()
					v6.important = important2
				end

				label.Text = `Now, on the topic of {`<font color="#{important2}">importance</font>`}...`
				animateLabel(label) -- equivalent call inferred; original call site unknown
				task.wait((math.max(3.5, #label.ContentText / 14)))
				break
			end
		end
	},
	{
		name = "appraiser",
		gate = function()
			return onStage(3, 2)
		end,
		run = function(p)
			local v9, v10 = npcAttachment("Appraiser", "Appraiser")
			local rod2 = v6.rod

			if not rod2 then
				rod2 = v2.rod:ToHex()
				v6.rod = rod2
			end

			local formatted = `<font color="#{rod2}">fish</font>`
			local appraise = v6.appraise

			if not appraise then
				appraise = v2.appraise:ToHex()
				v6.appraise = appraise
			end

			local formatted2 = `<font color="#{appraise}">Appraise</font>`
			local rod3 = v6.rod

			if not rod3 then
				rod3 = v2.rod:ToHex()
				v6.rod = rod3
			end

			guideToNpc(
				p,
				v9,
				v10,
				"Follow the path to meet the Appraiser!",
				`Hold out a {formatted} and talk to the Appraiser to {formatted2} your {`<font color="#{rod3}">fish</font>`}!`
			)
		end
	},
	{
		name = "rod_purchase",
		gate = function()
			return onStage(3, 3)
		end,
		run = function(p)
			local character = p.character
			local label = p.label
			local v9 = {
				"Lucky Rod",
				"Fast Rod",
				"Plastic Rod",
				"Training Rod"
			}

			for _, child in workspace:WaitForChild("world"):WaitForChild("interactables"):GetChildren() do
				if table.find(v9, child.Name) then
					beamTo(child.PrimaryPart)
				end
			end

			local rod2 = v6.rod

			if not rod2 then
				rod2 = v2.rod:ToHex()
				v6.rod = rod2
			end

			label.Text = `Purchase any {`<font color="#{rod2}">fishing rod</font>`} near the Merchant!`
			slideLabel(label, 0.05)
			local value = rod.Value

			local function rodChanged()
				return rod.Value ~= value
			end

			waitForLevelChange()
			beamTo()
			local rod3 = v6.rod

			if not rod3 then
				rod3 = v2.rod:ToHex()
				v6.rod = rod3
			end

			label.Text = `Since you've bought a new {`<font color="#{rod3}">fishing rod</font>`}, equip it in your Equipment Bag!`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			local itemId = findItemId("Equipment Bag")

			if itemId then
				forceIntoHotbar(itemId)
			end

			while rod.Value == value and task.wait() do
				if character:FindFirstChild("Equipment Bag") then
					local rod4 = v6.rod

					if not rod4 then
						rod4 = v2.rod:ToHex()
						v6.rod = rod4
					end

					label.Text = `In the main portion of your Equipment Bag, equip your new {`<font color="#{rod4}">fishing rod</font>`} you just bought!`

					repeat
						task.wait()
					until not character:FindFirstChild("Equipment Bag") or rod.Value ~= value

					label.Text = ""
				else
					local rod4 = v6.rod

					if not rod4 then
						rod4 = v2.rod:ToHex()
						v6.rod = rod4
					end

					label.Text = `Since you've bought a new {`<font color="#{rod4}">fishing rod</font>`}, equip it in your Equipment Bag!`
					local v13 = pointInInventory("item", "Equipment Bag")

					if v13 then
						local parent = v13.Parent

						repeat
							task.wait()
						until character:FindFirstChild("Equipment Bag") or rod.Value ~= value or not parent or parent.ItemName.Text ~= "Equipment Bag" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack))

						v13:Destroy()
					end
				end
			end

			while character:FindFirstChild("Equipment Bag") and task.wait() do
				label.Text = ("%* the Equipment Bag again to close!"):format(pressWord())
				local v12 = pointInInventory("item", "Equipment Bag", ("%* again to close!"):format(pressWord()))

				if not v12 then
					continue
				end

				local parent = v12.Parent

				repeat
					task.wait()
				until not character:FindFirstChild("Equipment Bag") or not parent or parent.ItemName.Text ~= "Equipment Bag" or not (parent.Parent and parent:IsDescendantOf(playerGui.backpack))

				v12:Destroy()
			end

			local rod4 = v6.rod

			if not rod4 then
				rod4 = v2.rod:ToHex()
				v6.rod = rod4
			end

			label.Text = `{`<font color="#{rod4}">Fishing rods</font>`} can get really powerful! There's always new ones to use in Fisch!`
			slideLabel(label, 0.6)
			task.wait((math.max(3.5, #label.ContentText / 14)))
			label.Text = ""
		end
	},
	{
		name = "gps",
		gate = function()
			return onStage(3, 4)
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local green = v6.green

			if not green then
				green = v2.green:ToHex()
				v6.green = green
			end

			label.Text = `Next, purchase a {`<font color="#{green}">GPS</font>`}. It's extremely useful for your navigation needs!`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			data.delay(3, function()
				slideLabel(label, 0.05)
			end)
			local hasItem = DataController.HasItem("GPS")
			local GPS = workspace:WaitForChild("world"):WaitForChild("interactables"):WaitForChild("GPS")

			for _, child in GPS.Parent:GetChildren() do
				if child.Name == "GPS" and child:FindFirstChild("moosewood") then
					GPS = child
				end
			end

			local attachment = GPS:WaitForChild("handle"):FindFirstChild("Attachment")
			local v10

			if hasItem or not attachment then
				v10 = nil
			else
				v10 = beamTo(attachment)
			end

			local fn

			if not hasItem then
				local v11 = DataController.InventoryReplicator:Listen({ "Inventory" }, function()
					hasItem = DataController.HasItem("GPS")
				end)
				local flag2 = false

				fn = function()
					if flag2 then
						return
					end

					flag2 = true
					v11()
				end

				maid:Add(fn)
			end

			if v10 then
				data.spawn(function()
					local magnitude = nil

					while (not magnitude or magnitude > 5) and not hasItem do
						local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							magnitude = (humanoidRootPart.Position - attachment.Parent.Position).Magnitude
						end

						task.wait()
					end

					if v10 then
						v10:Destroy()
						v10 = nil
					end
				end)
			end

			repeat
				task.wait()
			until hasItem

			if fn then
				fn()
			end

			if v10 then
				v10:Destroy()
				v10 = nil
			end

			label.Text = ""
			label.Position = UDim2.fromScale(0.5, 0.6)
		end
	},
	{
		name = "shipwright",
		gate = function()
			return onStage(3, 5)
		end,
		run = function(data)
			local character = data.character
			local label = data.label
			local v9, v10 = npcAttachment("Moosewood Shipwright", "Test Shipwright")
			local boat = v6.boat

			if not boat then
				boat = v2.boat:ToHex()
				v6.boat = boat
			end

			local formatted = `<font color="#{boat}">Boats</font>`
			local boat2 = v6.boat

			if not boat2 then
				boat2 = v2.boat:ToHex()
				v6.boat = boat2
			end

			guideToNpc(
				data,
				v9,
				v10,
				"Follow the path to meet the Shipwright!",
				`You can buy and spawn {formatted} from Shipwrights. If you bought a {`<font color="#{boat2}">Boat</font>`}, spawn one in!`
			)
			local boat3 = v6.boat

			if not boat3 then
				boat3 = v2.boat:ToHex()
				v6.boat = boat3
			end

			label.Text = `If you spawned in the {`<font color="#{boat3}">Boat</font>`}, you can sit in "{localPlayer.Name}'s Seat" and drive it!`
			slideLabel(label, 0.05)
			task.wait((math.max(3.5, #label.ContentText / 14)))
			local roslit = v6.roslit

			if not roslit then
				roslit = v2.roslit:ToHex()
				v6.roslit = roslit
			end

			label.Text = `Try sailing to {`<font color="#{roslit}">Roslit Bay</font>`}!`
			animateLabel(label) -- equivalent call inferred; original call site unknown
			task.wait((math.max(3.5, #label.ContentText / 14)))
			localPlayer.CameraMinZoomDistance = 0.5
			local v16 = false
			local valueChangedConnection = nil
			local zone = character:WaitForChild("zone")

			local function checkRoslit()
				local value = zone.Value

				if not value then
					return
				end

				local name = value.Name

				if name ~= "Roslit" and string.split(name, " ")[1] ~= "Roslit" then
					return
				end

				v16 = true

				if valueChangedConnection and valueChangedConnection.Connected then
					valueChangedConnection:Disconnect()
					valueChangedConnection = nil
				end
			end

			task.spawn(checkRoslit)
			valueChangedConnection = zone:GetPropertyChangedSignal("Value"):Connect(checkRoslit)
			data.trove:Add(valueChangedConnection)
			local oceanPOIs = workspace:WaitForChild("active"):FindFirstChild("OceanPOI's")
			local roslitBay = oceanPOIs and oceanPOIs:FindFirstChild("Roslit Bay")
			local v17 = beamTo(roslitBay, CFrame.new(0, -240, 0))

			while not v16 do
				task.wait()
			end

			if v17 then
				v17:Destroy()
			end

			local roslit2 = v6.roslit

			if not roslit2 then
				roslit2 = v2.roslit:ToHex()
				v6.roslit = roslit2
			end

			label.Text = `Hey! You made it to {`<font color="#{roslit2}">Roslit Bay</font>`}!`
			slideLabel(label, 0.6)
			task.wait((math.max(3.5, #label.ContentText / 14)))
			label.Text = "That about sums it up! Welcome to Fisch!"
			animateLabel(label) -- equivalent call inferred; original call site unknown
			task.wait((math.max(3.5, #label.ContentText / 14)))
			slideLabel(label, 2)
		end
	}
}

local function watchInventoryForHotbar()
	if not (Backpack and Backpack.forceItemIntoHotbar) then
		warn("[TutorialController] Backpack.forceItemIntoHotbar is missing")
		return
	end

	DataController.InventoryReplicator:WaitForLoaded()
	local v9 = DataController.InventoryReplicator:Index({ "Inventory" }) or {}
	local v10 = {}

	for k in v9 do
		v10[k] = true
	end

	v7 = 4
	local clone = table.clone(v9)
	maid:Add((DataController.InventoryReplicator:Listen({ "Inventory" }, function(p)
		if not p then
			return
		end

		local diff = patch.diff(clone, p)
		clone = table.clone(p)

		if not diff then
			return
		end

		for k in diff do
			if p[k] then
				if not v10[k] then
					v10[k] = true
					forceIntoHotbar(k)
				end
			else
				v10[k] = nil
			end
		end
	end)))
end

local function runFlow(instance)
	instance:WaitForChild("HumanoidRootPart")
	local backpack = playerGui:WaitForChild("backpack")
	backpack:WaitForChild("hotbar")
	backpack:WaitForChild("inventory")
	playerGui:WaitForChild("hud")
	local clone = tutorialOverlay:Clone()
	clone.Parent = playerGui
	maid:Add(localPlayer:GetAttributeChangedSignal("A/B_CanSkipTutorial"):Connect(function()
		clone.Skip.Visible = localPlayer:GetAttribute("A/B_CanSkipTutorial") == true
	end))
	clone.Skip.Visible = localPlayer:GetAttribute("A/B_CanSkipTutorial") == true
	local skip = clone.Skip
	local skipPopup = clone.SkipPopup
	local clone2 = clone:Clone()
	clone2:ClearAllChildren()
	clone2.DisplayOrder = 999
	clone2.IgnoreGuiInset = true
	clone2.Parent = playerGui
	maid:Add(skip.Activated:Connect(function()
		skipPopup.Visible = true
	end))
	maid:Add(skipPopup.IgnoreList.Close.Activated:Connect(function()
		skipPopup.Visible = false
	end))
	maid:Add(skipPopup.Confirm.Activated:Connect(function()
		skipPopup.Visible = false
		remoteEvent:FireServer()
	end))
	maid:Add(clone)
	maid:Add(clone2)
	local context = makeContext(instance, clone, clone2)
	localPlayer.CameraMinZoomDistance = 5
	context.label = context.showLabel("")
	local v9 = false
	local v10 = nil

	while v5.Parent and v5.Value < 4 do
		local v11 = v3[v5.Value]
		local v12

		if v11 then
			local v13 = currentLevel() -- equivalent call inferred; original call site unknown

			if v13 >= 1 then
				v12 = v13 <= v11
			else
				v12 = false
			end
		else
			v12 = false
		end

		if v12 then
			v10 = nil

			if not v9 then
				watchInventoryForHotbar()
				v9 = true
			end

			local v13 = nil

			for _, v15 in v8 do
				local success, result = pcall(v15.gate, context)

				if success and result then
					v13 = v15
					break
				elseif not success then
					warn((`[TutorialController] gate '{v15.name}' errored:\n{result}`))
				end
			end

			if v13 then
				local v15, v16 = xpcall(v13.run, debug.traceback, context)

				if not v15 then
					warn((`[TutorialController] step '{v13.name}' errored, retrying:\n{v16}`))
					task.wait(1)
				end
			else
				task.wait()
			end
		else
			v10 = v10 or os.clock()

			if os.clock() - v10 >= 15 then
				warn((`[Tutorial] guide state stuck at stage {v5.Value} level {currentguidelevel.Value}, stopping`))
				localPlayer.CameraMinZoomDistance = 0.5
				beamTo()
				maid:Clean()
				return
			else
				task.wait()
			end
		end
	end

	localPlayer.CameraMinZoomDistance = 0.5
	beamTo()
	maid:Clean()
	task.wait(1)

	if flag then
		return
	end

	anno_localthoughtbig:Fire(
		"<font color = '#feffb7'>Congratulations! You completed the <b>Tutorial</b>!</font>",
		"rbxassetid://11949235061"
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFlow()
	if thread then
		pcall(task.cancel, thread)
		thread = nil
	end

	maid:Clean()
end

local function onCharacter(character)
	stopFlow() -- equivalent call inferred; original call site unknown

	if not v5.Parent or v5.Value >= 4 then
		return
	end

	thread = task.spawn(function()
		runFlow(character)
		thread = nil
	end)
end

local function onSkipped()
	local v9 = thread ~= nil
	flag = true
	stopFlow() -- equivalent call inferred; original call site unknown
	localPlayer.CameraMinZoomDistance = 0.5
	beamTo()

	if v9 then
		anno_localthoughtbig:Fire("<font color=\"#feffb7\">Skipped the <b>Tutorial</b></font>")
	end
end

return {
	Start = function()
		remoteEvent.OnClientEvent:Connect(onSkipped)
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateInputUI)
		updateInputUI() -- equivalent call inferred; original call site unknown
		task.spawn(function()
			local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
			local flag2 = false
			local childAddedConnection = nil

			local function attemptTutorial()
				if flag2 then
					return
				end

				local tracker_currentguidestage = stats:FindFirstChild("tracker_currentguidestage")

				if not tracker_currentguidestage then
					return
				end

				flag2 = true

				if childAddedConnection then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end

				v5 = tracker_currentguidestage
				currentguidelevel = v5:WaitForChild("currentguidelevel")
				rod = stats:WaitForChild("rod")

				if v5.Value >= 4 then
					return
				end

				localPlayer.CharacterAdded:Connect(onCharacter)

				if localPlayer.Character then
					local character = localPlayer.Character
					stopFlow() -- equivalent call inferred; original call site unknown

					if v5.Parent then
						if v5.Value >= 4 then
							return
						else
							thread = task.spawn(function()
								runFlow(character)
								thread = nil
							end)
						end
					end
				end
			end

			childAddedConnection = stats.ChildAdded:Connect(attemptTutorial)
			attemptTutorial()
		end)
	end
}