local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local Pets = require(gameData:WaitForChild("Pets"))
local Eggs = require(gameData:WaitForChild("Eggs"))
local Mutations = require(gameData:WaitForChild("Mutations"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local SellValue = {
	SellIncomeMultiplier = 600,
	EggSellingEnabled = false,
	PetIncome = function(p, p2, p3, p4)
		local pet = Pets[p]
		local income = pet and tonumber(pet.Income) or 0

		if income <= 0 then
			return 0
		end

		return (math.floor(math.floor(income * ((tonumber(p2) or PetAging.WeightStandardKG) / PetAging.WeightStandardKG)) * Mutations.CombinedFactor(
			p3,
			p4
		)))
	end
}

function SellValue.PetWorth(p, p2, p3, p4)
	if not (p and Pets[p]) then
		return nil
	end

	local petIncome = SellValue.PetIncome(p, p2, p3, p4)

	if petIncome <= 0 then
		return nil
	end

	return petIncome * SellValue.SellIncomeMultiplier, petIncome
end

function SellValue.EggWorth(p, p2)
	if not SellValue.EggSellingEnabled then
		return nil
	end

	local v = p and Eggs[p]
	local sellPrice = v and tonumber(v.SellPrice) or 0
	local v2 = tonumber(p2) or 0

	if sellPrice <= 0 or v2 <= 0 then
		return nil
	end

	return sellPrice * v2
end

function SellValue.IsEthereal(p, p2)
	local v

	if p == "Pet" then
		v = Pets[p2]
	else
		v = Eggs[p2]
	end

	return v ~= nil and v.Rarity == "Ethereal"
end

return SellValue