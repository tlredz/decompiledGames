local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local InputService = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("InputService"))
local VoteIcon = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("VoteIcon"))
local parent = script.Parent.Parent
local cardVote = workspace:WaitForChild("Info"):WaitForChild("CardVote")
local cardVoting = workspace:WaitForChild("Info"):WaitForChild("CardVoting")
local inGamePlayers = workspace:WaitForChild("InGamePlayers")
local localPlayer = Players.LocalPlayer
local flag = false
local v = {
	InputService:GetBoundKeyCode("Vote1", "Gamepad") or Enum.KeyCode.ButtonX,
	InputService:GetBoundKeyCode("Vote2", "Gamepad") or Enum.KeyCode.ButtonA,
	InputService:GetBoundKeyCode("Vote3", "Gamepad") or Enum.KeyCode.ButtonB
}
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isGamepadPreferred()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local gamepadPreferred = isGamepadPreferred() -- equivalent call inferred; original call site unknown

local function applyPlayerHolderOffset(playerHolder, uDim, p)
	if not (playerHolder and uDim) then
		return
	end

	if p then
		uDim = UDim2.new(uDim.X.Scale, uDim.X.Offset, uDim.Y.Scale, uDim.Y.Offset - 16) or uDim
	end

	TweenService:Create(playerHolder, tweenInfo3, {
		Position = uDim
	}):Play()
end

local function applyIconVisibility(buttonIcon, p)
	if not buttonIcon then
		return
	end

	TweenService:Create(buttonIcon, tweenInfo3, {
		ImageTransparency = p and 0.2 or 1,
		BackgroundTransparency = p and 0.5 or 1
	}):Play()
end

local function updateAllCards(gamepadPreferred2)
	for _, v3 in pairs(v2) do
		if not v3 then
			continue
		end

		applyPlayerHolderOffset(v3.playerHolder, v3.playerHolderBasePos, gamepadPreferred2)
		applyIconVisibility(v3.buttonIcon, gamepadPreferred2)
	end
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	local gamepadPreferred2 = isGamepadPreferred() -- equivalent call inferred; original call site unknown

	if gamepadPreferred2 == gamepadPreferred then
		return
	end

	gamepadPreferred = gamepadPreferred2
	updateAllCards(gamepadPreferred)
end)

local function addButtonIcon(clone, p)
	local v3 = v[p]

	if not v3 then
		return
	end

	local imageForKeyCode = UserInputService:GetImageForKeyCode(v3)

	if not imageForKeyCode or imageForKeyCode == "" then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ControllerButtonIcon"
	imageLabel.Image = imageForKeyCode
	imageLabel.BackgroundTransparency = gamepadPreferred and 0.5 or 1
	imageLabel.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
	imageLabel.Size = UDim2.fromScale(0.225, 0.225)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.new(0.975, 0, 0, 0)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
	uIAspectRatioConstraint.Parent = imageLabel
	local uICorner = Instance.new("UICorner", imageLabel)
	uICorner.CornerRadius = UDim.new(1, 0)
	imageLabel.ZIndex = clone.ZIndex + 1
	imageLabel.ImageTransparency = gamepadPreferred and 0.2 or 1
	imageLabel.Parent = clone:WaitForChild("Holder")
	return imageLabel
end

local function triggerSlot(p)
	if not cardVoting.Value then
		return
	end

	local character = localPlayer.Character

	if not character or character.Parent ~= inGamePlayers then
		return
	end

	local v3 = v2[p]

	if v3 then
		v3.selectFn()
	end
end

