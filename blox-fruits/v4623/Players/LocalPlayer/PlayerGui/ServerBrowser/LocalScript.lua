local GuiService = game:GetService("GuiService")

if GuiService:IsTenFootInterface() then
	task.defer(function()
		script.Parent:Destroy()
	end)
	return
end

local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Notification = require(game.ReplicatedStorage.Notification)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local __ServerBrowser = game.ReplicatedStorage:WaitForChild("__ServerBrowser")
local v = __ServerBrowser:InvokeServer("getjob")
local remotes = game.ReplicatedStorage.Remotes
local commF_ = remotes.CommF_
local _ = remotes.CommE
local TextUtil = require(game.ReplicatedStorage:WaitForChild("Modules").Util.TextUtil)
local commaValue = TextUtil.commaValue
local remoteFunction = Net:RemoteFunction("DungeonNPCNetworkFunction")
local localPlayer = game.Players.LocalPlayer
local frame = script.Parent.Frame
local maxPlayers = game.Players.MaxPlayers

-- equivalent calls inferred from this helper; original call sites unknown
local function jobToNumber(value)
	return tonumber("0x" .. value:gsub("-", ""):sub(1, 7)) or 0
end

local function getName(job)
	local v2 = {
		"Big",
		"Small",
		"Large",
		"Strong",
		"Powerful",
		"Weak",
		"Overpowered",
		"Bad",
		"Odd",
		"Rich",
		"Short",
		"Adorable",
		"Alive",
		"Colorful",
		"Angry",
		"Good",
		"Beautiful",
		"Ugly",
		"Hot",
		"Cold",
		"Evil",
		"Famous",
		"Original",
		"Unoriginal",
		"Kind",
		"Nice",
		"Real",
		"Expensive",
		"Wild",
		"Wide",
		"Fake",
		"Proud",
		"Super",
		"Strange",
		"Wrong",
		"Right",
		"Talented",
		"Complex",
		"Pure",
		"Fancy",
		"Lucky",
		"Fresh",
		"Fantastic",
		"Dull",
		"Dizzy",
		"Eternal",
		"Mental",
		"Infinite",
		"Rogue"
	}
	local v3 = {
		"TAWG",
		"Robson",
		"Krazy",
		"Fruit",
		"Realm",
		"World",
		"Place",
		"Experience",
		"Dog",
		"Cat",
		"Guy",
		"Bird",
		"Legion",
		"Gank",
		"Family",
		"Sun",
		"Moon",
		"Gun",
		"Sword",
		"Melee",
		"Defense",
		"Bomb",
		"Spike",
		"Chop",
		"Spring",
		"Smoke",
		"Flame",
		"Ice",
		"Sand",
		"Dark",
		"Light",
		"Rubber",
		"Barrier",
		"Magma",
		"Tiger",
		"Quake",
		"Buddha",
		"Spider",
		"Phoenix",
		"Rumble",
		"Love",
		"Door",
		"Paw",
		"Gravity",
		"Dough",
		"Venom",
		"Control",
		"Dragon",
		"Falcon",
		"Diamond",
		"Kilo",
		"Shark",
		"Human",
		"Angel",
		"Rabbit",
		"Spin",
		"Topic",
		"Red",
		"Blue",
		"Green",
		"Yellow",
		"Soul",
		"Shadow"
	}
	local random = Random.new(jobToNumber(job))
	return v2[random:NextInteger(1, #v2)] .. " " .. v3[random:NextInteger(1, #v3)] .. " #" .. string.format(
		"%04d",
		random:NextInteger(1, 9999)
	)
end

local scrollingFrame = script.Parent.Frame.ScrollingFrame
local inside = script.Parent.Frame.FakeScroll.Inside
local framesByLayoutOrder = {}
local v2 = {}

for _, frame2 in pairs(inside:GetChildren()) do
	if not frame2:IsA("Frame") then
		continue
	end

	framesByLayoutOrder[frame2.LayoutOrder] = frame2
	local v3 = frame2
	frame2.Join.MouseButton1Click:Connect(function()
		if v3.Join.Text == "Join" then
			__ServerBrowser:InvokeServer("teleport", v3.Join:GetAttribute("Job"))
		end
	end)
end

function UpdateScroll()
	local uDim = UDim2.fromOffset(0, scrollingFrame.AbsoluteSize.Y * 0.21 * #v2)

	if uDim ~= scrollingFrame.CanvasSize then
		scrollingFrame.CanvasSize = uDim
	end

	local Y = scrollingFrame.CanvasPosition.Y
	inside.Position = UDim2.fromOffset(
		0,
		-Y % (scrollingFrame.AbsoluteSize.Y * 0.21) - scrollingFrame.AbsoluteSize.Y * 0.21
	)
	local v3 = math.ceil(scrollingFrame.CanvasPosition.Y / scrollingFrame.AbsoluteSize.Y / 0.21)

	for i = 1, 7 do
		local v4 = framesByLayoutOrder[i]
		local v5 = v3 + i - 1
		local v6 = v2[v5]
		local v7 = v5 == 0 and {
			Job = "1234567890123",
			Region = "ERROR",
			Count = 0,
			Bounty = 0,
			Name = ""
		} or v6

		if v7 then
			v4.Visible = true
			v4.ServerName.Text = "<b>Server Name:</b> " .. v7.Name
			v4.ServerName.TextBox:SetAttribute("TrueText", v7.Name)
			v4.ServerName.TextBox.Text = v7.Name
			v4.TextLabel.Text = "Region: " .. v7.Region .. " - Players: " .. v7.Count .. "/" .. maxPlayers .. " - Bounty: " .. commaValue(v7.Bounty)
			v4.Join:SetAttribute("Job", v7.Job)

			if v7.Job == v then
				v4.Join.BackgroundTransparency = 1
				v4.Join.Text = "Your Server"
				v4.Join.TextColor3 = Color3.new(1, 1, 1)
			else
				v4.Join.Text = "Join"
				v4.Join.BackgroundTransparency = 0
				v4.Join.TextColor3 = Color3.new(0, 0, 0)
			end
		else
			v4.Visible = false
			v4.Join:SetAttribute("Job", "")
		end
	end
end

scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateScroll)
scrollingFrame:GetPropertyChangedSignal("CanvasSize"):Connect(UpdateScroll)
local v3 = {}

local function HandleRender()
	v2 = {}
	local v4 = frame.Filters.Full.Check.Text == "✔️"
	local v5 = tonumber(({ frame.Filters.SearchBounty.TextBox.Text:gsub(",", "") })[1])
	local text

	if frame.Filters.SearchName.TextBox.Text ~= "" then
		text = frame.Filters.SearchName.TextBox.Text:lower() or nil
	end

	local text2

	if frame.Filters.SearchRegion.TextBox.Text ~= "" then
		text2 = frame.Filters.SearchRegion.TextBox.Text:lower() or nil
	end

	for _, v6 in pairs(v3) do
		if not (not text2 or v6.Region:lower():match(text2)) then
			continue
		end

		if not (not text or v6.Name:lower():match(text)) or v5 and v6.Bounty < v5 then
			continue
		end

		if not v4 and maxPlayers <= tonumber(v6.Count) then
			continue
		end

		table.insert(v2, v6)
	end

	frame.Total.Text = ("Showing %s/%s Servers"):format(#v2, #v3)
	UpdateScroll()
end

frame.Filters.Full.Check.MouseButton1Click:Connect(function()
	if frame.Filters.Full.Check.Text == "✔️" then
		frame.Filters.Full.Check.Text = ""
	else
		frame.Filters.Full.Check.Text = "✔️"
	end

	HandleRender()
end)
frame.Filters.SearchName.TextBox:GetPropertyChangedSignal("Text"):Connect(HandleRender)
frame.Filters.SearchRegion.TextBox:GetPropertyChangedSignal("Text"):Connect(HandleRender)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	task.wait()
	HandleRender()
end)
local flag = false

local function update()
	if flag then
		return
	end

	flag = true
	frame.Refresh.Text = "Refreshing..."
	local v4 = {}
	local count = 0

	for i = 1, 100 do
		local v5 = i
		task.delay(i * 1 / 50, function()
			local success, result = pcall(function()
				return __ServerBrowser:InvokeServer(v5)
			end)

			if not success then
				warn(result)
			end

			if not success then
				local count2 = 0

				repeat
					task.wait(0.5)
					count2 += 1
					local success2
					success2, result = pcall(function()
						return __ServerBrowser:InvokeServer(v5)
					end)
				until success2 or count2 >= 3
			end

			for k, v6 in pairs(result or {}) do
				v4[k] = v6
			end

			count += 1
		end)
	end

	repeat
		task.wait()
	until count >= 100

	v3 = {}
	tick()
	local count2 = 0

	for k, v5 in pairs(v4) do
		count2 += 1

		if count2 > 5000 then
			task.wait()
			count2 = 0
		end

		v5.Job = k
		v5.Name = getName(v5.Job)

		if v5.Job == v then
			local v6 = v3[1]
			v3[1] = v5
			table.insert(v3, v6)
		else
			table.insert(v3, v5)
		end
	end

	HandleRender()
	frame.Refresh.Text = "Refresh"
	flag = false
end

frame.Refresh.MouseButton1Click:Connect(update)
script.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if script.Parent.Enabled then
		update()
	end
end)
local _ = frame.TeleportButtons
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function tryTeleport(p)
	if flag2 then
		return
	end

	flag2 = true

	if p == "Dungeon" then
		remoteFunction:InvokeServer("TeleportToDungeonHub", false)
	else
		commF_:InvokeServer(p)
	end

	task.wait(1)
	flag2 = false
