local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local assets = ReplicatedStorage:WaitForChild("Assets")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local raid_Assets = assets:WaitForChild("Raid_Assets")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local raids = workspace:WaitForChild("Raids")
local startRaid = miscEvents:WaitForChild("StartRaid")
local raidFrame = script.Parent:WaitForChild("RaidFrame")
local wave = raidFrame:WaitForChild("Wave")
local timeLeft = raidFrame:WaitForChild("TimeLeft")
local start_Button = raidFrame:WaitForChild("Start_Button")
local title = start_Button:WaitForChild("Title")
local heart = raidFrame:WaitForChild("Heart")
local heart2 = raidFrame:WaitForChild("Heart2")
local heart3 = raidFrame:WaitForChild("Heart3")
local invisible_Parts = raid_Assets:WaitForChild("Invisible_Parts")
local timeLeftChangedConnection = nil
local tHChangedConnection = nil
local connection = nil
local valueChangedConnection = nil

while localPlayer:GetAttribute("LoadedData") == nil do
	task.wait(0.5)
end

local v2 = UserInputService.TouchEnabled == true or false

local function Format(p)
	return string.format("%02i", p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function convertToHMS(timeLeft2)
	local v3 = (timeLeft2 - timeLeft2 % 60) / 60
	local v4 = timeLeft2 - v3 * 60
	local v5 = v3 - (v3 - v3 % 60) / 60 * 60
	return string.format("%02i", v5) .. ":" .. string.format("%02i", v4)
end

local function Start_Raid()
	if localPlayer:GetAttribute("Raiding") then
		local child = raids:FindFirstChild((`Raid_{localPlayer:GetAttribute("Raiding")}`))

		if child and child:GetAttribute("Force_Start") == false and child:GetAttribute("Current_Wave") == 0 then
			local joiners = child:FindFirstChild("Joiners")

			if joiners and joiners:FindFirstChild(localPlayer.Name) then
				startRaid:FireServer("Start")
				start_Button.Visible = false
			end
		end
	end
end

local function Create_Wall(p: string, parent)
	if p == "Create_Wall" then
		local joiners = parent:FindFirstChild("Joiners")

		if joiners and joiners:FindFirstChild(localPlayer.Name) then
			local clone = invisible_Parts:Clone()
			clone:PivotTo(parent:GetPivot() * CFrame.new(0, 200, 0))
			clone.Parent = parent
		end
	end
end

local function Raid_Changed()
	if localPlayer:GetAttribute("Raiding") then
		local child = raids:FindFirstChild((`Raid_{localPlayer:GetAttribute("Raiding")}`))

		if child then
			local joiners = child:FindFirstChild("Joiners")
			local child2 = joiners and joiners:FindFirstChild(localPlayer.Name)

			if child2 then
				if child2.Value >= 3 then
					heart.Size = UDim2.new(0.01, 0, 1, 0)
					heart2.Size = UDim2.new(0.01, 0, 1, 0)
					heart3.Size = UDim2.new(0.01, 0, 1, 0)
					heart.ImageTransparency = 1
					heart2.ImageTransparency = 1
					heart3.ImageTransparency = 1

					if heart.ImageTransparency ~= 0 then
						TweenService:Create(
							heart,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 0,
								Size = UDim2.new(0.02, 0, 1, 0)
							}
						):Play()
					end

					if heart2.ImageTransparency ~= 0 then
						TweenService:Create(
							heart2,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 0,
								Size = UDim2.new(0.02, 0, 1, 0)
							}
						):Play()
					end

					if heart3.ImageTransparency ~= 0 then
						TweenService:Create(
							heart3,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 0,
								Size = UDim2.new(0.02, 0, 1, 0)
							}
						):Play()
					end
				elseif child2.Value == 2 then
					if heart.ImageTransparency ~= 1 then
						TweenService:Create(
							heart,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end
				elseif child2.Value == 1 then
					if heart.ImageTransparency ~= 1 then
						TweenService:Create(
							heart,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end

					if heart2.ImageTransparency ~= 1 then
						TweenService:Create(
							heart2,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end
				elseif child2.Value <= 0 then
					if heart.ImageTransparency ~= 1 then
						TweenService:Create(
							heart,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end

					if heart2.ImageTransparency ~= 1 then
						TweenService:Create(
							heart2,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end

					if heart3.ImageTransparency ~= 1 then
						TweenService:Create(
							heart3,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.025, 0, 1, 0),
								ImageTransparency = 1
							}
						):Play()
					end
				end

				if timeLeftChangedConnection == nil then
					timeLeftChangedConnection = child:GetAttributeChangedSignal("TimeLeft"):Connect(function()
						if localPlayer:GetAttribute("TH") then
							timeLeft.Text = ("เวลาที่เหลือ : %*"):format(convertToHMS(child:GetAttribute("TimeLeft")))
						else
							timeLeft.Text = ("Time Left: %*"):format(convertToHMS(child:GetAttribute("TimeLeft")))
						end
					end)
				end

				if tHChangedConnection == nil then
					tHChangedConnection = localPlayer:GetAttributeChangedSignal("TH"):Connect(function()
						if child:GetAttribute("Current_Wave") >= 1 then
							if localPlayer:GetAttribute("TH") then
								wave.Text = `ด่านที่ {child:GetAttribute("Current_Wave")}`
							else
								wave.Text = `Wave {child:GetAttribute("Current_Wave")}`
							end
						end
					end)
				end

				if connection == nil then
					connection = child:GetAttributeChangedSignal("Current_Wave"):Connect(function()
						if child:GetAttribute("Current_Wave") > 1 then
							TweenService:Create(
								wave,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TextColor3 = Color3.fromRGB(85, 255, 0)
								}
							):Play()

							if localPlayer:GetAttribute("TH") then
								wave.Text = `ด่านที่ {child:GetAttribute("Current_Wave")}`
							else
								wave.Text = `Wave {child:GetAttribute("Current_Wave")}`
							end

							task.wait(0.2)
							TweenService:Create(
								wave,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TextColor3 = Color3.fromRGB(255, 255, 255)
								}
							):Play()
						end
					end)
				end

				if valueChangedConnection == nil then
					valueChangedConnection = child2:GetPropertyChangedSignal("Value"):Connect(function()
						if child2.Value >= 3 then
							heart.Size = UDim2.new(0.01, 0, 1, 0)
							heart2.Size = UDim2.new(0.01, 0, 1, 0)
							heart3.Size = UDim2.new(0.01, 0, 1, 0)

							if heart.ImageTransparency ~= 0 then
								TweenService:Create(
									heart,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										ImageTransparency = 0,
										Size = UDim2.new(0.02, 0, 1, 0)
									}
								):Play()
							end

							if heart2.ImageTransparency ~= 0 then
								TweenService:Create(
									heart2,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										ImageTransparency = 0,
										Size = UDim2.new(0.02, 0, 1, 0)
									}
								):Play()
							end

							if heart3.ImageTransparency ~= 0 then
								TweenService:Create(
									heart3,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										ImageTransparency = 0,
										Size = UDim2.new(0.02, 0, 1, 0)
									}
								):Play()
							end
						elseif child2.Value == 2 then
							if heart.ImageTransparency ~= 1 then
								TweenService:Create(
									heart,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end
						elseif child2.Value == 1 then
							if heart.ImageTransparency ~= 1 then
								TweenService:Create(
									heart,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end

							if heart2.ImageTransparency ~= 1 then
								TweenService:Create(
									heart2,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end
						elseif child2.Value <= 0 then
							if heart.ImageTransparency ~= 1 then
								TweenService:Create(
									heart,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end

							if heart2.ImageTransparency ~= 1 then
								TweenService:Create(
									heart2,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end

							if heart3.ImageTransparency ~= 1 then
								TweenService:Create(
									heart3,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = UDim2.new(0.025, 0, 1, 0),
										ImageTransparency = 1
									}
								):Play()
							end
						end
					end)
				end
			end

			if not raidFrame.Visible then
				raidFrame.Visible = true
				timeLeft.TextTransparency = 1
				timeLeft.TextStrokeTransparency = 1
				timeLeft.UIStroke.Transparency = 1
				start_Button.Visible = true
				wave.Size = UDim2.new(1, 0, 0.03, 3)

				while child:GetAttribute("Starting") > 0 and localPlayer:GetAttribute("Raiding") do
					if localPlayer:GetAttribute("TH") then
						wave.Text = `เตรียมตัวต่อสู้ ({child:GetAttribute("Starting")})`
					else
						wave.Text = `Intermission ({child:GetAttribute("Starting")})`
					end

					task.wait(0.5)
				end

				TweenService:Create(timeLeft, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0,
					TextStrokeTransparency = 0
				}):Play()
				TweenService:Create(
					timeLeft.UIStroke,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 0
					}
				):Play()
				wave.Size = UDim2.new(1, 0, 0.033, 3)
				start_Button.Visible = false
				timeLeft.Visible = true

				if localPlayer:GetAttribute("TH") then
					timeLeft.Text = ("เวลาที่เหลือ : %*"):format(convertToHMS(child:GetAttribute("TimeLeft")))
				else
					timeLeft.Text = ("Time Left: %*"):format(convertToHMS(child:GetAttribute("TimeLeft")))
				end

				if localPlayer:GetAttribute("TH") then
					wave.Text = "ด่านที่ 1"
				else
					wave.Text = "Wave 1"
				end
			end
		end
	else
		if timeLeftChangedConnection then
			timeLeftChangedConnection:Disconnect()
			timeLeftChangedConnection = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
			valueChangedConnection = nil
		end

		if tHChangedConnection then
			tHChangedConnection:Disconnect()
			tHChangedConnection = nil
		end

		if raidFrame.Visible then
			task.wait(0.2)
			raidFrame.Visible = false
		end
	end
end

Raid_Changed()

if v2 then
	heart.Position = UDim2.new(0.865, 0, 1.45, 0)
	heart2.Position = UDim2.new(0.89, 0, 1.45, 0)
	heart3.Position = UDim2.new(0.915, 0, 1.45, 0)
	local uIStroke = wave:FindFirstChild("UIStroke")
	local uIStroke2 = timeLeft:FindFirstChild("UIStroke")
	local uIStroke3 = title:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Enabled = false
	end

	if uIStroke2 then
		uIStroke2.Enabled = false
	end

	if uIStroke3 then
		uIStroke3.Enabled = false
	end
end

localPlayer:GetAttributeChangedSignal("Raiding"):Connect(Raid_Changed)
startRaid.OnClientEvent:Connect(Create_Wall)
start_Button.Activated:Connect(Start_Raid)