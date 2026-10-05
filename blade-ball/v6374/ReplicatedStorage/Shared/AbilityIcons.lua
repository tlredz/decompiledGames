local iconsByName = {}
local iconsByName2 = {}

for _, child in pairs(game.ReplicatedStorage.Misc.DataAbilities:GetChildren()) do
	if child:GetAttribute("Hidden") then
		iconsByName[child.Name] = child:GetAttribute("Icon")
	else
		iconsByName2[child.Name] = child:GetAttribute("Icon")
	end
end

return (setmetatable(iconsByName2, {
	__index = iconsByName
}))