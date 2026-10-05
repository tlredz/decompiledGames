local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local presentation = game.ReplicatedStorage.ChickenOrHero.Presentation
local AnnouncementView = require(presentation.AnnouncementView)
local ValleyTheme = require(presentation.ValleyTheme)
local HudNavigation = require(presentation.HudNavigation)
return {
	bind = function(instance, object, callback)
		local v, v2, v3, v4 = AnnouncementView.build(instance)
		local scope = "Server"
		local v6 = false
		local v7 = false
		local v8 = true
		local connections = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function on(object2, p)
			table.insert(connections, object2:Connect(p))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function permitted()
			return ((localPlayer:GetAttribute("AdminLevel") or 0) >= 3 or localPlayer:GetAttribute("CreatorAuthorized") == true) and not localPlayer:GetAttribute("AdminRefreshActive")
		end

		local function update()
			local adminLevel = localPlayer:GetAttribute("AdminLevel") or 0

			if adminLevel < 5 then
				scope = "Server"
			end

			v3.Sender.Text = adminLevel >= 5 and "Owner:" or (localPlayer:GetAttribute("AdminTier") or "Staff") .. ":"
			v3.Global.Active = adminLevel >= 5
			v3.Global.TextTransparency = adminLevel >= 5 and 0 or 0.6
			v3.Server.BackgroundColor3 = scope == "Server" and ValleyTheme.Ink:Lerp(ValleyTheme.Gold, 0.22) or ValleyTheme.Ink
			v3.Global.BackgroundColor3 = scope == "Global" and ValleyTheme.Ink:Lerp(ValleyTheme.Purple, 0.24) or ValleyTheme.Ink
			v3.Scope.Text = scope == "Global" and "Every active server in this experience will see this." or "Only players in this server will see this."
			v3.Send.Text = v6 and "SENDING…" or scope == "Global" and "SEND TO ALL SERVERS" or "SEND TO SERVER"
			local send = v3.Send
			local active = not v6

			if active then
				if (localPlayer:GetAttribute("AdminLevel") or 0) >= 3 or localPlayer:GetAttribute("CreatorAuthorized") == true then
					active = not localPlayer:GetAttribute("AdminRefreshActive")
				else
					active = false
				end
			end

			send.Active = active
			v3.Send.AutoButtonColor = v3.Send.Active
			v3.Count.Text = #v3.Message.Text .. " / 180"
			v3.Count.TextColor3 = #v3.Message.Text > 180 and Color3.fromRGB(248, 147, 139) or ValleyTheme.Muted
			local v10 = v
			local visible = permitted() and not v7

			if visible then
				if localPlayer:GetAttribute("ClientReady") == true then
					visible = not (localPlayer:GetAttribute("JourneyOpen") or localPlayer:GetAttribute("MapVoteOpen"))
				else
					visible = false
				end
			end

			v10.Visible = visible
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hide()
			v7 = false
			v2.Visible = false
			localPlayer:SetAttribute("AnnouncementComposerOpen", nil)
			v3.Message:ReleaseFocus()
			update()
		end

		table.insert(connections, v.Activated:Connect(function()
			local v9

			if (localPlayer:GetAttribute("AdminLevel") or 0) >= 3 or localPlayer:GetAttribute("CreatorAuthorized") == true then
				v9 = not localPlayer:GetAttribute("AdminRefreshActive")
			else
				v9 = false
			end

			if not v9 then
				return
			end

			HudNavigation.opening("Announcements")
			callback()
			v7 = true
			v2.Visible = true
			localPlayer:SetAttribute("AnnouncementComposerOpen", true)
			v3.Status.Text = "Messages are filtered before sending."
			AnnouncementView.layout(instance, v3)
			update()
			v3.Message:CaptureFocus()
		end))
		on(v4.Activated, hide) -- equivalent call inferred; original call site unknown
		table.insert(connections, v3.Server.Activated:Connect(function()
			if not v6 then
				scope = "Server"
				update()
			end
		end))
		table.insert(connections, v3.Global.Activated:Connect(function()
			if not v6 and (localPlayer:GetAttribute("AdminLevel") or 0) >= 5 then
				scope = "Global"
				update()
			end
		end))
		on(v3.Message:GetPropertyChangedSignal("Text"), update) -- equivalent call inferred; original call site unknown
		table.insert(connections, v3.Send.Activated:Connect(function()
			if not v6 then
				local v9

				if (localPlayer:GetAttribute("AdminLevel") or 0) >= 3 or localPlayer:GetAttribute("CreatorAuthorized") == true then
					v9 = not localPlayer:GetAttribute("AdminRefreshActive")
				else
					v9 = false
				end

				if v9 then
					local text = v3.Message.Text:gsub("^%s+", ""):gsub("%s+$", "")

					if #text == 0 or #text > 180 then
						v3.Status.Text = "Write 1–180 characters before sending."
						return
					end

					v6 = true
					update()
					v3.Status.Text = "Filtering and sending…"
					v3.Message:ReleaseFocus()
					object:FireServer("Broadcast", {
						scope = scope,
						text = text
					})
					task.delay(15, function()
						if v8 and v6 then
							v6 = false
							v3.Status.Text = "Delivery was not confirmed. Check before sending again."
							update()
						end
					end)
				end
			end
		end))
		table.insert(connections, object.OnClientEvent:Connect(function(p, p2)
			if p == "BroadcastReply" and type(p2) == "table" then
				v6 = false
				v3.Status.Text = p2.message or ""

				if p2.ok then
					v3.Message.Text = ""
				end

				update()
			end
		end))
		table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
			if p ~= "Announcements" then
				hide() -- equivalent call inferred; original call site unknown
			end
		end))
		table.insert(connections, UserInputService.InputBegan:Connect(function(input)
			if v7 and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
				hide() -- equivalent call inferred; original call site unknown
			end
		end))

		for _, v9 in {
			"AdminLevel",
			"CreatorAuthorized",
			"AdminTier",
			"AdminRefreshActive",
			"ClientReady",
			"JourneyOpen",
			"MapVoteOpen"
		} do
			table.insert(connections, localPlayer:GetAttributeChangedSignal(v9):Connect(function()
				local v10

				if (localPlayer:GetAttribute("AdminLevel") or 0) >= 3 or localPlayer:GetAttribute("CreatorAuthorized") == true then
					v10 = not localPlayer:GetAttribute("AdminRefreshActive")
				else
					v10 = false
				end

				if v10 then
					update()
					return
				end

				hide() -- equivalent call inferred; original call site unknown
			end))
		end

		table.insert(connections, localPlayer:GetAttributeChangedSignal("AdminConsoleActive"):Connect(function()
			if localPlayer:GetAttribute("AdminConsoleActive") then
				hide() -- equivalent call inferred; original call site unknown
			end
		end))
		table.insert(connections, instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			AnnouncementView.layout(instance, v3)
		end))
		AnnouncementView.layout(instance, v3)
		update()
		return {
			destroy = function()
				v8 = false

				for _, connection in connections do
					connection:Disconnect()
				end

				hide() -- equivalent call inferred; original call site unknown
				v:Destroy()
				v2:Destroy()
			end
		}
	end
}