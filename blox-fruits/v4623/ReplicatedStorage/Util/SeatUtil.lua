local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local SeatUtil = {}

local function getSeatWelds(instance)
	local welds = {}

	for _, part in instance:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		for _, weld in part:GetJoints() do
			if not (weld:IsA("Weld") and weld.Name == "SeatWeld") then
				continue
			end

			local part1

			if weld.Part0 == part then
				part1 = weld.Part1
			else
				part1 = weld.Part0
			end

			if part1 and (part1:IsA("Seat") or part1:IsA("VehicleSeat")) then
				table.insert(welds, weld)
			end
		end
	end

	return welds
end

function SeatUtil.isSeated(instance)
	if not instance then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local sit

	if humanoid == nil then
		sit = #getSeatWelds(instance) > 0
	else
		sit = humanoid.Sit

		if not sit then
			if humanoid.SeatPart == nil then
				sit = #getSeatWelds(instance) > 0
			else
				sit = true
			end
		end
	end

	return sit
end

function SeatUtil.unseat(instance)
	local seatWelds = getSeatWelds(instance)

	for _, seatWeld in seatWelds do
		seatWeld:Destroy()
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid and (humanoid.Sit or humanoid.SeatPart or #seatWelds > 0) then
		humanoid.Sit = false
	end

	local cannonController = instance:FindFirstChild("CannonController")

	if cannonController then
		for _, child in cannonController:GetChildren() do
			if child.Name == "Cannon" then
				child:Destroy()
			end
		end
	end

	local cannonAnimation = instance:FindFirstChild("CannonAnimation")

	if cannonAnimation then
		cannonAnimation:Destroy()
	end
end

function SeatUtil.bindHumanoid(instance)
	local parent = instance.Parent
	assert(parent and parent:IsA("Model"), "Humanoid must belong to a character")

	local function updateSeating()
		local v = AttributeCounter.get(instance, "BlockSit") > 0
		instance:SetStateEnabled(Enum.HumanoidStateType.Seated, not v)

		if v then
			SeatUtil.unseat(parent)
		end
	end

	local seatPartChangedConnection = instance:GetPropertyChangedSignal("SeatPart"):Connect(updateSeating)
	local sitChangedConnection = instance:GetPropertyChangedSignal("Sit"):Connect(updateSeating)
	local connection = AttributeCounter.connect(instance, "BlockSit", updateSeating, true)
	return function()
		seatPartChangedConnection:Disconnect()
		sitChangedConnection:Disconnect()
		connection:Disconnect()
	end
end

return SeatUtil