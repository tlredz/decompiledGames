local ArmWrestling = {}
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local screenGui = script.Parent:FindFirstAncestorOfClass("ScreenGui")
local armWrestling = screenGui:WaitForChild("Activities"):WaitForChild("ArmWrestling")
local line = armWrestling:WaitForChild("Line")
local red = armWrestling:WaitForChild("Red")
local green = armWrestling:WaitForChild("Green")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function ArmWrestling:Start()
	self.Signals = {}
	self.Clicks = {}
	local total = 0

	local function get_click_speed(p)
		local now = os.clock()
		local count = 0

		for i = #self.Clicks, 1, -1 do
			if now - self.Clicks[i] < p then
				count += 1
			else
				break
			end
		end

		return count
	end

	table.insert(self.Signals, mouse.Button1Down:connect(function()
		table.insert(self.Clicks, os.clock())
		local clone = script.Ripple:Clone()
		clone.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
		local v = math.random(100, 400)
		clone.Size = UDim2.new(0, 0, 0, 0)
		local tween = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			Transparency = 1,
			Size = UDim2.new(0, v, 0, v)
		})
		tween:Play()
		tween.Completed:connect(function()
			return clone:Destroy()
		end)
		local clone2 = script.Hit:Clone()
		clone2.Parent = screenGui
		clone2.PlaybackSpeed = 0.8 + 0.5 * math.random()
		clone2:Play()
		clone2.Ended:connect(function()
			return clone2:Destroy()
		end)
		clone.Parent = screenGui
	end))
	table.insert(self.Signals, RunService.Heartbeat:connect(function(p)
		total += p

		if total >= 0.5 then
			total = 0
			Network:fire("ArmWrestlingClick", (get_click_speed(0.5)))
		end
	end))
end

function ArmWrestling:Stop() end

function ArmWrestling.Loop(_, player, p)
	local v = math.sin(20 * (os.clock() - player.Offset)) * 0.0015
	local timePosition = player.MovementTrack.TimePosition
	local movementGoal = player.MovementGoal
	local v2 = p * 5
	local v3 = timePosition + (movementGoal - timePosition) * v2

	if v3 >= 0.9985 then
		v *= (1 - v3) / 0.0015
	elseif v3 <= 0.0015 then
		v *= v3 / 0.0015
	end

	if player.Character == localPlayer.Character then
		green.Size = UDim2.new(1 - v3, -1, 1, -2)
		red.Size = UDim2.new(v3, -1, 1, -2)
		line.Position = UDim2.new(v3, 0, 0.5, 0)
	end

	player.MovementTrack.TimePosition = math.clamp(v3 + v, 0, 1)
end

function ArmWrestling.RegisterPlayer(_, instance)
	instance.MovementTrack = instance.Humanoid:LoadAnimation(script.Animations.Movement)
	instance.MovementTrack:Play(0)
	instance.MovementTrack:AdjustSpeed(0)
	instance.MovementTrack.TimePosition = 0.5
	instance.MovementGoal = 0.5
end

function ArmWrestling.DestroyPlayer(_, p)
	if p and p.MovementTrack then
		p.MovementTrack:Stop()
		p.MovementTrack = nil
		p.MovementGoal = nil
	end
end

local function get_movement_track(instance)
	for _, v in instance.Humanoid:GetPlayingAnimationTracks() do
		if v.Animation == script.Animations.Movement then
			return v
		end
	end
end

Network:listen("ArmWrestlingUpdate", function(items)
	for _, item in items do
		local characterData = ArmWrestling:GetCharacterData(item.Character)

		if characterData then
			characterData.MovementGoal = item.Percent
		else
			print("could not find character data")
		end
	end
end)
return ArmWrestling