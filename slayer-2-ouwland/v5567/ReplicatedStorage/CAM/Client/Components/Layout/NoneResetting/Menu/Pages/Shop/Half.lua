local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GridContent = require(script.Parent.GridContent)
require(ReplicatedStorage.Packages.faye)
return function(object, p, p2, p3, p4, p5, p6)
	return object:Create("Frame")({
		Name = p2.Name,
		Size = UDim2.fromScale(1, 0.5),
		p3,
		BackgroundTransparency = 1,
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		GridContent(object, p, p2, p4, "Half", p5, p6)
	})
end