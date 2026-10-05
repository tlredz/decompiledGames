local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
require(ReplicatedStorage:WaitForChild("FX"))
local shared = script.Parent.Shared
local utility = shared.Utility
require(utility.VisualHelper)
require(utility.MathHelper)
require(shared.Textures)
require(shared.Rocks)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
local Effect = require(ReplicatedStorage.Effect)
Random.new()
return function(data)
	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") and not data.Player:FindFirstChild("PlayerGui") and data.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", data.Player)
		folder.Name = "PlayerGui"
	end

	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position or data.player and data.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	if data.Stage == 1 then
		local v = ObjectClass.new(data.Player, data.CFrame, data.Proxy, data.Part)
		local proxy = data.Proxy
		local part = data.Part
		task.spawn(function()
			local descendants = data.Part:GetDescendants()

			if data.Part:IsA("BasePart") then
				data.Part.CanCollide = true
				data.Part.CanQuery = true
				data.Part.CanTouch = false
			end

			for _, part2 in pairs(descendants) do
				if not part2:IsA("BasePart") then
					continue
				end

				part2.CanCollide = true
				part2.CanQuery = true
				part2.CanTouch = false
			end

			while part and not part:GetAttribute("Destroying") and proxy and proxy:IsDescendantOf(workspace) do
				v.Model.PrimaryPart.CFrame = data.Part.CFrame
				task.wait()
			end

			if part then
				data.Part.CanCollide = false
				data.Part.CanQuery = false
			end

			for _, part2 in pairs(descendants) do
				if not part2:IsA("BasePart") then
					continue
				end

				part2.CanCollide = false
				part2.CanQuery = false
			end

			if part:HasTag("BeingCut") then
				if part:IsDescendantOf(workspace) then
					part:Destroy()
				end

				if v then
					v:Destroy()
				end
			elseif not v.IsThrowing then
				pcall(function()
					Effect.new("ControlRework.ObjectExplosion"):play({
						Object = data.Part,
						Scale = 2.15 * v:GetLayoutSize()
					})

					if part then
						part:Destroy()
					end
				end)

				if v then
					v:Destroy()
				end
			end
		end)
	end
end