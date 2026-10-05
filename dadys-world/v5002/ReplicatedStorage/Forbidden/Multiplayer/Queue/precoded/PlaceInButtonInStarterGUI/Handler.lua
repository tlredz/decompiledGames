local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signals = ReplicatedStorage:WaitForChild("Forbidden"):WaitForChild("Multiplayer"):WaitForChild("Queue"):WaitForChild("signals")
local join = signals:WaitForChild("join")
local leave = signals:WaitForChild("leave")
local toClientMatchInfo = signals:WaitForChild("toClientMatchInfo")
local parent = script.Parent
local flag = false
local flag2 = false
local flag3 = false

local function MatchFound(_) end

local function JoinRequestSent() end

local function LeaveRequestSent() end

-- equivalent calls inferred from this helper; original call sites unknown
local function Join()
	if flag3 then
		return
	end

	flag3 = true
	join:InvokeServer()
	flag3 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Leave()
	if flag3 then
		return
	end

	flag3 = true
	task.wait(0)
	leave:InvokeServer()
	flag3 = false
end

local function onPress()
	if flag then
		flag = false
		flag2 = true
		Leave() -- equivalent call inferred; original call site unknown
	end

	if flag2 then
		flag2 = false
	elseif not flag then
		flag = true
		Join() -- equivalent call inferred; original call site unknown
	end
end

parent.MouseButton1Up:Connect(onPress)
toClientMatchInfo.OnClientEvent:Connect(MatchFound)