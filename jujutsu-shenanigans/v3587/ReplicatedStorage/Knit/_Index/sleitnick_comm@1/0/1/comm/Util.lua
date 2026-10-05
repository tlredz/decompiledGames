local RunService = game:GetService("RunService")
local Option = require(script.Parent.Parent.Option)
local Util = {
	IsServer = RunService:IsServer(),
	WaitForChildTimeout = 60,
	DefaultCommFolderName = "__comm__",
	None = newproxy()
}

function Util.GetCommSubFolder(parent, name: string)
	local v

	if Util.IsServer then
		v = parent:FindFirstChild(name)

		if not v then
			v = Instance.new("Folder")
			v.Name = name
			v.Parent = parent
		end
	else
		v = parent:WaitForChild(name, Util.WaitForChildTimeout)
	end

	return Option.Wrap(v)
end

return Util