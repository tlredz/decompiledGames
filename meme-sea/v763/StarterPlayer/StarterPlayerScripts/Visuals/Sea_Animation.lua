local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local sea = workspace:WaitForChild("Sea", 60)
local seaBlock

if sea then
	seaBlock = sea:WaitForChild("SeaBlock", 60)
end

local texture

if seaBlock then
	texture = seaBlock:WaitForChild("Texture", 60)
else
	texture = nil
end

local settings_Handler = localPlayer:WaitForChild("PlayerGui", 60):WaitForChild("GameGui", 60):WaitForChild("Settings"):WaitForChild("Main"):WaitForChild("Container"):WaitForChild("Settings"):WaitForChild("Frame"):WaitForChild("Settings_Handler")
local tween = TweenService:Create(texture, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
	OffsetStudsU = 200,
	OffsetStudsV = 200
})
local flag = true

while not (texture or texture) do
	wait(1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSeaAnimation()
	tween:Play()
	tween.Completed:Wait()
	texture.OffsetStudsU = 0
	texture.OffsetStudsV = 0
end

local function Setup_SeaAnim()
	while texture.Parent and flag do
		setSeaAnimation() -- equivalent call inferred; original call site unknown
		task.wait()
	end
end

if settings_Handler then
	if settings_Handler:GetAttribute("FastMode_Enabled") then
		if flag then
			flag = false

			if tween then
				tween:Cancel()
			end
		end
	else
		if not flag then
			flag = true
		end

		task.spawn(Setup_SeaAnim)
	end

	settings_Handler:GetAttributeChangedSignal("FastMode_Enabled"):Connect(function()
		if settings_Handler:GetAttribute("FastMode_Enabled") then
			if flag then
				flag = false

				if tween then
					tween:Cancel()
				end
			end
		else
			if not flag then
				flag = true
			end

			task.spawn(Setup_SeaAnim)
		end
	end)
end