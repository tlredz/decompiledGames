local Utils = require(script.Parent.Utils)
local createBaseControl = Utils.CreateBaseControl
local PrimitiveControls = {
	String = function(p: string, filters)
		local baseControl = createBaseControl("String", p)
		baseControl.Filters = filters
		return baseControl
	end,
	Number = function(p: number, min: number?, max: number?, step: number?, flag: boolean?, p2: number?)
		local baseControl = createBaseControl("Number", p)
		baseControl.Min = min
		baseControl.Max = max
		baseControl.Step = step
		baseControl.Dragger = flag == nil or flag
		baseControl.Sensibility = p2 or p * 10
		return baseControl
	end,
	Boolean = function(flag: boolean)
		return createBaseControl("Boolean", flag)
	end
}
PrimitiveControls.Primitive = {
	string = PrimitiveControls.String,
	number = PrimitiveControls.Number,
	boolean = PrimitiveControls.Boolean
}
return PrimitiveControls