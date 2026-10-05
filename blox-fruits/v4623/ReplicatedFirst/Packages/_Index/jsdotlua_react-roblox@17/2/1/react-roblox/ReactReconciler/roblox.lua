local reactreconciler = require(script.Parent.Parent:WaitForChild("react-reconciler"))
local ReactRobloxHostConfig = require(script.Parent:WaitForChild("client"):WaitForChild("ReactRobloxHostConfig"))
return reactreconciler(ReactRobloxHostConfig)