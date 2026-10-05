local AutoOpenModalConfig = {
	Ids = table.freeze({
		BBWorldInfo = "BBWorldInfo",
		Galaxy2Welcome = "Galaxy2Welcome",
		SummerCoinFound = "SummerCoinFound",
		CandyCornFound = "CandyCornFound",
		SpeedBoostV3Notice = "SpeedBoostV3Notice"
	})
}
AutoOpenModalConfig.OpenOnJoin = {
	{
		Id = AutoOpenModalConfig.Ids.BBWorldInfo,
		Priority = 50,
		ModalTag = "BBWorldInfoMessage",
		EventKey = "Bbno2026"
	},
	{
		Id = AutoOpenModalConfig.Ids.Galaxy2Welcome,
		Priority = 40,
		ModalTag = "InfoModal",
		World = 4,
		WaitForOpenWithContent = true
	}
}
local v = {
	[AutoOpenModalConfig.Ids.SummerCoinFound] = true,
	[AutoOpenModalConfig.Ids.CandyCornFound] = true,
	[AutoOpenModalConfig.Ids.SpeedBoostV3Notice] = true
}

for _, v2 in ipairs(AutoOpenModalConfig.OpenOnJoin) do
	v[v2.Id] = true
end

function AutoOpenModalConfig.IsKnownId(p: string)
	return v[p] == true
end

return AutoOpenModalConfig