local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local tweens = require(ReplicatedStorage.SharedUtils.tweens)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function warnOnce(p: string, p2: string)
	if v[p] then
		return
	end

	v[p] = true
	warn("[ProfileEffects] " .. p .. ": " .. p2)
end

local v2 = {}

local function getModule(childName: string)
	local v3 = v2[childName]

	if v3 ~= nil then
		return v3 or nil
	end

	local moduleScript = script:FindFirstChild(childName)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(require, moduleScript)

		if success and type(result) == "table" and type(result.Start) == "function" then
			v2[childName] = result
			return result
		end

		v2[childName] = false
		warnOnce(childName, "module failed to load or has no Start function: " .. tostring(result)) -- equivalent call inferred; original call site unknown
		return nil
	else
		v2[childName] = false

		if not v[childName] then
			v[childName] = true
			warn("[ProfileEffects] " .. childName .. ": no effect module by that name - the print will draw still")
		end

		return nil
	end
end

local function isLive(parent)
	if not parent.Parent then
		return false
	end

	while parent and parent:IsA("GuiObject") do
		if not parent.Visible then
			return false
		end

		parent = parent.Parent
	end

	return true
end

return {
	Start = function(value, guiObject)
		if type(value) ~= "string" or value == "" or not (guiObject and guiObject:IsA("GuiObject")) then
			return nil
		end

		local module = getModule(value)

		if not module then
			return nil
		end

		local maid = Maid.new()
		local frame = Instance.new("Frame")
		frame.Name = "ProfileEffect"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.ClipsDescendants = true
		frame.ZIndex = guiObject.ZIndex
		frame.Active = false
		frame.Selectable = false
		maid:GiveTask(frame)
		local flag = true
		maid:GiveTask(function()
			flag = false
		end)
		local v3 = {
			Container = frame,
			ZIndex = frame.ZIndex,
			Maid = maid
		}
		local v4 = {}
		maid:GiveTask(function()
			for k in pairs(v4) do
				local v5 = k
				pcall(function()
					v5:Cancel()
					v5:Destroy()
				end)
			end

			table.clear(v4)
		end)

		function v3.Tween(p, p2, p3, callback)
			local v5 = tweens:playTween(p, p2, p3)
			v4[v5] = true
			local completedConnection = nil
			completedConnection = v5.Completed:Connect(function()
				completedConnection:Disconnect()
				v4[v5] = nil

				if callback then
					local success, result = pcall(callback)

					if not success then
						warnOnce(value, "a tween callback errored: " .. tostring(result)) -- equivalent call inferred; original call site unknown
					end
				end

				v5:Destroy()
			end)
			return v5
		end

		function v3.IsLive()
			return flag and isLive(frame)
		end

		function v3.Loop(duration: number, callback)
			task.spawn(function()
				while flag do
					if isLive(frame) then
						local success, result = pcall(callback)

						if not success then
							local v5 = value
							local v6 = "errored while running, stopping: " .. tostring(result)

							if v[v5] then
								break
							end

							v[v5] = true
							warn("[ProfileEffects] " .. v5 .. ": " .. v6)
							break
						end
					end

					task.wait(duration)
				end
			end)
		end

		if module.BackingIsPrint and guiObject:IsA("ImageLabel") and guiObject.Image ~= "" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Backing"
			imageLabel.BackgroundTransparency = 1
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Image = guiObject.Image
			imageLabel.ScaleType = guiObject.ScaleType
			imageLabel.ZIndex = frame.ZIndex
			imageLabel.Parent = frame
			v3.Backing = imageLabel
		end

		local topImage = module.TopImage

		if module.TopImageIsPrint and guiObject:IsA("ImageLabel") then
			topImage = guiObject.Image
		end

		if type(topImage) == "string" and topImage ~= "" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Top"
			imageLabel.BackgroundTransparency = 1
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Image = topImage

			if module.TopImageIsPrint and guiObject:IsA("ImageLabel") then
				imageLabel.ScaleType = guiObject.ScaleType
			end

			imageLabel.ZIndex = frame.ZIndex + 10
			imageLabel.Parent = frame
			v3.Top = imageLabel
		end

		frame.Parent = guiObject
		local success, result = pcall(module.Start, v3)

		if success then
			return {
				Key = value,
				Stop = function()
					maid:DoCleaning()
				end
			}
		end

		warnOnce(value, "Start failed, the print will draw still: " .. tostring(result)) -- equivalent call inferred; original call site unknown
		maid:DoCleaning()
		return nil
	end
}