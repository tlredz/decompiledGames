local parent = script.Parent.Parent
local packages = parent:FindFirstChild("Packages")
return {
	Directory = packages or parent.Parent,
	IsPlugin = packages ~= nil
}