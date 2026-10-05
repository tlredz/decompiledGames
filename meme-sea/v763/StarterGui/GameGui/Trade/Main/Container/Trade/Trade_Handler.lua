local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local tradeEvents = otherEvent:WaitForChild("TradeEvents")
local SetText = require(moduleScript:WaitForChild("SetText"))
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local trade = tradeEvents:WaitForChild("Trade")
local trade_Client = tradeEvents:WaitForChild("Trade_Client")
localPlayer:WaitForChild("Party", 60)
local tradeRequests = localPlayer:WaitForChild("RequestFolder", 60):WaitForChild("TradeRequests")
local parent = script.Parent
local parent2 = parent.Parent.Parent.Parent
local frame = parent.Frame
local playersList = frame.PlayersList
local topFrame = frame.TopFrame
local playerSearch = topFrame.PlayerSearch
local search = playerSearch.Search
local refresh = topFrame.Refresh
local player_Template = guiTemplate.TradeAssets.Player_Template
local headShot = Enum.ThumbnailType.HeadShot
local size420x420 = Enum.ThumbnailSize.Size420x420
local notification = sound_Effect:WaitForChild("Notification")
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function PlayerSearching()
	local text = string.lower(search.Text)

	for _, frame2 in ipairs(playersList:GetChildren()) do
		if not frame2:IsA("Frame") then
			continue
		end

		if text == "" or string.find(string.lower(frame2.Name), text) or string.find(
			string.lower(frame2.DisplayName_Frame.Player_DisplayName.Text),
			text
		) then
			frame2.Visible = true
		else
			frame2.Visible = false
		end
	end
end

local function SetColor_State(trade2, p: string)
	if p == "Accept" then
		trade2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		trade2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		trade2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		trade2.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Disabled" then
		trade2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		trade2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		trade2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		trade2.Colours.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	elseif p == "Trade" then
		trade2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		trade2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		trade2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		trade2.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 30, 68)
	elseif p == "Trading" then
		trade2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 130, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 72, 72))
		})
		trade2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 130, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 72, 72))
		})
		trade2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 130, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 72, 72))
		})
		trade2.Colours.Pattern.ImageColor3 = Color3.fromRGB(44, 44, 44)
	elseif p == "Pending" then
		trade2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		trade2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		trade2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		trade2.Colours.Pattern.ImageColor3 = Color3.fromRGB(0, 45, 68)
	end
end

local function Set_State(p: string, _, p2)
	if p == "Pending" then
		if localPlayer:GetAttribute("TH") then
			if p2.TradeFrame.Trade.Textlabel.Text ~= "รอดำเนินการ" then
				p2.TradeFrame.Trade.Textlabel.Text = "รอดำเนินการ"
			end
		elseif p2.TradeFrame.Trade.Textlabel.Text ~= "Pending" then
			p2.TradeFrame.Trade.Textlabel.Text = "Pending"
		end

		SetColor_State(p2.TradeFrame.Trade, "Pending")
	elseif p == "Disabled" then
		if localPlayer:GetAttribute("TH") then
			if p2.TradeFrame.Trade.Textlabel.Text ~= "ปิดเทรด" then
				p2.TradeFrame.Trade.Textlabel.Text = "ปิดเทรด"
			end
		elseif p2.TradeFrame.Trade.Textlabel.Text ~= "Disabled" then
			p2.TradeFrame.Trade.Textlabel.Text = "Disabled"
		end

		SetColor_State(p2.TradeFrame.Trade, "Disabled")
	elseif p == "Trading" then
		if localPlayer:GetAttribute("TH") then
			if p2.TradeFrame.Trade.Textlabel.Text ~= "อยู่ในการเทรด" then
				p2.TradeFrame.Trade.Textlabel.Text = "อยู่ในการเทรด"
			end
		elseif p2.TradeFrame.Trade.Textlabel.Text ~= "Trading" then
			p2.TradeFrame.Trade.Textlabel.Text = "Trading"
		end

		SetColor_State(p2.TradeFrame.Trade, "Trading")
	end
end

