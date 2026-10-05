return table.freeze({
	HasObtained = function(data)
		if data.MechaScramblerObtained == true or data.Index and data.Index["Mecha Scrambler"] == true then
			return true
		end

		for _, v in data.Inventory or {} do
			if v.Category == "Mecha Scrambler" and v.CreatorTemporary ~= true then
				return true
			end
		end

		for _, v in data.EggInventory or {} do
			if v.AssetCategory == "Mecha Scrambler" and v.CreatorTemporary ~= true then
				return true
			end
		end

		return false
	end
})