local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)

-- equivalent calls inferred from this helper; original call sites unknown
local function focus(selectedObject)
	if UserInputService.GamepadEnabled and not MenuNavigation.IsCursorActive() then
		GuiService.SelectedObject = selectedObject
	end
end

local function avatar(p: number)
	return (`rbxthumb://type=AvatarHeadShot&id={p}&w=420&h=420`)
end

return {
	new = function(data, callback, callback2)
		local invite = data.Root.Editor.Invite
		local invitePrompt = data.InvitePrompt
		local confirmation = invite.Confirmation
		local request = ReplicatedStorage:WaitForChild("ContentCreatorRemotes"):WaitForChild("Request")

		local function resize()
			local v = invite.AbsoluteSize.Y < 340
			invite.Back.Position = UDim2.fromOffset(14, v and 4 or 12)
			invite.Title.Position = UDim2.fromOffset(118, v and 4 or 12)
			invite.Query.Position = UDim2.fromOffset(16, v and 52 or 68)
			invite.Find.Position = UDim2.new(1, -102, 0, v and 52 or 68)
			invite.AccountCard.Position = UDim2.fromOffset(16, v and 102 or 124)
			invite.AccountCard.Size = UDim2.new(1, -32, 0, v and 60 or 100)
			invite.AccountCard.Avatar.Position = UDim2.fromOffset(10, v and 8 or 12)
			invite.AccountCard.Avatar.Size = UDim2.fromOffset(v and 44 or 72, v and 44 or 72)
			invite.AccountCard.Account.Position = UDim2.fromOffset(v and 68 or 92, v and 2 or 10)
			invite.AccountCard.Status.Position = UDim2.fromOffset(v and 68 or 92, v and 30 or 66)
			invite.Send.Position = UDim2.new(0, 16, 1, v and -52 or -58)
			invite.AccountCard.UserId.Visible = not v
			invite.Message.Visible = not v
		end

		invite:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		resize()
		local server = nil
		local v2 = nil
		local preview = nil
		local v3 = nil
		local selectedObject = nil
		local v4 = {}
		local flag = false

		local function resultView(data2)
			if not data2 then
				return
			end

			invite.Message.Text = data2.Message or ""

			if not data2.Ok then
				return
			end

			local data3 = data2.Data

			if not data3 then
				invite.Send.Visible = false
			elseif data3.NeedsWhitelist then
				preview = data3.Preview
				local account = preview.Accounts[1]
				local accountCard = invite.AccountCard
				local send = invite.Send
				accountCard.Visible = false
				send.Visible = false
				confirmation.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={account.UserId}&w=420&h=420`
				confirmation.Account.Text = "@" .. account.Name
				confirmation.UserId.Text = "User ID: " .. account.UserId
				confirmation.Message.Text = "Are you sure you want to whitelist " .. account.Name .. "?"
				confirmation.Visible = true
				focus(confirmation.Cancel) -- equivalent call inferred; original call site unknown
			elseif data3.Native then
				invite.Send.Visible = false
				local success, result = pcall(function()
					return SocialService:CanSendGameInviteAsync(Players.LocalPlayer, data3.UserId)
				end)

				if success and result then
					local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
					experienceInviteOptions.InviteUser = data3.UserId
					experienceInviteOptions.LaunchData = data3.LaunchData
					experienceInviteOptions.PromptMessage = "Join " .. data3.ServerName
					local v5 = pcall(function()
						SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
					end)
					experienceInviteOptions:Destroy()

					if not v5 then
						invite.Message.Text = "Roblox could not open the invite prompt. Find the account and try again."
						callback2(invite.Message.Text, false)
					end
				else
					invite.Message.Text = "Roblox cannot invite this account. They may need to be your friend or change their invite settings."
					callback2(invite.Message.Text, false)
				end
			elseif data3.Token then
				v2 = data3
				confirmation.Visible = false
				invite.AccountCard.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={data3.UserId}&w=420&h=420`
				invite.AccountCard.Account.Text = "@" .. data3.Name
				invite.AccountCard.UserId.Text = "User ID: " .. data3.UserId
				invite.AccountCard.Status.Text = data3.Online and "● Online in game" or "● Not in game"
				local status = invite.AccountCard.Status
				local textColor

				if data3.Online then
					textColor = Color3.fromRGB(132, 255, 0)
				else
					textColor = Color3.fromRGB(190, 190, 204)
				end

				status.TextColor3 = textColor
				invite.Send.Text = data3.Online and "Send invitation" or "Open Roblox invite"
				local accountCard = invite.AccountCard
				local send = invite.Send
				accountCard.Visible = true
				send.Visible = true
				invite.Message.Text = data3.Online and "They can accept or decline without leaving their current server first." or "Roblox will ask you to confirm. The creator must be present or within their return period when this player joins."
			end
		end

		local function request2(p)
			if flag then
				return
			end

			flag = true
			invite.Find.Text = "…"
			local success, result = pcall(function()
				local v5 = callback("invitePlayers", p)

				if v5 == nil then
					invite.Message.Text = "The panel was busy with another action. Press it again."
				end

				resultView(v5)
			end)
			flag = false
			invite.Find.Text = "Find"

			if not success then
				warn(result)
				invite.Message.Text = "Could not complete this invitation. Try again."
			end
		end

		invite.Find.Activated:Connect(function()
			local accountCard = invite.AccountCard
			local send = invite.Send
			local confirmation2 = confirmation
			accountCard.Visible = false
			send.Visible = false
			confirmation2.Visible = false
			v2 = nil
			preview = nil
			request2({
				action = "find",
				server = server,
				query = invite.Query.Text
			})
		end)
		invite.Send.Activated:Connect(function()
			if v2 then
				request2({
					action = "send",
					token = v2.Token
				})
			end
		end)
		confirmation.Confirm.Activated:Connect(function()
			if preview then
				request2({
					action = "confirm",
					token = preview.Token
				})
			end
		end)

		local function cancelWhitelist()
			confirmation.Visible = false
			preview = nil
		end

		confirmation.Cancel.Activated:Connect(cancelWhitelist)
		local v5 = false

		local function promptNative(list)
			if v5 or type(list) ~= "table" or #list == 0 then
				return
			end

			v5 = true
			local names = {}

			for k, v6 in list do
				if #list > 1 then
					callback2(`Roblox invite {k} of {#list} · @{v6.Name}`, true)
				end

				local v7 = v6
				local success, result = pcall(function()
					return SocialService:CanSendGameInviteAsync(Players.LocalPlayer, v7.UserId)
				end)

				if success and result then
					local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
					experienceInviteOptions.InviteUser = v6.UserId
					experienceInviteOptions.LaunchData = v6.LaunchData
					experienceInviteOptions.PromptMessage = "Join " .. v6.ServerName
					local v8 = false
					local gameInvitePromptClosedConnection = SocialService.GameInvitePromptClosed:Connect(function(p)
						if p == Players.LocalPlayer then
							v8 = true
						end
					end)
					local v10 = pcall(function()
						SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
					end)
					experienceInviteOptions:Destroy()

					if v10 then
						local v11 = os.clock() + 30

						while not v8 and os.clock() < v11 do
							task.wait(0.1)
						end
					else
						table.insert(names, v6.Name)
					end

					gameInvitePromptClosedConnection:Disconnect()
				else
					table.insert(names, v6.Name)
				end
			end

			v5 = false

			if #names > 0 then
				callback2(
					`Roblox would not invite {table.concat(names, ", ")}. They may need to be your friend or change their invite settings.`,
					false
				)
			end
		end

		local function back()
			if not flag then
				invite.Visible = false
			end
		end

		invite.Back.Activated:Connect(back)

		local function showNext()
			v3 = nil

			while #v4 > 0 do
				local v6 = table.remove(v4, 1)

				if not (v6.ExpiresAt > os.time()) then
					continue
				end

				v3 = v6
				break
			end

			invitePrompt.Visible = v3 ~= nil

			if v3 then
				invitePrompt.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={v3.InviterUserId}&w=420&h=420`
				invitePrompt.Account.Text = "@" .. v3.InviterName
				invitePrompt.Server.Text = v3.ServerName
				invitePrompt.Accept.Text = "Accept & join"
				invitePrompt.Decline.Text = "Decline"
				focus(invitePrompt.Decline) -- equivalent call inferred; original call site unknown
			elseif selectedObject and selectedObject.Parent then
				focus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end

		local v6 = false

		local function respond(accept)
			if not v3 or v6 then
				return
			end

			v6 = true
			local token = v3.Token
			invitePrompt.Accept.Text = "Please wait…"
			local success, result = pcall(function()
				return request:InvokeServer("respondInvite", {
					token = token,
					accept = accept
				})
			end)
			v6 = false

			if success and result then
				callback2(result.Message, result.Ok)
			else
				callback2("Could not respond. Try again.", false)
			end

			if success and result then
				showNext()
			else
				invitePrompt.Accept.Text = "Try again"
			end
		end

		invitePrompt.Accept.Activated:Connect(function()
			respond(true)
		end)
		invitePrompt.Decline.Activated:Connect(function()
			respond(false)
		end)
		task.spawn(function()
			while data.Parent do
				if v3 and not v6 then
					local v7 = v3.ExpiresAt - os.time()

					if v7 <= 0 then
						showNext()
					else
						invitePrompt.Message.Text = "Accept to join their server. Expires in " .. v7 .. "s."
					end
				end

				task.wait(1)
			end
		end)
		return {
			Back = back,
			CancelWhitelist = cancelWhitelist,
			Native = promptNative,
			Decline = function()
				respond(false)
			end,
			Open = function(p)
				if flag then
					return
				end

				server = p
				v2 = nil
				preview = nil
				invite.Query.Text = ""
				local accountCard = invite.AccountCard
				local send = invite.Send
				local confirmation2 = confirmation
				accountCard.Visible = false
				send.Visible = false
				confirmation2.Visible = false
				invite.Message.Text = "Find someone by username or user ID."
				invite.Visible = true
			end,
			Receive = function(p)
				if type(p) ~= "table" or type(p.Token) ~= "string" or v3 and v3.Token == p.Token then
					return
				end

				for _, v7 in v4 do
					if v7.Token == p.Token then
						return
					end
				end

				if #v4 >= 5 then
					task.spawn(function()
						pcall(function()
							request:InvokeServer("respondInvite", {
								token = p.Token,
								accept = false
							})
						end)
					end)
					return
				end

				table.insert(v4, p)

				if not v3 then
					selectedObject = GuiService.SelectedObject
					showNext()
				end
			end
		}
	end
}