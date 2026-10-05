local Players = game:GetService("Players")
game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("TextService")
game:GetService("HttpService")
game:GetService("Chat")
local localPlayer = Players.LocalPlayer
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
ReplicatedStorage:WaitForChild("Sound_Effect")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local partyEvents = otherEvent:WaitForChild("PartyEvents")
local SetText = require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Abbreviate"))
require(moduleScript:WaitForChild("Setting"))
require(modules:WaitForChild("FadeModule"))
require(moduleScript:WaitForChild("Translate"))
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local party_Client = partyEvents:WaitForChild("Party_Client")
local tradeEvents = otherEvent:WaitForChild("TradeEvents")
local party = partyEvents:WaitForChild("Party")
local trade = tradeEvents:WaitForChild("Trade")
local playerSettings = localPlayer:WaitForChild("PlayerSettings", 60)
local party2 = localPlayer:WaitForChild("Party", 60)
localPlayer:WaitForChild("Cooldown", 60)
local requestFolder = localPlayer:WaitForChild("RequestFolder")
local partyInvites = requestFolder:WaitForChild("PartyInvites")
local tradeRequests = requestFolder:WaitForChild("TradeRequests")
local partyIcon = playerSettings:WaitForChild("PartyIcon", 60)
local parent = script.Parent
local menu = parent.Parent.Parent.Parent.Parent.Menu
local party3 = menu.Parent.Party
local trade2 = menu.Parent.Trade
local frame = parent.Frame
local playersList = frame.PlayersList
local topFrame = frame.TopFrame
local playerSearch = topFrame.PlayerSearch
local search = playerSearch.Search
local refresh = topFrame.Refresh
local player_Template = guiTemplate.PartyAssets:WaitForChild("Player_Template")
local party_Mark = guiTemplate:WaitForChild("Party_Mark")
local headShot = Enum.ThumbnailType.HeadShot
local size420x420 = Enum.ThumbnailSize.Size420x420
local notification = sound_Effect:WaitForChild("Notification")
local _ = {
	" ",
	"  ",
	"   ",
	"    ",
	"     ",
	"      ",
	"       ",
	"        ",
	"         ",
	"          ",
	"           ",
	"            ",
	"             ",
	"              ",
	"               ",
	"                ",
	"                 ",
	"                  ",
	"                   ",
	"                    "
}
local connections = {}

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function Kick_Party(name: string)
	if party2:FindFirstChild(name) and party:InvokeServer({
		Action = "Leave_Party",
		Target = name
	}) then
		if localPlayer:GetAttribute("TH") then
			local setText = SetText.SetText
			local v5

			if name then
				v5 = `<font color="rgb(255,100,100)">{name}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `คุณเตะ {v5} ออกจากปาร์ตี้ของคุณแล้ว!`,
				MessageColor = "White"
			})
		else
			local setText = SetText.SetText
			local v5

			if name then
				v5 = `<font color="rgb(255,100,100)">{name}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `You've kicked {v5} from your party!`,
				MessageColor = "White"
			})
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return party3.Visible == true and party3.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function OpeningGiftFrame()
	return menu.Visible == true and menu.Position == UDim2.new(0.5, 0, 0.5, 0) and menu.Main.AllMenu:GetAttribute("CurrentOpen") == "Shop" and menu.Main.Container.Shop.PlayerListFrame.Visible == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TradeOpening()
	return trade2.Visible == true and trade2.Position == UDim2.new(0.5, 0, 0.5, 0)
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

local function SetColor_State(invite, p: string)
	if p == "Accept" then
		invite.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		invite.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		invite.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		invite.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Disabled" then
		invite.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.Colours.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	elseif p == "Kick" then
		invite.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		invite.Colours.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	elseif p == "Invite" then
		invite.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		invite.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		invite.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		invite.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 30, 68)
	elseif p == "Invited" then
		invite.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		invite.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		invite.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 143))
		})
		invite.Colours.Pattern.ImageColor3 = Color3.fromRGB(0, 45, 68)
	end
end

