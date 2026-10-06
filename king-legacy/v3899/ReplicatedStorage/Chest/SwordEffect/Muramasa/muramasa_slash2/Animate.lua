local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local v = {
	"rbxassetid://7850072140",
	"rbxassetid://7850071666",
	"rbxassetid://7850071178",
	"rbxassetid://7850070947",
	"rbxassetid://7850070711",
	"rbxassetid://7850070404",
	"rbxassetid://7850070156",
	"rbxassetid://7850069950",
	"rbxassetid://7850069707",
	"rbxassetid://7850069436",
	"rbxassetid://7850069207",
	"rbxassetid://7850068914",
	"rbxassetid://7850068711",
	"rbxassetid://7850068392",
	"rbxassetid://7850068069",
	"rbxassetid://7850067802",
	"rbxassetid://7850067227",
	"rbxassetid://7850066757",
	"rbxassetid://7850066121",
	"rbxassetid://7850065784"
}
local v2 = {
	"rbxassetid://7850028225",
	"rbxassetid://7850027391",
	"rbxassetid://7850026699",
	"rbxassetid://7850026364",
	"rbxassetid://7850025913",
	"rbxassetid://7850025694",
	"rbxassetid://7850025472",
	"rbxassetid://7850025194",
	"rbxassetid://7850024936",
	"rbxassetid://7850024696",
	"rbxassetid://7850024253",
	"rbxassetid://7850023850",
	"rbxassetid://7850023614",
	"rbxassetid://7850023363",
	"rbxassetid://7850023080",
	"rbxassetid://7850022899",
	"rbxassetid://7850022657",
	"rbxassetid://7850022476",
	"rbxassetid://7850022243",
	"rbxassetid://7850022057",
	"rbxassetid://7850021851",
	"rbxassetid://7850021695",
	"rbxassetid://7850021440"
}
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local cFrame = script.Parent.CFrame
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cFrame
		clone.CFrame *= CFrame.Angles(0, 2.181661564992912, 0)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(255, 113, 66)
		pointLight.Brightness = 0
		pointLight.Range = 0
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8882227579",
			PlaybackSpeed = 1.15,
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = script.Parent
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8882263648",
			PlaybackSpeed = 0.8,
			Volume = 1.5
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = script.Parent
		sound2:Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 14
			}, function(p)
				local v3 = math.floor(p * 14)
				local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.flamee:Clone()
				clone2.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
					0,
					0.4487989505128276 * v3,
					0
				) * CFrame.new(0, 0, -17)
				clone2.Parent = clone
				clone2.Flames:Emit(math.random(5, 8))
			end)
		end)
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1,
				Range = 30
			}
		):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v3 = math.floor(p * #v)

				if clone:FindFirstChild("Top") then
					clone.Top.Texture = v[v3]
				end
			end)
		end)
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if clone:FindFirstChild("Bottom") then
				clone.Bottom.Texture = v2[v3]
			end
		end)

		if clone:FindFirstChild("Bottom") then
			clone.Bottom.Texture = ""
		end

		if clone:FindFirstChild("Top") then
			clone.Top.Texture = ""
		end

		_G.PU:Dust(clone, 1.25)
	end)
end