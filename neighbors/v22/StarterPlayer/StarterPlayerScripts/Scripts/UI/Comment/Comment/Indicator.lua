local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local Comment = require(ReplicatedStorage.Assets.Data.Comment)
require(ReplicatedStorage.Assets.Data.Comment.Types)
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local folder = Instance.new("Folder", workspace)
folder.Name = "CommentIndicators"

-- equivalent calls inferred from this helper; original call sites unknown
local function random(p: number, p2: number)
	return math.random() * (p2 - p) + p
end

local function nrandom(p: number, p2: number)
	return random(p, p2) * (math.random(0, 1) == 1 and 1 or -1)
end

local function displayIndicator(position: Vector3, text: string, color: Color3, duration: number)
	local clone = script.Indicator:Clone()
	clone.CFrame = CFrame.new(
		position + Vector3.new(
			(math.random() * 1 + 0) * (math.random(0, 1) == 1 and 1 or -1),
			1,
			(math.random() * 1 + 0) * (math.random(0, 1) == 1 and 1 or -1)
		),
		currentCamera.CFrame.Position
	)
	clone.UI.Text.Text = text
	clone.UI.Text.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	clone.UI.Text.Rotation = 0
	clone.UI.Size = UDim2.fromScale(3, 0.2)
	TweenService:Create(clone.UI, TweenInfo.new(0.25), {
		Size = UDim2.fromScale(3, 0.45)
	}):Play()
	task.delay(duration - 1, function()
		TweenService:Create(clone.UI.Text, TweenInfo.new(0.3), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(clone.UI.Text.UIStroke, TweenInfo.new(0.3), {
			Transparency = 1
		}):Play()
	end)
	clone.Parent = folder
	task.delay(duration, function()
		clone:Destroy()
	end)
	task.spawn(function()
		local v = (currentCamera.CFrame.RightVector * ((math.random() * 0 + 1) * (math.random(0, 1) == 1 and 1 or -1)) + createVector(
			0,
			1,
			0
		)) * 50
		local total = 0
		local v2 = createVector(0, 0, 0)

		while clone:IsDescendantOf(workspace) do
			local RunService = game:GetService("RunService")
			local v3 = RunService.RenderStepped:Wait()

			if total < 0.1 then
				v2 += v * v3
			else
				v2 *= 1 - v3 * 20
			end

			total += v3
			clone.CFrame += v2 * v3
		end
	end)
end

Network:listen("Comment/AddedComment", function(data)
	if data.Sender and data.Receiver then
		local currentHouse = House:GetCurrentHouse()

		if not currentHouse or (House:GetHouseFromPlayer(data.Sender) ~= currentHouse or House:GetHouseFromPlayer(data.Receiver) ~= currentHouse) then
			return
		end

		if data.Receiver.Character and data.Receiver.Character.PrimaryPart then
			local commentStyle = Comment:GetCommentStyle(data.CommentType)
			local color = data.IsNegative and Color3.fromRGB(255, 0, 0) or commentStyle.Color
			local commentValueString = Comment:GetCommentValueString(data.CommentType, data.IsNegative, 0)
			displayIndicator(data.Receiver.Character.PrimaryPart.Position, `{commentValueString} Rep`, color, 5)
		end
	end
end)