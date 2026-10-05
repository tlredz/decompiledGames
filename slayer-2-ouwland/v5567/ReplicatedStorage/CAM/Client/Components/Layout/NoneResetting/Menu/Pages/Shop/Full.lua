local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GridContent = require(script.Parent.GridContent)
require(ReplicatedStorage.Packages.faye)
return function(object, p, p2, p3, p4, p5)
	return object:Create("Frame")({
		Name = p2.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GridContent(object, p, p2, p3, "Full", p4, p5)
	})
end