local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
game:GetService("ContentProvider")
ReplicatedFirst:RemoveDefaultLoadingScreen()
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
local v = false
local v2 = false
local v3 = nil
local v4 = false
TeleportService.LocalPlayerArrivedFromTeleport:connect(function(_, data)
	v3 = true
	ReplicatedFirst.ClientLoaded:FireServer("Teleport")

	if data then
		if data.Joined == true then
			v = true
		end

		if data.ModeSwitch then
			v2 = true
		end

		if data.PortalEvent == true then
			v4 = true
		end
	end
end)
local _ = game.PlaceId == 142823291
local _ = game.PlaceId == 142823291
local _ = game.PlaceId == 142823291
local flag = false
local isTenFootInterface = GuiService:IsTenFootInterface()
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local loading = script:WaitForChild("Loading")
loading.Name = "Loading"
loading.Parent = playerGui
local container = loading:WaitForChild("Container")
local images = container:WaitForChild("Images")
local grey = images:WaitForChild("Grey")
local colored_Clean = images:WaitForChild("Colored_Clean")

if isTenFootInterface then
	task.spawn(function()
		game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("IsXbox"):FireServer()
	end)
	playerGui:SetAttribute("Device", "Gamepad")
end

local ResetGUI

ResetGUI = function(instance, clone)
	clone.AncestryChanged:connect(function(_, p)
		if p == nil and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI") == nil then
			local clone2 = instance:Clone()
			ResetGUI(instance, clone2)
			clone2.Name = "MainGUI"
			clone2.Parent = game.Players.LocalPlayer.PlayerGui
		end
	end)
end

local v5 = game.GameId == 119460199
local _ = game.PlaceId == 636649648
local _ = game.PlaceId == 335132309
local _ = game.PlaceId == 5928494131

local function GiveGameGUI()
	local clone

	if flag then
		clone = game.ReplicatedStorage:WaitForChild("GUI"):WaitForChild("MainMobile"):Clone()
	elseif isTenFootInterface then
		if v5 then
			if playerGui:WaitForChild("MainXbox", 1) then
				clone = playerGui:WaitForChild("MainXbox")
			else
				clone = game.ReplicatedStorage:WaitForChild("GUI"):WaitForChild("MainXbox"):Clone()
			end
		else
			clone = game.ReplicatedStorage:WaitForChild("GUI"):WaitForChild("MainXbox"):Clone()
		end
	else
		local RunService2 = game:GetService("RunService")
		RunService2:IsStudio()
		clone = game.ReplicatedStorage:WaitForChild("GUI"):WaitForChild("MainPC"):Clone()
	end

	clone.Name = "MainGUI"
	clone.Parent = game.ReplicatedStorage
	local clone2 = clone:Clone()
	clone2.AncestryChanged:connect(function(_, p)
		if p == nil and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI") == nil then
			local clone3 = clone:Clone()
			ResetGUI(clone, clone3)
			clone3.Name = "MainGUI"
			clone3.Parent = game.Players.LocalPlayer.PlayerGui
		end
	end)
	clone2.Parent = game.Players.LocalPlayer.PlayerGui
end

local function LoadGame()
	tonumber(game.ContentProvider.RequestQueueSize)
	local v6 = false
	local v7 = false
	task.spawn(function()
		task.wait(7)
		pcall(function()
			if not v6 then
				local skip = container:WaitForChild("Skip")
				skip.Visible = true
				local warning = container:WaitForChild("Warning")
				warning.Visible = true
				container:WaitForChild("Skip").Activated:Connect(function()
					v7 = true
				end)
			end
		end)
	end)

	while game.ContentProvider.RequestQueueSize > 0 and not v7 do
		local loadingText = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText.Text = "Loading World: " .. game.ContentProvider.RequestQueueSize .. " objects left."
		RunService.PreSimulation:Wait()
	end

	v6 = true
	local skip = container:WaitForChild("Skip")
	skip.Visible = false
	local warning = container:WaitForChild("Warning")
	warning.Visible = false
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
local isStudio = RunService:IsStudio()

