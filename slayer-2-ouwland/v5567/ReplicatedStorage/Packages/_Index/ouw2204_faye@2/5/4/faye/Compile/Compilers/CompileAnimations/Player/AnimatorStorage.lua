return {
	Holder = nil,
	Ids = nil,
	Step = nil,
	RegularTweenHolder = nil,
	TweenserviceBanned = {
		string = true,
		boolean = true,
		NumberSequence = true,
		ColorSequence = true,
		NumberRange = true,
		PhysicalProperties = true,
		Ray = true,
		Rect = true,
		Region3 = true
	},
	Multipliers = {
		NumberSequence = 2,
		ColorSequence = 2,
		NumberRange = 2
	},
	Active = setmetatable({}, {
		__mode = "k"
	}),
	Count = 0,
	RegularTweenCount = 0
}