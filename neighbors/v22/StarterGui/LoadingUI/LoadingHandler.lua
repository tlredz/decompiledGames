local localPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local frame = script.Parent:WaitForChild("Frame")
local spinner = frame:WaitForChild("Spinner")
local label = frame:WaitForChild("Label")
local loadingBlur = script:WaitForChild("LoadingBlur")
local text = label.Text

if not localPlayer:GetAttribute("DataLoaded") then
	loadingBlur.Parent = game.Lighting
	script.Parent.Enabled = true
	local lastTime = os.clock()
	local v = 0

	while not localPlayer:GetAttribute("DataLoaded") do
		local v2 = v + 1
		v = v2 / 30 % 4 == 0 and 0 or v2
		spinner.Rotation += 5
		label.Text = text .. string.rep(".", v / 30 % 4)
		task.wait()
	end

	if os.clock() - lastTime > 1 then
		TweenService:Create(spinner, TweenInfo.new(0.3), {
			ImageTransparency = 1
		}):Play()

		for _, label2 in frame:GetChildren() do
			if label2:IsA("TextLabel") then
				TweenService:Create(label2, TweenInfo.new(0.3), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
			end
		end

		task.wait(0.3)
		frame.Active = false
		TweenService:Create(loadingBlur, TweenInfo.new(0.5), {
			Size = 0
		}):Play()
		TweenService:Create(frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
			ImageTransparency = 1
		}):Play()
		task.wait(0.65)
	end

	loadingBlur:Destroy()
	script.Parent.Enabled = false
end