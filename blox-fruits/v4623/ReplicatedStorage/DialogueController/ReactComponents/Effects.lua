-- equivalent calls inferred from this helper; original call sites unknown
local function createLetterShake()
	return {
		splitCharacters = true,
		interval = 0.03333333333333333,
		offset = function(p: number, _: number)
			local v = p * 0.035
			return Vector2.new((math.random() * 2 - 1) * v, (math.random() * 2 - 1) * v)
		end
	}
end

return {
	Shake = createLetterShake(),
	DialogueShake = {
		wholeText = true,
		interval = 0,
		offset = function(p: number, p2: number)
			local v = p * 0.18
			return Vector2.new(0, math.sin(p2 * 3.141592653589793 * 2 * 8) * v)
		end
	},
	ShoutShake = createLetterShake(),
	Wiggle = {
		splitCharacters = false,
		interval = 0,
		rotation = function(_: number, p: number)
			return math.sin(p * 5) * 6
		end
	},
	Rainbow = {
		splitCharacters = false,
		interval = 0,
		color = function(_: number, p: number)
			return Color3.fromHSV(p * 0.4 % 1, 0.65, 1)
		end
	}
}