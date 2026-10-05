require(script.Parent.FayeTypes)
return function(value: number?, p, p2, value2: number?, flag: boolean?, value3: number?)
	return {
		__typeIndex = 1,
		Time = value or 1,
		EasingStyle = p or Enum.EasingStyle.Linear,
		EasingDirection = p2 or Enum.EasingDirection.Out,
		RepeatCount = value2 or 0,
		Reverse = flag or false,
		DelayTime = value3 or 0
	}
end