local Animations = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("ContentProvider")
local v = {}
local animationsByName = {}

function LoadAnimationTracks()
	local animations = game.ReplicatedStorage:WaitForChild("Core"):WaitForChild("Animations")

	for _, animation in pairs(animations:GetDescendants()) do
		if animation:IsA("Animation") then
			animationsByName[animation.Name] = animation
		end
	end
end

Client.Events.PlayAnimation:Connect(function(p, options)
	local v2 = options or {}
	local v3 = animationsByName[p]

	if v3 then
		if v[p] then
			v[p].LastPlay = tick()
			v[p].Track:Play(v2.FadeTime, v2.Weight, v2.Speed)
		elseif Client.PlayerHandler.Humanoid then
			local track = Client.PlayerHandler.Humanoid:LoadAnimation(v3)
			v[p] = {
				Track = track
			}
			v[p].LastPlay = tick()
			track:Play(v2.FadeTime, v2.Weight, v2.Speed)
		end

		if v2.PlayTime then
			local lastPlay = v[p].LastPlay
			task.delay(v2.PlayTime, function()
				if lastPlay == v[p].LastPlay then
					v[p].Track:Stop()
				end
			end)
		end
	end
end)
Client.Events.StopAnimation:Connect(function(p)
	if v[p] then
		v[p].Track:Stop()
	end
end)

function Animations.Init()
	localPlayer.CharacterAdded:Connect(function()
		v = {}
	end)
	task.spawn(function()
		LoadAnimationTracks()
	end)
end

return Animations