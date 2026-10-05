local BakingConfig = {
	COOK_DURATION_SECONDS = 5,
	CLAIM_GRACE_SECONDS = 10,
	WARNING_TO_FIRE_SECONDS = 3,
	TIME_DISPLAY_BLINK_INTERVAL = 0.25,
	BURNT_FOOD_TOOL = "Burnt Food",
	EAT_STATES = {
		"Full",
		"SomeEaten",
		"MostlyEaten",
		"NearlyEaten",
		"Empty"
	},
	Foods = {
		Brownies = {
			ovenFolder = "Brownies",
			sharedFolder = "Brownie",
			fullTool = "Brownies",
			portionTool = "Brownies",
			displayName = "Brownies",
			sharedIcon = "rbxassetid://73037666067364",
			portionIcon = "rbxassetid://106178233860231",
			requiresVip = true
		},
		Cake = {
			ovenFolder = "Cake",
			sharedFolder = "StrawberryCake",
			fullTool = "StrawberryCake",
			portionTool = "StrawberryCake",
			displayName = "Strawberry Cake",
			sharedIcon = "rbxassetid://115681652754190",
			portionIcon = "rbxassetid://85251066931702"
		},
		Chicken = {
			ovenFolder = "Chicken",
			sharedFolder = "RoastChicken",
			fullTool = "RoastChicken",
			portionTool = "RoastChicken",
			displayName = "Roast Chicken",
			sharedIcon = "rbxassetid://138191923144123",
			portionIcon = "rbxassetid://128507101734408"
		},
		Cookies = {
			ovenFolder = "Cookies",
			sharedFolder = "Cookies",
			fullTool = "Cookies",
			portionTool = "Cookies",
			displayName = "Cookies",
			sharedIcon = "rbxassetid://130457393503611",
			portionIcon = "rbxassetid://118665742114146"
		},
		Enchiladas = {
			ovenFolder = "Enchiladas",
			sharedFolder = "Enchiladas",
			fullTool = "Enchiladas",
			portionTool = "Enchiladas",
			displayName = "Enchiladas",
			sharedIcon = "rbxassetid://88406554990313",
			portionIcon = "rbxassetid://106655423148109",
			requiresVip = true
		},
		Lasagne = {
			ovenFolder = "Lasagne",
			sharedFolder = "Lasagne",
			fullTool = "Lasagne",
			portionTool = "Lasagne",
			displayName = "Lasagne",
			sharedIcon = "rbxassetid://135919376586929",
			portionIcon = "rbxassetid://127454877553399"
		},
		Muffins = {
			ovenFolder = "Muffins",
			sharedFolder = "Muffins",
			fullTool = "Muffins",
			portionTool = "ChocolateMuffin",
			displayName = "Muffins",
			sharedIcon = "rbxassetid://129506680050576",
			portionIcon = "rbxassetid://100520779167737"
		},
		Pizza = {
			ovenFolder = "Pizza",
			sharedFolder = "Pizza",
			fullTool = "Pizza",
			portionTool = "Pizza",
			displayName = "Pizza",
			sharedIcon = "rbxassetid://108330668484044",
			portionIcon = "rbxassetid://106562890160143"
		}
	}
}

function BakingConfig.GetFood(p: string)
	return BakingConfig.Foods[p]
end

function BakingConfig.GetFullToolName(p: string)
	return "BakeFull_" .. p
end

function BakingConfig.GetPortionToolName(p: string)
	return "BakePortion_" .. p
end

function BakingConfig.ParseToolName(p: string)
	for k in BakingConfig.Foods do
		if p == BakingConfig.GetFullToolName(k) then
			return k, "Full"
		end

		if p == BakingConfig.GetPortionToolName(k) then
			return k, "Portion"
		end
	end

	return nil, nil
end

function BakingConfig.GetToolTextureId(p: string, p2: string)
	local food = BakingConfig.GetFood(p)

	if food == nil then
		return nil
	end

	if p2 == "Portion" then
		return food.portionIcon or food.sharedIcon
	end

	return food.sharedIcon
end

function BakingConfig.GetIconForToolName(p: string)
	local toolName, v = BakingConfig.ParseToolName(p)

	if toolName ~= nil and v ~= nil then
		return BakingConfig.GetToolTextureId(toolName, v)
	end

	local food = BakingConfig.Foods[p]

	if food ~= nil then
		return food.sharedIcon
	end

	for _, food2 in BakingConfig.Foods do
		if food2.fullTool == p or food2.portionTool == p or food2.displayName == p then
			return food2.sharedIcon
		end
	end

	return nil
end

function BakingConfig.GetNextEatState(p: string)
	for k, v in BakingConfig.EAT_STATES do
		if v == p then
			return BakingConfig.EAT_STATES[k + 1]
		end
	end

	return nil
end

return BakingConfig