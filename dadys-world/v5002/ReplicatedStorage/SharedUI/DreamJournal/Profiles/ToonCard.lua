local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gradients = require(ReplicatedStorage.Modules.Gradients)
local UITemplates = require(ReplicatedStorage.SharedUtils.UITemplates)

local function isMastered(p, value: string)
	if type(p) ~= "table" then
		return false
	end

	local masteredToons = p.MasteredToons

	if type(masteredToons) == "table" then
		return masteredToons[value] == true
	end

	local mastery = p.Mastery

	if type(mastery) ~= "table" then
		return false
	end

	for _, v in pairs(mastery) do
		if not (type(v) == "table" and v.Name == value) then
			continue
		end

		local requirementList = v.RequirementList

		if type(requirementList) ~= "table" then
			return false
		end

		local count = 0
		local count2 = 0

		for _, v2 in pairs(requirementList) do
			if not (type(v2) == "table" and v2.Current and v2.Amount) then
				continue
			end

			count += 1

			if v2.Current >= v2.Amount then
				count2 += 1
			end
		end

		return count > 0 and count <= count2
	end

	return false
end

local function applyGradient(instance, attributes)
	local frame = instance:FindFirstChild("Frame")
	local gradientBackground = frame and frame:FindFirstChild("GradientBackground")

	if not (gradientBackground and gradientBackground:IsA("ImageLabel")) then
		return
	end

	local uIGradient = frame:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		uIGradient.Enabled = attributes.MainCharacter == true
	end

	if attributes.MainCharacter then
		if attributes.HolidayTower and attributes.Easter then
			Gradients.setEasterMain(gradientBackground)
		elseif attributes.HolidayTower and attributes.Halloween then
			Gradients.setHalloweenMain(gradientBackground)
		elseif attributes.HolidayTower then
			Gradients.setHolidayMainImage(gradientBackground)
		else
			Gradients.setMainImage(gradientBackground)
		end
	elseif attributes.Lethal then
		Gradients.setLethalImage(gradientBackground)
	elseif not attributes.HolidayTower then
		Gradients.setDefaultImage(gradientBackground)
	elseif attributes.Easter then
		Gradients.setEaster(gradientBackground)
	elseif attributes.Halloween then
		Gradients.setHalloween(gradientBackground)
	else
		Gradients.setHolidayImage(gradientBackground)
	end
end

return {
	Decorate = function(instance, value: string, p)
		if not instance or type(value) ~= "string" or value == "" then
			return
		end

		local masteryStar = instance:FindFirstChild("MasteryStar")

		if masteryStar and masteryStar:IsA("GuiObject") then
			masteryStar.Visible = isMastered(p, value)
		end

		local describe = UITemplates.Describe(UITemplates.Types.Toon, value)

		if not describe.Missing then
			applyGradient(instance, describe.Attributes)
		end
	end
}