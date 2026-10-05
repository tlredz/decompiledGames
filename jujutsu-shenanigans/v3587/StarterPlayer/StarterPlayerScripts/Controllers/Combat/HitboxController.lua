local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local remotes = replicatedStorage.Remotes
local utils = replicatedStorage.Utils
local controller = Knit.CreateController({
	Name = "HitboxController"
})
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters }
local v = nil
remotes.GetClient.OnClientEvent:Connect(function(object)
	local cFrame = workspace.CurrentCamera.CFrame

	if object and object.Parent then
		object:FireServer(cFrame)
	end
end)
local hitsphere = utils.Hitbox.Hitsphere

function controller:SphereHitbox(p, position, p2)
	if p then
		position = (p.HumanoidRootPart.CFrame * position).Position
	end

	if hitsphere.Transparency ~= 1 then
		local _ = createVector(1, 1, 1) * p2
		local clone = hitsphere:Clone()
		clone.Position = position
		clone.Size = createVector(1, 1, 1) * p2
		clone.Parent = workspace.Effects
		Debris:AddItem(clone, 0.5)
	end

	local parents = {}

	for _, v2 in workspace:GetPartBoundsInRadius(position, p2 / 2, overlapParams) do
		if v2.Name == "HumanoidRootPart" and v2.Parent ~= p and v2.Parent:FindFirstChild("Humanoid") then
			table.insert(parents, v2.Parent)
		end
	end

	return parents
end

function controller.KnitStart(_)
	v.Hitbox:Connect(function(p, p2, p3, object, p4)
		if not p.HumanoidRootPart then
			return
		end

		repeat
			local sphereHitbox = controller:SphereHitbox(p, p2, p3)

			if #sphereHitbox > 0 then
				object:FireServer(sphereHitbox)
			end

			task.wait(0.025)
		until not object.Parent or p4 and not p4.Parent
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("HitboxService")
end

return controller