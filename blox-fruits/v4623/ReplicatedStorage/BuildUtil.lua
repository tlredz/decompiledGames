local Option = require(game.ReplicatedStorage.Packages.Option)
local BuildUtil = {
	getFalconName = function()
		local falconName = script:GetAttribute("FalconName")
		assert(typeof(falconName) == "string", "bad \"FalconName\" attribute")
		return falconName
	end,
	getNewFalconName = function()
		local falconNewName = script:GetAttribute("FalconNewName")
		assert(typeof(falconNewName) == "string", "bad \"FalconNewName\" attribute")

		if falconNewName:len() <= 0 then
			return nil
		end

		return falconNewName
	end
}

function BuildUtil.matchNewFalconName()
	return Option.from(BuildUtil.getNewFalconName())
end

function BuildUtil.getFalconZSkillName()
	local falconZSkillName = script:GetAttribute("FalconZSkillName")
	assert(typeof(falconZSkillName) == "string", "bad \"FalconZSkillName\" attribute")
	return falconZSkillName
end

function BuildUtil.getFalconXSkillName()
	local falconXSkillName = script:GetAttribute("FalconXSkillName")
	assert(typeof(falconXSkillName) == "string", "bad \"FalconXSkillName\" attribute")
	return falconXSkillName
end

function BuildUtil.getFalconPermanentSprite()
	local falconPermanentSprite = script:GetAttribute("FalconPermanentSprite")
	assert(typeof(falconPermanentSprite) == "Rect", "bad \"FalconPermanentSprite\" attribute")
	return falconPermanentSprite
end

function BuildUtil.getFalconSprite()
	local falconSprite = script:GetAttribute("FalconSprite")
	assert(typeof(falconSprite) == "Rect", "bad \"FalconSprite\" attribute")
	return falconSprite
end

function BuildUtil.getFalconBeliPrice()
	local falconBeliPrice = script:GetAttribute("FalconBeliPrice")
	assert(typeof(falconBeliPrice) == "number", "bad \"FalconBeliPrice\" attribute")
	return falconBeliPrice
end

function BuildUtil.getFalconStockChance()
	local falconStockChance = script:GetAttribute("FalconStockChance")
	assert(typeof(falconStockChance) == "number", "bad \"FalconStockChance\" attribute")
	return falconStockChance
end

function BuildUtil.getBarrierName()
	local barrierName = script:GetAttribute("BarrierName")
	assert(typeof(barrierName) == "string", "bad \"BarrierName\" attribute")
	return barrierName
end

function BuildUtil.getNewBarrierName()
	local barrierNewName = script:GetAttribute("BarrierNewName")
	assert(typeof(barrierNewName) == "string", "bad \"BarrierNewName\" attribute")

	if barrierNewName:len() <= 0 then
		return nil
	end

	return barrierNewName
end

function BuildUtil.matchNewBarrierName()
	return Option.from(BuildUtil.getNewBarrierName())
end

function BuildUtil.getBarrierPermanentSprite()
	local barrierPermanentSprite = script:GetAttribute("BarrierPermanentSprite")
	assert(typeof(barrierPermanentSprite) == "Rect", "bad \"BarrierPermanentSprite\" attribute")
	return barrierPermanentSprite
end

function BuildUtil.getBarrierSprite()
	local barrierSprite = script:GetAttribute("BarrierSprite")
	assert(typeof(barrierSprite) == "Rect", "bad \"BarrierSprite\" attribute")
	return barrierSprite
end

function BuildUtil.getBarrierBeliPrice()
	local barrierBeliPrice = script:GetAttribute("BarrierBeliPrice")
	assert(typeof(barrierBeliPrice) == "number", "bad \"BarrierBeliPrice\" attribute")
	return barrierBeliPrice
end

function BuildUtil.getBarrierStockChance()
	local barrierStockChance = script:GetAttribute("BarrierStockChance")
	assert(typeof(barrierStockChance) == "number", "bad \"BarrierStockChance\" attribute")
	return barrierStockChance
end

function BuildUtil.getIfNewGravityEnabled()
	local gravityIsNew = script:GetAttribute("GravityIsNew")
	assert(typeof(gravityIsNew) == "boolean", "bad \"GravityIsNew\" attribute")
	return gravityIsNew
end

function BuildUtil.getGravityStockChance()
	local gravityStockChance = script:GetAttribute("GravityStockChance")
	assert(typeof(gravityStockChance) == "number", "bad \"GravityStockChance\" attribute")
	return gravityStockChance
end

return BuildUtil