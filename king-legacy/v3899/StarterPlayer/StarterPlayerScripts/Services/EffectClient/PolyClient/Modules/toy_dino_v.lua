local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(ReplicatedStorage.Chest.Modules.PeodizService)
return function(data)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local trex = data.trex

	for _, motor6D in pairs(trex:GetDescendants()) do
		if motor6D:IsA("Motor6D") then
			motor6D:Destroy()
		end
	end

	for _, part in pairs(trex:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(100000000, 100000000, 100000000)
		bodyVelocity.P = 1000
		bodyVelocity.Velocity = part.CFrame.UpVector * math.random(-50, 50) + part.CFrame.RightVector * math.random(
			-50,
			50
		) + part.CFrame.LookVector * math.random(-50, 50)
		part.Anchored = false
		part.Massless = true
		part.CanCollide = true
		part.CollisionGroup = "p"
		_G.PU:Dust(bodyVelocity, 0.1)
	end
end