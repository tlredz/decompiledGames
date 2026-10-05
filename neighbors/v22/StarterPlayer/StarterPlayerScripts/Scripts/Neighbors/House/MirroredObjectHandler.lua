local ReplicatedStorage = game:GetService("ReplicatedStorage")
local House = require(ReplicatedStorage.Modules.Neighbors.House)

local function updateMirroredStatus()
	local currentHouse = House:GetCurrentHouse()
	House:GetCurrentPrefab()

	for _, hous in next, House.Houses, nil do
		for _, v in next, hous.Mirrored, nil do
			local parent

			if hous ~= currentHouse then
				parent = hous.Server:FindFirstChild("ShowInAll")
			end

			v.Parent = parent
		end
	end
end

House.ActiveHouseChanged:Connect(updateMirroredStatus)
House.ActiveSkinChanged:Connect(updateMirroredStatus)