local function Set_State(p: string, instance, state)
	if p == "Disabled" then
		if state.ProfileFrame.InParty.Visible then
			state.ProfileFrame.InParty.Visible = false
		end

		SetColor_State(state.InviteFrame.Invite, "Disabled")

		if localPlayer:GetAttribute("TH") then
			if state.InviteFrame.Invite.Textlabel.Text ~= "ปิดอยู่" then
				state.InviteFrame.Invite.Textlabel.Text = "ปิดอยู่"
			end
		elseif state.InviteFrame.Invite.Textlabel.Text ~= "Disabled" then
			state.InviteFrame.Invite.Textlabel.Text = "Disabled"
		end

		state.LayoutOrder = 7

		if instance:GetAttribute("Verified") then
			state.LayoutOrder -= 1
		end

		if instance:GetAttribute("Developer") then
			state.LayoutOrder -= 1
		end

		if instance:GetAttribute("Friends") then
			state.LayoutOrder -= 1
		end
	elseif p == "Invited" then
		if localPlayer:GetAttribute("TH") then
			if state.InviteFrame.Invite.Textlabel.Text ~= "รอดำเนินการ" then
				state.InviteFrame.Invite.Textlabel.Text = "รอดำเนินการ"
			end
		elseif state.InviteFrame.Invite.Textlabel.Text ~= "Pending" then
			state.InviteFrame.Invite.Textlabel.Text = "Pending"
		end

		if state.ProfileFrame.InParty.Visible then
			state.ProfileFrame.InParty.Visible = false
		end

		SetColor_State(state.InviteFrame.Invite, "Invited")

		if instance:GetAttribute("Verified") then
			state.LayoutOrder -= 1
		end

		if instance:GetAttribute("Developer") then
			state.LayoutOrder -= 1
		end

		if instance:GetAttribute("Friends") then
			state.LayoutOrder -= 1
		end
	end
end

local UpdateInviteUi

