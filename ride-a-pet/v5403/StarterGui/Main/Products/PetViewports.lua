local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetViewportService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetViewportService"))
local v = {
	Dragon = {
		Padding = 0.82,
		VerticalBias = 0.18
	}
}

local function FillPetHolder(guiObject)
	for _, guiObject2 in guiObject:GetChildren() do
		local petViewport = guiObject2:IsA("GuiObject") and guiObject2:FindFirstChild("PetViewport")

		if not (petViewport and petViewport:IsA("ViewportFrame")) then
			continue
		end

		local visible = PetViewportService.Build(petViewport, guiObject2.Name, v[guiObject2.Name])
		petViewport.Visible = visible
		local petImage = guiObject2:FindFirstChild("PetImage")

		if petImage then
			petImage.Visible = not visible
		end

		if not visible then
			warn(string.format("Products: no pet asset named %q - showing its image slot instead", guiObject2.Name))
		end
	end
end

for _, guiObject in script.Parent:GetDescendants() do
	if guiObject.Name == "PetHolder" and guiObject:IsA("GuiObject") then
		FillPetHolder(guiObject)
	end
end