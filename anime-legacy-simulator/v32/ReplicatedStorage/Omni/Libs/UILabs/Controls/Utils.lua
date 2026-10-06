return {
	CreateBaseControl = function(p: string, controlValue)
		return {
			EntryType = "Control",
			Type = p,
			ControlValue = controlValue
		}
	end
}