local function UpdatePlayerUi(p: string)
	search.Text = ""

	for _, frame2 in ipairs(playersList:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, v in ipairs(Players:GetPlayers()) do
		if v.Name == localPlayer.Name or v.Name == p or not Players:FindFirstChild(v.Name) or playersList:FindFirstChild(v.Name) then
			continue
		end

		local clone = player_Template:Clone()
		clone.Name = v.Name
		clone.Player_Name.Text = `@{v.Name}`
		clone.DisplayName_Frame.Player_DisplayName.Text = v.DisplayName
		local userThumbnailAsync = nil
		local v2 = nil
		local v3 = v
		local success, _ = pcall(function()
			userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(v3.UserId, headShot, size420x420)
		end)

		if success and userThumbnailAsync then
			clone.ProfileFrame.Profile.Image = userThumbnailAsync
		else
			clone.ProfileFrame.Profile.Image = "rbxassetid://5861062308"
		end

		clone.LayoutOrder = 0

		if v.RequestFolder.TradeRequests:FindFirstChild(localPlayer.Name) then
			SetColor_State(clone.TradeFrame.Trade, "Pending")
			clone.LayoutOrder = 1

			if localPlayer:GetAttribute("TH") then
				clone.TradeFrame.Trade.Textlabel.Text = "รอดำเนินการ"
			else
				clone.TradeFrame.Trade.Textlabel.Text = "Pending"
			end
		elseif tradeRequests:FindFirstChild(v.Name) then
			SetColor_State(clone.TradeFrame.Trade, "Accept")
			clone.LayoutOrder = -1

			if localPlayer:GetAttribute("TH") then
				clone.TradeFrame.Trade.Textlabel.Text = "ยอมรับ"
			else
				clone.TradeFrame.Trade.Textlabel.Text = "Accept"
			end
		elseif v:GetAttribute("Trading") then
			SetColor_State(clone.TradeFrame.Trade, "Trading")
			clone.LayoutOrder = 2

			if localPlayer:GetAttribute("TH") then
				clone.TradeFrame.Trade.Textlabel.Text = "อยู่ในการเทรด"
			else
				clone.TradeFrame.Trade.Textlabel.Text = "Trading"
			end
		elseif v.PlayerSettings.TradeRequests.Value == false and v:GetAttribute("LoadedData") then
			SetColor_State(clone.TradeFrame.Trade, "Disabled")
			clone.LayoutOrder = 3

			if localPlayer:GetAttribute("TH") then
				clone.TradeFrame.Trade.Textlabel.Text = "ปิดเทรด"
			else
				clone.TradeFrame.Trade.Textlabel.Text = "Disabled"
			end
		end

		if v:GetAttribute("Verified") then
			clone.DisplayName_Frame.Verified_Badge.Visible = true
			clone.LayoutOrder -= 1
		end

		if v:GetAttribute("Developer") then
			clone.DisplayName_Frame.Hammer_Badge.Visible = true
			clone.LayoutOrder -= 1
		end

		if v:GetAttribute("Friends") then
			clone.DisplayName_Frame.Friend_Badge.Visible = true
			clone.LayoutOrder -= 1
		end

		clone.Parent = playersList
		clone.Visible = true
		local v4 = v
		connections[#connections + 1] = clone.TradeFrame.Trade.Activated:Connect(function()
			if tradeRequests:FindFirstChild(v4.Name) then
				if localPlayer:GetAttribute("Trading") == nil then
					local child = Players:FindFirstChild(clone.Name)

					if child then
						if child:GetAttribute("Trading") == nil then
							trade:InvokeServer({
								Action = "Trade_Accept",
								Trader = clone.Name
							})
						elseif localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local name = clone.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} กำลังเทรดกับผู้เล่นคนอื่นอยู่!`,
								MessageColor = "White"
							})
						else
							local setText = SetText.SetText
							local name = clone.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} is currently trading with another player!`,
								MessageColor = "White"
							})
						end
					else
						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local name = clone.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} ไม่ได้อยู่ในเซิร์ฟเวอร์แล้ว!`,
								MessageColor = "White"
							})
						else
							local setText = SetText.SetText
							local name = clone.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} is no longer on the server!`,
								MessageColor = "White"
							})
						end

						if tradeRequests:FindFirstChild(clone.Name) then
							tradeRequests:FindFirstChild(clone.Name):Destroy()
							trade:InvokeServer({
								Action = "Decline",
								Trader = clone.Name
							})
						end
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ตอนนี้คุณกำลังเทรดกับผู้เล่นคนอื่นอยู่!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "You are currently trading with another player!",
						MessageColor = "Red"
					})
				end
			elseif v4:GetAttribute("Trading") == nil then
				if v4.RequestFolder.TradeRequests:FindFirstChild(localPlayer.Name) == nil then
					if v4.PlayerSettings.TradeRequests.Value == true then
						if v4:GetAttribute("LoadedData") and v4:GetAttribute("LoadedItem") and v4.Team ~= nil then
							if trade:InvokeServer({
								Action = "Send",
								Target = v4.Name
							}) == true then
								local v6 = clone

								if localPlayer:GetAttribute("TH") then
									if v6.TradeFrame.Trade.Textlabel.Text ~= "รอดำเนินการ" then
										v6.TradeFrame.Trade.Textlabel.Text = "รอดำเนินการ"
									end
								elseif v6.TradeFrame.Trade.Textlabel.Text ~= "Pending" then
									v6.TradeFrame.Trade.Textlabel.Text = "Pending"
								end

								SetColor_State(v6.TradeFrame.Trade, "Pending")

								if localPlayer:GetAttribute("TH") then
									local setText = SetText.SetText
									local name = v4.Name
									local v11

									if name then
										v11 = `<font color="rgb(100,255,100)">{name}</font>`
									end

									setText(localPlayer, "CustomMessage", {
										Message = `คุณได้ส่งคำขอการเทรดให้กับ {v11} เรียบร้อยแล้ว!`,
										MessageColor = "White"
									})
								else
									local setText = SetText.SetText
									local name = v4.Name
									local v11

									if name then
										v11 = `<font color="rgb(100,255,100)">{name}</font>`
									end

									setText(localPlayer, "CustomMessage", {
										Message = `You've sent a trade request to {v11}`,
										MessageColor = "White"
									})
								end
							end
						elseif localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local name = v4.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} ยังโหลดไม่เสร็จ!`,
								MessageColor = "White"
							})
						else
							local setText = SetText.SetText
							local name = v4.Name
							local v10

							if name then
								v10 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v10} hasn't loaded yet!`,
								MessageColor = "White"
							})
						end
					else
						local v6 = clone

						if localPlayer:GetAttribute("TH") then
							if v6.TradeFrame.Trade.Textlabel.Text ~= "ปิดเทรด" then
								v6.TradeFrame.Trade.Textlabel.Text = "ปิดเทรด"
							end
						elseif v6.TradeFrame.Trade.Textlabel.Text ~= "Disabled" then
							v6.TradeFrame.Trade.Textlabel.Text = "Disabled"
						end

						SetColor_State(v6.TradeFrame.Trade, "Disabled")

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local name = v4.Name
							local v11

							if name then
								v11 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v11} ปิดรับคำขอการเทรดของเขาอยู่!`,
								MessageColor = "White"
							})
						else
							local setText = SetText.SetText
							local name = v4.Name
							local v11

							if name then
								v11 = `<font color="rgb(255,100,100)">{name}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `{v11} has disabled their trade requests!`,
								MessageColor = "White"
							})
						end
					end
				else
					local v6 = clone

					if localPlayer:GetAttribute("TH") then
						if v6.TradeFrame.Trade.Textlabel.Text ~= "รอดำเนินการ" then
							v6.TradeFrame.Trade.Textlabel.Text = "รอดำเนินการ"
						end
					elseif v6.TradeFrame.Trade.Textlabel.Text ~= "Pending" then
						v6.TradeFrame.Trade.Textlabel.Text = "Pending"
					end

					SetColor_State(v6.TradeFrame.Trade, "Pending")

					if localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณได้ส่งคำขอการเทรดให้กับผู้เล่นคนนี้ไปแล้ว!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You've already sent a trade request to this player!",
							MessageColor = "Red"
						})
					end
				end
			else
				local v6 = clone

				if localPlayer:GetAttribute("TH") then
					if v6.TradeFrame.Trade.Textlabel.Text ~= "อยู่ในการเทรด" then
						v6.TradeFrame.Trade.Textlabel.Text = "อยู่ในการเทรด"
					end
				elseif v6.TradeFrame.Trade.Textlabel.Text ~= "Trading" then
					v6.TradeFrame.Trade.Textlabel.Text = "Trading"
				end

				SetColor_State(v6.TradeFrame.Trade, "Trading")

				if localPlayer:GetAttribute("TH") then
					local setText = SetText.SetText
					local name = v4.Name
					local v11

					if name then
						v11 = `<font color="rgb(255,100,100)">{name}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `{v11} กำลังเทรดกับผู้เล่นคนอื่นอยู่!`,
						MessageColor = "White"
					})
				else
					local setText = SetText.SetText
					local name = v4.Name
					local v11

					if name then
						v11 = `<font color="rgb(255,100,100)">{name}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `{v11} is currently trading with another player!`,
						MessageColor = "White"
					})
				end
			end
		end)
	end
