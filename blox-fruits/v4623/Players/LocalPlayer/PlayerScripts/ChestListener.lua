local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("CollectionService")
require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local chestConfiguration = ReplicatedStorage:WaitForChild("ChestConfiguration")
local ChestSettings = require(chestConfiguration:WaitForChild("ChestSettings"))
local ChestTypes = require(chestConfiguration:WaitForChild("ChestTypes"))
local ClientChest = require(script.ClientChest)
local chestModels = ChestSettings.MODELS_LOCATION.ChestModels
local folder = Instance.new("Folder")
folder.Name = ChestSettings.FOLDER_NAME
folder.Parent = ChestSettings.FOLDER_LOCATION
local v = {}

local function chestRegister(instance)
	if not v[instance] then
		while true do
			local Global = require(game.ReplicatedStorage.Global)

			if not Global.isClientFramedropping() then
				break
			end

			task.wait()
		end

		local chestModel = chestModels[ChestTypes[instance:GetAttribute("IsChristmasChest") and "XmasChest" or instance.Name].Model]
		v[instance] = ClientChest.new(instance, chestModel, folder)
		v[instance]:Connect()
	end
end

local function chestUnregister(p)
	if v[p] then
		while true do
			local Global = require(game.ReplicatedStorage.Global)

			if not Global.isClientFramedropping() then
				break
			end

			task.wait()
		end

		if v[p] then
			v[p]:Destroy()
			v[p] = nil
		end
	end
end

game.ReplicatedStorage.Remotes.Chest.OnClientEvent:Connect(function(p, p2)
	if p2 then
		chestRegister(p)
	else
		chestUnregister(p)
	end
end)
local now = tick()

local function discoveryChanged()
	now = 1.5
end

game.Players.LocalPlayer:GetAttributeChangedSignal("ChestDiscovery"):Connect(discoveryChanged)
task.spawn(discoveryChanged)

while true do
	if math.clamp(tick() - now, 0, 1.5) >= 1.5 then
		now = tick()

		for _, v2 in pairs(v) do
			if v2.Highlighter then
				v2.Highlighter()
			end
		end
	end

	task.wait()
end