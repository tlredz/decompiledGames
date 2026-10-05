local function isNewPlayer(value: number?, value2: number?)
	return (value or 0) < 1000 and (value2 or 0) < 1000
end

return table.freeze({
	IsNewPlayer = isNewPlayer,
	SessionAttribute = "IsNewPlayerSession"
})