end

local function Setup_Hover(button)
	button.MouseEnter:Connect(function()
		if button.HoverText.TextTransparency ~= 0 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if button.HoverText.TextTransparency ~= 1 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1
			}):Play()
		end
	end)
	button.MouseButton1Up:Connect(function()
		if button.HoverText.TextTransparency ~= 1 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1
			}):Play()
		end
	end)
	button.MouseButton1Down:Connect(function()
		if button.HoverText.TextTransparency ~= 0 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()
		end
	end)
end

search:GetPropertyChangedSignal("Text"):Connect(PlayerSearching)
search.Focused:Connect(function()
	if playerSearch.UIStroke.Color ~= Color3.fromRGB(73, 76, 83) then
		TweenService:Create(
			playerSearch.UIStroke,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Color = Color3.fromRGB(73, 76, 83)
			}
		):Play()
	end
end)
search.FocusLost:Connect(function()
	if playerSearch.UIStroke.Color ~= Color3.fromRGB(57, 59, 65) then
		TweenService:Create(
			playerSearch.UIStroke,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Color = Color3.fromRGB(57, 59, 65)
			}
		):Play()
	end
end)

for _, button in ipairs(topFrame:GetChildren()) do
	if button:IsA("GuiButton") then
		Setup_Hover(button)
	end
