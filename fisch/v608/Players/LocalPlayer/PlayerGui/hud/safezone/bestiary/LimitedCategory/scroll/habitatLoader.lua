local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local WorldController = require(legacyControllers.WorldController)
local currentWorldIndex = WorldController:GetCurrentWorldIndex()
local localPlayer = game.Players.LocalPlayer
local v = "All"
script.Parent.Parent.Parent.currentHabitat.Value = v
local scroll = script.Parent.Parent.Parent:WaitForChild("fish"):WaitForChild("scroll")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local fish = require(ReplicatedStorage2.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage3.shared.modules:WaitForChild("fx"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage4.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local locations = require(ReplicatedStorage5.shared.modules:WaitForChild("library"):WaitForChild("locations"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local character = require(ReplicatedStorage6.shared.modules:WaitForChild("character"))

if not character.PS(localPlayer) then
	repeat
		task.wait()
	until character.PS(localPlayer) ~= nil
end

function UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, p2.AbsoluteContentSize.X, 0, p2.AbsoluteContentSize.Y + 20)
end

function LoadBestiaryCatagory(_)
	local isLimited = script.Parent.Parent.Parent:WaitForChild("IsLimited")
	isLimited.Value = true
	local search = script.Parent.Parent.Parent:WaitForChild("fish"):WaitForChild("search")
	search.Text = ""

	for _, child in pairs(scroll:GetChildren()) do
		local v2 = "" .. string.split(child.Name, " ")[1] .. " "
		local v3 = string.sub(child.Name, #v2 + 1)

		if not fish[v3] then
			continue
		end

		if fish[v3].From == v then
			child.Visible = true
		elseif fish[v3].FromLimited and fish[v3].FromLimited == v then
			child.Visible = true
		else
			child.Visible = false
		end
	end

	scroll.Parent.Parent.title.Text = "Bestiary [" .. v .. "]"
	scroll.Parent.Parent.header.Image = locations[v].Banner
	script.Parent.Parent.Parent.currentHabitat.Value = v
	UpdateCanvasSize(scroll, scroll.UIGridLayout)
	UpdateCanvasSize(script.Parent, script.Parent:WaitForChild("UIListLayout"))
	scroll.Parent.Parent.select.frame.Visible = false
	scroll.Parent.Parent.select.none.Visible = true
	FindCompletetion()
end

function FindCompletetion()
	task.spawn(function()
		if script.Parent.Parent.Parent:WaitForChild("IsLimited").Value == true then
			local percent = script.Parent.Parent.Parent.fish:WaitForChild("percent")
			percent.Visible = false
		end

		return 0
	end)
end

task.wait(2)
LoadBestiaryCatagory()

for k, location in pairs(locations) do
	if not ((not location.Worlds or table.find(location.Worlds, currentWorldIndex)) and location.Limited == true) then
		continue
	end

	local clone = script:WaitForChild("button"):Clone()
	clone.Name = k
	clone.Image = location.Banner
	clone.Parent = script.Parent
	local v2 = k
	clone.MouseButton1Click:Connect(function()
		v = v2
		LoadBestiaryCatagory()
		local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage7:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("bestiaryCatagory"),
			script.Parent,
			true
		)
	end)
	clone.MouseEnter:Connect(function()
		local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage7:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
			script.Parent,
			true
		)
	end)
	local title = clone:WaitForChild("title")
	title.Text = k
	clone.ImageColor3 = Color3.fromRGB(255, 255, 255)
	discovered = true
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	UpdateCanvasSize(script.Parent, script.Parent:WaitForChild("UIListLayout"))
end)