end

local sea1 = frame.TeleportButtons.Sea1
local sea2 = frame.TeleportButtons.Sea2
local sea3 = frame.TeleportButtons.Sea3
local dungeon = frame.TeleportButtons.Dungeon

local function clicked(instance, p)
	if not instance:GetAttribute("Active") or instance:GetAttribute("TeleportInProgress") then
		return
	end

	local character = localPlayer.Character

	if character and character:GetAttribute("InCombat") then
		Notification.new("<Color=Red>Cannot teleport while in combat!<Color=/>"):Display()
		local Global = require(game.ReplicatedStorage.Global)
		Global.toggleMenu("ServerBrowser")
	elseif instance:GetAttribute("Confirmed") then
		instance:SetAttribute("TeleportInProgress", true)
		instance.TextLabel.Text = "Teleporting..."
		tryTeleport(p) -- equivalent call inferred; original call site unknown
		instance:SetAttribute("Confirmed", false)
		instance:SetAttribute("TeleportInProgress", nil)
		instance.TextLabel.Text = instance:GetAttribute("OriginalText")
	else
		instance.TextLabel.Text = "Confirm?"
		instance:SetAttribute("Confirmed", true)
		local v4 = (instance:GetAttribute("ConfirmedTick") or 0) + 1
		instance:SetAttribute("ConfirmedTick", v4)
		task.delay(1.5, function()
			if instance:GetAttribute("ConfirmedTick") == v4 and not instance:GetAttribute("TeleportInProgress") then
				instance:SetAttribute("Confirmed", false)
				instance.TextLabel.Text = instance:GetAttribute("OriginalText")
			end
		end)
	end
