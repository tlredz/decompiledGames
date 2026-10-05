local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local GeneratorOffsetLookup = {}

local function readField(p, p2)
	local v = p and p[p2]

	if type(v) == "table" then
		return v.Y or 0, v.Z or 0, true
	end

	return 0, 0, false
end

local function readModule(p, p2)
	if not p2 then
		return readField(p, "GeneratorOffset")
	end

	local treadmillGeneratorOffset = p and p.TreadmillGeneratorOffset
	local Y, Z, flag

	if type(treadmillGeneratorOffset) == "table" then
		Y = treadmillGeneratorOffset.Y or 0
		Z = treadmillGeneratorOffset.Z or 0
		flag = true
	else
		flag = false
		Y = 0
		Z = 0
	end

	if flag then
		return Y, Z, true
	end

	return readField(p, "GeneratorOffset")
end

function GeneratorOffsetLookup.forNames(p, p2, p3)
	local skin = p2 and p2 ~= "" and p2 ~= "Default" and p and TowerLUT:GetSkin(p, p2)

	if skin then
		local success, result = pcall(require, skin)

		if success and result then
			local Y, Z, flag, generatorOffset

			if p3 then
				local treadmillGeneratorOffset = result and result.TreadmillGeneratorOffset
				local flag2

				if type(treadmillGeneratorOffset) == "table" then
					Y = treadmillGeneratorOffset.Y or 0
					Z = treadmillGeneratorOffset.Z or 0
					flag2 = true
				else
					flag2 = false
					Y = 0
					Z = 0
				end

				if flag2 then
					flag = true
				else
					generatorOffset = result and result.GeneratorOffset

					if type(generatorOffset) == "table" then
						Y = generatorOffset.Y or 0
						Z = generatorOffset.Z or 0
						flag = true
					else
						flag = false
						Y = 0
						Z = 0
					end
				end
			else
				generatorOffset = result and result.GeneratorOffset

				if type(generatorOffset) == "table" then
					Y = generatorOffset.Y or 0
					Z = generatorOffset.Z or 0
					flag = true
				else
					flag = false
					Y = 0
					Z = 0
				end
			end

			if flag then
				return Y, Z
			end
		end
	end

	local tower = p and TowerLUT:GetTower(p)

	if not tower then
		return 0, 0
	end

	local success, result = pcall(require, tower)

	if not (success and result) then
		return 0, 0
	end

	local Y, Z, flag, generatorOffset

	if p3 then
		local treadmillGeneratorOffset = result and result.TreadmillGeneratorOffset
		local flag2

		if type(treadmillGeneratorOffset) == "table" then
			Y = treadmillGeneratorOffset.Y or 0
			Z = treadmillGeneratorOffset.Z or 0
			flag2 = true
		else
			flag2 = false
			Y = 0
			Z = 0
		end

		if flag2 then
			flag = true
		else
			generatorOffset = result and result.GeneratorOffset

			if type(generatorOffset) == "table" then
				Y = generatorOffset.Y or 0
				Z = generatorOffset.Z or 0
				flag = true
			else
				flag = false
				Y = 0
				Z = 0
			end
		end
	else
		generatorOffset = result and result.GeneratorOffset

		if type(generatorOffset) == "table" then
			Y = generatorOffset.Y or 0
			Z = generatorOffset.Z or 0
			flag = true
		else
			flag = false
			Y = 0
			Z = 0
		end
	end

	if flag then
		return Y, Z
	end

	return 0, 0
end

function GeneratorOffsetLookup.forCharacter(instance, p)
	return GeneratorOffsetLookup.forNames(instance:GetAttribute("ToonName"), instance:GetAttribute("CurrentSkin"), p)
end

return GeneratorOffsetLookup