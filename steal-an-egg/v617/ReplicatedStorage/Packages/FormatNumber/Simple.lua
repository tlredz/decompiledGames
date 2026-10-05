local v = {
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Ocd",
	"Nod",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg",
	"Qavg",
	"Qivg",
	"Sxvg",
	"Spvg",
	"Ocvg",
	"Novg",
	"Tg"
}
local Main = require(script.Parent.Main)
local v3 = {}
local v4 = {}
return table.freeze({
	Format = function(self: number, p: string?)
		assert(type(self) == "number", "Value provided must be a number")
		local v5 = p == nil and "" or p
		assert(type(v5) == "string", "Skeleton provided must be a string")
		local v6 = v3[v5]

		if v6 then
			return v6:Format(self)
		end

		local v7
		v7, v6 = Main.NumberFormatter.forSkeleton(v5)
		assert(v7, v6)
		v3[v5] = v6
		return v6:Format(self)
	end,
	FormatCompact = function(value: number, p: string?)
		assert(type(value) == "number", "Value provided must be a number")
		local v5 = p == nil and "" or p
		assert(type(v5) == "string", "Skeleton provided must be a string")
		local v6 = v4[v5]

		if not v6 then
			local v7, v8 = Main.NumberFormatter.forSkeleton(v5)
			assert(v7, v8)
			v6 = v8:Notation(Main.Notation.compactWithSuffixThousands(v))
			v4[v5] = v6
		end

		assert(
			#v ~= 0,
			"Please provide the suffix abbreviations for FormatCompact at the top of the Simple ModuleScript"
		)
		return v6:Format(value)
	end
})