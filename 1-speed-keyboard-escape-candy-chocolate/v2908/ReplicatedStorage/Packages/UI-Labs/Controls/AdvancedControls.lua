local Utils = require(script.Parent.Utils)
local createBaseControl = Utils.CreateBaseControl
local AdvancedControls = {}

function AdvancedControls.Choose(list, value: number?)
	if #list <= 0 then
		error("UI-Labs: Array given in a Choose control is empty")
	end

	if value and #list < value then
		error((`UI-Labs: Def index ({value}) given for the array is outside of the array size ({#list})`))
	end

	local baseControl = createBaseControl("Choose", list[value or 1])
	baseControl.List = list
	baseControl.DefIndex = value or 1
	return baseControl
end

function AdvancedControls.EnumList(list, defIndex: string)
	if list[defIndex] == nil then
		error((`UI-Labs: Key given for the EnumList list ({defIndex}) does not exist in the list`))
	end

	local baseControl = createBaseControl("EnumList", list[defIndex])
	baseControl.List = list
	baseControl.DefIndex = defIndex
	return baseControl
end

function AdvancedControls.RGBA(color: Color3, value: number?)
	return createBaseControl("RGBA", {
		Color = color,
		Transparency = value or 0
	})
end

function AdvancedControls.Slider(p: number, min: number, max: number, step: number?)
	if max <= min then
		error((`UI-Labs: Max slider value ({max}) must be greater than the Min value ({min})`))
	end

	local baseControl = createBaseControl("Slider", p)
	baseControl.Min = min
	baseControl.Max = max
	baseControl.Step = step
	return baseControl
end

function AdvancedControls.Object(value: string?, p, predicator)
	local baseControl = createBaseControl("Object", p)
	baseControl.ClassName = value or "Instance"
	baseControl.Predicator = predicator
	return baseControl
end

return AdvancedControls