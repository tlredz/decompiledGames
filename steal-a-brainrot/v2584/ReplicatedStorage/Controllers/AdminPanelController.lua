local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.Synchronizer)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local AdminCommands = require(ReplicatedStorage.Datas.AdminCommands)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = TopbarPlus.new():setImage(102554277994487, "Selected"):setImage(95529031547606, "Deselected"):setImageScale(0.7):setImageRatio(2):setOrder(2):setEnabled(false)
local adminPanel = playerGui:WaitForChild("AdminPanel").AdminPanel
local content = adminPanel.Content
local close = adminPanel.Header.Close
local profiles = adminPanel.Profiles
local scrollingFrame = profiles.ScrollingFrame
local template = scrollingFrame.Template
local scrollingFrame2 = content.ScrollingFrame
local template2 = scrollingFrame2.Template
local remoteEvent = Net:RemoteEvent("AdminPanelService/PlaceCooldownFromChat")
local remoteEvent2 = Net:RemoteEvent("AdminPanelService/DealWithThis")
local remoteEvent3 = Net:RemoteEvent("AdminPanelService/OpenUI")
local v2 = nil
local v3 = nil

local function getPlayerFromPrefix(value: string)
	if value == "" then
		return nil
	end

	local lower = value:lower()

	for _, v4 in ipairs(Players:GetPlayers()) do
		if v4.Name:sub(1, #value):lower() == lower then
			return v4
		end
	end

	return nil
end

local v4 = {}

local function PlaceOnCooldown(child, p: number)
	if child:GetAttribute("OnCooldown") then
		return
	end

	child:SetAttribute("OnCooldown", true)
	local maid = Trove.new()
	local now = os.clock()
	local timer = child:FindFirstChild("Timer")
	timer.Visible = true
	child.CooldownFrame.Visible = true
	v4[child] = maid
	maid:Add(function()
		v4[child] = nil
		timer.Visible = false
		child.CooldownFrame.Visible = false
		child:SetAttribute("OnCooldown", false)
	end)
	maid:Add(child:GetAttributeChangedSignal("ResetCooldown"):Once(function()
		maid:Destroy()
	end))
	maid:Add(Timer.Simple(1, function()
		local v5 = math.max(now + p - os.clock(), 0)
		timer.Text = `{math.floor(v5)}s`

		if v5 <= 0 then
			maid:Destroy()
		end
	end, true))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ResetCooldown(child)
	if v4[child] then
		v4[child]:Destroy()
		v4[child] = nil
	end
end

local function Reset()
	v2 = nil
	v3 = nil

	for _, button in ipairs(profiles.ScrollingFrame:GetChildren()) do
		if not (button:IsA("ImageButton") and button.Name ~= "Template") then
			continue
		end

		button.UIStroke.Color = Color3.new(0, 0, 0)
		button.UIStroke.Thickness = 1.5
	end

	for _, button in ipairs(scrollingFrame2:GetChildren()) do
		if not (button:IsA("ImageButton") and button.Name ~= "Template") then
			continue
		end

		button.UIStroke.Color = Color3.new(0, 0, 0)
		button.UIStroke.Thickness = 1.5
	end
end

local function ExecuteCommand()
	if not (v3 and v2) then
		return
	end

	local v5 = v2
	local name = v5.Name
	local v6 = v3
	local adminCommand = AdminCommands[v6]

	if not adminCommand then
		return
	end

	local child = scrollingFrame2:FindFirstChild(v6)
	Reset()
	local v7, v8 = Net:RemoteFunction("a434c202-a33e-49b9-80a0-4957c24b60b8"):InvokeServer(
		"fcec6acb-8d1e-4fa1-8d84-fbe0f52f5f0c",
		v5,
		v6
	)

	if not v7 then
		return
	end

	ResetCooldown(child) -- equivalent call inferred; original call site unknown
	PlaceOnCooldown(child, v8 + adminCommand.cooldown - workspace:GetServerTimeNow())
	local child2 = not FFlags:GetInstant("AdminPanel/UserCooldownDisabled", true) and profiles.ScrollingFrame:FindFirstChild(name)

	if child2 then
		ResetCooldown(child2) -- equivalent call inferred; original call site unknown
		PlaceOnCooldown(
			child2,
			v8 + FFlags:GetInstant("AdminPanel/UserCooldownDuration", 10) - workspace:GetServerTimeNow()
		)
	end
end

local function SelectCommand(p)
	local v5

	if p then
		v5 = p.Name or nil
	end

	v3 = v5

	for _, button in ipairs(scrollingFrame2:GetChildren()) do
		if not (button:IsA("ImageButton") and button.Name ~= "Template") then
			continue
		end

		local v6 = button == p
		button.UIStroke.Color = v6 and Color3.new(1, 1, 0) or Color3.new(0, 0, 0)
		button.UIStroke.Thickness = v6 and 3 or 1.5
	end
end

local function SelectProfile(p)
	local v5

	if p then
		v5 = Players:FindFirstChild(p.Name) or nil
	end

	v2 = v5

	for _, button in ipairs(profiles.ScrollingFrame:GetChildren()) do
		if not (button:IsA("ImageButton") and button.Name ~= "Template") then
			continue
		end

		local v6 = button == p
		button.UIStroke.Color = v6 and Color3.new(1, 1, 0) or Color3.new(0, 0, 0)
		button.UIStroke.Thickness = v6 and 3 or 1.5
	end
end

local function SetupCommands()
	for _, button in ipairs(scrollingFrame2:GetChildren()) do
		if button:IsA("ImageButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	for k, adminCommand in AdminCommands do
		local clone = template2:Clone()
		clone.Name = k
		clone.Command.Text = ";" .. adminCommand.name
		clone.Icon.Image = adminCommand.icon or clone.Icon.Image
		clone.Timer.Text = adminCommand.cooldown .. "s"
		clone.Timer.Visible = false
		local v5 = AnimatedButton.new(clone)
		v5:Animate()
		v5.OnActivated:Connect(function()
			SelectCommand(clone)
			ExecuteCommand()
		end)
		clone.Visible = true
		clone.Parent = scrollingFrame2
	end

	local v5 = InterfaceController:Register("AdminPanel", adminPanel, "TopQuint")
	v5:AttachCloseButton(close)
	v5:Close()
	v.selected:Connect(function()
		InterfaceController:SetState("AdminPanel", true)
	end)
	v.deselected:Connect(function()
		InterfaceController:SetState("AdminPanel", false)
	end)
	v:setEnabled(not (ServerData.IsDuelsServer() or ServerData.IsTradePlaza()))
	v5.OnOpen:Connect(function()
		v:select()
	end)
	v5.OnClose:Connect(function()
		v:deselect()
	end)
end

local function SetupProfiles()
	for _, button in ipairs(profiles.ScrollingFrame:GetChildren()) do
		if button:IsA("ImageButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	for _, v5 in ipairs(Players:GetPlayers()) do
		local clone = template:Clone()
		clone.Name = v5.Name
		clone.playerName.Text = v5.Name
		clone.playerPhoto.Image = `rbxthumb://type=AvatarHeadShot&id={v5.UserId}&w=100&h=100`
		local v6 = AnimatedButton.new(clone)
		v6:Animate()
		v6.OnActivated:Connect(function()
			SelectProfile(clone)
			ExecuteCommand()
		end)
		clone.Visible = true
		clone.Parent = profiles.ScrollingFrame
	end
end

return {
	Start = function(_)
		local flag = false
		remoteEvent3.OnClientEvent:Connect(function()
			InterfaceController:SetState("AdminPanel", true)
		end)
		remoteEvent.OnClientEvent:Connect(function(childName: string)
			PlaceOnCooldown(scrollingFrame2:FindFirstChild(childName), AdminCommands[childName].cooldown)
			Reset()
		end)
		remoteEvent2.OnClientEvent:Connect(function(p: string, p2: string, p3)
			local adminCommand = AdminCommands[p]

			if not adminCommand then
				return
			end

			local effects = adminCommand.effects
			local v5 = effects and effects[p2]

			if not v5 then
				return
			end

			task.spawn(v5, p3)
		end)

		if localPlayer:GetAttribute("AdminCommands") then
			task.spawn(function()
				flag = true
				SetupProfiles()
				SetupCommands()
			end)
		else
			localPlayer:GetAttributeChangedSignal("AdminCommands"):Connect(function()
				if not localPlayer:GetAttribute("AdminCommands") then
					return
				end

				flag = true
				SetupProfiles()
				SetupCommands()
			end)
		end

		Players.PlayerAdded:Connect(function()
			if flag then
				SetupProfiles()
			end
		end)
		Players.PlayerRemoving:Connect(function()
			if flag then
				SetupProfiles()
			end
		end)

		local function liveParseCommand(text: string)
			local v5 = text:lower():gsub("^;", "")
			local v6 = string.split(v5, " ")
			local v7 = v6[1] or ""
			local v8 = v6[2] or ""
			SelectCommand(scrollingFrame2:FindFirstChild(v7))

			if v8 == "" then
				SelectProfile(nil)
				return
			end

			local playerFromPrefix = getPlayerFromPrefix(v8)
			SelectProfile(playerFromPrefix and scrollingFrame:FindFirstChild(playerFromPrefix.Name) or nil)
		end

		local textBox = adminPanel.CommandBox:FindFirstChild("TextBox")
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			liveParseCommand(textBox.Text)
		end)
		textBox.FocusLost:Connect(function(p)
			if p then
				ExecuteCommand()
			end
		end)
	end
}