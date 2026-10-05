local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
local UI = require(game.ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Modules.Stats)
local CurrentCustomServerData = require(script.Parent.CustomServerHandler.CurrentCustomServerData)
local localPlayer = Players.LocalPlayer
local customServerMenuMusic = localPlayer.PlayerGui:WaitForChild("Prompts"):WaitForChild("CustomServerMenuMusic")
local customServer = localPlayer.PlayerGui:WaitForChild("CustomServer").CustomServer
local menuMusic = customServer.Pages.Main.List.MenuMusic
local customMenuMusic = ReplicatedStorage.Assets:WaitForChild("CustomMenuMusic")
local child = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function open()
	flag = true
	customServerMenuMusic.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close()
	flag = false
	customServerMenuMusic.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleUI()
	if flag then
		close() -- equivalent call inferred; original call site unknown
	else
		open() -- equivalent call inferred; original call site unknown
	end
end

local function updateSearch()
	local v = customServerMenuMusic.Search.Text:lower():gsub(" ", "")

	for _, frame in customServerMenuMusic.List:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = frame.Title.Text:lower():gsub(" ", ""):match(v)
		end
	end
end

local function updateSelection(name: string?)
	local value = customMenuMusic.SoundID.Value

	if not name then
		for _, child2 in customMenuMusic.Music:GetChildren() do
			if tostring(child2.SoundId):gsub("rbxassetid://", "") ~= value then
				continue
			end

			name = child2.Name
			break
		end
	end

	if child then
		child.IsSelected.Visible = false
	end

	child = customServerMenuMusic.List:FindFirstChild(name)

	if not child then
		warn("Failed to find music frame by the name of: ", name)
		return
	end

	child.IsSelected.Visible = true
	customServer.Pages.Main.List.MenuMusic.Title.Text = `Menu Music <font weight="Regular">({name})</font>`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectSong(p)
	customServerMenuMusic.List:FindFirstChild(p.Name)
	updateSelection(p.Name)
end

local function confirmSong()
	if customServerMenuMusic.Buttons.Confirm.Blocked.Visible then
		return
	end

	CurrentCustomServerData.Data.CustomMusic = child.Name
	close() -- equivalent call inferred; original call site unknown
end

local function registerSong(child2)
	local clone = script.Template:Clone()
	clone.Name = child2.Name
	clone.Title.Text = child2.Name
	clone.Parent = customServerMenuMusic.List
	UI:Bind(clone.Button)
	UI:AddShadowOnHover(clone.Button)
	clone.Button.MouseButton1Click:Connect(function()
		selectSong(child2) -- equivalent call inferred; original call site unknown
		customServerMenuMusic.Buttons.Confirm.Blocked.Visible = false
	end)
end

close() -- equivalent call inferred; original call site unknown

for _, child2 in customMenuMusic.Music:GetChildren() do
	registerSong(child2)
end

updateSelection()
UI:Bind(customServerMenuMusic.Buttons.Cancel.Button)
UI:Bind(customServerMenuMusic.Buttons.Confirm.Button)
UI:AddShadowOnHover(customServerMenuMusic.Buttons.Cancel.Button)
UI:AddShadowOnHover(customServerMenuMusic.Buttons.Confirm.Button)
customServerMenuMusic.Search:GetPropertyChangedSignal("Text"):Connect(updateSearch)
customServerMenuMusic.Buttons.Confirm.Button.MouseButton1Click:Connect(function()
	if customServerMenuMusic.Buttons.Confirm.Blocked.Visible then
		return
	end

	CurrentCustomServerData.Data.CustomMusic = child.Name
	close() -- equivalent call inferred; original call site unknown
end)
customServerMenuMusic.Buttons.Cancel.Button.MouseButton1Click:Connect(function()
	close() -- equivalent call inferred; original call site unknown
end)
menuMusic.Value.Button.MouseButton1Click:Connect(function()
	toggleUI() -- equivalent call inferred; original call site unknown
end)
customMenuMusic.SoundID.Changed:Connect(function()
	updateSelection()
end)