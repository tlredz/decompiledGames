local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
game:GetService("RunService")
return function(data, _)
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

	local cycle = data.cycle
	local root = data.root
	local lastTime = tick()
	PeodizService.new({
		Time = 10
	}, function()
		if not (cycle and root) then
			return true
		end

		cycle.CFrame = CFrame.new(root.CFrame.p) * CFrame.new(0, 2.5, 0) * CFrame.Angles(
			0,
			math.rad((tick() - lastTime) * 55),
			0
		)

		if cycle and root then
			return
		else
			return true
		end
	end)
end