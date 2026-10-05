local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TeleportService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.Shared.PlayerNameUtility)
local clans = ReplicatedStorage2.Controllers.Clans
require3(clans.ClanController)
local v4 = require3(clans.UI.ClanPagesController)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local invite = v4.ClanGui.Pages.Invite
local message = invite.Message
local search = invite.Search
local scrollingFrame = invite.ScrollingFrame
local player = scrollingFrame.Player
player.Parent = nil
local remoteFunction = v:RemoteFunction("SendClanInvite")

local function updateMessage()
	local count = 0

	for _, v5 in Players:GetPlayers() do
		if v5 == localPlayer or v5:GetAttribute("ClanId") then
			continue
		end

		count += 1
	end

	message.Visible = count <= 0
end

local ClanInviteController = {}

function ClanInviteController:SendInvite(p: number, p2: string)
	local v5, v6 = remoteFunction:InvokeServer(p)

	if v5 then
		local rBXGeneral = TextChatService:FindFirstChild("RBXGeneral", true)

		if rBXGeneral then
			rBXGeneral:DisplaySystemMessage(("Successfully sent clan invite to %s!"):format(p2))
		end
	else
		ReplicatedStorage2.Misc.error:Play()
		_G.SendNotification(("Could not send clan invite! %s"):format(v6 or "Unknown error"))
	end
end

function ClanInviteController:Start()
	invite.Close.Activated:Connect(function()
		v4:RemovePage("Invite")
	end)
	v2.observePlayer(function(player2)
		local clone = player:Clone()
		clone.PlayerPortrait.Image = ""
		task.spawn(pcall, function()
			clone.PlayerPortrait.Image = Players:GetUserThumbnailAsync(
				player2.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		clone.Status.Text = ""
		clone.Username.Text = v3:GetHumanoidDisplayName(player2, false)
		clone.Parent = scrollingFrame

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFrameVisibility()
			local clanId = player2:GetAttribute("ClanId")

			if not clone:IsDescendantOf(game) then
				return
			end

			clone.Visible = not clanId
			updateMessage()
		end

		updateFrameVisibility() -- equivalent call inferred; original call site unknown
		local clanIdChangedConnection = player2:GetAttributeChangedSignal("ClanId"):Connect(updateFrameVisibility)
		local mouseEnterConnection = clone.MouseEnter:Connect(function()
			clone.Username.Text = v3:GetHumanoidName(player2, false)
		end)
		local mouseLeaveConnection = clone.MouseLeave:Connect(function()
			clone.Username.Text = v3:GetHumanoidDisplayName(player2, false)
		end)
		local activatedConnection = nil

		if player2 == localPlayer then
			clone.LayoutOrder = 0
			clone.Invite.Visible = false
			clone.Name = "!Self"
		else
			clone.Name = player2.DisplayName
			activatedConnection = clone.Invite.Activated:Connect(function()
				self:SendInvite(player2.UserId, player2.DisplayName)
			end)
		end

		return function()
			mouseEnterConnection:Disconnect()
			mouseLeaveConnection:Disconnect()
			clanIdChangedConnection:Disconnect()

			if activatedConnection then
				activatedConnection:Disconnect()
				activatedConnection = nil
			end

			clone:Destroy()
		end
	end)
	local thread = nil
	local v5 = nil
	search.Username:GetPropertyChangedSignal("Text"):Connect(function()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		v5 = nil
		search.PlayerPortrait.Image = ""
		search.Invite.Active = false
		search.Invite.ImageTransparency = 0.5
		search.Invite.Label.TextTransparency = 0.5
		search.Username.TextColor3 = Color3.fromRGB(255, 255, 255)
		local text = search.Username.Text
		thread = task.delay(2, function()
			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, text)

			if success and userIdFromNameAsync then
				v5 = userIdFromNameAsync
				search.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={userIdFromNameAsync}&w=150&h=150`
				search.Invite.Active = true
				search.Invite.ImageTransparency = 0
				search.Invite.Label.TextTransparency = 0
			else
				search.Username.TextColor3 = Color3.fromRGB(214, 35, 35)
				ReplicatedStorage2.Misc.error:Play()
			end
		end)
	end)
	search.Invite.Activated:Connect(function()
		if v5 then
			self:SendInvite(v5, search.Username.Text)
		end
	end)
end

return ClanInviteController