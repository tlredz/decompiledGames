local vessels = require(game.ReplicatedStorage.shared.modules.vessels)
local library = vessels.library
local parent = script.Parent
local character = require(game.ReplicatedStorage.shared.modules.character)
local v = character.PS(game.Players.LocalPlayer)

if v == nil then
	repeat
		task.wait(1)
		v = character.PS(game.Players.LocalPlayer)
	until v ~= nil
end

local boats = v:WaitForChild("Boats")

local function createSearchBar(instance, instance2)
	local textBox = instance:WaitForChild("TextBox")

	local function updateSearch()
		local lower = textBox.Text:match("^%s*(.-)%s*$"):lower()

		for _, frame in ipairs(instance2:GetChildren()) do
			if not (frame:IsA("Frame") and frame:GetAttribute("CanSearch")) then
				continue
			end

			if library[frame:GetAttribute("BoatName")].HideInShop and not boats:FindFirstChild(frame:GetAttribute("BoatName")) then
				frame.Visible = false
			else
				frame.Visible = frame.Name:lower():find(lower, 1, true) ~= nil and not frame:GetAttribute("Hidden") or frame:GetAttribute("AlwaysVisible")
			end
		end
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)
end

local search = parent:WaitForChild("Search")
local safezone = parent:WaitForChild("ships"):WaitForChild("main"):WaitForChild("safezone")
local textBox = search:WaitForChild("TextBox")

local function updateSearch()
	local lower = textBox.Text:match("^%s*(.-)%s*$"):lower()

	for _, frame in ipairs(safezone:GetChildren()) do
		if not (frame:IsA("Frame") and frame:GetAttribute("CanSearch")) then
			continue
		end

		if library[frame:GetAttribute("BoatName")].HideInShop and not boats:FindFirstChild(frame:GetAttribute("BoatName")) then
			frame.Visible = false
		else
			frame.Visible = frame.Name:lower():find(lower, 1, true) ~= nil and not frame:GetAttribute("Hidden") or frame:GetAttribute("AlwaysVisible")
		end
	end
end

textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)