local ViewportFrame = require(script.Parent.ViewportFrame)
local ObjectRefMap = require(script.Parent.ObjectRefMap)
local worldProps = require(script.Parent.Implementations.worldProps)
require(script.Parent.createInstanceCopy)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local GuiService = game:GetService("GuiService")
local guiInset, _ = GuiService:GetGuiInset()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and UserInputService.MouseEnabled == false

local function withinCone(p, ...)
	if not p then
		return
	end

	local v2, v3, v4, v5, v6 = ...
	local vector = p - v2
	local dot = vector:Dot(v3)
	local v7

	if dot <= v5 then
		v7 = dot >= 0
	else
		v7 = false
	end

	local v8 = dot / v5 * v4
	local magnitude = (vector - v3 * dot).Magnitude
	local v9 = v7 and magnitude <= v8

	if v6 then
		local clone = game.ReplicatedStorage["Ope-Ope"].Effects.Cone:Clone()
		clone.CFrame = CFrame.new(v2, v2 + v3) * CFrame.new(0, 0, -v5 / 2) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Color = v9 and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
		clone.Transparency = 0.5
		clone.Mesh.Scale = Vector3.new(2 * v4, v5, 2 * v4) / 50
		clone.Parent = workspace._WorldOrigin
		delay(1, function()
			clone:Destroy()
		end)
	end

	return v9 and workspace:FindPartOnRayWithWhitelist(Ray.new(v2, vector), { workspace.Map }) == nil
end

local Renderer = {}
Renderer.__index = Renderer

local function onAddedToStack(data, p, p2)
	local v2 = ObjectRefMap.fromModel(p.target, p2)
	local v3 = ViewportFrame.withReferences(v2)
	v3.dot.ImageColor3 = p.color
	v3.rbx.FillColor = p.color

	if typeof(v3.rbx) == "Instance" then
		v3.rbx:SetAttribute("__FillColor", p.color)
	end

	v3.rbx.OutlineColor = p.color
	local humanoid = v2.worldModel:FindFirstChild("Humanoid")
	local charName

	if humanoid and humanoid.DisplayName ~= "" then
		charName = humanoid.DisplayName
	else
		charName = v2.worldModel.Name
	end

	v3.charName = charName
	v3.player = game.Players:GetPlayerFromCharacter(v2.worldModel)

	if humanoid and v3.player then
		v3.charName = v2.worldModel.Name .. (string.match(humanoid.DisplayName or "", " .*") or "")
		local CollectionService = game:GetService("CollectionService")
		v3.lockOn = CollectionService:HasTag(localPlayer.Character, "KenUpgrade")
	end

	if not p2 then
		v3.connection = v2.worldModel.DescendantAdded:Connect(function(_) end)
		v3.connection2 = v2.worldModel.DescendantRemoving:Connect(function(_) end)

		if data.onAddedImpl then
			for k, v5 in pairs(v2.map) do
				data.onAddedImpl(k, v5, p)
			end
		end
	end

	v3:requestParent(data.targetScreenGui)
	data._viewportMap[p] = v3
end

local function onRemovedFromStack(p, p2)
	if p.onRemovedImpl then
		local reference = p._viewportMap[p2]:getReference()

		for k, v2 in pairs(reference.map) do
			p.onRemovedImpl(k, v2, p2)
		end
	end

	local v2 = p._viewportMap[p2]

	if v2.connection and v2.connection2 then
		v2.connection:Disconnect()
		v2.connection2:Disconnect()
	end

	v2:requestParent(nil)
	v2:destruct()
	p._viewportMap[p2] = nil
end

function Renderer:new()
	assert(self, "Renderer.new must be provided with a targetScreenGui.")
	local v2 = {
		_stack = {},
		_viewportMap = {},
		targetScreenGui = self
	}
	setmetatable(v2, Renderer)
	self.IgnoreGuiInset = true
	return v2:withRenderImpl(worldProps)
end

function Renderer:withRenderImpl(callback)
	local v2 = callback()
	self.onAddedImpl = v2.onAdded
	self.onRemovedImpl = v2.onRemoved
	self.onBeforeRenderImpl = v2.onBeforeRender
	self.onRenderImpl = v2.onRender
	return self
end

