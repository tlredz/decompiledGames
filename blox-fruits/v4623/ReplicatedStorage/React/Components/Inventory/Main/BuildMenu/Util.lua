local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
return {
	tutorialMessage = function(p: string?, p2: string?, p3: string?)
		local v = {}

		if p then
			table.insert(v, FormatUtil.italic((`"{p}"`)))

			if p2 or p3 then
				table.insert(v, "")
			end
		end

		if p2 then
			table.insert(v, p2)

			if p3 then
				table.insert(v, "")
			end
		end

		if p3 then
			table.insert(v, FormatUtil.bold("Tip: ") .. p3)
		end

		return table.concat(v, "\n")
	end
}