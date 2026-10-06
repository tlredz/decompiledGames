local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GroupService = game:GetService("GroupService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local joinGroup = script.Parent.CoinHUD:WaitForChild("JoinGroup")
local v = false
local v2 = false
local v3 = false
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(text)
	pcall(function()
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("SendNotification", {
			Title = "Toebuu's",
			Text = text,
			Duration = 5
		})
	end)
end

local function update()
	local groupRewardStatus = localPlayer:GetAttribute("GroupRewardStatus")
	joinGroup.Text = groupRewardStatus == "claimed" and "Reward claimed" or v2 and groupRewardStatus == "eligible" and "Claim 20 coins" or v2 and "Group: Joined" or v3 and "Request sent" or "Join +20 coins"
	local v5 = joinGroup
	local interactable = not v

	if interactable then
		if groupRewardStatus == "loading" or groupRewardStatus == nil or groupRewardStatus == "claimed" or v2 and groupRewardStatus ~= "eligible" then
			interactable = false
		else
			interactable = not v3
		end
	end

	v5.Interactable = interactable
end

local function check()
	local success, result = pcall(localPlayer.IsInGroupAsync, localPlayer, 1058336662)

	if success then
		v2 = result
		update()
	end

	return success
end

local function visible(parent)
	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == playerGui
end

local function blocked()
	if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
		return true
	end

	local success, result = pcall(function()
		return GuiService.IsModalDialog
	end)

	if success and result then
		return true
	end

	for _, guiObject in playerGui:GetDescendants() do
		if guiObject:IsA("GuiObject") and (guiObject.Name == "Panel" or guiObject.Name == "Stage" or guiObject.Name == "ResetConfirmation" or guiObject.Parent.Name == "GamepassPerkControls") and visible(guiObject) then
			return true
		end
	end

	return false
end

local v5 = false

local function claim()
	if v5 or localPlayer:GetAttribute("GroupRewardStatus") ~= "eligible" then
		return
	end

	v5 = true

	for i = 1, 4 do
		local success, result = pcall(function()
			return game.ReplicatedStorage.GroupRewardCheck:InvokeServer()
		end)

		if success and result.claimed then
			notify("Reward claimed! +20 coins. Thanks for joining!") -- equivalent call inferred; original call site unknown
			break
		else
			if success and result.existing then
				break
			end

			if i < 4 then
				task.wait(5)
			else
				notify("Your membership is still updating. Press Claim 20 coins to retry.") -- equivalent call inferred; original call site unknown
			end
		end
	end

	v5 = false
	update()
end

localPlayer:GetAttributeChangedSignal("GroupRewardStatus"):Connect(function()
	update()

	if v2 then
		task.spawn(claim)
	end
end)

local function prompt(p)
	if v2 then
		task.spawn(claim)
		return
	end

	if v or v3 then
		return
	end

	v = true
	update()
	local success, result = pcall(localPlayer.IsInGroupAsync, localPlayer, 1058336662)

	if success then
		v2 = result
		update()
	end

	if success and localPlayer:GetAttribute("GroupRewardStatus") ~= "loading" and localPlayer:GetAttribute("GroupRewardStatus") ~= nil then
		if v2 or p and blocked() then
			v = false
			update()
		else
			v4 = true
			localPlayer:SetAttribute("GroupJoinPromptAttempted", true)
			local success2, result2 = pcall(GroupService.PromptJoinAsync, GroupService, 1058336662)

			if success2 then
				v2 = result2 == Enum.GroupMembershipStatus.Joined or result2 == Enum.GroupMembershipStatus.AlreadyMember
				v3 = result2 == Enum.GroupMembershipStatus.JoinRequestPending

				if v2 then
					task.spawn(claim)
				elseif v3 then
					notify("Your join request was sent.") -- equivalent call inferred; original call site unknown
				end
			elseif not p then
				notify("Couldn't open the group prompt. Please try again in the published game.") -- equivalent call inferred; original call site unknown
			end

			v = false
			update()
		end
	else
		v = false
		update()

		if not p then
			notify("Unable to check group membership. Please try again.") -- equivalent call inferred; original call site unknown
		end
	end
end

joinGroup.Activated:Connect(function()
	prompt(false)
end)
task.spawn(function()
	local success, result = pcall(localPlayer.IsInGroupAsync, localPlayer, 1058336662)

	if success then
		v2 = result
		update()
	end

	if v2 then
		claim()
	end
end)
task.spawn(function()
	task.wait(120)

	while not v4 and not v2 and not v3 and localPlayer:GetAttribute("GroupRewardStatus") ~= "claimed" do
		if not (v or blocked()) then
			task.wait(2)

			if not blocked() then
				prompt(true)
			end
		end

		task.wait(2)
	end
end)