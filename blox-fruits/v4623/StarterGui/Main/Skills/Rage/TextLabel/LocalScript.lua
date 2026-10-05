for _, propertyName in pairs({
	"Text",
	"TextColor3",
	"TextStrokeColor3",
	"TextStrokeTransparency"
}) do
	local v = propertyName
	script.Parent.Parent:GetPropertyChangedSignal(propertyName):Connect(function()
		script.Parent[v] = script.Parent.Parent[v]
	end)
end