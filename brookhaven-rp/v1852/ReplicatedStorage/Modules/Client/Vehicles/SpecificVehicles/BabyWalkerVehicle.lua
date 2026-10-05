local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "BabyWalkerVehicle",
	Extensions = {
		{
			ShouldConstruct = function(p)
				return p.Instance:WaitForChild("PlayerObject").Value == Players.LocalPlayer
			end
		}
	}
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local v2 = self._Janitor:Add(animator:LoadAnimation(self.Instance:WaitForChild("Idle")))
	local v3 = self._Janitor:Add(animator:LoadAnimation(self.Instance:WaitForChild("Walk")))
	v2:Play()

	local function onMoveDirectionChanged()
		if humanoid.MoveDirection == createVector(0, 0, 0) then
			v2:Play()
			v3:Stop()
		else
			local magnitude = humanoid.MoveDirection.Magnitude

			if v3.IsPlaying then
				v3:AdjustSpeed(magnitude)
			else
				v3:Play(nil, nil, magnitude)
			end

			v2:Stop()
		end
	end

	self._Janitor:Add(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(onMoveDirectionChanged))
	onMoveDirectionChanged()
	self._Janitor:Add(function()
		v2:Stop()
		v3:Stop()
	end)
	local rainCover = self.Instance:FindFirstChild("RainCover", true)

	if not rainCover then
		return
	end

	for _, part in rainCover:GetChildren() do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part:AddTag("MakeInvisibleOnFirstPersonCamera")
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v