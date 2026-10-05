return {
	New = function(value: string, value2: number, value3: number, p: string?, flag: boolean?)
		return {
			name = value or "",
			userId = value2 or 0,
			placeId = value3 or 0,
			jobId = p or nil,
			IsInGame = flag or false
		}
	end
}