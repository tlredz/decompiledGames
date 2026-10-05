local StarlineCaster = {}
game:GetService("ContentProvider")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Net = require(ReplicatedStorage.packages.Net)
local v = {
	{
		Name = "Cassiopeia",
		Image = "rbxassetid://73667138663205",
		Vertices = {
			{
				x = 0.1,
				y = 0.31
			},
			{
				x = 0.3,
				y = 0.52
			},
			{
				x = 0.52,
				y = 0.46
			},
			{
				x = 0.7,
				y = 0.69
			},
			{
				x = 0.9,
				y = 0.46
			}
		},
		Edges = {
			{
				from = 1,
				to = 2
			},
			{
				from = 2,
				to = 3
			},
			{
				from = 3,
				to = 4
			},
			{
				from = 4,
				to = 5
			}
		}
	},
	{
		Name = "Ursa Major",
		Image = "rbxassetid://80634738860633",
		Vertices = {
			{
				x = 0.07,
				y = 0.18
			},
			{
				x = 0.21,
				y = 0.2
			},
			{
				x = 0.28,
				y = 0.26
			},
			{
				x = 0.37,
				y = 0.33
			},
			{
				x = 0.36,
				y = 0.43
			},
			{
				x = 0.29,
				y = 0.54
			},
			{
				x = 0.36,
				y = 0.68
			},
			{
				x = 0.48,
				y = 0.82
			},
			{
				x = 0.52,
				y = 0.8
			},
			{
				x = 0.52,
				y = 0.48
			},
			{
				x = 0.57,
				y = 0.39
			},
			{
				x = 0.79,
				y = 0.45
			},
			{
				x = 0.93,
				y = 0.52
			},
			{
				x = 0.72,
				y = 0.52
			},
			{
				x = 0.68,
				y = 0.61
			},
			{
				x = 0.73,
				y = 0.68
			},
			{
				x = 0.83,
				y = 0.78
			},
			{
				x = 0.8,
				y = 0.8
			}
		},
		Edges = {
			{
				from = 1,
				to = 2
			},
			{
				from = 2,
				to = 3
			},
			{
				from = 3,
				to = 4
			},
			{
				from = 4,
				to = 5
			},
			{
				from = 4,
				to = 11
			},
			{
				from = 5,
				to = 10
			},
			{
				from = 10,
				to = 11
			},
			{
				from = 5,
				to = 6
			},
			{
				from = 6,
				to = 7
			},
			{
				from = 7,
				to = 8
			},
			{
				from = 8,
				to = 9
			},
			{
				from = 11,
				to = 12
			},
			{
				from = 12,
				to = 13
			},
			{
				from = 12,
				to = 14
			},
			{
				from = 14,
				to = 15
			},
			{
				from = 15,
				to = 16
			},
			{
				from = 16,
				to = 17
			},
			{
				from = 16,
				to = 18
			}
		}
	},
	{
		Name = "Crux",
		Image = "rbxassetid://100682018025408",
		Vertices = {
			{
				x = 0.31,
				y = 0.51
			},
			{
				x = 0.46,
				y = 0.22
			},
			{
				x = 0.69,
				y = 0.35
			},
			{
				x = 0.61,
				y = 0.78
			}
		},
		Edges = {
			{
				from = 1,
				to = 3
			},
			{
				from = 2,
				to = 4
			}
		}
	},
	{
		Name = "Lyra",
		Image = "rbxassetid://102285776967282",
		Vertices = {
			{
				x = 0.62,
				y = 0.22
			},
			{
				x = 0.53,
				y = 0.37
			},
			{
				x = 0.39,
				y = 0.45
			},
			{
				x = 0.5,
				y = 0.71
			},
			{
				x = 0.37,
				y = 0.78
			}
		},
		Edges = {
			{
				from = 1,
				to = 2
			},
			{
				from = 2,
				to = 3
			},
			{
				from = 2,
				to = 4
			},
			{
				from = 3,
				to = 5
			},
			{
				from = 4,
				to = 5
			}
		}
	},
	{
		Name = "Orion",
		Image = "rbxassetid://103681841500594",
		Vertices = {
			{
				x = 0.37,
				y = 0.18
			},
			{
				x = 0.32,
				y = 0.19
			},
			{
				x = 0.28,
				y = 0.31
			},
			{
				x = 0.3,
				y = 0.3
			},
			{
				x = 0.33,
				y = 0.4
			},
			{
				x = 0.37,
				y = 0.45
			},
			{
				x = 0.47,
				y = 0.4
			},
			{
				x = 0.53,
				y = 0.47
			},
			{
				x = 0.5,
				y = 0.61
			},
			{
				x = 0.47,
				y = 0.64
			},
			{
				x = 0.45,
				y = 0.65
			},
			{
				x = 0.41,
				y = 0.82
			},
			{
				x = 0.59,
				y = 0.78
			},
			{
				x = 0.67,
				y = 0.57
			},
			{
				x = 0.7,
				y = 0.56
			},
			{
				x = 0.72,
				y = 0.49
			},
			{
				x = 0.72,
				y = 0.45
			},
			{
				x = 0.71,
				y = 0.42
			}
		},
		Edges = {
			{
				from = 1,
				to = 2
			},
			{
				from = 2,
				to = 3
			},
			{
				from = 3,
				to = 4
			},
			{
				from = 4,
				to = 5
			},
			{
				from = 5,
				to = 6
			},
			{
				from = 6,
				to = 7
			},
			{
				from = 6,
				to = 8
			},
			{
				from = 7,
				to = 8
			},
			{
				from = 8,
				to = 9
			},
			{
				from = 9,
				to = 10
			},
			{
				from = 10,
				to = 11
			},
			{
				from = 11,
				to = 12
			},
			{
				from = 12,
				to = 13
			},
			{
				from = 8,
				to = 16
			},
			{
				from = 14,
				to = 15
			},
			{
				from = 15,
				to = 16
			},
			{
				from = 16,
				to = 17
			},
			{
				from = 17,
				to = 18
			}
		}
	}
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo6 = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
local uDim = UDim2.fromOffset(48, 48)
local uDim2 = UDim2.fromOffset(64, 64)
local color = Color3.fromRGB(255, 255, 150)

-- equivalent calls inferred from this helper; original call sites unknown
local function isConsole()
	local success, result = pcall(function()
		return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	end)
	return success and result == true
end

local function buildConstellation(constellationOverlay, data, uDim3)
	local absoluteSize = constellationOverlay.AbsoluteSize
	local scale = uDim3.X.Scale
	local v2 = math.min(absoluteSize.X, absoluteSize.Y) * scale
	local clone = script.ConstellationFrame:Clone()
	clone.Name = "Constellation_" .. data.Name
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.fromScale(0.5, 0.5)
	clone.Size = UDim2.fromOffset(v2, v2)
	clone.BackgroundTransparency = 1

	for _, child in clone:GetChildren() do
		if not (child:IsA("UIAspectRatioConstraint") or child:IsA("UIPadding") or child:IsA("UIListLayout")) then
			continue
		end

		child:Destroy()
	end

	clone.Parent = constellationOverlay
	local clones = {}
	local clones2 = {}

	for k, v3 in data.Vertices do
		local clone2 = script.VertexDot:Clone()
		clone2.Name = "Vertex" .. k
		clone2.AnchorPoint = Vector2.new(0.5, 0.5)
		clone2.Size = uDim
		clone2.Position = UDim2.fromScale(v3.x, v3.y)
		clone2.Parent = clone
		clones[k] = clone2
	end

	for k, edge in data.Edges do
		local v3 = data.Vertices[edge.from]
		local v4 = data.Vertices[edge.to]
		local v5 = v4.x - v3.x
		local v6 = v4.y - v3.y
		local v7 = math.sqrt(v5 * v5 + v6 * v6)
		local v8 = math.atan2(v6, v5)
		local midpointX = (v3.x + v4.x) / 2
		local midpointY = (v3.y + v4.y) / 2
		local clone2 = script.EdgeLine:Clone()
		clone2.Name = "Edge_" .. edge.from .. "_" .. edge.to
		clone2.AnchorPoint = Vector2.new(0.5, 0.5)
		clone2.Size = UDim2.new(v7, 0, 0, 3)
		clone2.Position = UDim2.fromScale(midpointX, midpointY)
		clone2.Rotation = math.deg(v8)
		clone2.Parent = clone
		clones2[k] = clone2
	end

	return clone, clones, clones2
end

function StarlineCaster.Morph(p, parent, object)
	object:Preload(script:GetChildren())
	local config = p.config
	local random = object:GetRandom(7)

	if isConsole() then
		GuiService.AutoSelectGuiEnabled = false
		p.reelTrove:Add(function()
			GuiService.AutoSelectGuiEnabled = true
		end)
	end

	task.spawn(function()
		object:WaitUntilReady()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local clone = script.Overlay:Clone()
		clone.DisplayOrder = 100
		clone.Parent = playerGui
		p.reelTrove:Add(clone)
		local constellationOverlay = clone.ConstellationOverlay
		object.logicTweens:Create(constellationOverlay, tweenInfo4, {
			BackgroundTransparency = 0.5
		}):Play()
		local v2 = math.clamp((object.resilience or 50) / config.ResilienceFactor, 1, 5)
		local v3 = math.ceil(config.BaseConstellationsNeeded * v2)
		local count = 0

		while object.active and count < v3 do
			if count > 0 then
				object:WaitLogic(config.ConstellationInterval)

				if not object.active then
					break
				end
			end

			local v4 = v[random:NextInteger(1, #v)]
			local constellation, v5, v6 = buildConstellation(
				constellationOverlay,
				v4,
				UDim2.fromScale(config.ConstellationSize, config.ConstellationSize)
			)

			for _, v7 in v5 do
				v7.ImageTransparency = 0
			end

			local v7 = {}
			local v8 = #v4.Vertices
			local count2 = 0
			local flag = false
			local maid = p.reelTrove:Extend()

			local function onVertexHit(p2)
				if v7[p2] then
					return
				end

				v7[p2] = true
				count2 += 1
				local v14 = v5[p2]
				v14.ImageColor3 = color
				object.logicTweens:Create(v14, tweenInfo2, {
					Size = uDim2
				}):Play()

				for k, edge in v4.Edges do
					local to = nil

					if edge.from == p2 and v7[edge.to] then
						to = edge.to
					elseif edge.to == p2 and v7[edge.from] then
						to = edge.from
					end

					if to then
						object.logicTweens:Create(v6[k], tweenInfo3, {
							BackgroundTransparency = 0.2
						}):Play()
					end
				end

				local starHit = script:FindFirstChild("StarHit")

				if starHit then
					local clone2 = starHit:Clone()
					clone2.PlaybackSpeed = count2 / v8 * 0.4 + 0.9
					clone2.Parent = script
					clone2:Play()
					task.delay(2, function()
						clone2:Destroy()
					end)
				end

				object:AddProgress(config.ProgressPerVertex)
				Net:RemoteEvent("StarlineVertexHit"):FireServer()
				local fish = parent:FindFirstChild("fish")

				if fish then
					local clone2 = script.FallingStar:Clone()
					clone2.Position = UDim2.fromScale(fish.Position.X.Scale, -0.2)
					clone2.Rotation = random:NextNumber(-30, 30)
					clone2.Parent = parent
					local position = fish.Position
					local v15 = object.logicTweens:Create(clone2, tweenInfo, {
						Position = position,
						Rotation = clone2.Rotation + random:NextNumber(-60, 60)
					})
					v15.Completed:Once(function()
						object.fx:SpawnShake(parent, 0.15, 2, 0.01, false)
						local v16 = object.logicTweens:Create(clone2, tweenInfo6, {
							Size = UDim2.fromOffset(40, 40),
							ImageTransparency = 1
						})
						v16.Completed:Once(function()
							clone2:Destroy()
						end)
						v16:Play()
					end)
					v15:Play()
				end

				if v8 <= count2 then
					flag = true
				end
			end

			local v14 = false
			local v15 = v4
			local v16 = v7

			local function getAvailableVertices()
				local result = {}

				if count2 > 0 then
					for k, edge in v15.Edges do
						if v16[edge.from] and not v16[edge.to] then
							result[edge.to] = true
						elseif v16[edge.to] and not v16[edge.from] then
							result[edge.from] = true
						end
					end
				end

				return result
			end

			local v18 = v4
			local v19 = v7
			local onVertexHit2 = onVertexHit

			local function checkVertexCollision(p2, items)
				if not (constellation and constellation.Parent) then
					return
				end

				local v20 = next(items) ~= nil
				local absolutePosition = constellation.AbsolutePosition
				local absoluteSize = constellation.AbsoluteSize

				for k, v21 in v18.Vertices do
					if v19[k] or not (not v20 or items[k]) then
						continue
					end

					local v22 = absolutePosition.X + v21.x * absoluteSize.X
					local v23 = absolutePosition.Y + v21.y * absoluteSize.Y
					local v24 = p2.X - v22
					local v25 = p2.Y - v23

					if not (math.sqrt(v24 * v24 + v25 * v25) <= config.VertexHitRadius * math.min(
						absoluteSize.X,
						absoluteSize.Y
					)) then
						continue
					end

					onVertexHit2(k)
				end
			end

			local success, result = pcall(function()
				return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
			end)
			local vector, imageLabel

			if success and result == true then
				local viewportSize = workspace.CurrentCamera.ViewportSize
				vector = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
				imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "GamepadCursor"
				imageLabel.Image = "rbxasset://textures/ArrowFarCursor.png"
				imageLabel.BackgroundTransparency = 1
				imageLabel.Size = UDim2.fromOffset(32, 32)
				imageLabel.ZIndex = 100
				imageLabel.Position = UDim2.fromOffset(vector.X, vector.Y)
				imageLabel.Parent = clone
				maid:Add(imageLabel)
			else
				imageLabel = nil
				vector = nil
			end

			maid:Add(UserInputService.InputBegan:Connect(function(input, _)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					v14 = true
				end
			end))
			maid:Add(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					v14 = false
				end
			end))
			local getAvailableVertices2 = getAvailableVertices
			local v20 = v5
			local v21 = v7
			local checkVertexCollision2 = checkVertexCollision
			maid:Add(object.OnLogicStep:Connect(function(p2)
				local v22 = getAvailableVertices2()

				if next(v22) ~= nil then
					for k, v23 in v20 do
						if not v21[k] then
							v23.ImageTransparency = v22[k] and 0 or 0.6
						end
					end
				end

				if imageLabel then
					local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
					local X = 0
					local v23 = 0

					for k, v25 in gamepadState do
						if v25.KeyCode ~= Enum.KeyCode.Thumbstick1 then
							continue
						end

						X = v25.Position.X
						v23 = -v25.Position.Y
						break
					end

					local v25 = math.abs(X) < 0.15 and 0 or X
					local v26 = math.abs(v23) < 0.15 and 0 or v23
					local viewportSize = workspace.CurrentCamera.ViewportSize
					vector = Vector2.new(
						math.clamp(vector.X + v25 * 600 * p2, 0, viewportSize.X),
						(math.clamp(vector.Y + v26 * 600 * p2, 0, viewportSize.Y))
					)
					imageLabel.Position = UDim2.fromOffset(vector.X, vector.Y)

					if (v25 ~= 0 or v26 ~= 0) and not flag then
						checkVertexCollision2(vector, v22)
					end
				else
					if not v14 or flag then
						return
					end

					checkVertexCollision2(UserInputService:GetMouseLocation() - GuiService:GetGuiInset(), v22)
				end
			end))
			local lastTime = os.clock()

			while object.active and not (flag or os.clock() - lastTime > config.ConstellationDuration) do
				object:WaitLogic(0.05)
			end

			for _, v22 in v5 do
				object.logicTweens:Create(v22, tweenInfo5, {
					ImageTransparency = 1
				}):Play()
			end

			for _, v22 in v6 do
				object.logicTweens:Create(v22, tweenInfo5, {
					BackgroundTransparency = 1
				}):Play()
			end

			local v22 = constellation
			object:DelayLogic(0.5, function()
				v22:Destroy()
			end)
			maid:Clean()

			if flag then
				count += 1
			end
		end

		object.logicTweens:Create(constellationOverlay, tweenInfo5, {
			BackgroundTransparency = 1
		}):Play()
	end)
end

setmetatable(StarlineCaster, module)
return StarlineCaster