UpdateInviteUi = function(p: string)
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
		clone.Username_Frame.Player_Name.Text = v.Name
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

		clone.LayoutOrder = 10

		if party2:FindFirstChild(clone.Name) then
			clone.ProfileFrame.InParty.Visible = true

			if localPlayer:GetAttribute("TH") then
				clone.InviteFrame.Invite.Textlabel.Text = "เตะ"
			else
				clone.InviteFrame.Invite.Textlabel.Text = "Kick"
			end

			SetColor_State(clone.InviteFrame.Invite, "Kick")
		elseif partyInvites:FindFirstChild(clone.Name) then
			clone.LayoutOrder = 1
			SetColor_State(clone.InviteFrame.Invite, "Accept")
			clone.DeclineFrame.Visible = true

			if localPlayer:GetAttribute("TH") then
				clone.InviteFrame.Invite.Textlabel.Text = "ยอมรับ"
			else
				clone.InviteFrame.Invite.Textlabel.Text = "Accept"
			end
		elseif v.PlayerSettings.PartyInvites.Value == false and v:GetAttribute("LoadedData") then
			SetColor_State(clone.InviteFrame.Invite, "Disabled")
			clone.LayoutOrder = 7

			if localPlayer:GetAttribute("TH") then
				clone.InviteFrame.Invite.Textlabel.Text = "ปิดอยู่"
			else
				clone.InviteFrame.Invite.Textlabel.Text = "Disabled"
			end
		elseif v.RequestFolder.PartyInvites:FindFirstChild(localPlayer.Name) then
			SetColor_State(clone.InviteFrame.Invite, "Invited")

			if localPlayer:GetAttribute("TH") then
				clone.InviteFrame.Invite.Textlabel.Text = "รอดำเนินการ"
			else
				clone.InviteFrame.Invite.Textlabel.Text = "Pending"
			end
		elseif party2:FindFirstChild(clone.Name) == nil then
			clone.LayoutOrder = 4
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
		connections[#connections + 1] = clone.InviteFrame.Invite.Activated:Connect(function()
			if Players:FindFirstChild(v4.Name) then
				if v4:GetAttribute("LoadedData") then
					if party2:FindFirstChild(clone.Name) ~= nil then
						Kick_Party(clone.Name)
					elseif partyInvites:FindFirstChild(clone.Name) ~= nil then
						party:InvokeServer({
							Action = "Invite_Accept",
							Inviter = clone.Name
						})
					elseif v4.RequestFolder.PartyInvites:FindFirstChild(localPlayer.Name) == nil then
						if v4.PlayerSettings.PartyInvites.Value == true then
							if party:InvokeServer({
								Action = "Invite",
								Target = v4.Name
							}) == true then
								Set_State("Invited", v4, clone)

								if localPlayer:GetAttribute("TH") then
									local setText = SetText.SetText
									local name = v4.Name
									local v10

									if name then
										v10 = `<font color="rgb(100,255,100)">{name}</font>`
									end

									setText(localPlayer, "CustomMessage", {
										Message = `คุณได้ส่งคำเชิญเข้าร่วมปาร์ตี้ให้กับ {v10} เรียบร้อยแล้ว!`,
										MessageColor = "White"
									})
								else
									local setText = SetText.SetText
									local name = v4.Name
									local v10

									if name then
										v10 = `<font color="rgb(100,255,100)">{name}</font>`
									end

									setText(localPlayer, "CustomMessage", {
										Message = `You've sent a party invite to {v10}`,
										MessageColor = "White"
									})
								end
							end
						else
							Set_State("Disabled", v4, clone)

							if localPlayer:GetAttribute("TH") then
								local setText = SetText.SetText
								local name = v4.Name
								local v10

								if name then
									v10 = `<font color="rgb(255,100,100)">{name}</font>`
								end

								setText(localPlayer, "CustomMessage", {
									Message = `{v10} ปิดรับคำเชิญเข้าร่วมปาร์ตี้ของเขาอยู่!`,
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
									Message = `{v10} has disabled their party invites!`,
									MessageColor = "White"
								})
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณได้ส่งคำเชิญเข้าร่วมปาร์ตี้ให้กับผู้เล่นคนนี้ไปแล้ว!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You've already sent a party invite to this player!",
							MessageColor = "Red"
						})
					end
				elseif localPlayer:GetAttribute("TH") then
					local setText = SetText.SetText
					local name = clone.Name
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
					local name = clone.Name
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
				if localPlayer:GetAttribute("TH") then
					local setText = SetText.SetText
					local name = clone.Name
					local v10

					if name then
						v10 = `<font color="rgb(255,100,100)">{name}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `{v10} ออกจากเกมไปแล้ว!`,
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
						Message = `{v10} has already left the game!`,
						MessageColor = "White"
					})
				end

				UpdateInviteUi()
			end
		end)
		local v6 = clone
		connections[#connections + 1] = clone.DeclineFrame.Decline.Activated:Connect(function()
			if partyInvites:FindFirstChild(v6.Name) then
				party:InvokeServer({
					Action = "Invite_Decline",
					Inviter = v6.Name
				})
				UpdateInviteUi()
			end
		end)
	end
end

local function Update_PartyMark(model)
	if partyIcon.Value == true then
		if model then
			if model and model.Parent and model:IsA("Model") then
				if party2:FindFirstChild(model.Name) then
					local humanoidRootPart = not model:FindFirstChild("Party_Mark") and model:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local clone = party_Mark:Clone()
						clone.Adornee = humanoidRootPart
						clone.Enabled = true
						clone.Parent = model
					end
				else
					local party_Mark2 = model:FindFirstChild("Party_Mark")

					if party_Mark2 then
						party_Mark2:Destroy()
					end
				end
			end
		else
			for _, model2 in ipairs(character:GetChildren()) do
				if not (model2 and model2.Parent and model2:IsA("Model")) then
					continue
				end

				if party2:FindFirstChild(model2.Name) then
					if not model2:FindFirstChild("Party_Mark") then
						local humanoidRootPart = model2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							local clone = party_Mark:Clone()
							clone.Adornee = humanoidRootPart
							clone.Enabled = true
							clone.Parent = model2
						end
					end
				else
					local party_Mark2 = model2:FindFirstChild("Party_Mark")

					if party_Mark2 then
						party_Mark2:Destroy()
					end
				end
			end
		end
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

local function Setup_Badge(instance)
	if instance.HasVerifiedBadge then
		instance:SetAttribute("Verified", true)
	end

	if instance:GetRankInGroup(14223953) >= 253 then
		instance:SetAttribute("Developer", true)
	end

	if instance:IsFriendsWith(localPlayer.UserId) then
		instance:SetAttribute("Friends", true)
	end
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

party2.ChildAdded:Connect(function()
	Update_PartyMark()
	UpdateInviteUi()
end)
party2.ChildRemoved:Connect(function()
	Update_PartyMark()
	UpdateInviteUi()
end)
refresh.Activated:Connect(UpdateInviteUi)
character.ChildAdded:Connect(function(child)
	local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:FindFirstChild("Died") then
		humanoidRootPart.Died.SoundId = "rbxassetid://958257111"
		humanoidRootPart.Died.RollOffMaxDistance = 1000
		humanoidRootPart.Died.RollOffMinDistance = 50
	end

	Update_PartyMark(child)
end)
partyIcon.Changed:Connect(function()
	if partyIcon.Value == true then
		Update_PartyMark()
		return
	end

	for _, model in ipairs(character:GetChildren()) do
		if not (model and model.Parent and model:IsA("Model") and party2:FindFirstChild(model.Name)) then
			continue
		end

		local party_Mark2 = model:FindFirstChild("Party_Mark")

		if party_Mark2 then
			party_Mark2:Destroy()
		end
	end
end)
partyInvites.ChildAdded:Connect(function(child)
	if localPlayer:GetAttribute("TH") then
		local setText = SetText.SetText
		local name = child.Name
		local v5

		if name then
			v5 = `<font color="rgb(100,255,100)">{name}</font>`
		end

		setText(localPlayer, "CustomMessage", {
			Message = `{v5} ส่งคำเชิญปาร์ตี้ให้คุณแล้ว!`,
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
			Message = `{v5} sent you a party invite!`,
			MessageColor = "White"
		})
	end

	if OpeningThisFrame() and playersList.Visible then
		UpdateInviteUi()
		return
	end

	notification:Play()
	party3:SetAttribute("Amount", party3:GetAttribute("Amount") + 1)
end)
UpdateInviteUi()
party_Client.OnClientEvent:Connect(function(p: string)
	if p == "Refresh" and OpeningThisFrame() and playersList.Visible then
		UpdateInviteUi()
	end
end)
guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == parent.Name and action == "Open" and playersList.Visible then
		UpdateInviteUi()
	end
end)

for _, v in ipairs(Players:GetPlayers()) do
	if v.Name ~= localPlayer.Name then
		Setup_Badge(v)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	repeat
		task.wait(1)
	until player:GetAttribute("LoadedData") or not (player and player.Parent)

	if player.Name ~= localPlayer.Name then
		Setup_Badge(player)
	end

	if OpeningThisFrame() and playersList.Visible then
		UpdateInviteUi()
	elseif TradeOpening() then
		guiEvent:Fire({
			MenuName = "Trading",
			Action = "Open"
		})
	end

	if OpeningGiftFrame() then
		guiEvent:Fire({
			MenuName = "Gift",
			Action = "Open"
		})
	end
end)

local function Clear_Skills(userId)
	for _, child in ipairs(skills:GetChildren()) do
		if string.find(child.Name, userId) then
			child:Destroy()
		end
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	if OpeningThisFrame() and playersList.Visible then
		UpdateInviteUi(player.Name)
	elseif TradeOpening() then
		guiEvent:Fire({
			MenuName = "Trading",
			Action = "Open"
		})
	end

	if tradeRequests:FindFirstChild(player.Name) then
		tradeRequests:FindFirstChild(player.Name):Destroy()
		trade:InvokeServer({
			Action = "Decline",
			Trader = player.Name
		})
	end

	if OpeningGiftFrame() then
		guiEvent:Fire({
			MenuName = "Gift",
			Action = "Open"
		})
	end

	local v = not player.Name and "Idk" or player.Name

	if menu.Main.Container.Shop.Shop_Handler:GetAttribute("Gifting") == v then
		menu.Main.Container.Shop.Shop_Handler:SetAttribute("Gifting", "None")
	end

	Clear_Skills(player.UserId)
end)