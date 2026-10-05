local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(script:WaitForChild("LocalPlayerFriended"))
return {
	Start = function(_)
		task.defer(function()
			local remoteEvent = v:RemoteEvent("PlayerFriended")
			v2.friendAdded:Connect(function(p)
				remoteEvent:FireServer(p)
			end)
		end)
	end
}