local function WaitForCharacter()
	if not isStudio then
		local loadingText = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText.Text = "Loading Data..."
		task.wait(1)
		local loadingBar = loading:WaitForChild("Container"):WaitForChild("LoadingBar")
		loadingBar.Visible = true
		local loadingText_2 = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText_2.Visible = false
		task.wait(0.5)
		TweenService:Create(
			loading:WaitForChild("Container"):WaitForChild("LoadingBar"):WaitForChild("BarContainer"):WaitForChild("Bar"),
			tweenInfo,
			{
				Size = UDim2.new(1, 0, 1, 0)
			}
		):Play()
		task.wait(1.8)
		local loadingBar_2 = loading:WaitForChild("Container"):WaitForChild("LoadingBar")
		loadingBar_2.Visible = false
		local loadingText_3 = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText_3.Text = "Loading Character..."
		local loadingText_4 = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText_4.Visible = true
	end

	local loadingData

	repeat
		task.wait()
		loadingData = game.Players.LocalPlayer:FindFirstChild("LoadingData")
	until game.Players.LocalPlayer.Character ~= nil or loadingData

	if loadingData then
		local loadingText_5 = loading:WaitForChild("Container"):WaitForChild("LoadingText")
		loadingText_5.Text = "Verifying Data, please wait 60 seconds!..."

		repeat
			wait()
		until game.Players.LocalPlayer.Character ~= nil
	end
end

_G.Cache = {}
_G.SmallCache = {}

local function GetImage(p)
	if _G.Cache[p] ~= nil then
		return _G.Cache[p]
	end

	if tonumber(p) then
		p = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. p or p
	end

	return p
end

