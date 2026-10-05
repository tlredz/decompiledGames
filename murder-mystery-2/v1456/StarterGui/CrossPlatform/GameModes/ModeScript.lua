local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local requestTeleport = game.ReplicatedStorage.Remotes.Extras.RequestTeleport
local FriendsModule = require(game.ReplicatedStorage.Modules.FriendsModule)
local parent = script.Parent
local modes = parent:WaitForChild("Container"):WaitForChild("Modes")
local teleportInfo = parent.TeleportInfo
local overlay = parent.Overlay
local modeFrame = script:WaitForChild("ModeFrame")
local modeOverlay = script:WaitForChild("ModeOverlay")
local listItem = modeOverlay:WaitForChild("ModeInfo"):WaitForChild("ModeList"):WaitForChild("ListItem")
listItem.Parent = script
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local gameModes = require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync")).GameModes

local function getPlayerCount(p)
	return gameModes[p].PlayerCount
end

local function getFriendsPlayingMode(_)
	return 0
end

local function updateFrame(p)
	local name = p.Name
	local info = p.Info
	local friendsOnline = FriendsModule:GetFriendsOnline()
	local placeID = gameModes[name].PlaceID
	local count = 0

	for _, v in friendsOnline do
		if v.PlaceId == placeID then
			count += 1
		end
	end

	local text = count .. " " .. (count == 1 and "Friend" or "Friends") .. " Online"
	info.PlayerCount.Visible = gameModes[name].PlayerCount > 0
	info.FriendsPlaying.Visible = count > 0
	info.FriendsPlaying.TextLabel.Text = text
	local popular = info.Popular
	popular.Visible = name == "Standard" and info.PlayerCount.Visible == false and info.FriendsPlaying.Visible == false
	local child = overlay.Container:FindFirstChild(name)
	child.FriendsPlaying.Visible = count > 0
	child.FriendsPlaying.TextLabel.Text = text
	child.Actions.Friends.Visible = count > 0
end

local function setupModes()
	for k, gameMode in gameModes do
		if gameMode.Hidden then
			continue
		end

		local clone = modeFrame:Clone()
		clone.Name = k
		clone.Info.ModeName.TextLabel.Text = gameMode.DisplayName
		clone.Info.ModeIcon.ImageLabel.Image = gameMode.Image
		clone.Info.ModeIcon.Limited.Visible = gameMode.LimitedTime == true
		clone.LayoutOrder = gameMode.Order
		local clone2 = modeOverlay:Clone()
		clone2.ModeName.Text = gameMode.DisplayName
		clone2.ModeInfo.ModeIcon.ImageLabel.Image = gameMode.Image

		for k2, text in gameMode.Description do
			local clone3 = listItem:Clone()
			clone3.Text = text
			clone3.LayoutOrder = k2
			clone3.Parent = clone2.ModeInfo.ModeList
		end

		clone2.Name = k
		clone2.Parent = overlay.Container
		updateFrame(clone)
		clone.Info.ModeIcon.CurrentServer.Visible = gameMode.PlaceID == game.PlaceId
		clone.Button.Activated:Connect(function()
			if not overlay.Visible then
				for i, frame in overlay.Container:GetChildren() do
					if frame:IsA("Frame") and frame.Name ~= "Close" then
						frame.Visible = frame == clone2
					end
				end

				overlay.Visible = true
			end
		end)
		local v2 = gameMode
		local v3 = k
		clone2.Actions.Play.Activated:Connect(function()
			local placeID = v2.PlaceID
			teleportInfo.Visible = true
			requestTeleport:InvokeServer(v3)
		end)
		clone2.Actions.Friends.Activated:Connect(function()
			WindowService:ToggleFrame("FriendsOnline")
		end)
		clone.Parent = modes
	end
end

TeleportService.TeleportInitFailed:Connect(function()
	teleportInfo.Visible = false
end)
overlay.Close.Button.Activated:Connect(function()
	overlay.Visible = false
end)
WindowService:RegisterFrame(parent, "ModeBrowser", function()
	for _, frame in modes:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local _ = frame.Name
		updateFrame(frame)
	end
end)
parent:WaitForChild("Container"):WaitForChild("Title"):WaitForChild("Close"):WaitForChild("Button").Activated:Connect(function()
	parent.Visible = false
end)
os.clock()
setupModes()
task.spawn(function()
	while true do
		task.wait(10)

		for _, frame in modes:GetChildren() do
			if frame:IsA("Frame") then
				updateFrame(frame)
			end
		end
	end
end)