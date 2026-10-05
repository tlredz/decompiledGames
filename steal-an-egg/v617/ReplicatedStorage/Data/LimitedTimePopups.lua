local function FromEDT(p: number, p2: number, p3: number, p4: number)
	return DateTime.fromUniversalTime(p, p2, p3, p4 + 4).UnixTimestamp
end

return {
	LuminousEgg = {
		Name = "LuminousEgg",
		StartTime = DateTime.fromUniversalTime(2026, 9, 23, 15).UnixTimestamp,
		EndTime = DateTime.fromUniversalTime(2026, 9, 26, 15).UnixTimestamp
	}
}