local _ = {
	"Item",
	"Perks",
	"Radios",
	"Effects",
	"Emotes",
	"Toys",
	"Pets"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function DoneLoading()
	colored_Clean.Visible = true
	colored_Clean.ImageTransparency = 0
	grey.Visible = false
	local loadingText = container:WaitForChild("LoadingText")
	loadingText.Text = ""
	local thumbs = container:WaitForChild("Thumbs")
	thumbs.Visible = false
end

local function FadeOut()
	while container.BackgroundTransparency < 1 do
		local v6 = RunService.PreSimulation:Wait() * 1.3
		container.BackgroundTransparency += v6
		colored_Clean.ImageTransparency += v6
	end
end

local v6 = true
task.spawn(function()
	while task.wait() and v6 do
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end

	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end)

local function Play()
	if not flag then
		LoadGame()
	end

	DoneLoading() -- equivalent call inferred; original call site unknown
	task.wait(1)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	GiveGameGUI()
	FadeOut()
	loading:Destroy()
	game.ReplicatedStorage.GUI:Destroy()
	v6 = false
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("LoadedCompletely"):FireServer()
end

local _ = game.PlaceId == 142823291
local _ = game.PlaceId == 142823291
local _ = game.PlaceId == 142823291
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isVIPServer = ReplicatedStorage:GetAttribute("IsVIPServer") == true
local v7 = not (v or isVIPServer)
local placeId = nil
local gameId = nil
local v8 = {
	[142823291] = "Main Server",
	[335132309] = "Main Server",
	[636649648] = "Main Server",
	[188331334] = "Testing Server",
	[333740520] = "Testing Server",
	[4809287476] = "Testing Server"
}
local _ = {
	[142823291] = true,
	[188331334] = true
}
local v9 = {
	[333740520] = true,
	[335132309] = true
}
local v10 = {
	[636649648] = true
}
local _ = {
	[4809287476] = true
}
local v11 = {
	Hardcore = 333740520,
	Classic = 188331334,
	[333740520] = "Disguises",
	[188331334] = "Standard"
}
local _ = {
	Hardcore = 335132309,
	Classic = 142823291,
	Assassin = 636649648,
	[335132309] = "Disguises",
	[142823291] = "Standard",
	[636649648] = "Assassin"
}
local clone = not flag and script:WaitForChild("Join"):Clone() or script:WaitForChild("JoinPhone"):Clone()
clone.Retry.Retry.MouseButton1Click:connect(function()
	clone.Retry.Visible = false
	clone.Friends.Visible = true
end)
local v12 = v11[game.PlaceId]
local UpdateList

UpdateList = function(p)
	local v13 = p or game.Players.LocalPlayer:GetFriendsOnline()
	clone.Friends.FriendsList.ScrollingFrame.Container:ClearAllChildren()
	local clone_2 = script.FriendLayout:Clone()
	clone_2.Parent = clone.Friends.FriendsList.ScrollingFrame.Container

	for _, v14 in pairs(v13) do
		if not v8[v14.PlaceId] then
			continue
		end

		local clone2 = script.FriendFrame:Clone()
		clone2.FriendName.Text = v14.UserName or v14.DisplayName or ""
		local v15 = v11[v14.PlaceId]

		if v14.LocationType == 3 then
			clone2.Studio.Visible = true
		elseif v15 and not v12 then
			clone2.Server.Text = "Testing Server"
			clone2.Server.Visible = true
		elseif v12 and not v15 then
			clone2.Server.Text = "Main Server"
			clone2.Server.Visible = true
		else
			clone2.Join.Visible = true
			clone2.Assassin.Visible = v10[v14.PlaceId]
			clone2.Hardcore.Visible = v9[v14.PlaceId]
		end

		clone2.Parent = clone.Friends.FriendsList.ScrollingFrame.Container
		local v16 = v14
		clone2.Join.MouseButton1Click:connect(function()
			clone.Friends.Visible = false
			clone.Loading.Visible = true
			local flag2 = false

			for k, v18 in pairs(game.Players:GetPlayers()) do
				if v18.UserId ~= v16.VisitorId then
					continue
				end

				flag2 = true
				break
			end

			if flag2 then
				clone:Destroy()
				Play()
			else
				placeId = v16.PlaceId
				gameId = v16.GameId
				TeleportService:TeleportToPlaceInstance(placeId, gameId, game.Players.LocalPlayer, "", {
					Joined = true
				})
				spawn(function()
					while clone.Loading.Visible == true do
						clone.Loading.Spinner.Rotation = clone.Loading.Spinner.Rotation + 5
						local RunService2 = game:GetService("RunService")
						RunService2.RenderStepped:wait()
					end
				end)
				wait(5)
				clone.Friends.Visible = false
				clone.Retry.Visible = true
				clone.Loading.Visible = false
				spawn(function()
					while clone.Retry.Visible == true do
						clone.Retry.Spinner.Rotation = clone.Retry.Spinner.Rotation + 5
						local RunService2 = game:GetService("RunService")
						RunService2.RenderStepped:wait()
					end
				end)
				spawn(function()
					local v18 = 1

					while clone.Retry.Visible == true do
						clone.Retry.Retrying.Text = "Retrying... (" .. v18 .. ")"
						placeId = v16.PlaceId
						gameId = v16.GameId
						TeleportService:TeleportToPlaceInstance(placeId, gameId, game.Players.LocalPlayer, "", {
							Joined = true
						})

						for i = 1, 50 do
							wait(0.1)

							if not clone.Retry.Visible then
								break
							end
						end

						v18 += 1
					end
				end)
				UpdateList()
			end
		end)
	end
end

local function JoinFriend()
	if not v7 then
		Play()
		return
	end

	local friendsOnline = nil
	pcall(function()
		friendsOnline = game.Players.LocalPlayer:GetFriendsOnline()
	end)

	if friendsOnline and #friendsOnline > 0 then
		local v13 = false

		for _, v14 in pairs(friendsOnline) do
			if v8[v14.PlaceId] then
				v13 = true
			end
		end

		if v13 and not flag then
			clone.Parent = game.Players.LocalPlayer.PlayerGui
			UpdateList(friendsOnline)
			clone.Friends.Play.MouseButton1Click:Connect(function()
				clone:Destroy()
				Play()
			end)
		else
			Play()
		end
	else
		Play()
	end
end

local function SelectGameMode()
	JoinFriend()
end

local function ConnectJoinFrame()
	clone = not flag and script.Join:Clone() or script.JoinPhone:Clone()
	clone.Retry.Retry.MouseButton1Click:connect(function()
		clone.Retry.Visible = false
		clone.Friends.Visible = true
	end)
end

local v13 = {
	Tablet = "Phone",
	Phone = "Tablet"
}

local function SelectDevice()
	local deviceSelect = script:WaitForChild("DeviceSelect")
	local v14 = game.ReplicatedStorage.Remotes.Extras.GetData:InvokeServer("LastDevice")
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:PreloadAsync({
		"https://www.roblox.com/asset/?id=466263397",
		"https://www.roblox.com/asset/?id=466240313"
	})
	task.wait()
	deviceSelect.Parent = game.Players.LocalPlayer.PlayerGui

	if v14 then
		local last = deviceSelect:WaitForChild("Container"):WaitForChild(v14):WaitForChild("Last")
		last.Visible = true
		local cover = deviceSelect:WaitForChild("Container"):WaitForChild(v13[v14]):WaitForChild("Cover")
		cover.Visible = true
		local switch = deviceSelect:WaitForChild("Container"):WaitForChild(v13[v14]):WaitForChild("Switch")
		switch.Visible = true
	end

	deviceSelect:WaitForChild("Container"):WaitForChild("Phone"):WaitForChild("Button").MouseButton1Click:connect(function()
		flag = true
		game.Players.LocalPlayer.PlayerGui:SetAttribute("Device", "Phone")
		task.spawn(function()
			game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("ChangeLastDevice"):FireServer("Phone")
		end)
		deviceSelect:Destroy()
		ConnectJoinFrame()
		JoinFriend()
		_G.MobileDevice = "Phone"
	end)
	deviceSelect:WaitForChild("Container"):WaitForChild("Tablet"):WaitForChild("Button").MouseButton1Click:connect(function()
		task.spawn(function()
			game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("ChangeLastDevice"):FireServer("Tablet")
		end)
		deviceSelect:Destroy()
		ConnectJoinFrame()
		JoinFriend()
		_G.MobileDevice = "Tablet"
		game.Players.LocalPlayer.PlayerGui:SetAttribute("Device", "Tablet")
	end)
end

local v14 = UserInputService:GetLastInputType() == Enum.UserInputType.Touch
local touchEnabled = UserInputService.TouchEnabled
local keyboardEnabled = UserInputService.KeyboardEnabled

if v5 then
	print("== TESTING SERVER ==")
end

print("Server Version: " .. game.PlaceVersion)
local v16 = v5 and isStudio and script:GetAttribute("studioTouchEnabled") and true or v14 or touchEnabled and not keyboardEnabled or touchEnabled and isStudio

local function Initialize()
	WaitForCharacter()

	if game.Players.LocalPlayer.FollowUserId > 0 and not isVIPServer then
		local v17 = false

		for _, child in pairs(game.Players:GetChildren()) do
			if child.userId ~= game.Players.LocalPlayer.FollowUserId then
				continue
			end

			v17 = true
			break
		end

		if not v17 then
			local loadingText = container:WaitForChild("LoadingText")
			loadingText.Text = "Joining User..."
			game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("Follow"):FireServer()
			task.wait(5)
			local loadingText_2 = container:WaitForChild("LoadingText")
			loadingText_2.Text = "Failed to join user."
			task.wait(1)
		end

		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("DeviceService"))

		if v16 then
			SelectDevice()
			return
		end

		JoinFriend()
		game.Players.LocalPlayer.PlayerGui:SetAttribute("Device", "PC")
	else
		if isTenFootInterface or flag then
			Play()
			return
		end

		if v16 then
			SelectDevice()
			return
		end

		JoinFriend()
		game.Players.LocalPlayer.PlayerGui:SetAttribute("Device", "PC")
	end
end

Initialize()