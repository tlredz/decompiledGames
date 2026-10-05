local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local v = {
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight
}
local GamepadIconController = {}
GamepadIconController.MappedImages = {
	ButtonCross = "rbxassetid://15619825983",
	ButtonCircle = "rbxassetid://15619826649",
	ButtonSquare = "rbxassetid://15619828333",
	ButtonTriangle = "rbxassetid://15619827653",
	ButtonL1 = "rbxassetid://15619831131",
	ButtonL2 = "rbxassetid://15619829957",
	ButtonR1 = "rbxassetid://15619829359",
	ButtonR2 = "rbxassetid://15619830504",
	PlayStation_DPadLeft = "rbxassetid://15648370212",
	PlayStation_DPadRight = "rbxassetid://15648373597",
	PlayStation_DPadDown = "rbxassetid://15648372627",
	PlayStation_DPadUp = "rbxassetid://15648374640",
	Xbox_DPadDown = "rbxassetid://15619807830",
	Xbox_DPadUp = "rbxassetid://15619807447",
	Xbox_DPadRight = "rbxassetid://15619808344",
	Xbox_DPadLeft = "rbxassetid://15619806485",
	ButtonA = "rbxassetid://15619793934",
	ButtonB = "rbxassetid://15619796451",
	ButtonX = "rbxassetid://15619792495",
	ButtonY = "rbxassetid://15619793108",
	ButtonLB = "rbxassetid://15619817100",
	ButtonRB = "rbxassetid://15619818331",
	ButtonLT = "rbxassetid://15619821224",
	ButtonRT = "rbxassetid://15619820707"
}

function GamepadIconController:GetMappedImageForDpad(p2)
	local v2 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" and "PlayStation" or "Xbox"
	local v3 = string.format("%s_%s", v2, p2.Name)
	return self.MappedImages[v3] or UserInputService:GetImageForKeyCode(p2)
end

function GamepadIconController:GetMappedImageForKeyCode(p)
	if table.find(v, p) then
		return self:GetMappedImageForDpad(p)
	end

	local stringForKeyCode = UserInputService:GetStringForKeyCode(p)
	return self.MappedImages[stringForKeyCode] or UserInputService:GetImageForKeyCode(p)
end

function GamepadIconController.GetMappedImageForKeyString(p, p2: string)
	return p.MappedImages[p2]
end

return GamepadIconController