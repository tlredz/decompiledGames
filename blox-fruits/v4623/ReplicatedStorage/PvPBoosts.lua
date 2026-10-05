local PvPBoosts = {
	[500000] = { 4, 3 },
	[1000000] = { 3, 2 },
	[1500000] = { 3, 2 }
}

for i = 2000000, 4500000, 500000 do
	PvPBoosts[i] = { 1.5, 1 }
end

for i = 5000000, 20000000, 1000000 do
	PvPBoosts[i] = { 1, 0.6 }
end

for _, v in pairs(PvPBoosts) do
	v[1] /= 100
	v[2] /= 100
end

return PvPBoosts