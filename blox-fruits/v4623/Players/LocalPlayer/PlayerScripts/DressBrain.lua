local createVector = vector.create
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local circleIsland = workspace:WaitForChild("Map"):WaitForChild("CircleIsland", 10)

if not circleIsland then
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openRightThisSecond()
	task.spawn(function()
		local secretLabDoors = circleIsland:WaitForChild("SecretLabDoors")

		if secretLabDoors then
			secretLabDoors.colormodel.Color = Color3.fromRGB(91, 213, 84)
			secretLabDoors.rightdoor:PivotTo(CFrame.new(createVector(-5598.376, 230.428, -5903.652)) * secretLabDoors.rightdoor:GetPivot().Rotation)
			secretLabDoors.leftdoor:PivotTo(CFrame.new(createVector(-5597.709, 230.428, -5884.55)) * secretLabDoors.leftdoor:GetPivot().Rotation)
		end
	end)
end

local function checkPart()
	if not commF_:InvokeServer("CheckBlockPart") then
		return
	end

	openRightThisSecond() -- equivalent call inferred; original call site unknown
	return true
end

local v = false

for _ = 1, 15 do
	local flag

	if commF_:InvokeServer("CheckBlockPart") then
		task.spawn(function()
			local secretLabDoors = circleIsland:WaitForChild("SecretLabDoors")

			if secretLabDoors then
				secretLabDoors.colormodel.Color = Color3.fromRGB(91, 213, 84)
				secretLabDoors.rightdoor:PivotTo(CFrame.new(createVector(-5598.376, 230.428, -5903.652)) * secretLabDoors.rightdoor:GetPivot().Rotation)
				secretLabDoors.leftdoor:PivotTo(CFrame.new(createVector(-5597.709, 230.428, -5884.55)) * secretLabDoors.leftdoor:GetPivot().Rotation)
			end
		end)
		flag = true
	end

	if flag then
		v = true
		break
	else
		wait(1)
	end
end

if not v then
	remotes:WaitForChild("BlockPart").OnClientEvent:Connect(function()
		openRightThisSecond() -- equivalent call inferred; original call site unknown
	end)
end