function Renderer:addToStack(p2)
	if self._viewportMap[p2] then
		return
	end

	table.insert(self._stack, p2)
	onAddedToStack(self, p2, true)
end

function Renderer:removeFromStack(p2)
	local flag = false

	for i = #self._stack, 1, -1 do
		if p2 ~= self._stack[i] then
			continue
		end

		table.remove(self._stack, i)
		flag = true
		break
	end

	if flag then
		onRemovedFromStack(self, p2)
	end
end

function Renderer:step(_)
	if not self.onRenderImpl then
		return
	end

	local cFrame = workspace.CurrentCamera.CFrame
	local magnitude = workspace.CurrentCamera.ViewportSize.Magnitude
	local position = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart.Position or cFrame.p

	for i = #self._stack, 1, -1 do
		local v2 = self._stack[i]
		local v3 = self._viewportMap[v2]
		local objectRef = v3.objectRef
		local isA = objectRef.worldModel:IsA("Model")
		local primaryPart

		if isA then
			primaryPart = objectRef.worldModel.PrimaryPart
		else
			primaryPart = objectRef.worldModel
		end

		if not primaryPart then
			continue
		end

		local v4 = not isA and {
			NameDisplayDistance = 0
		} or objectRef.worldModel:FindFirstChild("Humanoid") or {
			NameDisplayDistance = 0
		}
		local cFrame2 = primaryPart.CFrame
		v3.dot.ImageColor3 = v2.color
		local worldToScreenPoint, v5 = currentCamera:WorldToScreenPoint(cFrame2.p)

		if v5 and worldToScreenPoint.Z > 0 then
			if (v == false and (worldToScreenPoint.Z < 80 or (position - cFrame2.p).Magnitude < v4.NameDisplayDistance) or objectRef.worldModel == localPlayer.Character) and objectRef.worldModel:IsA("Model") then
				if objectRef.rbx and typeof(objectRef.rbx) ~= "table" then
					for k, v6 in pairs(objectRef.map) do
						v6.CFrame = k.CFrame
					end

					v3.dot.Visible = false
					v3.name.Visible = false
				else
					v3:requestParent(nil)
					v3:destruct()
					onAddedToStack(self, v2)
					break
				end
			else
				local v6 = 2.5 + primaryPart.Size.Y / 2 * 2.5
				local uDim = UDim2.new(0, worldToScreenPoint.X, 0, worldToScreenPoint.Y + guiInset.Y)
				local dot = v3.dot
				local name = v3.name
				dot.Position = uDim

				if v3.lockOn and objectRef.worldModel:GetAttribute("InCombat") and cFrame.LookVector:Dot(cFrame2.LookVector) > 0 and withinCone(
					cFrame2.p,
					position,
					cFrame.LookVector,
					magnitude * 0.2,
					350
				) then
					dot.Image = "http://www.roblox.com/asset/?id=429500449"
					dot.Size = UDim2.new(0, v6 * 3.5, 0, v6 * 3.5)
				else
					dot.Image = "rbxassetid://2091181653"
					dot.Size = UDim2.new(0, v6, 0, v6)
				end

				if objectRef.worldModel:IsA("Model") then
					dot.Visible = true
					name.Visible = true
				elseif worldToScreenPoint.Z < 900 then
					dot.Visible = true
					name.Visible = true
				else
					dot.Visible = false
					name.Visible = false
				end

				name.TextSize = v6 * 2.5
				name.Position = uDim - UDim2.new(0, 0, 0, v6 * 2)
				name.Text = v2.displayName or v3.charName
				name.AutoLocalize = Players:GetPlayerFromCharacter(objectRef.worldModel) == nil
			end
		else
			v3.dot.Visible = false
			v3.name.Visible = false
		end

		local rbx = v3.rbx
		rbx.Enabled = worldToScreenPoint.Z < 600 and worldToScreenPoint.Z >= 0 and objectRef.worldModel:IsA("Model")

		if v3.rbx.Enabled and (not objectRef.rbx or typeof(objectRef.rbx) == "table") then
			v3:requestParent(nil)
			v3:destruct()
			onAddedToStack(self, v2)
			break
		elseif v3.dot.Image == "rbxassetid://2091181653" and v3.rbx.Enabled then
			v3.dot.Visible = false
		end
	end
end

return Renderer