InputService:OnReady(function()
	InputService:OnAction("Vote1", function()
		if not cardVoting.Value then
			return
		end

		local character = localPlayer.Character

		if character then
			if character.Parent ~= inGamePlayers then
				return
			end

			local v3 = v2[1]

			if v3 then
				v3.selectFn()
			end
		end
	end)
	InputService:OnAction("Vote2", function()
		if not cardVoting.Value then
			return
		end

		local character = localPlayer.Character

		if character then
			if character.Parent ~= inGamePlayers then
				return
			end

			local v3 = v2[2]

			if v3 then
				v3.selectFn()
			end
		end
	end)
	InputService:OnAction("Vote3", function()
		if not cardVoting.Value then
			return
		end

		local character = localPlayer.Character

		if character then
			if character.Parent ~= inGamePlayers then
				return
			end

			local v3 = v2[3]

			if v3 then
				v3.selectFn()
			end
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function syncVoteContext()
		InputService:SetContextEnabled("CardVote", cardVoting.Value == true)
	end

	cardVoting:GetPropertyChangedSignal("Value"):Connect(syncVoteContext)
	syncVoteContext() -- equivalent call inferred; original call site unknown
end)
cardVote.ChildAdded:Connect(function(child)
	local character = localPlayer.Character

	if not character or character.Parent ~= inGamePlayers or not cardVoting.Value then
		return
	end

	local v3 = nil

	for i = 1, #v do
		if v2[i] then
			continue
		end

		v3 = i
		break
	end

	if not v3 then
		return
	end

	local votes = child:WaitForChild("Votes")
	local description = child:WaitForChild("Description")
	local icon = child:WaitForChild("Icon")
	local clone = (child.Name == "DyleFloor" and parent.VoteFrame:FindFirstChild("FancyTemplate") and parent.VoteFrame.FancyTemplate or parent.VoteFrame.Template):Clone()
	local holder = clone:FindFirstChild("Holder")
	local playerHolder = holder and holder:FindFirstChild("PlayerHolder")
	local position = playerHolder and playerHolder.Position
	clone.ZIndex = 4 - v3
	local v4 = {
		selectFn = nil,
		playerHolder = playerHolder,
		playerHolderBasePos = position,
		buttonIcon = addButtonIcon(clone, v3)
	}
	v2[v3] = v4

	if playerHolder and position then
		applyPlayerHolderOffset(playerHolder, position, gamepadPreferred)
	end

	local function addVote(stringValue, p)
		if not stringValue:IsA("StringValue") then
			return
		end

		local holder2 = clone:FindFirstChild("Holder")

		if not holder2 then
			return
		end

		local playerHolder2 = holder2:FindFirstChild("PlayerHolder")

		if not playerHolder2 or playerHolder2:FindFirstChild(stringValue.Name) then
			return
		end

		local clone2 = parent.VoteFrame.Template.Holder.PlayerHolder.Template:Clone()
		local tween = TweenService:Create(clone2.Holder, tweenInfo2, {
			Size = UDim2.new(1, 0, 1, 0)
		})
		clone2.Name = stringValue.Name
		clone2.Parent = playerHolder2
		clone2.Holder.Size = UDim2.new(0.5, 0, 0.5, 0)
		clone2.Visible = true

		if stringValue.Value and stringValue.Value ~= "" then
			clone2.Holder.ItemImage.Image = stringValue.Value
		end

		local child2 = inGamePlayers:FindFirstChild(stringValue.Name)
		local config = child2 and child2:FindFirstChild("Config")
		local moduleName = config and config:FindFirstChild("ModuleName")
		VoteIcon.Apply(clone2.Holder.ItemImage, moduleName and moduleName.Value)
		tween:Play()

		if p then
			clone.Choose:Play()
		end
	end

	for _, child2 in pairs(votes:GetChildren()) do
		addVote(child2)
	end

	local childAddedConnection = votes.ChildAdded:Connect(function(child2)
		addVote(child2, child2.Name == localPlayer.Name)
	end)
	local childRemovedConnection = votes.ChildRemoved:Connect(function(stringValue)
		if not stringValue:IsA("StringValue") then
			return
		end

		local holder2 = clone:FindFirstChild("Holder")

		if not holder2 then
			return
		end

		local playerHolder2 = holder2:FindFirstChild("PlayerHolder")

		if not playerHolder2 then
			return
		end

		local child2 = playerHolder2:FindFirstChild(stringValue.Name)

		if child2 and child.Name == clone.Name then
			child2:Destroy()
		end
	end)

	local function selectCard()
		if flag then
			return
		end

		flag = true

		if character and character.Parent == inGamePlayers and cardVoting.Value then
			ReplicatedStorage.Events.CardVoteEvent:FireServer(child)
		end

		flag = false
	end

	v4.selectFn = selectCard
	local activatedConnection = clone.Activated:Connect(selectCard)
	clone.Parent = parent.VoteFrame
	clone.Name = child.Name
	clone.Holder.ItemName.Text = child.Value
	clone.Holder.ItemDescrption.Text = description.Value
	clone.Holder.ItemImage.Image = icon.Value
	clone.Holder.Position = UDim2.new(0, 0, 1.5, 0)

	if child.Name == "IcedOver" then
		local color = Color3.fromRGB(85, 160, 210)
		local color2 = Color3.fromRGB(150, 210, 245)
		local color3 = Color3.fromRGB(180, 230, 255)

		for _, guiObject in pairs(clone:GetDescendants()) do
			if guiObject:IsA("Frame") and guiObject.BackgroundTransparency < 1 then
				guiObject.BackgroundColor3 = color
			elseif (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject.Name ~= "ItemImage" then
				guiObject.ImageColor3 = color2
			end
		end

		local holder2 = clone:FindFirstChild("Holder")

		if holder2 and not holder2:FindFirstChildOfClass("UIStroke") then
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = color3
			uIStroke.Thickness = 2
			uIStroke.Transparency = 0.2
			uIStroke.Parent = holder2
		end
	end

	clone.Visible = true
	clone.Flip:Play()
	TweenService:Create(clone.Holder, tweenInfo, {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	local destroyingConnection = nil
	destroyingConnection = child.Destroying:Connect(function()
		v2[v3] = nil
		clone.Flip:Play()
		local tween = TweenService:Create(clone.Holder, tweenInfo, {
			Position = UDim2.new(0, 0, 1.5, 0)
		})
		activatedConnection:Disconnect()
		activatedConnection = nil
		childAddedConnection:Disconnect()
		childAddedConnection = nil
		childRemovedConnection:Disconnect()
		childRemovedConnection = nil
		flag = false
		tween:Play()
		tween.Completed:Wait()
		clone:Destroy()
		clone = nil
		destroyingConnection:Disconnect()
		destroyingConnection = nil
	end)
end)
return {}