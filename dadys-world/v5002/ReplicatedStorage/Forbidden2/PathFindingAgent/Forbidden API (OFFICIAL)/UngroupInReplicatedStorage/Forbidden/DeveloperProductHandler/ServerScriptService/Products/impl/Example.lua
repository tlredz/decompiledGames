local Players = game:GetService("Players")
local Config = require(script:WaitForChild("Config"))
local Example = {}

function Example.GetProductId()
	return Config.ProductId
end

function Example.GetProductName()
	return script.Name
end

function Example.Trigger(p)
	local playerByUserId = Players:GetPlayerByUserId(p.PlayerId)
	print("Triggered by " .. playerByUserId.Name)
end

return Example