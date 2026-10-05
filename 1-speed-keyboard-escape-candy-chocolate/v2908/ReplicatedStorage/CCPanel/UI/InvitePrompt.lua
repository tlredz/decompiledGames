local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIKit = require(script.Parent.UIKit)
local Remotes = require(ReplicatedStorage.CCPanel.Remotes)
return {
	mount = function()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "CCInvitePromptGui"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 310
		screenGui.Enabled = false
		screenGui.Parent = playerGui
		local frame = Instance.new("Frame")
		frame.Name = "Prompt"
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 90)
		frame.Size = UDim2.fromOffset(320, 148)
		frame.BackgroundColor3 = UIKit.C_BG
		frame.BorderSizePixel = 0
		UIKit.corner(frame, 8)
		frame.Parent = screenGui
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = UIKit.C_ACCENT
		uIStroke.Thickness = 2
		uIStroke.Parent = frame
		UIKit.label(
			frame,
			"Title",
			"🌍 Invitation CC Worlds",
			UDim2.new(1, -20, 0, 20),
			UDim2.new(0, 10, 0, 10),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local label = UIKit.label(
			frame,
			"Body",
			"",
			UDim2.new(1, -20, 0, 36),
			UDim2.new(0, 10, 0, 34),
			12,
			UIKit.C_TEXT,
			UIKit.FONT
		)
		label.TextWrapped = true
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.RichText = true
		local label2 = UIKit.label(
			frame,
			"Timer",
			"",
			UDim2.new(1, -20, 0, 16),
			UDim2.new(0, 10, 0, 74),
			11,
			UIKit.C_SUB,
			UIKit.FONT
		)
		local btn = UIKit.btn(
			frame,
			"Accept",
			"Accepter",
			UDim2.new(0.5, -15, 0, 30),
			UDim2.new(0, 10, 0, 100),
			UIKit.C_ON,
			Color3.new(1, 1, 1)
		)
		local btn2 = UIKit.btn(
			frame,
			"Decline",
			"Refuser",
			UDim2.new(0.5, -15, 0, 30),
			UDim2.new(0.5, 5, 0, 100),
			UIKit.C_OFF,
			Color3.new(1, 1, 1)
		)
		local v = {}
		local v2 = nil
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setButtonsActive(flag2: boolean)
			btn.Active = flag2
			btn2.Active = flag2
			btn.AutoButtonColor = flag2
			btn2.AutoButtonColor = flag2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hide()
			v2 = nil
			screenGui.Enabled = false
		end

		local function fn()
			local now = os.clock()

			while #v > 0 do
				local v3 = table.remove(v, 1)

				if not (now < v3.expiresAt) then
					continue
				end

				v2 = v3
				label.Text = string.format("<b>%s</b> t'invite dans son World %d.", v3.fromName, v3.worldIndex)
				label.RichText = true
				setButtonsActive(true) -- equivalent call inferred; original call site unknown
				flag = false
				screenGui.Enabled = true
				return
			end

			hide() -- equivalent call inferred; original call site unknown
		end

		local function respond(flag2: boolean)
			local v3 = v2

			if not v3 or flag then
				return
			end

			flag = true
			setButtonsActive(false) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local v4 = UIKit.invoke(Remotes.RespondCCWorldInvite, v3.inviteId, flag2)

				if not v4.success then
					label2.Text = tostring(v4.error or "Échec")
					label2.TextColor3 = UIKit.C_OFF
					task.wait(2)
				end

				label2.TextColor3 = UIKit.C_SUB
				fn()
			end)
		end

		btn.MouseButton1Click:Connect(function()
			local v3 = v2

			if v3 then
				if flag then
					return
				end

				flag = true
				setButtonsActive(false) -- equivalent call inferred; original call site unknown
				local v4 = true
				task.spawn(function()
					local v5 = UIKit.invoke(Remotes.RespondCCWorldInvite, v3.inviteId, v4)

					if not v5.success then
						label2.Text = tostring(v5.error or "Échec")
						label2.TextColor3 = UIKit.C_OFF
						task.wait(2)
					end

					label2.TextColor3 = UIKit.C_SUB
					fn()
				end)
			end
		end)
		btn2.MouseButton1Click:Connect(function()
			local v3 = v2

			if v3 then
				if flag then
					return
				end

				flag = true
				setButtonsActive(false) -- equivalent call inferred; original call site unknown
				local v4 = false
				task.spawn(function()
					local v5 = UIKit.invoke(Remotes.RespondCCWorldInvite, v3.inviteId, v4)

					if not v5.success then
						label2.Text = tostring(v5.error or "Échec")
						label2.TextColor3 = UIKit.C_OFF
						task.wait(2)
					end

					label2.TextColor3 = UIKit.C_SUB
					fn()
				end)
			end
		end)
		local v3 = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local now = os.clock()

			if now - v3 < 0.25 then
				return
			end

			v3 = now
			local v4 = v2

			if not v4 or flag then
				return
			end

			local v5 = math.max(0, (math.floor(v4.expiresAt - now)))

			if v5 <= 0 then
				fn()
			else
				label2.Text = "Expire dans " .. v5 .. "s"
			end
		end)
		local cCWorldInviteReceivedConnection = Remotes.CCWorldInviteReceived:connect(function(data)
			if type(data) ~= "table" then
				return
			end

			if type(data.inviteId) ~= "string" or type(data.fromName) ~= "string" or type(data.worldIndex) ~= "number" or type(data.expiresIn) ~= "number" then
				return
			end

			table.insert(v, {
				inviteId = data.inviteId,
				fromName = data.fromName,
				worldIndex = data.worldIndex,
				expiresAt = os.clock() + data.expiresIn
			})

			if not v2 then
				fn()
			end
		end)
		return {
			destroy = function()
				heartbeatConnection:Disconnect()

				if type(cCWorldInviteReceivedConnection) == "function" then
					cCWorldInviteReceivedConnection()
				end

				table.clear(v)
				v2 = nil
				screenGui:Destroy()
			end
		}
	end
}