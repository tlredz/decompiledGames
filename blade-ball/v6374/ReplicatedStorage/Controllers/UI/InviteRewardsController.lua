local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v3 = require3(ReplicatedStorage2.Packages.Promise)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
local v6 = require3(ReplicatedStorage2.Packages.Net)
local v7 = require3(ReplicatedStorage2.Packages.Reliever)
local v8 = require3(ReplicatedStorage2.ServerInfo)
local v9 = require3(ReplicatedStorage2.Common.Utils)
local v10 = require3(ReplicatedStorage2.Shared.InviteRewards)
local remoteEvent = v6:RemoteEvent("PromptFriendInviteClosed")
local remoteFunction = v6:RemoteFunction("SendAFKFriendInvite")
local localPlayer = Players.LocalPlayer
local inviteRewards = localPlayer.PlayerGui:WaitForChild("InviteRewards")
local scrollingFrame = inviteRewards.Frame.ScrollingFrame
local template = scrollingFrame.Template
template.Parent = nil
local maid = v5.new()
local v11 = nil
local promisify = v3.promisify(function(p, p2: number?)
	return SocialService:CanSendGameInviteAsync(p, p2)
end)
local promisify2 = v3.promisify(function(p: number, p2, p3)
	return Players:GetUserThumbnailAsync(p, p2, p3)
end)
local promisify3 = v3.promisify(function(p: number)
	return Players:GetFriendsAsync(p)
end)
local InviteRewardsController = {}

function InviteRewardsController:Create(data)
	local clone = maid:Clone(template)
	clone.Name = data.Id
	clone.PlayerProfile.Headshot.Image = v9.Icons:GetIcon("DEFAULT_MISSING")
	clone.Username.Text = `@{data.Username}`
	clone.Status.Text = data.IsOnline and "Online" or "Offline"
	local status = clone.Status
	local textColor

	if data.IsOnline then
		textColor = Color3.fromRGB(89, 240, 85)
	else
		textColor = Color3.fromRGB(231, 78, 89)
	end

	status.TextColor3 = textColor
	clone.LayoutOrder = data.IsOnline and 0 or 1
	clone.Parent = scrollingFrame
	clone.InviteButton:AddTag("UI_ButtonHoverAnimation2")
	maid:Add(clone.InviteButton.Activated:Connect(function()
		local promptOptions = self.PromptOptions

		if promptOptions and promptOptions.Type == "AFK" and data.IsOnline and v6:Invoke(
			"TrySendAFKInviteLocally",
			data.Id
		) == true or self.CurrentInvitePrompt then
			return
		end

		local v13 = v6:Invoke("GetInviteData", data.Id)
		local v14 = maid:Add(Instance.new("ExperienceInviteOptions"))

		if v13 then
			v14.LaunchData = HttpService:JSONEncode(v13)
		end

		v14.InviteUser = data.Id
		self.CurrentInvitePrompt = data.Id
		SocialService:PromptGameInvite(localPlayer, v14)
	end))
	maid:AddPromise(promisify2(data.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)):andThen(function(image: string)
		clone.PlayerProfile.Headshot.Image = image
	end)
	return clone
end

function InviteRewardsController:Clear()
	maid:Clean()
end

function InviteRewardsController:HasRewards()
	local v12 = v11 or v4.Client:WaitReplion("Data")

	for k in v10 do
		if not v12:Find("InviteRewards.ClaimedRewards", k) then
			return false
		end
	end

	return true
end

function InviteRewardsController:Watch(callback)
	local function update()
		callback(self:HasRewards())
	end

	local connection = (v11 or v4.Client:WaitReplion("Data")):OnArrayInsert("InviteRewards.ClaimedRewards", update)
	local connection2 = v:OnGuiOpen(inviteRewards.Name, update)
	task.spawn(update)
	return function()
		connection:Disconnect()
		connection2:Disconnect()
	end
end

function InviteRewardsController.HasFriends(_)
	if localPlayer.UserId <= 0 then
		return false
	end

	local v12, v13 = maid:AddPromise(v3.retryWithDelay(promisify3, 10, 2, localPlayer.UserId)):await()

	if v12 and v13 then
		return #v13:GetCurrentPage() > 0
	end

	return false