end

sea1.Activated:Connect(function()
	clicked(sea1, "TravelMain")
end)
sea2.Activated:Connect(function()
	clicked(sea2, "TravelDressrosa")
end)
sea3.Activated:Connect(function()
	clicked(sea3, "TravelZou")
end)
dungeon.Activated:Connect(function()
	clicked(dungeon, "Dungeon")
end)

local function applyButtonColors(instance, p)
	if p == "Active" then
		instance.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
		instance.BorderColor3 = Color3.fromRGB(255, 240, 69)
		instance.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
		instance.Trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
		instance:SetAttribute("Active", true)
	elseif p == "Inactive" then
		instance.BackgroundColor3 = Color3.fromRGB(132, 132, 132)
		instance.BorderColor3 = Color3.fromRGB(91, 91, 91)
		instance.Trans.BackgroundColor3 = Color3.fromRGB(194, 194, 194)
		instance.Trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
		instance:SetAttribute("Active", false)
	end
end

sea1.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
sea1.BorderColor3 = Color3.fromRGB(255, 240, 69)
sea1.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
sea1.Trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
sea1:SetAttribute("Active", true)

for _, v4 in {
	sea1,
	sea2,
	sea3,
	dungeon
} do
	v4:SetAttribute("OriginalText", v4.TextLabel.Text)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshSea2Progress(p)
	local v4 = p or commF_:InvokeServer("DressrosaQuestProgress")
	local talkedDetective = v4.TalkedDetective
	local usedKey = v4.UsedKey
	local killedIceBoss = v4.KilledIceBoss
	applyButtonColors(sea2, talkedDetective and usedKey and killedIceBoss and "Active" or "Inactive")
end

refreshSea2Progress(nil) -- equivalent call inferred; original call site unknown
remotes:WaitForChild("RefreshDressrosaQuestPro").OnClientEvent:Connect(refreshSea2Progress)

local function refreshSea3Progress(p)
	applyButtonColors(sea3, (p or commF_:InvokeServer("ZQuestProgress", "Check")) == 1 and "Active" or "Inactive")
end

applyButtonColors(sea3, (nil or commF_:InvokeServer("ZQuestProgress", "Check")) == 1 and "Active" or "Inactive")
remotes:WaitForChild("RefreshZQuestPro").OnClientEvent:Connect(refreshSea3Progress)
local level = localPlayer:WaitForChild("Data"):WaitForChild("Level")

local function levelChanged()
	applyButtonColors(dungeon, level.Value >= 1100 and "Active" or "Inactive")
end

applyButtonColors(dungeon, level.Value >= 1100 and "Active" or "Inactive")
level.Changed:Connect(levelChanged)

local function reflectDeviceLayout()
	local isMobile = LastInput.IsMobile()
	local deviceLayout = MobileUIController:GetDeviceLayout()

	if isMobile and deviceLayout == "Phone" then
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.fromScale(0.5, 0)
		local Y = script.Parent.AbsoluteSize.Y
		frame.UISizeConstraint.MinSize = Vector2.new(638, Y - 100)
	else
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.UISizeConstraint.MinSize = Vector2.new(638, 319)
	end
end

reflectDeviceLayout()
LastInput.Changed:Connect(reflectDeviceLayout)
MobileUIController:GetDeviceLayoutChangedSignal():Connect(reflectDeviceLayout)