local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local v = {
	"rbxassetid://9054352395",
	"rbxassetid://9054352089",
	"rbxassetid://9054351780",
	"rbxassetid://9054351594",
	"rbxassetid://9054351293",
	"rbxassetid://9054351049",
	"rbxassetid://9054350829",
	"rbxassetid://9054350577",
	"rbxassetid://9054350217",
	"rbxassetid://9054350001",
	"rbxassetid://9054349737",
	"rbxassetid://9054349439",
	"rbxassetid://9054349149",
	"rbxassetid://9054348932",
	"rbxassetid://9054348723",
	"rbxassetid://9054348509",
	"rbxassetid://9054348176",
	"rbxassetid://9054347918",
	"rbxassetid://9054347714",
	"rbxassetid://9054347381"
}
local v2 = {
	"rbxassetid://9054401306",
	"rbxassetid://9054401053",
	"rbxassetid://9054401053",
	"rbxassetid://9054400763",
	"rbxassetid://9054400499",
	"rbxassetid://9054400206",
	"rbxassetid://9054399929",
	"rbxassetid://9054399478",
	"rbxassetid://9054399068",
	"rbxassetid://9054398655",
	"rbxassetid://9054398350",
	"rbxassetid://9054398053",
	"rbxassetid://9054397700",
	"rbxassetid://9054397356",
	"rbxassetid://9054397071",
	"rbxassetid://9054396787",
	"rbxassetid://9054396492",
	"rbxassetid://9054396264",
	"rbxassetid://9054396016",
	"rbxassetid://9054395811"
}
return function()
	task.spawn(function()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			PlaybackSpeed = 0.85,
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = script.Parent
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9099051717",
			Volume = 1,
			TimePosition = 0.1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = script.Parent
		sound2:Play()
		local cFrame = script.Parent.CFrame
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cFrame
		clone.CFrame = clone.CFrame
		game.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		task.spawn(function()
			wait(0.1)
			game.TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				}
			):Play()
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(85, 122, 255)
		pointLight.Brightness = 0
		pointLight.Range = 0
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1.5,
				Range = 30
			}
		):Play()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v3 = math.floor(p * #v)

			if clone:FindFirstChild("Outer") then
				clone.Outer.Texture = v[v3]
			end

			if clone:FindFirstChild("Inner") then
				clone.Inner.Texture = v2[v3]
			end
		end)

		if clone:FindFirstChild("Outer") then
			clone.Outer.Texture = ""
		end

		if clone:FindFirstChild("Inner") then
			clone.Inner.Texture = ""
		end

		_G.PU:Dust(clone, 1)
	end)
end