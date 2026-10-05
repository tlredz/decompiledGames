require(script.Types)
local External = require(script.External)
local RobloxExternal = require(script.RobloxExternal)
External.setExternalProvider(RobloxExternal)
return (table.freeze({
	version = {
		major = 0,
		minor = 3,
		isRelease = true
	},
	Contextual = require(script.Utility.Contextual),
	Safe = require(script.Utility.Safe),
	cleanup = require(script.Memory.legacyCleanup),
	deriveScope = require(script.Memory.deriveScope),
	doCleanup = require(script.Memory.doCleanup),
	innerScope = require(script.Memory.innerScope),
	scoped = require(script.Memory.scoped),
	Observer = require(script.Graph.Observer),
	Computed = require(script.State.Computed),
	ForKeys = require(script.State.ForKeys),
	ForPairs = require(script.State.ForPairs),
	ForValues = require(script.State.ForValues),
	peek = require(script.State.peek),
	Value = require(script.State.Value),
	Attribute = require(script.Instances.Attribute),
	AttributeChange = require(script.Instances.AttributeChange),
	AttributeOut = require(script.Instances.AttributeOut),
	Child = require(script.Instances.Child),
	Children = require(script.Instances.Children),
	Hydrate = require(script.Instances.Hydrate),
	New = require(script.Instances.New),
	OnChange = require(script.Instances.OnChange),
	OnEvent = require(script.Instances.OnEvent),
	Out = require(script.Instances.Out),
	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring)
}))