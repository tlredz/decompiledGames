local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
return {
	new = function(p, callback, callback2)
		local follow = p.Root.Editor.Follow

		local function resize()
			local v = follow.AbsoluteSize.Y < 340
			follow.Back.Position = UDim2.fromOffset(14, v and 4 or 12)
			follow.Title.Position = UDim2.fromOffset(118, v and 4 or 12)
			follow.Query.Position = UDim2.fromOffset(16, v and 52 or 68)
			follow.Find.Position = UDim2.new(1, -102, 0, v and 52 or 68)
			follow.AccountCard.Position = UDim2.fromOffset(16, v and 102 or 124)
			follow.AccountCard.Size = UDim2.new(1, -32, 0, v and 60 or 100)
			follow.AccountCard.Avatar.Position = UDim2.fromOffset(10, v and 8 or 12)
			follow.AccountCard.Avatar.Size = UDim2.fromOffset(v and 44 or 72, v and 44 or 72)
			follow.AccountCard.Account.Position = UDim2.fromOffset(v and 68 or 92, v and 2 or 10)
			follow.AccountCard.Status.Position = UDim2.fromOffset(v and 68 or 92, v and 30 or 66)
			follow.Send.Position = UDim2.new(0, 16, 1, v and -52 or -58)
			follow.AccountCard.UserId.Visible = not v
			follow.Message.Visible = not v
		end

		follow:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		resize()
		local v = nil
		local flag = false
		local count = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function focus(selectedObject)
			if UserInputService.GamepadEnabled and not MenuNavigation.IsCursorActive() then
				GuiService.SelectedObject = selectedObject
			end
		end

		local function request(action: string)
			if flag or action == "follow" and not (v and v.CanFollow) then
				return
			end

			flag = true
			local v2 = count
			local v3

			if action == "find" then
				v3 = {
					action = "find",
					query = follow.Query.Text
				}
			else
				v3 = {
					action = action,
					token = v.Token
				}
			end

			if action == "find" then
				v = nil
				local accountCard = follow.AccountCard
				local send = follow.Send
				accountCard.Visible = false
				send.Visible = false
			end

			local find = follow.Find
			local send = follow.Send
			find.Text = "Finding..."
			send.Text = "Please wait..."
			local success, result = pcall(callback, "followPlayer", v3)
			flag = false
			local find2 = follow.Find
			local send2 = follow.Send
			find2.Text = "Find"
			send2.Text = "Follow player"

			if v2 ~= count then
				return
			end

			if not (success and result) then
				callback2("Could not complete the lookup. Try again.", false)
				return
			end

			follow.Message.Text = result.Message or ""
			local data = result.Data

			if result.Ok and data then
				v = data
				follow.AccountCard.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. data.UserId .. "&w=420&h=420"
				follow.AccountCard.Account.Text = "@" .. data.Name
				follow.AccountCard.UserId.Text = "User ID: " .. data.UserId
				follow.AccountCard.Status.Text = data.Status == "Online" and "Online in game" or data.Status == "Here" and "In your server" or data.Status == "Offline" and "Offline / not in game" or "Unavailable"
				local status = follow.AccountCard.Status
				local textColor

				if data.Status == "Online" or data.Status == "Here" then
					textColor = Color3.fromRGB(132, 255, 0)
				else
					textColor = Color3.fromRGB(190, 190, 204)
				end

				status.TextColor3 = textColor
				follow.AccountCard.Visible = true
				follow.Send.Visible = data.CanFollow == true
				local v5

				if data.CanFollow then
					v5 = follow.Send
				else
					v5 = follow.Find
				end

				focus(v5) -- equivalent call inferred; original call site unknown
			elseif action == "follow" then
				v = nil
				follow.Send.Visible = false
			end
		end

		follow.Find.Activated:Connect(function()
			request("find")
		end)
		follow.Query.FocusLost:Connect(function(p2)
			if p2 then
				request("find")
			end
		end)
		follow.Query:GetPropertyChangedSignal("Text"):Connect(function()
			count += 1
			v = nil
			local accountCard = follow.AccountCard
			local send = follow.Send
			accountCard.Visible = false
			send.Visible = false
		end)
		follow.Send.Activated:Connect(function()
			request("follow")
		end)

		local function back()
			follow.Visible = false
			count += 1
			focus(p.Root.Editor.Run) -- equivalent call inferred; original call site unknown
		end

		follow.Back.Activated:Connect(back)
		return {
			Back = back,
			Open = function()
				if flag then
					return
				end

				count += 1
				v = nil
				follow.Query.Text = ""
				local accountCard = follow.AccountCard
				local send = follow.Send
				accountCard.Visible = false
				send.Visible = false
				follow.Message.Text = "Find a player by username or user ID."
				follow.Visible = true
				focus(follow.Find) -- equivalent call inferred; original call site unknown
			end
		}
	end
}