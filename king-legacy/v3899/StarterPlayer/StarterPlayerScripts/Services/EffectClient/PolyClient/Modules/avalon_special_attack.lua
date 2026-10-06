local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
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

	local cf = data.cf
	local cf2 = data.cf2
	local v = 30
	local p = cf.p
	local v2 = "SmallBump2"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local v3 = (cf.p - cf2.p).Magnitude * 0.0025 * 1.35
	task.spawn(function()
		local clone = replicatedStorage.Chest.SwordEffect.Avalon["star_" .. data.mode]:Clone()
		_G.PU:Dust(clone, 2)
		clone.Parent = workspace.Effects
		clone.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0, 14)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://14019446930",
			Volume = 1.5,
			PlaybackSpeed = 1.1
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.35,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p2)
				local v4 = math.floor(p2 * 360)
				clone.Attachment.Specs:Emit(math.random(1, 2))
				clone.Attachment.smoke2:Emit(math.random(0, 1))
				clone.Attachment.w:Emit(math.random(0, 1))
				clone.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, math.rad(v4 * 3), 0) * CFrame.new(
					0,
					p2 * (cf.p - cf2.p).Magnitude,
					(360 - v4) / 40 + 5
				)
			end)
		end)
		wait(v3 - 0.2)
		clone.Attachment.specs.Enabled = false
	end)
	task.spawn(function()
		wait()
		local clone = replicatedStorage.Chest.SwordEffect.Avalon["star_" .. data.mode]:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
			0,
			0,
			14
		)
		_G.PU:Dust(clone, 2)
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.35,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p2)
				local v4 = math.floor(p2 * 360)
				clone.Attachment.Specs:Emit(math.random(1, 2))
				clone.Attachment.smoke2:Emit(math.random(0, 1))
				clone.Attachment.w:Emit(math.random(0, 1))
				clone.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
					0,
					math.rad(v4 * 3),
					0
				) * CFrame.new(0, p2 * (cf.p - cf2.p).Magnitude, (360 - v4) / 40 + 5)
			end)
		end)
		wait(v3 - 0.2)
		clone.Attachment.specs.Enabled = false
	end)
end