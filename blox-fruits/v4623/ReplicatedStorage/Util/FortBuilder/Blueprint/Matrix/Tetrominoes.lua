local v = {
	"O",
	"I",
	"T",
	"S",
	"Z",
	"L",
	"J"
}
local v2 = { "Duo", "Mono" }
local v3 = {
	O = {
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 1, 0 },
			{ 1, 1 }
		}
	},
	I = {
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 0, 2 },
			{ 0, 3 }
		},
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 2, 0 },
			{ 3, 0 }
		}
	},
	T = {
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 2, 0 },
			{ 1, 1 }
		},
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 0, 2 },
			{ 1, 1 }
		},
		{
			{ 1, 0 },
			{ 0, 1 },
			{ 1, 1 },
			{ 2, 1 }
		},
		{
			{ 1, 0 },
			{ 0, 1 },
			{ 1, 1 },
			{ 1, 2 }
		}
	},
	S = {
		{
			{ 1, 0 },
			{ 2, 0 },
			{ 0, 1 },
			{ 1, 1 }
		},
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 1, 1 },
			{ 1, 2 }
		}
	},
	Z = {
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 1, 1 },
			{ 2, 1 }
		},
		{
			{ 1, 0 },
			{ 0, 1 },
			{ 1, 1 },
			{ 0, 2 }
		}
	},
	L = {
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 0, 2 },
			{ 1, 0 }
		},
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 1, 1 },
			{ 2, 1 }
		},
		{
			{ 1, 0 },
			{ 1, 1 },
			{ 1, 2 },
			{ 0, 2 }
		},
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 2, 0 },
			{ 2, 1 }
		}
	},
	J = {
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 1, 1 },
			{ 1, 2 }
		},
		{
			{ 0, 0 },
			{ 1, 0 },
			{ 2, 0 },
			{ 0, 1 }
		},
		{
			{ 0, 0 },
			{ 0, 1 },
			{ 0, 2 },
			{ 1, 2 }
		},
		{
			{ 0, 1 },
			{ 1, 1 },
			{ 2, 1 },
			{ 2, 0 }
		}
	},
	Duo = {
		{
			{ 0, 0 },
			{ 1, 0 }
		},
		{
			{ 0, 0 },
			{ 0, 1 }
		}
	},
	Mono = {
		{
			{ 0, 0 }
		}
	}
}
local Tetrominoes = {}

function Tetrominoes.getLegalTypes()
	return v
end

function Tetrominoes.getIllegalTypes()
	return v2
end

function Tetrominoes.getTetrominoRotations(p: string)
	return #(v3[p] or {})
end

function Tetrominoes.getTetrominoCoordinates(p: string, p2: number)
	return (v3[p] or {})[p2]
end

return Tetrominoes