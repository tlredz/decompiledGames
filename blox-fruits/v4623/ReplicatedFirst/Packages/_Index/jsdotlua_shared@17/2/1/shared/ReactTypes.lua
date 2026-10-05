require(script.Parent.Parent:WaitForChild("luau-polyfill"))
require(script.Parent:WaitForChild("flowtypes.roblox"))
return {
	DiscreteEvent = 0,
	UserBlockingEvent = 1,
	ContinuousEvent = 2
}