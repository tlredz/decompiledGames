local SnowClothesClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function GetIngredientNumber(instance, p)
	local v = 1

	while true do
		local attribute = instance:GetAttribute("Ingredient" .. v)

		if attribute == p then
			break
		end

		if attribute == nil then
			return
		else
			v += 1
		end
	end

	return v
end

function CheckBuildItem(p, instance, instance2)
	if instance2:GetAttribute("Destroyed") or instance2:GetAttribute("Interaction") ~= "Item" or instance:GetAttribute("Cooldown") then
		return
	end

	local name = instance2.Name
	local v = GetIngredientNumber(instance, name)

	if v and instance:GetAttribute("Quantity" .. v) > (instance:GetAttribute("Added" .. v) or 0) then
		instance2.Parent = game.ReplicatedStorage.TempStorage
		instance2:SetAttribute("Destroyed", true)
		local v2 = Client.Events.RequestAddSnowShopIngredient:InvokeServer(p, instance2)

		if v2 and v2.Success then
			instance2:Destroy()
		else
			instance2.Parent = workspace.Items
			instance2:SetAttribute("Destroyed", nil)
		end
	end
end

function LoadClothingBench(instance, p)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent and parent.Parent then
			CheckBuildItem(instance, p, parent)
		end
	end)
end

function SnowClothingShopAdded(instance)
	local recipes = instance:WaitForChild("Recipes")

	for _, child in pairs(instance:WaitForChild("Functional"):GetChildren()) do
		local child2 = recipes:WaitForChild("Recipe" .. string.sub(child.Name, 6))
		LoadClothingBench(child, child2)
	end
end

function SnowClothesClient.Init()
	Client.Utility.ForAllTagged("SnowClothingShop", SnowClothingShopAdded)
end

return SnowClothesClient