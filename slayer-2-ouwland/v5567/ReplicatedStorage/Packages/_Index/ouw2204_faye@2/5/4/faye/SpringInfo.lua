require(script.Parent.FayeTypes)
return function(value: number?, value2: number?, value3: number?, value4: number?, flag: boolean?, value5: number?)
	return {
		__typeIndex = 2,
		Time = value or 1,
		Frequency = value2 or 1,
		Damping = value3 or 0.2,
		RepeatCount = value4 or 0,
		Reverse = flag or false,
		DelayTime = value5 or 0
	}
end