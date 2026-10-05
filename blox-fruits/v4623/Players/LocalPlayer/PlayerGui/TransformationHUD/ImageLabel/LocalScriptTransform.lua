local localPlayer = game.Players.LocalPlayer
local race = localPlayer:WaitForChild("Data"):WaitForChild("Race")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local v = {
	Skypiea = Color3.fromRGB(255, 210, 50),
	Human = Color3.fromRGB(217, 0, 3),
	Cyborg = Color3.fromRGB(255, 130, 251),
	Ghoul = Color3.fromRGB(33, 0, 0),
	Fishman = Color3.fromRGB(0, 90, 255),
	Mink = Color3.fromRGB(90, 255, 90),
	Draco = Color3.fromRGB(255, 94, 0)
}
parent.Visible = false
parent.ImageTransparency = 1
local connections = {}

local function onChar(character)
	parent.Visible = false
	parent.ImageTransparency = 1

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	local raceEnergy = character:WaitForChild("RaceEnergy", 5)
	local raceTransformed = character:WaitForChild("RaceTransformed", 5)

	if not (character and character.Parent and character:IsDescendantOf(workspace)) then
		return
	end

	local function hook(raceEnergy2, raceTransformed2)
		local flag = false
		table.insert(connections, raceEnergy2:GetPropertyChangedSignal("Value"):Connect(function()
			if raceTransformed2.Value then
				return
			end

			if raceEnergy2.Value >= 1 then
				if not flag then
					flag = true
					parent.Visible = true
					parent.Image = "http://www.roblox.com/asset/?id=7299611278"
					TweenService:Create(parent, TweenInfo.new(1), {
						ImageTransparency = 0.6,
						ImageColor3 = v[race.Value]
					}):Play()
				end
			else
				if flag then
					local tween = TweenService:Create(parent, TweenInfo.new(1), {
						ImageTransparency = 1
					})
					tween.Completed:Connect(function()
						parent.Visible = false
					end)
					tween:Play()
				end

				flag = false
			end
		end))
		table.insert(connections, raceTransformed2:GetPropertyChangedSignal("Value"):Connect(function()
			flag = false
			wait(0.1)

			if raceTransformed2.Value then
				parent.Visible = true
				parent.Image = "http://www.roblox.com/asset/?id=7299611278"
				TweenService:Create(parent, TweenInfo.new(2.5), {
					ImageTransparency = 0.5,
					ImageColor3 = v[race.Value]
				}):Play()
			else
				local tween = TweenService:Create(parent, TweenInfo.new(2.5), {
					ImageTransparency = 1
				})
				tween.Completed:Connect(function()
					parent.Visible = false
				end)
				tween:Play()
			end
		end))
	end

	if raceEnergy and raceTransformed then
		hook(raceEnergy, raceTransformed)
	else
		local function check()
			if raceEnergy and raceTransformed then
				for _, connection in pairs(connections) do
					connection:Disconnect()
				end

				connections = {}
				hook(raceEnergy, raceTransformed)
			end
		end

		table.insert(connections, character.ChildAdded:Connect(function(child)
			if child.Name == "RaceTransformed" then
				raceTransformed = child
				check()
			elseif child.Name == "RaceEnergy" then
				raceEnergy = child
				check()
			end
		end))
	end
end

localPlayer.CharacterAdded:Connect(onChar)

if localPlayer.Character then
	onChar(localPlayer.Character)
end