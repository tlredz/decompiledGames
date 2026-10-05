local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local WorldController = require(legacyControllers.WorldController)
local currentWorldIndex = WorldController:GetCurrentWorldIndex()
local localPlayer = game.Players.LocalPlayer
local currentWorldBestiary = WorldController:GetCurrentWorldBestiary()
script.Parent.Parent.Parent.currentHabitat.Value = currentWorldBestiary
local scroll = script.Parent.Parent.Parent:WaitForChild("fish"):WaitForChild("scroll")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage3.shared.modules:WaitForChild("fx"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage4.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local locations = require(ReplicatedStorage5.shared.modules:WaitForChild("library"):WaitForChild("locations"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local character = require(ReplicatedStorage6.shared.modules:WaitForChild("character"))
local v = character.PS(localPlayer)

if not v then
	repeat
		task.wait()
		v = character.PS(localPlayer)
	until v ~= nil
end

function UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, p2.AbsoluteContentSize.X, 0, p2.AbsoluteContentSize.Y + 20)
end

function LoadBestiaryCatagory(_)
	local isLimited = script.Parent.Parent.Parent:WaitForChild("IsLimited")
	isLimited.Value = false
	local search = script.Parent.Parent.Parent:WaitForChild("fish"):WaitForChild("search")
	search.Text = ""
	local location = locations[currentWorldBestiary]
	print(location)

	if currentWorldBestiary == "All" then
		scroll.Parent.Parent.title.Text = "Bestiary"
		scroll.Parent.Parent.header.Image = "rbxassetid://17849803528"
	else
		scroll.Parent.Parent.title.Text = "Bestiary [" .. (location and location.Name or currentWorldBestiary) .. "]"
		scroll.Parent.Parent.header.Image = locations[currentWorldBestiary].Banner
	end

	script.Parent.Parent.Parent.currentHabitat.Value = currentWorldBestiary
	UpdateCanvasSize(scroll, scroll.UIGridLayout)
	UpdateCanvasSize(script.Parent, script.Parent:WaitForChild("UIListLayout"))
	scroll.Parent.Parent.select.frame.Visible = false
	scroll.Parent.Parent.select.none.Visible = true
	FindCompletetion()
end

function FindCompletetion()
	task.spawn(function()
		local bestiary = character:GetBestiary(localPlayer, currentWorldBestiary)
		local v2 = tonumber(string.format("%." .. 1 .. "f", bestiary))

		if currentWorldBestiary == "All" or currentWorldBestiary == "None" or currentWorldBestiary == nil then
			local percent = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent.Text = "   " .. v2 .. "% Completed [All]"
		else
			local percent_2 = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent_2.Text = "   " .. v2 .. "% Completed [" .. currentWorldBestiary .. "]"
		end

		if v2 >= 100 then
			local percent_3 = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent_3.TextColor3 = Color3.fromRGB(200, 192, 106)

			if v:FindFirstChild("Stats"):FindFirstChild("tracker_bestiaryCompletions") and not v:FindFirstChild("Stats"):FindFirstChild("tracker_bestiaryCompletions"):FindFirstChild(currentWorldBestiary) then
				local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
				ReplicatedStorage7:WaitForChild("events"):WaitForChild("bestiarycomplete"):FireServer(currentWorldBestiary)
			end
		else
			local percent_4 = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent_4.TextColor3 = Color3.fromRGB(120, 120, 120)
		end

		if script.Parent.Parent.Parent.IsLimited.Value == false then
			local percent_5 = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent_5.Visible = true
		end

		return (tonumber(string.format("%." .. 1 .. "f", v2)))
	end)
end

task.wait(2)
LoadBestiaryCatagory()
script.Parent.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	currentWorldBestiary = WorldController:GetCurrentWorldBestiary()
	LoadBestiaryCatagory()
end)

for k, location in pairs(locations) do
	if not (location.Hide ~= true and (not location.Worlds or table.find(location.Worlds, currentWorldIndex))) then
		continue
	end

	local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
	local timeEvent = ReplicatedStorage7:GetAttribute("TimeEvent")
	local clone = script:WaitForChild("button"):Clone()

	if k == "All" then
		clone.Name = "1 " .. "All"
	else
		clone.Name = k
	end

	clone.Image = location.Banner
	clone.Parent = script.Parent
	local v2 = false
	local v3 = k
	clone.MouseButton1Click:Connect(function()
		if v2 == false then
			return
		end

		currentWorldBestiary = v3
		LoadBestiaryCatagory()
		local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage8:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("bestiaryCatagory"),
			script.Parent,
			true
		)
	end)
	clone.MouseEnter:Connect(function()
		local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage8:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
			script.Parent,
			true
		)
	end)
	local v4 = k
	local v5 = location

	local function CheckEnabled(flag: boolean?)
		if v:FindFirstChild("Stats"):FindFirstChild("tracker_locationsdiscovered"):FindFirstChild(v4 .. "Discovered") or v4 == "All" or v4 == "Moosewood" or v5.Event ~= nil then
			local title = clone:WaitForChild("title")
			title.Text = v5.Name or v4
			clone.ImageColor3 = Color3.fromRGB(255, 255, 255)
			v2 = true
		else
			v2 = false
			local title_2 = clone:WaitForChild("title")
			title_2.Text = "???"
			clone.ImageColor3 = Color3.fromRGB(35, 35, 35)
		end
	end

	if location.Event and timeEvent then
		v2 = true
		local timeEventChangedConnection = nil
		local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
		local v7 = clone
		local v8 = k
		timeEventChangedConnection = ReplicatedStorage8:GetAttributeChangedSignal("TimeEvent"):Connect(function(p)
			if p == nil then
				timeEventChangedConnection:Disconnect()
				v7:Destroy()

				if currentWorldBestiary == v8 then
					currentWorldBestiary = "All"
					LoadBestiaryCatagory()
				end
			end
		end)
	elseif location.Event and not timeEvent then
		clone:Destroy()
	end

	CheckEnabled()
	local CheckEnabled2 = CheckEnabled
	v:FindFirstChild("Stats"):FindFirstChild("tracker_locationsdiscovered").ChildAdded:Connect(function()
		CheckEnabled2()
	end)
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	UpdateCanvasSize(script.Parent, script.Parent:WaitForChild("UIListLayout"))
end)
script.Parent.Parent.Parent.Changed:Connect(function()
	FindCompletetion()
end)