local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
task.wait(0.2)

for _, animation in ipairs(ReplicatedStorage:GetDescendants()) do
	if animation:IsA("Animation") then
		ContentProvider:PreloadAsync({ animation })
	end

	task.wait()
end