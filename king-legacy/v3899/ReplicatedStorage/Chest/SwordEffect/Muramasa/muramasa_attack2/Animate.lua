local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local v = {
	"rbxassetid://7850072140",
	"rbxassetid://7850071666",
	"rbxassetid://7850071178",
	"rbxassetid://7850070711",
	"rbxassetid://7850070156",
	"rbxassetid://7850069707",
	"rbxassetid://7850069207",
	"rbxassetid://7850068711",
	"rbxassetid://7850068069",
	"rbxassetid://7850067802",
	"rbxassetid://7850067227",
	"rbxassetid://7850066757",
	"rbxassetid://7850066523",
	"rbxassetid://7850066121",
	"rbxassetid://7850065784"
}
local v2 = {
	"rbxassetid://7850028225",
	"rbxassetid://7850027391",
	"rbxassetid://7850026699",
	"rbxassetid://7850025913",
	"rbxassetid://7850025472",
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
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local cFrame = script.Parent.CFrame
		local parent = script.Parent
		parent.Parent = workspace.Effects
		parent.CFrame = cFrame
		parent.CFrame *= CFrame.Angles(0, 2.181661564992912, 0)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6780413304",
			PlaybackSpeed = 1.25,
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = script.Parent
		sound:Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 10
			}, function(p)
				local v3 = p * 10
				local clone = replicatedStorage.Chest.SwordEffect.Muramasa.flamee:Clone()
				clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
					0,
					0.6283185307179586 * v3,
					0
				) * CFrame.new(0, 0, -7.6)
				clone.Parent = parent
				clone.Flames:Emit(math.random(5, 8))
			end)
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = parent
		pointLight.Color = Color3.fromRGB(255, 113, 66)
		pointLight.Brightness = 0
		pointLight.Range = 0
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1,
				Range = 15
			}
		):Play()
		game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = parent.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v3 = math.floor(p * #v)

				if parent:FindFirstChild("Top") then
					parent.Top.Texture = v[v3]
				end
			end)
		end)
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if parent:FindFirstChild("Bottom") then
				parent.Bottom.Texture = v2[v3]
			end
		end)

		if parent:FindFirstChild("Bottom") then
			parent.Bottom.Texture = ""
		end

		if parent:FindFirstChild("Top") then
			parent.Top.Texture = ""
		end

		_G.PU:Dust(parent, 1)
	end)
end