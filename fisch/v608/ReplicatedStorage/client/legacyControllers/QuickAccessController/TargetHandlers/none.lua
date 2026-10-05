local None = {}

function None.GetOptions()
	return {}
end

function None.Select(_: string) end

function None.GetDisplay(_: string)
	return "Text", ""
end

function None.GetDescription(_: string)
	return "Customize the Quick Access menu in Settings"
end

return None