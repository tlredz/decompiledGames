local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
parent.Equipped:Connect(function()
	ReplicatedStorage:WaitForChild("Client"):WaitForChild("BanHammer"):WaitForChild("Equipped"):Fire(parent)
end)