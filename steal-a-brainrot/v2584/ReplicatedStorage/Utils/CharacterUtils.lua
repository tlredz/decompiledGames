local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = {
	"idle",
	"walk",
	"run",
	"swim",
	"swimidle",
	"jump",
	"fall",
	"climb",
	"sit",
	"toolnone",
	"toolslash",
	"toollunge",
	"wave",
	"point",
	"dance",
	"dance2",
	"dance3",
	"laugh",
	"cheer"
}
local CharacterUtils = {
	GetCharacter = function(_, player)
		if RunService:IsServer() then
			if not player then
				return nil
			end
		else
			player = player or Players.LocalPlayer
		end

		local character = player.Character

		if not character then
			return nil
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return nil
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			return character, humanoidRootPart, humanoid
		end

		return nil
	end,
	SetAnimations = function(self, instance, childName: string, list)
		local animate = instance:FindFirstChild("Animate")

		if not animate then
			return
		end

		local child = animate:FindFirstChild(childName)

		if not child then
			return
		end

		local originalValues = child:FindFirstChild("OriginalValues")

		if originalValues then
			for _, animation in ipairs(child:GetChildren()) do
				if animation:IsA("Animation") then
					animation:Destroy()
				end
			end

			for _, child2 in ipairs(originalValues:GetChildren()) do
				child2.Parent = child
			end

			originalValues:Destroy()
		end

		if list then
			local folder = Instance.new("Folder")

			for _, child2 in ipairs(child:GetChildren()) do
				child2.Parent = folder
			end

			folder.Name = "OriginalValues"
			folder.Parent = child

			for _, v2 in ipairs(list) do
				local clone = v2:Clone()
				clone.Parent = child
			end
		end
	end
}

function CharacterUtils:RevertAnimations(p, p2: string)
	CharacterUtils:SetAnimations(p, p2, nil)
end

function CharacterUtils.RevertAllAnimations(_, p)
	for _, v2 in ipairs(v) do
		CharacterUtils:RevertAnimations(p, v2)
	end
end

return CharacterUtils