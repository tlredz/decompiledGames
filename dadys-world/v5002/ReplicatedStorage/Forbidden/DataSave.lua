local DataSave = {}
local DataStoreService = game:GetService("DataStoreService")
local v = "Forbidden"
local dataStore = nil

function DataSave.ForceSave(instance)
	if dataStore == nil then
		error("Store not found!")
		return
	end

	local v2 = {}

	for _, child in pairs(instance:WaitForChild("leaderstats"):GetChildren()) do
		v2[child.Name] = child.Value
	end

	for _, child in pairs(instance:WaitForChild("StoredValues"):GetChildren()) do
		v2[child.Name] = child.Value
	end

	local function save()
		local success, result = pcall(function()
			dataStore:SetAsync("Player_" .. instance.UserId, v2)
		end)

		if result then
			return false
		end

		if success then
			return true
		end
	end

	local count = 0

	while count < 3 do
		count += 1
		local success, result = pcall(function()
			dataStore:SetAsync("Player_" .. instance.UserId, v2)
		end)
		local v3

		if result then
			v3 = false
		else
			v3 = success and true or nil
		end

		if v3 then
			break
		end
	end
end

function DataSave.Activate(items: string, items2: string, p: string)
	local function create(parent)
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		folder.Parent = parent
		local folder2 = Instance.new("Folder")
		folder2.Name = "StoredValues"
		folder2.Parent = parent

		for k, item in pairs(items) do
			local numberValue = Instance.new("NumberValue")
			numberValue.Parent = folder
			numberValue.Value = item
			numberValue.Name = k
		end

		for k, item in pairs(items2) do
			local numberValue = Instance.new("NumberValue")
			numberValue.Parent = folder2
			numberValue.Value = item
			numberValue.Name = k
		end
	end

	local function load(instance)
		create(instance)

		if p then
			v = p
		end

		dataStore = DataStoreService:GetDataStore(v)
		local async = dataStore:GetAsync("Player_" .. instance.UserId)

		if async then
			for _, child in pairs(instance:WaitForChild("leaderstats"):GetChildren()) do
				if async[child.Name] ~= nil then
					child.Value = async[child.Name]
				end
			end

			for _, child in pairs(instance:WaitForChild("StoredValues"):GetChildren()) do
				if async[child.Name] ~= nil then
					child.Value = async[child.Name]
				end
			end
		end
	end

	game.Players.PlayerAdded:Connect(load)
	game.Players.PlayerRemoving:Connect(DataSave.ForceSave)
	game:BindToClose(function()
		local Players = game:GetService("Players")

		for _, v2 in pairs(Players:GetChildren()) do
			DataSave.ForceSave(v2)
		end
	end)
end

return DataSave