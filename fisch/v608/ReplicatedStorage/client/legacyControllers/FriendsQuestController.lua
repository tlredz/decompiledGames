local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
game:GetService("SoundService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local _ = ReplicatedStorage:WaitForChild("shared").modules
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local QuestController = require(ReplicatedStorage.client.legacyControllers.QuestController)
local remoteEvent = Net:RemoteEvent("FriendsQuestService/ToggleFriendsQuestUI")
local remoteEvent2 = Net:RemoteEvent("FriendsQuestService/UpdateQuest")
local remoteEvent3 = Net:RemoteEvent("FriendsQuestService/Invite")
local remoteEvent4 = Net:RemoteEvent("FriendsQuestService/AcceptInvite")
local remoteFunction = Net:RemoteFunction("FriendsQuestService/Spin")
local localPlayer = Players.LocalPlayer
local friends = localPlayer.PlayerGui:WaitForChild("Friends")
local v = false
local FriendsQuestController = {}

local function Animate(p: number)
	local list = friends.FriendQuests.Rewards.List
	local v2 = math.random(20, 30)
	local v3 = (p - 1 - (v2 - 1)) % 6 + 1
	local v4 = {}
	local total = 0

	for i = 1, v2 do
		local v5 = i ^ 1.5
		v4[i] = v5
		total += v5
	end

	local v5 = {}

	for i = 1, v2 do
		v5[i] = v4[i] / total * 5
	end

	for i = 1, v2 do
		for i2 = 1, 6 do
			local child = list:FindFirstChild("Result" .. i2, true)

			if not child then
				continue
			end

			local spinStroke = child:FindFirstChild("SpinStroke")

			if spinStroke then
				spinStroke.Visible = false
			end
		end

		local child = list:FindFirstChild("Result" .. v3, true)
		local spinStroke = child and child:FindFirstChild("SpinStroke")

		if spinStroke then
			spinStroke.Visible = true
		end

		script.Tick:Play()
		task.wait(v5[i])
		v3 = v3 % 6 + 1
	end

	for i = 1, 6 do
		local child = list:FindFirstChild("Result" .. i, true)

		if not child then
			continue
		end

		local spinStroke = child:FindFirstChild("SpinStroke")

		if spinStroke then
			spinStroke.Visible = false
		end
	end

	script.Success:Play()
	local child = list:FindFirstChild("Result" .. p, true)

	if child and child:FindFirstChild("SpinStroke") then
		child.SpinStroke.Visible = true
		child.SpinStroke.UIStroke.Color = Color3.fromRGB(51, 255, 85)
		GeneralUtils.fastTween(
			child.SpinStroke.UIStroke,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
			{
				Transparency = 1
			}
		)
		task.wait(8)
		GeneralUtils.fastTween(child.SpinStroke.UIStroke, TweenInfo.new(0.3), {
			Transparency = 1
		}).Completed:Wait()
		child.SpinStroke.Visible = false
		child.SpinStroke.UIStroke.Transparency = 0
		child.SpinStroke.UIStroke.Color = Color3.fromRGB(255, 225, 0)
	end

	v = false
end

local function UpdateQuestFrame(p, p2)
	local friendQuests = friends.FriendQuests
	friendQuests.Info.Quests.YourQuest.QuestDescription.Text = QuestController:GetGoalDescriptionFromId(
		`FriendQuest{p.CurrentQuestIndex}`,
		1
	)
	friendQuests.Header.Spins.Text = `Spins: {p.Spins}`
	local other = friendQuests.Info.Pair.Other
	local add = friendQuests.Info.Pair.Add
	local lastUserId = other:GetAttribute("LastUserId")

	if p2 ~= nil and lastUserId ~= p2.UserId then
		other:SetAttribute("LastUserId", p2.UserId)
		other.Image = Players:GetUserThumbnailAsync(
			p2.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
	end

	other.Visible = p2 ~= nil
	add.Visible = p2 == nil
	friendQuests.Info.Quests.FriendQuest.Friend.Visible = p2 ~= nil
	friendQuests.Spin.Visible = p.Spins > 0
end

local ToggleUI

ToggleUI = function(childName: string, visible: boolean)
	if visible == nil then
		visible = not friends:FindFirstChild(childName).Visible
	end

	local findFirstChild = friends:FindFirstChild(childName)
	findFirstChild.Visible = visible

	if childName == "InvitePlayer" and visible == false then
		ToggleUI("FriendQuests", true)
	elseif childName == "InvitePlayer" and visible == true then
		ToggleUI("FriendQuests", false)
	end
end

local function SetupInvitePlayerFrame()
	local invitePlayer = friends.InvitePlayer
	local template = invitePlayer.List.ScrollingFrame.Template
	local v2 = {}

	local function destroySlot(p)
		local v3 = v2[p.UserId]

		if v3 then
			v2[p.UserId] = nil
			v3.Instance:Destroy()
			v3.Connection:Disconnect()
		end
	end

	local function createSlot(player)
		local clone = template:Clone()
		clone.Name = player.UserId
		clone._Name.Text = `{player.DisplayName} <font color="rgb(200,200,200)">(@{player.Name})</font>`
		clone.Headshot.Image = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		clone.Parent = template.Parent
		clone.Visible = true
		v2[player.UserId] = {
			Instance = clone,
			Connection = clone.Activated:Connect(function()
				remoteEvent3:FireServer(player.UserId)
			end)
		}
	end

	for _, v3 in Players:GetPlayers() do
		if v3 ~= localPlayer then
			createSlot(v3)
		end
	end

	Players.PlayerAdded:Connect(createSlot)
	Players.PlayerRemoving:Connect(destroySlot)
	invitePlayer.Close.Activated:Connect(function()
		ToggleUI("InvitePlayer", false)
	end)
	invitePlayer.Invite.Activated:Connect(function()
		if SocialService:CanSendGameInviteAsync(localPlayer) then
			SocialService:PromptGameInvite(localPlayer)
		end
	end)
end

local function SetupFriendsQuestFrame()
	local friendQuests = friends.FriendQuests
	friendQuests.Info.Pair.You.Image = Players:GetUserThumbnailAsync(
		localPlayer.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	friendQuests.Info.Pair.Add.Activated:Connect(function()
		ToggleUI("InvitePlayer", true)
	end)
	friendQuests.Close.Activated:Connect(function()
		FriendsQuestController:Toggle(false)
	end)
	friendQuests.Spin.Activated:Connect(function()
		if v == true then
			return
		end

		local v2 = remoteFunction:InvokeServer()

		if v2 then
			v = true
			Animate(v2)
		end
	end)
end

function FriendsQuestController:Toggle(visible: boolean)
	if visible == nil or not visible then
		visible = not friends.FriendQuests.Visible
	end

	if visible ~= friends.FriendQuests.Visible then
		friends.FriendQuests.Visible = visible
	end
end

function FriendsQuestController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(...)
		FriendsQuestController:Toggle(...)
	end)
	remoteEvent2.OnClientEvent:Connect(UpdateQuestFrame)
	remoteEvent3.OnClientEvent:Connect(function(player)
		local pendingInvites = friends.PendingInvites
		local clone = pendingInvites.Container.Template:Clone()
		local maid = Trove.new()
		clone.Headshot.Image = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		clone._Name.Text = `{player.DisplayName} <font color="rgb(200,200,200)">(@{player.Name})</font>`
		clone.Visible = true
		clone.Parent = pendingInvites.Container
		maid:Add(clone)
		local activated = clone.Options.Accept.Activated
		maid:Add(activated:Connect(function()
			remoteEvent4:FireServer(player.UserId)
			maid:Destroy()
			maid = nil
		end))
		local activated2 = clone.Options.Decline.Activated
		maid:Add(activated2:Connect(function()
			maid:Destroy()
			maid = nil
		end))
		task.delay(5, function()
			if maid then
				maid:Destroy()
			end
		end)
	end)
	SetupFriendsQuestFrame()
	SetupInvitePlayerFrame()
end

return FriendsQuestController