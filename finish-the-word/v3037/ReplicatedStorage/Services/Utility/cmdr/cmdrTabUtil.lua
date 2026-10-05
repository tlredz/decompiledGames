local CmdrTabUtil = {}

function CmdrTabUtil.getTabCandidates(p)
	local v = not p and {} or p.Entries or {}
	local insertTexts = {}

	for i = 1, #v do
		local v2 = v[i]

		if not v2 or v2.NonInsertable then
			continue
		end

		local insertText = v2.InsertText or v2.Name

		if not (insertText and insertText ~= "") then
			continue
		end

		if p and p.Stage == "command" then
			insertTexts[#insertTexts + 1] = insertText
		elseif v2.ArgsText == "" then
			insertTexts[#insertTexts + 1] = insertText
		end
	end

	return insertTexts
end

function CmdrTabUtil.splitCurrentToken(value)
	local v = tostring(value or "")

	if v:match("%s$") then
		return v
	end

	return v:match("^(.*%s)[^%s]*$") or ""
end

return CmdrTabUtil