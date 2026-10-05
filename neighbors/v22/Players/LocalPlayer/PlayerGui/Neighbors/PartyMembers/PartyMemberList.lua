local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ThumbnailGenerator = require(ReplicatedStorage.Modules.ThumbnailGenerator)
require(ReplicatedStorage.Modules.PlayerStates)
local PartyClient = require(ReplicatedStorage.Modules.PartyClient)
require(ReplicatedStorage.Modules.GamepassUtil)
local UI = require(ReplicatedStorage.Modules.UI)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local navigation = playerGui:WaitForChild("HouseCustomization"):WaitForChild("Navigation")
local invite = script.Parent.Invite
local scrollingFrame = script.Parent.ScrollingFrame
local _ = scrollingFrame.UIGridLayout
local hover = scrollingFrame.Parent.Parent.Parent:WaitForChild("MainMenu"):WaitForChild("Hover")
local v = UI:GetDeviceType() == "Mobile" and 3 or 5

if v == 3 then
	scrollingFrame.Size = UDim2.new(1, 0, 1, -155)
	invite.Position = UDim2.new(0.5, 0, 1, -60)
end

UI:RegisterConstantUIScale(script.Parent.UIScale, {
	PC = 1.25,
	Mobile = 1.5,
	Tablet = 1.5
})
UI:AddShadowOnHover(invite.ImageButton)
UI:Bind(invite.ImageButton)
UI:RegisterScrollingFrame(scrollingFrame, { scrollingFrame.Parent.UIScale })

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdatePlayerListVisibility()
	scrollingFrame.Visible = not navigation.Visible
end

local function UpdateScrollingFrame(p)
	if p == invite then
		return
	end

	local count = 0

	for _, frame in scrollingFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Visible and frame ~= invite then
			count += 1
		end
	end

	invite.Visible = UI:GetDeviceType() ~= "Mobile"
	pcall(function()
		invite.Parent = v <= count and scrollingFrame.Parent or scrollingFrame
	end)
end

local function UpdatePlayerList()
	local partyMembers = PartyClient:GetPartyMembers()
	local partyHost = PartyClient:GetPartyHost()
	local playerByUserIds = {}

	for _, frame in scrollingFrame:GetChildren() do
		if not (frame:IsA("Frame") and frame.Visible and frame ~= invite) then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(frame:GetAttribute("UserId") or 0)

		if playerByUserId then
			if table.find(partyMembers, playerByUserId) then
				table.insert(playerByUserIds, playerByUserId)
			else
				frame:Destroy()
			end
		else
			frame:Destroy()
		end
	end

	for _, partyMember in partyMembers do
		local v2 = table.find(playerByUserIds, partyMember) ~= nil
		local visible = partyMember == partyHost
		local v4 = v2 and scrollingFrame:FindFirstChild(partyMember.Name) or scrollingFrame.Player:Clone()
		v4:SetAttribute("UserId", partyMember.UserId)
		v4.Visible = true
		v4.Name = partyMember.Name
		v4.AvatarHeadshot.Image = ThumbnailGenerator("AvatarHeadShot", partyMember.UserId, Vector2.new(150, 150))
		v4.LayoutOrder = visible and 0 or 1
		v4.IsHost.Visible = visible
		v4.Parent = scrollingFrame

		if UserInputService.TouchEnabled or v2 then
			if not v2 then
				local v5 = v4
				partyMember:GetAttributeChangedSignal("PartyId"):Once(function()
					v5:Destroy()
				end)
			end
		else
			local v5 = partyMember
			v4.MouseEnter:Connect(function()
				partyHost = PartyClient:GetPartyHost()
				visible = v5 == partyHost
				hover.Visible = true
				hover.Username.Text = `{v5.DisplayName}` .. (visible and " (Host)" or "")
			end)
			v4.MouseLeave:Connect(function()
				hover.Visible = false
			end)
		end
	end
end

if not UserInputService.TouchEnabled then
	RunService:BindToRenderStep("PlayerMemberHover", Enum.RenderPriority.Camera.Value, function()
		if not hover.Visible then
			return
		end

		GuiService:GetGuiInset()
		local mouse = Players.LocalPlayer:GetMouse()
		hover.Position = UDim2.fromOffset(mouse.X + 20, mouse.Y + 10)
	end)
end

local function GetPartyMemberJoinSignal()
	local partyId = Players.LocalPlayer:GetAttribute("PartyId")
	local bindableEvent = Instance.new("BindableEvent")

	local function PlayerAdded(instance)
		instance:GetAttributeChangedSignal("PartyId"):Connect(function()
			local partyId2 = instance:GetAttribute("PartyId")

			if instance == Players.LocalPlayer then
				partyId = partyId2
				bindableEvent:Fire(instance)
			elseif partyId2 == partyId and partyId ~= nil then
				bindableEvent:Fire(instance)
			end
		end)

		if instance:GetAttribute("PartyId") == partyId and partyId ~= nil then
			bindableEvent:Fire(instance)
		end
	end

	for _, v2 in Players:GetPlayers() do
		PlayerAdded(v2)
	end

	Players.PlayerAdded:Connect(PlayerAdded)
	return bindableEvent.Event
end

local function GetPartyMemberLeaveSignal()
	local bindableEvent = Instance.new("BindableEvent")
	local partyIds = {}

	local function PlayerAdded(instance)
		partyIds[instance] = instance:GetAttribute("PartyId")
		instance:GetAttributeChangedSignal("PartyId"):Connect(function()
			local partyId = Players.LocalPlayer:GetAttribute("PartyId")
			local v2 = partyIds[instance]
			partyIds[instance] = instance:GetAttribute("PartyId")

			if v2 == partyId and partyId ~= nil then
				bindableEvent:Fire(instance)
			end
		end)
	end

	local function PlayerRemoving(instance)
		local partyId = instance:GetAttribute("PartyId")

		if Players.LocalPlayer:GetAttribute("PartyId") == partyId then
			UpdatePlayerList()
		end
	end

	for _, v2 in Players:GetPlayers() do
		partyIds[v2] = v2:GetAttribute("PartyId")
		local v3 = v2
		v2:GetAttributeChangedSignal("PartyId"):Connect(function()
			local partyId = Players.LocalPlayer:GetAttribute("PartyId")
			local v4 = partyIds[v3]
			partyIds[v3] = v3:GetAttribute("PartyId")

			if v4 == partyId and partyId ~= nil then
				bindableEvent:Fire(v3)
			end
		end)
	end

	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoving)
	return bindableEvent.Event
end

GetPartyMemberJoinSignal():Connect(function()
	script.Sounds.Join:Play()
	UpdatePlayerList()
end)
GetPartyMemberLeaveSignal():Connect(function()
	script.Sounds.Leave:Play()
	UpdatePlayerList()
end)
scrollingFrame.ChildAdded:Connect(UpdateScrollingFrame)
scrollingFrame.ChildRemoved:Connect(UpdateScrollingFrame)
navigation:GetPropertyChangedSignal("Visible"):Connect(UpdatePlayerListVisibility)
invite.ImageButton.Activated:Connect(function()
	playerGui.Neighbors.Party.Visible = not playerGui.Neighbors.Party.Visible
end)
localPlayer:GetAttributeChangedSignal("Verified"):Connect(UpdateScrollingFrame)
localPlayer:GetAttributeChangedSignal("MegaParty"):Connect(UpdateScrollingFrame)
UpdatePlayerList()
UpdatePlayerListVisibility() -- equivalent call inferred; original call site unknown