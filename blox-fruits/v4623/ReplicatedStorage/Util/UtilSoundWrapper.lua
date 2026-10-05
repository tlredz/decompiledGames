local v = {
	"Looped",
	"PlaybackSpeed",
	"RollOffMaxDistance",
	"RollOffMinDistance",
	"Volume"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local util = ReplicatedStorage:WaitForChild("Util")
local Sound = require(util:WaitForChild("Sound"))
return {
	Play = function(self, parent)
		local utilSoundName = self:GetAttribute("UtilSoundName")

		if utilSoundName == nil then
			error("UtilSoundWrapper.Play: Missing UtilSoundName property within soundConfig: " .. self:GetFullName())
		end

		if parent == nil then
			parent = self.Parent
		end

		local attributesByAttributeName = Sound:Play(utilSoundName, parent)

		for _, attributeName in ipairs(v) do
			attributesByAttributeName[attributeName] = self:GetAttribute(attributeName)
		end

		return attributesByAttributeName
	end
}