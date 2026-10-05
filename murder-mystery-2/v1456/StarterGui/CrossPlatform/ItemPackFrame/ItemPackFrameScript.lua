require(script:WaitForChild("GodlyShop"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("Button"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local parent = script.Parent
local itemPack = parent:WaitForChild("Container"):WaitForChild("ItemPack")

local function initialize()
	WindowService:RegisterFrame(parent, "ItemPack")
	Button.createButton(itemPack:WaitForChild("Title"):WaitForChild("Close"), function()
		WindowService:Back()
	end)
end

initialize()