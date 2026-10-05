local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Beach = require(script.Beach)
local React = require(ReplicatedStorage.Packages.React)
local createElement = React.createElement
return function()
	return createElement(Beach, {})
end