local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local Mount = require(script.Parent.Mount)
return function(parent)
	local frame = Instance.new("Frame")
	frame.Name = "Icon"
	frame.BackgroundTransparency = 0.5
	frame.Size = UDim2.fromOffset(200, 200)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Parent = parent
	Mount(frame, 0)
	return function()
		frame:Destroy()
	end
end