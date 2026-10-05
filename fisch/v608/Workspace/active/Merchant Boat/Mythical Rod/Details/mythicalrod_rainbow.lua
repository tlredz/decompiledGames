local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parts = {}
local trails = {}

for _, part in pairs(script.Parent:GetChildren()) do
	if not (part:IsA("BasePart") and part.Name == "Neon" and part.Material == Enum.Material.Neon) then
		continue
	end

	table.insert(parts, part)

	if part:FindFirstChildWhichIsA("Trail") then
		table.insert(trails, part:FindFirstChildWhichIsA("Trail"))
	end
end

local now = 0
local startRecursion

startRecursion = function()
	while not (script:IsDescendantOf(workspace) and script:FindFirstAncestorWhichIsA("Tool")) do
		script.AncestryChanged:Wait()
	end

	local preRenderConnection = nil
	local RunService = game:GetService("RunService")
	preRenderConnection = RunService.PreRender:Connect(function()
		if tick() < now + 0.08333333333333333 then
			return
		end

		now = tick()

		if script:IsDescendantOf(workspace) and script:FindFirstAncestorWhichIsA("Tool") then
			local character = localPlayer.Character
			local handle = script.Parent.Parent and script.Parent.Parent:FindFirstChild("handle")

			if not handle then
				return
			end

			local position = handle.Position

			if character and character:FindFirstChild("HumanoidRootPart") and position then
				for _, v in parts do
					v.Color = Color3.fromHSV(tick() % 20 / 20, 1, 1)
				end

				for _, v in trails do
					v.Color = ColorSequence.new(v.Parent.Color)
				end
			end
		else
			preRenderConnection:Disconnect()
			startRecursion()
		end
	end)
end

startRecursion()