end

trade_Client.OnClientEvent:Connect(function(p)
	if p.Action == "Update_PlayerList" and OpeningThisFrame() and playersList.Visible == true then
		UpdatePlayerUi()
	end
end)
refresh.Activated:Connect(UpdatePlayerUi)
tradeRequests.ChildAdded:Connect(function(child)
	if localPlayer:GetAttribute("TH") then
		local setText = SetText.SetText
		local name = child.Name
		local v5

		if name then
			v5 = `<font color="rgb(100,255,100)">{name}</font>`
		end

		setText(localPlayer, "CustomMessage", {
			Message = `{v5} ส่งคำขอการเทรดให้คุณแล้ว!`,
			MessageColor = "White"
		})
	else
		local setText = SetText.SetText
		local name = child.Name
		local v5

		if name then
			v5 = `<font color="rgb(100,255,100)">{name}</font>`
		end

		setText(localPlayer, "CustomMessage", {
			Message = `{v5} sent you a trade request!`,
			MessageColor = "White"
		})
	end

	if OpeningThisFrame() and playersList.Visible == true then
		UpdatePlayerUi()
		return
	end

	notification:Play()
	parent2:SetAttribute("Amount", parent2:GetAttribute("Amount") + 1)
end)
tradeRequests.ChildRemoved:Connect(function()
	if OpeningThisFrame() and playersList.Visible == true then
		UpdatePlayerUi()
	end
end)
guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "Trading" and action == "Open" and playersList.Visible == true then
		UpdatePlayerUi()
	end
end)