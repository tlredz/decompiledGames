local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Moonlite = require(ReplicatedStorage.packages.Moonlite)
local Signal = require(ReplicatedStorage.packages.Signal)
local Trove = require(ReplicatedStorage.packages.Trove)
local subtitles = require(ReplicatedStorage.client.modules.subtitles)
local v = {
	Workspace = workspace,
	ReplicatedStorage = ReplicatedStorage
}

local function createObjectFor(child, fn)
	local v2 = Trove.new()
	local parent = v[child.Name]

	if parent == nil then
		return v2:WrapClean()
	end

	for _, child2 in child:GetChildren() do
		child2.Parent = parent
		fn(child2, parent, child)
		v2:Add(child2)
	end

	return v2:WrapClean()
end

if RunService:IsServer() then
	warn((`{script:GetFullName()} is not supposed to be used in the server.`))
end

return function(data)
	local maid = Trove.new()
	local clone = table.clone(data.Subtitles or {})
	local clone2 = table.clone(data.Sounds or {})

	for k, v2 in clone2 do
		clone2[k] = maid:Clone(v2)
	end

	local v2 = {
		Trove = maid,
		SceneInstanceCreated = maid:Add(Signal.new()),
		SceneInstanceMoved = maid:Add(Signal.new()),
		SceneCompleted = maid:Add(Signal.new()),
		SceneLoaded = maid:Add(Signal.new()),
		Completed = maid:Add(Signal.new()),
		Destroy = function(self)
			maid:Destroy()
		end
	}
	local clone3 = maid:Clone(script.MoonAnimatorEffects)
	maid:Add(function()
		clone3:Destroy()
	end)
	maid:Add(task.defer(function()
		for _, v3 in clone2 do
			if not (v3.SoundId ~= "rbxasset://0" and v3.SoundId ~= "rbxasset://" and v3.SoundId ~= "") then
				continue
			end

			local volume = v3.Volume
			v3.Parent = Players.LocalPlayer.PlayerGui
			v3.Volume = 0
			v3:Play()
			local v4 = 5

			while v3.TimeLength == 0 do
				v4 -= task.wait()

				if v4 <= 0 then
					break
				end
			end

			v3.TimePosition = 0
			v3.Volume = volume
			v3:Stop()
		end

		local v3 = 0

		for _, v4 in clone2 do
			v4:Play()
			local v5 = v4
			maid:Add(RunService.PostSimulation:Connect(function()
				local timePosition = v5.TimePosition

				if v3 + 0.1 < timePosition then
					v5.TimePosition = v3 % v5.TimeLength
				end
			end))
		end

		local total = 0

		for k, scene in data.Scenes do
			local _ = scene.Name
			local maid2 = maid:Extend()
			local clone4 = maid2:Clone(scene)

			for _, child in clone4.Objects:GetChildren() do
				local v4 = k
				maid2:Add(createObjectFor(child, function(p, p2, p3)
					v2.SceneInstanceMoved:Fire(v4, p, p2, p3)
				end))
			end

			v2.SceneInstanceCreated:Fire(k, clone4)

			if clone3 then
				clone3.Parent = ReplicatedStorage
			end

			local player = Moonlite.CreatePlayer(clone4.Save)
			v2.SceneLoaded:Fire(k, player)
			player.Looped = false

			if clone3 then
				clone3.Parent = Players.LocalPlayer.PlayerGui
			end

			maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
				v3 = total + player.TimePosition

				for k2, v5 in clone do
					if v5.Shown or not (v3 >= v5.Delay) then
						continue
					end

					v5.Shown = true
					subtitles.show(v5.Text, v5.DisplayTime, v5.GradientToShow)
				end
			end))
			local v5 = player
			maid2:Add(function()
				v5:Stop()
				v5:Destroy()
			end)
			player:Play()
			player.Completed:Wait()
			total += player.TimePosition
			maid2:Clean()
			v2.SceneCompleted:Fire(k)
		end

		v2.Completed:Fire()
	end))
	return v2
end