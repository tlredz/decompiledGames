local CrockpotClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {
	"Stew",
	"Berry",
	"Chilli",
	"Hearty Stew",
	"Shark",
	"Seafood Chowder",
	"Steak Dinner",
	"Pumpkin Soup",
	"BBQ Ribs",
	"Carrot Cake",
	"Jar o' Jelly",
	"Candy Apple",
	"Cotton Candy",
	"Pumpkin Pie",
	"Candy Corn",
	"Turkey Legs",
	"Casserole",
	"Berry Juice",
	"Roast Turkey",
	"Corn on the Cob",
	"Stuffed Peppers",
	"Stuffing Bowl",
	"Sweet Potato Pie",
	"Spicy Swordfish",
	"BBQ Ribs",
	"Hearty Thanksgiving Meal",
	"Strawberry",
	"Candied Meat",
	"Meat? Sandwich",
	"Giant Lollypop",
	"Rock Cake"
}
local v2 = { "Berry", "Chilli" }
local v3 = false

function AddCrockpot(instance)
	if instance.Name == "Chefs Station" and (localPlayer:GetAttribute("Class") or "None") ~= "Chef" then
		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "ItemPlace" or child.Name == "DashedLine" then
				child:Destroy()
			end
		end
	end

	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent:GetAttribute("CrockPotBanned") or parent:GetAttribute("PreparedMeal") or parent:GetAttribute("ToolName") == "Consumable" or string.find(
			parent.Name,
			"Shark"
		) then
			return
		end

		if instance:GetAttribute("Ingredients") >= 3 or instance:GetAttribute("Cooking") or otherPart:GetAttribute("Crockpot") or instance:GetAttribute("CanTake") then
			return
		end

		if instance.Name == "Chefs Station" and (localPlayer:GetAttribute("Class") or "None") ~= "Chef" then
			local owner = parent:GetAttribute("Owner")

			if (owner and owner == localPlayer.UserId or parent:GetAttribute("LastOwner") and parent:GetAttribute("LastOwner") == localPlayer.UserId) and not v3 then
				Client.PopUpUI.AddPopUp("only the Chef can cook with this", "warning")
				v3 = true
				task.spawn(function()
					wait(10)
					v3 = false
				end)
			end
		else
			if table.find(v, parent.Name) and not (Client.Utility.IsFlameActive("Thanksgiving Flame") and table.find(
				v2,
				parent.Name
			)) then
				return
			end

			if parent and parent.Parent and (parent:GetAttribute("RestoreHunger") or parent:GetAttribute("CrockpotIngredient")) then
				local owner = parent:GetAttribute("Owner")

				if owner == nil or owner == localPlayer.UserId then
					local parent2 = parent.Parent
					task.spawn(function() end)
					parent.Parent = nil
					local v4 = Client.Events.RequestCrockpotItem:InvokeServer(instance, parent)

					if v4 and v4.Success then
						Client.Sound.Play("AddCrockpot", {
							Duplicate = true
						})
					else
						parent.Parent = parent2
					end
				end
			end
		end
	end)
end

function CrockpotClient.Init()
	task.spawn(function() end)
end

Client.Utility.ForAllTagged("Crockpot", AddCrockpot)
return CrockpotClient