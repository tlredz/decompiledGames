local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local FovHandler = {
	NewFOVInstance = function(script: string, p, value: number?, _: number?, value2: number?)
		local getvaluesfolder = Utility.getvaluesfolder(p)
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "FOV"
		numberValue.Value = 70
		numberValue:SetAttribute("Script", script)
		numberValue:SetAttribute("Priority", value2 or 0)
		DebrisModule:AddItem(numberValue, value or 5)
		numberValue.Parent = getvaluesfolder
		return numberValue
	end,
	GetFOVInstance = function(p: string, p2)
		local getvaluesfolder = Utility.getvaluesfolder(p2)

		for _, child in pairs(getvaluesfolder:GetChildren()) do
			if child.Name == "FOV" and child:GetAttribute("Script") == p then
				return child
			end
		end
	end
}

function FovHandler.SetFOV(p: string, p2, p3: number)
	local fOVInstance = FovHandler.GetFOVInstance(p, p2)

	if not fOVInstance then
		return
	end

	fOVInstance.Value = p3
	return fOVInstance
end

function FovHandler.DeleteFOVInstance(p: string, p2)
	local fOVInstance = FovHandler.GetFOVInstance(p, p2)

	if fOVInstance then
		fOVInstance:Destroy()
	end
end

return FovHandler