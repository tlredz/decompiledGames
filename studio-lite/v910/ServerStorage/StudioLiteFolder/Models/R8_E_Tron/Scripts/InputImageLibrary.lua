local v = {}
local InputImageLibrary = {}

for _, child in pairs(script.Spritesheets:GetChildren()) do
	v[child.Name] = {}

	for _, moduleScript in pairs(child:GetChildren()) do
		local v2 = v[child.Name]
		local name = moduleScript.Name
		local module = require(moduleScript)
		v2[name] = module.new()
	end
end

local function getImageInstance(p, p2, p3)
	if type(p2) == "userdata" then
		p2 = string.sub(tostring(p2), 14)
	end

	local v2 = v.XboxOne[p3]

	if v2 then
		return (v2:GetSprite(p, p2))
	end

	warn("Could not find style: " .. p3)
end

function InputImageLibrary.GetImageLabel(_, p, p2, p3)
	return getImageInstance("ImageLabel", p, p2, p3)
end

function InputImageLibrary.GetImageButton(_, p, p2, p3)
	return getImageInstance("ImageButton", p, p2, p3)
end

return InputImageLibrary