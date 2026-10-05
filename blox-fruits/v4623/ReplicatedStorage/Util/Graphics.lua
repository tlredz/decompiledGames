local Graphics = {
	ScaleDown = function(value: string)
		if value == nil or #value <= 1 then
			return ""
		end

		local v = string.match(value, "%d+")

		if v then
			return "rbxthumb://type=Asset&id=" .. v .. "&w=150&h=150"
		end

		return value
	end,
	ScaleUp = function(value: string)
		if value == nil or #value <= 1 then
			return ""
		end

		local v = string.match(value, "%d+")

		if v then
			return "rbxassetid://" .. v
		end

		return value
	end
}

function Graphics.SmartScale(p: string)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return Graphics.ScaleDown(p)
	end

	return Graphics.ScaleUp(p)
end

return Graphics