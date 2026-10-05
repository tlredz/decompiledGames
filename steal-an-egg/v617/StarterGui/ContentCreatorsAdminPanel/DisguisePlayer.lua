local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
return {
	new = function(p, callback, callback2)
		local disguise = p.Root.Editor.Disguise

		local function resize()
			local v = disguise.AbsoluteSize.Y < 340
			disguise.Back.Position = UDim2.fromOffset(14, v and 4 or 12)
			disguise.Title.Position = UDim2.fromOffset(118, v and 4 or 12)
			disguise.Query.Position = UDim2.fromOffset(16, v and 52 or 68)
			disguise.Find.Position = UDim2.new(1, -102, 0, v and 52 or 68)
			disguise.AccountCard.Position = UDim2.fromOffset(16, v and 102 or 124)
			disguise.AccountCard.Size = UDim2.new(1, -32, 0, v and 60 or 100)
			disguise.AccountCard.Avatar.Position = UDim2.fromOffset(10, v and 8 or 12)
			disguise.AccountCard.Avatar.Size = UDim2.fromOffset(v and 44 or 72, v and 44 or 72)
			disguise.AccountCard.Account.Position = UDim2.fromOffset(v and 68 or 92, v and 2 or 10)
			disguise.AccountCard.Status.Position = UDim2.fromOffset(v and 68 or 92, v and 30 or 66)
			disguise.Send.Position = UDim2.new(0, 16, 1, v and -52 or -58)
			disguise.AccountCard.UserId.Visible = not v
			disguise.Message.Visible = not v
		end

		disguise:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
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

		-- equivalent calls inferred from this helper; original call sites unknown
		local function back()
			disguise.Visible = false
			count += 1
			focus(p.Root.Editor.Run) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sendLabel()
			if v then
				return "Disguise as @" .. v.Name
			end

			return "Disguise"
		end

		local function request(action: string)
			if flag or action == "confirm" and not v then
				return
			end

			flag = true
			local v2 = count
			local v3

			if action == "find" then
				v3 = {
					action = "find",
					query = disguise.Query.Text
				}
			else
				v3 = {
					action = action,
					token = v.Token
				}
			end

			if action == "find" then
				v = nil
				local accountCard = disguise.AccountCard
				local send = disguise.Send
				accountCard.Visible = false
				send.Visible = false
			end

			local find = disguise.Find
			local send = disguise.Send
			find.Text = "Finding..."
			send.Text = "Please wait..."
			local success, result = pcall(callback, "disguisePlayer", v3)
			flag = false
			local find2 = disguise.Find
			local send2 = disguise.Send
			local text = sendLabel() -- equivalent call inferred; original call site unknown
			find2.Text = "Find"
			send2.Text = text

			if v2 ~= count then
				return
			end

			if not (success and result) then
				callback2("Could not complete the lookup. Try again.", false)
				return
			end

			disguise.Message.Text = result.Message or ""
			local data = result.Data

			if action == "find" and result.Ok and data then
				v = data
				disguise.AccountCard.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. data.UserId .. "&w=420&h=420"
				disguise.AccountCard.Account.Text = "@" .. data.Name
				disguise.AccountCard.UserId.Text = "User ID: " .. data.UserId
				disguise.AccountCard.Status.Text = data.DisplayName
				local accountCard = disguise.AccountCard
				local send3 = disguise.Send
				accountCard.Visible = true
				send3.Visible = true
				disguise.Send.Text = sendLabel()
				focus(disguise.Send) -- equivalent call inferred; original call site unknown
			elseif action == "confirm" and result.Ok then
				v = nil
				back() -- equivalent call inferred; original call site unknown
			end
		end

		disguise.Find.Activated:Connect(function()
			request("find")
		end)
		disguise.Query.FocusLost:Connect(function(p2)
			if p2 then
				request("find")
			end
		end)
		disguise.Query:GetPropertyChangedSignal("Text"):Connect(function()
			count += 1
			v = nil
			local accountCard = disguise.AccountCard
			local send = disguise.Send
			accountCard.Visible = false
			send.Visible = false
		end)
		disguise.Send.Activated:Connect(function()
			request("confirm")
		end)
		disguise.Back.Activated:Connect(back)
		return {
			Back = back,
			Open = function()
				if flag then
					return
				end

				count += 1
				v = nil
				disguise.Query.Text = ""
				local accountCard = disguise.AccountCard
				local send = disguise.Send
				accountCard.Visible = false
				send.Visible = false
				disguise.Message.Text = "Find a player by username or user ID."
				disguise.Visible = true
				focus(disguise.Find) -- equivalent call inferred; original call site unknown
			end
		}
	end
}