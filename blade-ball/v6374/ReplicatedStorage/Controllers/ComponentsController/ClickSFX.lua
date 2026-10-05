local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Trove)
local click = ReplicatedStorage2:WaitForChild("Misc"):WaitForChild("click")
return {
	Tags = { "UI_ClickSFX" },
	Callback = function(p)
		if not pcall(function()
			return p.Activated
		end) then
			return
		end

		local activatedConnection = p.Activated:Connect(function()
			click:Play()
		end)
		return function()
			activatedConnection:Disconnect()
		end
	end
}