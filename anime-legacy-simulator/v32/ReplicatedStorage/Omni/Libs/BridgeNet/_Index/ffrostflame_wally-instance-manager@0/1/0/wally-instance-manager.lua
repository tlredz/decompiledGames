local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WallyInstanceManager = {}

function WallyInstanceManager.add(p, p2)
	if not ReplicatedStorage:FindFirstChild(p.Name) then
		local folder = Instance.new("Folder")
		folder.Name = p.Name
		folder.Parent = ReplicatedStorage
	end

	p2.Parent = ReplicatedStorage:FindFirstChild(p.Name)
end

function WallyInstanceManager.get(p, childName: string)
	if ReplicatedStorage:FindFirstChild(p.Name) == nil then
		return nil
	end

	return (ReplicatedStorage[p.Name]:FindFirstChild(childName))
end

function WallyInstanceManager.waitForInstance(p, childName: string, value: number)
	return ReplicatedStorage:WaitForChild(p.Name):WaitForChild(childName, value or 1)
end

return WallyInstanceManager