task.wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local chestConfiguration = ReplicatedStorage:WaitForChild("ChestConfiguration")
local ChestSettings = require(chestConfiguration:WaitForChild("ChestSettings"))
local ChestTypes = require(chestConfiguration:WaitForChild("ChestTypes"))
local ClientChest = require(script.ClientChest)
local FunctionQueue = require(game.ReplicatedStorage.Util.FunctionQueue)
local v = FunctionQueue.test("Chest", 2, 2)
local octree = Util.Octree.new()
local chestModels = ChestSettings.MODELS_LOCATION.ChestModels
local folder = Instance.new("Folder")
folder.Name = ChestSettings.FOLDER_NAME
folder.Parent = ChestSettings.FOLDER_LOCATION
local v2 = {}

local function chestRegister(instance)
	if not v2[instance] then
		local chestModel = chestModels[ChestTypes[instance:GetAttribute("IsChristmasChest") and "XmasChest" or instance.Name].Model]
		v2[instance] = ClientChest.new(instance, chestModel, folder)
		v2[instance].Node = octree:CreateNode(instance.Position, instance)
	end
end

local function chestUnregister(p)
	if v2[p] then
		v2[p]:Destroy()
		v2[p] = nil
	end
end

local v3 = {}

for _, v4 in pairs(CollectionService:GetTagged(ChestSettings.STREAM_TAG)) do
	if not v2[v4] then
		chestRegister(v4)
	end
end

CollectionService:GetInstanceAddedSignal(ChestSettings.STREAM_TAG):Connect(chestRegister)
CollectionService:GetInstanceRemovedSignal(ChestSettings.STREAM_TAG):Connect(chestUnregister)
local cFrame = workspace.CurrentCamera.CFrame
local startLoop

startLoop = function()
	local _, result = pcall(function()
		while true do
			cFrame = workspace.CurrentCamera.CFrame
			local v4 = nil
			v:Yield("search", function()
				v4 = octree:KNearestNeighborsSearch(
					cFrame.Position,
					ChestSettings.STREAM.BATCH_SIZE,
					ChestSettings.STREAM.DISTANCE
				)
			end)

			for k, v5 in pairs(v2) do
				local v6 = k
				local connection = v5
				v:Yield("update", function()
					if table.find(v4, v6) then
						if not v3[v6] then
							v3[v6] = true
							connection.Flag = 1
						end
					elseif v3[v6] then
						v3[v6] = nil
						connection.Flag = -1
					end

					if connection.Flag == 1 then
						connection:Connect()

						if connection.CanCollect == true then
							connection:CreateModel()
							connection.Flag = 0
						end
					elseif connection.Flag == -1 then
						connection:RemoveModel()
						connection:Disconnect()
						connection.Flag = 0
					end
				end)
			end

			task.wait(ChestSettings.STREAM.INTERVAL)
		end
	end)

	if result then
		warn(ChestSettings.PRINT_NAME .. " Something went wrong in the render loop, restarting in 10 seconds: \n")
		warn(result)
		task.wait(10)
		startLoop()
	end
end

startLoop()