local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToyShelfClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {
	["Deer Buddy"] = "Deer",
	["Hungry Deer Buddy"] = "HungryDeer"
}
local v2 = nil
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
ContextActionService:BindActionAtPriority("CloseToyShelf", function(_, p, _)
	local toyShelf = Client.Interface.ToyShelf

	if not toyShelf.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	toyShelf.Visible = false
	GamepadService:DisableGamepadCursor()
	Client.Sound.Play("CloseButton")
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)

function InitiateToyShelf(instance)
	v2 = instance
	local v3 = {}
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent or parent:GetAttribute("Owner") and parent:GetAttribute("Owner") ~= localPlayer.UserId or v3[parent] or parent:GetAttribute("Destroyed") then
			return
		end

		local v4 = nil

		for k, v5 in pairs(v) do
			if parent.Name == k then
				v4 = v5
			end
		end

		if v4 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function undo()
				v3[parent] = nil
				parent.Parent = workspace.Items
			end

			v3[parent] = true
			parent.Parent = game.ReplicatedStorage.TempStorage
			local v5 = Client.Events.RequestAddToy:InvokeServer(parent, instance)

			if v5 and v5.Success then
				v3[parent] = nil
			else
				task.spawn(function()
					wait(0.5)
					undo() -- equivalent call inferred; original call site unknown
				end)
			end
		end
	end)
end

local v3 = {}
local transparenciesByEmitter = {}

function SetParticleTransparency(list, value)
	local v4 = math.clamp(value, 0, 1)

	for _, emitter in ipairs(list) do
		if not transparenciesByEmitter[emitter] then
			transparenciesByEmitter[emitter] = emitter.Transparency
		end

		if not (emitter:IsA("ParticleEmitter") and transparenciesByEmitter[emitter]) then
			continue
		end

		local keypoints = transparenciesByEmitter[emitter].Keypoints
		local numberSequenceKeypoints = {}

		for _, keypoint in ipairs(keypoints) do
			local v5 = keypoint.Value * (1 - v4) + v4
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v5, keypoint.Envelope))
		end

		emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end
end

function PassiveGlow(p, items, p2)
	if v3[p] and v3[p] == p2 or p2 < 3 then
		return
	end

	v3[p] = p2

	for _, item in pairs(items) do
		if not (item.PrimaryPart and item.PrimaryPart:FindFirstChild("DraggingAttachment")) then
			break
		end

		if #item.PrimaryPart.DraggingAttachment:GetChildren() == 0 then
			for _, child in pairs(ReplicatedStorage.Assets.Particles.ToyShelf.PassiveGlow:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = item.PrimaryPart.DraggingAttachment
			end
		end

		for _, emitter in pairs(item.PrimaryPart.DraggingAttachment:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if p2 == 3 then
				SetParticleTransparency({ emitter }, 0.75)
			elseif p2 == 4 then
				SetParticleTransparency({ emitter }, 0.6)
			elseif p2 == 5 then
				SetParticleTransparency({ emitter }, 0.4)
				emitter.Color = ColorSequence.new(Color3.fromRGB(191, 0, 255))
			end

			emitter.Enabled = true
		end
	end
end

local v4 = {}
Client.Events.ToyShelfVFX:Connect(function(list, p)
	if not (v2 and list and p) then
		return
	end

	local child = v2:FindFirstChild(list .. "Shelf")

	if not child then
		return
	end

	local children = {}

	for _, child2 in pairs(child:GetChildren()) do
		if string.sub(child2.Name, 1, #list) == list then
			table.insert(children, child2)
		end
	end

	if #children == 0 then
		return
	end

	for _, v5 in pairs(children) do
		print(v5.Name)
		print(list)
		print((string.sub(v5.Name, #list)))
		tonumber((string.sub(v5.Name, #list + 1)))
		Client.Utility.SpawnParticles("ToyLevel" .. p, v5:GetPivot())
	end

	PassiveGlow(list, children, p)

	if not v4[p] then
		v2.TouchZone.Squeak:Play()

		if v2.TouchZone:FindFirstChild("Level" .. p) then
			v2.TouchZone:FindFirstChild("Level" .. p):Play()
		end
	end
end)
Client.Events.SetToyGui:Connect(function(p, p2, text)
	local v5 = v[p]
	local child = Client.Interface.ToyShelf.FrameHolder:FindFirstChild(v5 .. "Frame")

	if not child then
		print("NO FRAME EXISTS")
		return
	end

	child.Title.Text = p .. " (" .. p2 .. "/5)"
	child.Description.Text = text

	for i = 1, 5 do
		local child2 = child.Frame:FindFirstChild("plushy" .. i)

		if child2 and i <= p2 then
			child2.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

function ToyShelfClient.ToggleToyShelf()
	local toyShelf = Client.Interface.ToyShelf
	toyShelf.Visible = not toyShelf.Visible
	Client.Sound.Play("CloseButton")

	if toyShelf.Visible and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		GamepadService:EnableGamepadCursor(toyShelf)
	end
end

function InitiateButtons()
	local toyShelf = Client.Interface.ToyShelf
	toyShelf.CloseButton.Activated:Connect(function()
		toyShelf.Visible = false
		Client.Sound.Play("CloseButton")
	end)
end

function ToyShelfClient.Init()
	task.spawn(function()
		InitiateButtons()
	end)
end

Client.Utility.ForAllTagged("ToyShelf", InitiateToyShelf)
return ToyShelfClient