local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local CustomizationInfo = {
	skinColors = {
		Demon = {
			Color3.fromRGB(149, 137, 136),
			Color3.fromRGB(203, 146, 139),
			Color3.fromRGB(159, 173, 192),
			Color3.fromRGB(189, 181, 139),
			Color3.fromRGB(160, 132, 79),
			Color3.fromRGB(96, 84, 92),
			Color3.fromRGB(72, 62, 66),
			Color3.fromRGB(58, 74, 84),
			Color3.fromRGB(110, 68, 74),
			Color3.fromRGB(46, 42, 48),
			Color3.fromRGB(236, 232, 230),
			Color3.fromRGB(224, 214, 220),
			Color3.fromRGB(214, 222, 228),
			(Color3.fromRGB(230, 218, 206))
		},
		Human = {
			Color3.fromRGB(204, 142, 105),
			Color3.fromRGB(175, 148, 131),
			Color3.fromRGB(106, 57, 9),
			Color3.fromRGB(124, 92, 70),
			Color3.fromRGB(90, 76, 66),
			Color3.fromRGB(255, 204, 153),
			Color3.fromRGB(143, 76, 42),
			Color3.fromRGB(255, 239, 174),
			Color3.fromRGB(241, 200, 180),
			Color3.fromRGB(198, 160, 118),
			Color3.fromRGB(160, 110, 78),
			Color3.fromRGB(62, 40, 30),
			Color3.fromRGB(226, 178, 130),
			(Color3.fromRGB(120, 78, 62))
		}
	},
	Hair = {},
	Noses = {},
	Mouths = {},
	facialAccessories = {},
	Beards = {},
	Shirts = {},
	Pants = {},
	Shoes = {}
}
local hair = CustomizationInfo.Hair
local hairs = game.ReplicatedStorage.Assets.Appearance.Hairs

for i = 1, #hairs:GetChildren() do
	table.insert(hair, hairs:FindFirstChild("Hair" .. i))
end

local noses = CustomizationInfo.Noses
local noses2 = game.ReplicatedStorage.Assets.Appearance.Noses

for i = 1, #noses2:GetChildren() do
	table.insert(noses, noses2:FindFirstChild("Nose" .. i))
end

local mouths = CustomizationInfo.Mouths
local mouths2 = game.ReplicatedStorage.Assets.Appearance.Mouths

for i = 1, #mouths2:GetChildren() do
	table.insert(mouths, mouths2:FindFirstChild("Mouth" .. i))
end

local shoes = CustomizationInfo.Shoes
local shoes2 = game.ReplicatedStorage.Assets.Appearance.Shoes

for i = 1, #shoes2:GetChildren() do
	table.insert(shoes, shoes2:FindFirstChild("Shoe" .. i))
end

local facialAccessories = CustomizationInfo.facialAccessories
local accessories = game.ReplicatedStorage.Assets.Appearance.Accessories

for i = 1, #accessories:GetChildren() do
	table.insert(facialAccessories, accessories:FindFirstChild("Accessory" .. i))
end

local shirts = CustomizationInfo.Shirts
local shirts2 = game.ReplicatedStorage.Assets.Appearance.Shirts

for i = 1, #shirts2:GetChildren() do
	table.insert(shirts, shirts2:FindFirstChild("Shirt" .. i))
end

local pants = CustomizationInfo.Pants
local pants2 = game.ReplicatedStorage.Assets.Appearance.Pants

for i = 1, #pants2:GetChildren() do
	table.insert(pants, pants2:FindFirstChild("Pants" .. i))
end

local beards = CustomizationInfo.Beards
local beards2 = game.ReplicatedStorage.Assets.Appearance.Beards

for i = 1, #beards2:GetChildren() do
	table.insert(beards, beards2:FindFirstChild("Beard" .. i))
end

function CustomizationInfo.getBeards(_)
	return CustomizationInfo.Beards
end

function CustomizationInfo.getShoes(_)
	return CustomizationInfo.Shoes
end

function CustomizationInfo.getNoses(_)
	return CustomizationInfo.Noses
end

function CustomizationInfo.getShirts(_)
	return CustomizationInfo.Shirts
end

function CustomizationInfo.getPants(_)
	return CustomizationInfo.Pants
end

function CustomizationInfo.getMouths(p, p2)
	if p2 == nil then
		p2 = Utility.GetData(p)
	end

	local result = {}
	local human = game.ReplicatedStorage.Assets.Appearance.Mouths.Human

	if p2.Race.Value == "Demon" then
		human = game.ReplicatedStorage.Assets.Appearance.Mouths.Demon
	end

	for i = 1, #human:GetChildren() do
		table.insert(result, human:FindFirstChild("Mouth" .. i))
	end

	return result
end

function CustomizationInfo.getFacialAccessories()
	return CustomizationInfo.facialAccessories
end

function CustomizationInfo.getEyes(p, p2)
	if p2 == nil then
		p2 = Utility.GetData(p)
	end

	local result = {}
	local human = game.ReplicatedStorage.Assets.Appearance.Eyes.Human

	if p2.Race.Value == "Demon" then
		human = game.ReplicatedStorage.Assets.Appearance.Eyes.Demon
	end

	for i = 1, #human:GetChildren() do
		table.insert(result, human:FindFirstChild("Eye" .. i))
	end

	return result
end

function CustomizationInfo.getHairs(_)
	return CustomizationInfo.Hair
end

function CustomizationInfo.getHorns(p, p2)
	if p2 == nil then
		p2 = Utility.GetData(p)
	end

	local value = p2.Race.Value

	if value ~= "Demon" and value ~= "Hybrid" then
		return {}
	end

	local result = {}
	local horns = game.ReplicatedStorage.Assets.Appearance:FindFirstChild("Horns")

	if horns == nil then
		return result
	end

	for i = 1, #horns:GetChildren() do
		table.insert(result, horns:FindFirstChild("Horn" .. i))
	end

	return result
end

function CustomizationInfo.getBodyColors(p, p2)
	if p2 == nil then
		p2 = Utility.GetData(p)
	end

	return CustomizationInfo.skinColors[p2.Race.Value] or CustomizationInfo.skinColors.Human
end

return CustomizationInfo