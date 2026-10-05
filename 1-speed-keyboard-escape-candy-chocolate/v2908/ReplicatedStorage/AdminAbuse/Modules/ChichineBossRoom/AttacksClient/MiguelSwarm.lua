local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local connections = {}
local flag = false

local function tweenOutBillboard(folder)
	for _, billboardGui in folder:GetDescendants() do
		if not billboardGui:IsA("BillboardGui") then
			continue
		end

		for _, guiObject in billboardGui:GetChildren() do
			if guiObject:IsA("TextLabel") then
				TweenService:Create(guiObject, tweenInfo, {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
			elseif guiObject:IsA("ImageLabel") then
				TweenService:Create(guiObject, tweenInfo, {
					ImageTransparency = 1
				}):Play()
			elseif guiObject:IsA("Frame") then
				TweenService:Create(guiObject, tweenInfo, {
					BackgroundTransparency = 1
				}):Play()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isMiguelNpc(model)
	if not model:IsA("Model") then
		return false
	end

	return model:GetAttribute("ArchetypeId") == "Miguel" or model.Name:sub(1, 7) == "Miguel_"
end

local function watchNpc(instance)
	-- equivalent call inferred; original call site unknown
	if not isMiguelNpc(instance) then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.Died:Once(function()
		if instance.Parent then
			tweenOutBillboard(instance)
		end
	end)
end

local MiguelSwarm = {}

function MiguelSwarm.init()
	if flag then
		return
	end

	flag = true

	for _, v in CollectionService:GetTagged("AABossNpc") do
		task.spawn(watchNpc, v)
	end

	local connection = CollectionService:GetInstanceAddedSignal("AABossNpc"):Connect(function(p)
		task.spawn(watchNpc, p)
	end)
	table.insert(connections, connection)
end

function MiguelSwarm.cleanup()
	flag = false

	for _, v in connections do
		local connection = v
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(connections)
end

return MiguelSwarm