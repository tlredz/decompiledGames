local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("ModuleScript")

while localPlayer:GetAttribute("LoadedData") == nil do
	task.wait(1)
end

local parts = {}

local function SetupEffect(part)
	if part then
		if part:IsA("BasePart") and part:IsDescendantOf(workspace.Character) and table.find(parts, part) == nil then
			parts[#parts + 1] = part
		end
	else
		local tagged = CollectionService:GetTagged("RainbowAura")

		for _, part2 in ipairs(tagged) do
			if not (part2:IsA("BasePart") and part2:IsDescendantOf(workspace.Character) and table.find(parts, part2) == nil) then
				continue
			end

			parts[#parts + 1] = part2
		end
	end
end

SetupEffect()
CollectionService:GetInstanceAddedSignal("RainbowAura"):Connect(SetupEffect)
local total = 0

while true do
	if #parts > 0 then
		for _, v in ipairs(parts) do
			if not (v and v.Parent and v:IsDescendantOf(workspace.Character) and (v.Position - currentCamera.CFrame.Position).Magnitude <= 500) then
				continue
			end

			v.Color = Color3.fromHSV(total, 1, 1)
		end

		total += 0.02

		if total >= 1 then
			total = 0
		end
	end

	task.wait(0.25)
end