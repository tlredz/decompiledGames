local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local DrawContext = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Contexts"):WaitForChild("DrawContext"))
return function()
	return (React.useContext(DrawContext))
end