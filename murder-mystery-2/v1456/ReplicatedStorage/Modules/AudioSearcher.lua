local AssetService = game:GetService("AssetService")
return {
	searchAudio = function(searchKeyword)
		local audioSearchParams = Instance.new("AudioSearchParams")
		audioSearchParams.AudioSubType = Enum.AudioSubType.Music
		local audioSearchParams2 = Instance.new("AudioSearchParams")
		audioSearchParams2.AudioSubType = Enum.AudioSubType.SoundEffect
		audioSearchParams.SearchKeyword = searchKeyword
		audioSearchParams2.SearchKeyword = searchKeyword
		local success, result = pcall(function()
			return AssetService:SearchAudio(audioSearchParams)
		end)
		local success2, result2 = pcall(function()
			return AssetService:SearchAudio(audioSearchParams2)
		end)
		local currentPage = {}
		local currentPage2 = {}

		if success then
			currentPage = result:GetCurrentPage()
		else
			warn(result)
		end

		if success2 then
			currentPage2 = result2:GetCurrentPage()
		else
			warn(result2)
		end

		if not (success2 or success) then
			return nil
		end

		local result3 = {}

		for i = 1, 30 do
			local v = currentPage[i]
			local v2 = currentPage2[i]

			if v then
				table.insert(result3, v)
			end

			if v2 then
				table.insert(result3, v2)
			end
		end

		return result3
	end
}