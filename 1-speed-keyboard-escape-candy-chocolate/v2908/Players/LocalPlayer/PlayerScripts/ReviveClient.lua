local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Ads = require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("Ads"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local revivePrompt = remotes:WaitForChild("RevivePrompt")
local requestRevive = remotes:WaitForChild("RequestRevive")
local requestAdRevive = remotes:WaitForChild("RequestAdRevive")
local reviveSuccess = remotes:WaitForChild("ReviveSuccess")
local REVIVE = Config.DEV_PRODUCTS.REVIVE

local function getTaggedInGui(tag: string)
	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideFrame()
	local taggedInGui = getTaggedInGui("ReviveFrame")

	if taggedInGui and taggedInGui:IsA("GuiObject") then
		taggedInGui.Visible = false
	end
end

local flag = false
local mouseButton1ClickConnections = {}
local flag2 = false

local function maximizeZIndex(folder)
	if flag2 then
		return
	end

	flag2 = true
	folder.ZIndex += 99999

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 99999
		end
	end

	local screenGui = folder:FindFirstAncestorOfClass("ScreenGui")

	if screenGui then
		screenGui.DisplayOrder = 99999
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectButtons()
	for _, connection in mouseButton1ClickConnections do
		if connection.Connected then
			connection:Disconnect()
		end
	end
end

revivePrompt.OnClientEvent:Connect(function(p: number)
	if flag then
		return
	end

	flag = true
	local taggedInGui = getTaggedInGui("ReviveFrame")

	if not (taggedInGui and taggedInGui:IsA("GuiObject")) then
		flag = false
		return
	end

	maximizeZIndex(taggedInGui)
	local taggedInGui2 = getTaggedInGui("ReviveText")

	if taggedInGui2 and taggedInGui2:IsA("TextLabel") then
		taggedInGui2.Text = "Revive to level " .. tostring(p) .. " ?"
	end

	taggedInGui.Visible = true
	local flag3 = false
	local taggedInGui3 = getTaggedInGui("ReviveButton")

	if taggedInGui3 and taggedInGui3:IsA("GuiButton") then
		local mouseButton1ClickConnection = taggedInGui3.MouseButton1Click:Connect(function()
			if flag3 then
				return
			end

			flag3 = true
			requestRevive:FireServer()
		end)
		table.insert(mouseButton1ClickConnections, mouseButton1ClickConnection)
	end

	local taggedInGui4 = getTaggedInGui("AdReviveButton")

	if taggedInGui4 and taggedInGui4:IsA("GuiButton") then
		taggedInGui4.Visible = false

		if Ads.checkForAds() then
			taggedInGui4.Visible = true
			local mouseButton1ClickConnection = taggedInGui4.MouseButton1Click:Connect(function()
				if flag3 then
					return
				end

				flag3 = true
				requestAdRevive:FireServer()
			end)
			table.insert(mouseButton1ClickConnections, mouseButton1ClickConnection)
		else
			taggedInGui4.Visible = false
		end
	end

	task.delay(5, function()
		disconnectButtons() -- equivalent call inferred; original call site unknown
		table.clear(mouseButton1ClickConnections)
		hideFrame() -- equivalent call inferred; original call site unknown
		flag = false
	end)
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if not (p == localPlayer.UserId and p2 == REVIVE) then
		return
	end

	if not p3 then
		hideFrame() -- equivalent call inferred; original call site unknown
		flag = false
	end
end)
reviveSuccess.OnClientEvent:Connect(function()
	disconnectButtons() -- equivalent call inferred; original call site unknown
	hideFrame() -- equivalent call inferred; original call site unknown
	flag = false
	local BUY = Config.SOUNDS.BUY
	local sound = Instance.new("Sound")
	sound.SoundId = BUY.ID
	sound.Volume = BUY.Volume
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 5)
end)