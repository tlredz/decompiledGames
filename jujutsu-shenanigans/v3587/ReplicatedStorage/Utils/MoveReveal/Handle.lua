local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local item = script:WaitForChild("Item")
local moveset = parent:WaitForChild("Moveset")
local parent2 = parent.Parent.Parent
Players:GetPlayerFromCharacter(parent2)
local v = {}

local function createItem(numberValue, moveset2)
	if not numberValue:IsA("NumberValue") or moveset:FindFirstChild(numberValue.Name) or v[numberValue] then
		return
	end

	local clone = item:Clone()
	clone.Name = numberValue.Name
	clone.Parent = moveset
	v[numberValue] = {}

	if numberValue:GetAttribute("Key") then
		clone.LayoutOrder = numberValue:GetAttribute("Key")
		clone.Key.Key.Text = numberValue:GetAttribute("Key")
	end

	local ancestryChangedConnection = nil
	ancestryChangedConnection = numberValue.AncestryChanged:Connect(function()
		if numberValue.Parent == moveset2 then
			clone.Parent = moveset
			return
		end

		if numberValue.Parent then
			clone.Parent = numberValue
			return
		end

		clone:Destroy()
		v[numberValue] = nil
		ancestryChangedConnection:Disconnect()
	end)

	if numberValue:GetAttribute("LastUse") then
		numberValue:GetAttributeChangedSignal("LastUse"):Connect(function()
			v[numberValue][1] = numberValue:GetAttribute("ReadyAt") or 0
			local v2 = v[numberValue][1] - workspace:GetServerTimeNow()
			local v3

			repeat
				v3 = v[numberValue][1] - workspace:GetServerTimeNow()
				local v4 = math.clamp(v3 / v2, 0, 1)
				clone.Cooldown.Size = UDim2.new(1, 0, v4, 0)
				task.wait()
			until v3 <= 0 or not (numberValue.Parent and clone.Parent and v[numberValue])

			if clone.Parent and v[numberValue] and v[numberValue][1] then
				if v3 <= 0 then
					v[numberValue][1] = nil
				end

				clone.Cooldown.Size = UDim2.new(1, 0, 0, 0)
				clone.BackgroundColor3 = Color3.new(1, 1, 1)
				TweenService:Create(clone, TweenInfo.new(1), {
					BackgroundColor3 = Color3.fromRGB(31, 31, 31)
				}):Play()
			end
		end)

		if v[numberValue] and v[numberValue][1] then
			numberValue:SetAttribute("LastUse", workspace:GetServerTimeNow())
		end
	end
end

local moveset2 = parent2:WaitForChild("Moveset")

if #moveset2:GetChildren() > 0 then
	for _, child in moveset2:GetChildren() do
		createItem(child, moveset2)
	end
end

moveset2.ChildAdded:Connect(function(child)
	createItem(child, moveset2)
end)