end

function InviteRewardsController:Update()
	local v12, v13 = maid:AddPromise(v3.retryWithDelay(promisify, 10, 2, localPlayer)):await()

	if not (v12 and v13) then
		return
	end

	local v14, v15 = maid:AddPromise(v3.retryWithDelay(promisify3, 10, 2, localPlayer.UserId)):await()

	if v14 and v15 then
		self:Clear()
		maid:AddPromise(v9.Pages:IterPagesAsync(v15)):andThen(function(items)
			maid:Add(task.spawn(function()
				for _, item in items do
					self:Create(item)
					v7.relieve()
				end
			end))
		end)
	end
end

function InviteRewardsController:CanInvite()
	return not v8.isPrivateServer() and workspace:GetAttribute("AreInvitesEnabled") and localPlayer.UserId > 0
end

function InviteRewardsController:PromptFriendInvite(p2)
	if v:IsOpen(inviteRewards.Name) then
		return false
	end

	self.PromptOptions = p2 or {
		Type = "Default"
	}
	v:Open(inviteRewards.Name)
	return true
end

function InviteRewardsController:Start()
	v11 = v4.Client:WaitReplion("Data")
	v6:Connect("PromptFriendInvite", function(...)
		self:PromptFriendInvite(...)
	end)
	SocialService.GameInvitePromptClosed:Connect(function(p)
		if p ~= localPlayer then
			return
		end

		local promptOptions = self.PromptOptions
		local currentInvitePrompt = self.CurrentInvitePrompt

		if currentInvitePrompt then
			if promptOptions and promptOptions.Type == "AFK" then
				remoteFunction:InvokeServer(currentInvitePrompt)
			else
				remoteEvent:FireServer(currentInvitePrompt)
			end
		end

		self.CurrentInvitePrompt = nil
	end)
	local privateServer = v8.isPrivateServer()
	local canInvite = self:CanInvite()
	inviteRewards.Frame.CantInvite.Visible = privateServer
	inviteRewards.Frame.CantInvite2.Visible = not (privateServer or canInvite)

	if canInvite then
		task.spawn(function()
			self:Update()
		end)
	end

	inviteRewards.Frame.Close:AddTag("UI_ButtonHoverAnimation2")
	inviteRewards.Frame.Close.Activated:Connect(function()
		v:Close(inviteRewards.Name)
	end)
	local clones = {}

	for k, v12 in v10 do
		local clone = table.clone(v12)
		clone.Id = k
		table.insert(clones, clone)
	end

	table.sort(clones, function(a, b)
		return a.Invites < b.Invites
	end)

	local function onUpdate()
		local promptOptions = self.PromptOptions

		if self:HasRewards() or promptOptions and promptOptions.Type ~= "Default" then
			inviteRewards.Frame.Position = UDim2.fromScale(0.5, 0.5)

			for k in clones do
				local child = inviteRewards.Frame:FindFirstChild((`Reward{k}`))

				if child then
					child.Visible = false
				end
			end
		else
			inviteRewards.Frame.Position = UDim2.fromScale(0.526, 0.5)
			local count = #clones

			for k, v13 in clones do
				if v11:Find("InviteRewards.ClaimedRewards", v13.Id) then
					continue
				end

				count = k
				break
			end

			for k, _ in clones do
				local child = inviteRewards.Frame:FindFirstChild((`Reward{k}`))

				if child then
					child.Visible = k == count
				end
			end
		end
	end

	self:Watch(onUpdate)
	v:OnGuiOpen(inviteRewards.Name, function()
		if self.PromptOptions then
			v2(Enum.CoreGuiType.PlayerList, false)
		else
			v:Close(inviteRewards.Name)
		end
	end)
	v:OnGuiClose(inviteRewards.Name, function()
		self.PromptOptions = nil
		v2(Enum.CoreGuiType.PlayerList, true)
	end)
end

return InviteRewardsController