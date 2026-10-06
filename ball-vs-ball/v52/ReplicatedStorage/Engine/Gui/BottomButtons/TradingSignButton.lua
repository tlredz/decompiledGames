local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Observers"))
local ButtonAnimator = require(script.Parent.ButtonAnimator)
local flag = false
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		local localPlayer = Players.LocalPlayer
		local v = localPlayer:WaitForChild("PlayerGui"):WaitForChild("下方按钮区"):WaitForChild("区域"):WaitForChild("下方区域"):WaitForChild("手持展牌按钮")
		local v2 = ButtonAnimator.new(v, v)
		local v3 = v:WaitForChild("描边")
		local color = v3.Color
		local color2 = Color3.new(1, 1, 0)
		local waitForChild = v:WaitForChild("快捷键")
		waitForChild.Visible = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
		local v4 = false
		local v5 = false
		local v6 = nil
		local v7 = nil
		local connections = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sync()
			v2:SetEnabled(false)
			v2:SetVisible(false)
		end

		local function findTool()
			local tool = v7 and v7:FindFirstChild("手持展牌")

			if tool and tool:IsA("Tool") then
				return tool
			end

			local tool2 = v6 and v6:FindFirstChild("手持展牌")

			if tool2 and tool2:IsA("Tool") then
				return tool2
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateStrokeColor()
			local v8

			if v6 == nil then
				v8 = false
			else
				v8 = v6:FindFirstChild("手持展牌") ~= nil
			end

			local v9 = v3
			local color3

			if v8 then
				color3 = color2
			else
				color3 = color
			end

			v9.Color = color3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshHasTool()
			local tool = v7 and v7:FindFirstChild("手持展牌")

			if not (tool and tool:IsA("Tool")) then
				tool = v6 and v6:FindFirstChild("手持展牌")

				if not (tool and tool:IsA("Tool")) then
					tool = nil
				end
			end

			v4 = tool ~= nil
			updateStrokeColor() -- equivalent call inferred; original call site unknown
			sync() -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disconnectBackpack()
			for _, connection in connections do
				connection:Disconnect()
			end

			connections = {}
		end

		local function watchBackpack(backpack)
			disconnectBackpack() -- equivalent call inferred; original call site unknown
			v7 = backpack
			table.insert(connections, backpack.ChildAdded:Connect(function(child)
				if child.Name == "手持展牌" then
					refreshHasTool() -- equivalent call inferred; original call site unknown
				end
			end))
			table.insert(connections, backpack.ChildRemoved:Connect(function(child)
				if child.Name == "手持展牌" then
					refreshHasTool() -- equivalent call inferred; original call site unknown
				end
			end))
			refreshHasTool() -- equivalent call inferred; original call site unknown
		end

		localPlayer.ChildAdded:Connect(function(backpack)
			if backpack:IsA("Backpack") then
				watchBackpack(backpack)
			end
		end)
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")

		if backpack then
			watchBackpack(backpack)
		end

		Observers.observeCharacter(function(_, instance)
			v6 = instance
			refreshHasTool() -- equivalent call inferred; original call site unknown
			local childAddedConnection = instance.ChildAdded:Connect(function(child)
				if child.Name == "手持展牌" then
					refreshHasTool() -- equivalent call inferred; original call site unknown
				end
			end)
			local childRemovedConnection = instance.ChildRemoved:Connect(function(child)
				if child.Name == "手持展牌" then
					refreshHasTool() -- equivalent call inferred; original call site unknown
				end
			end)
			return function()
				childAddedConnection:Disconnect()
				childRemovedConnection:Disconnect()

				if v6 == instance then
					v6 = nil
				end

				refreshHasTool() -- equivalent call inferred; original call site unknown
			end
		end, { localPlayer })

		local function setEquipped(flag2: boolean)
			local humanoid = v6 and v6:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			if flag2 then
				local tool = v7 and v7:FindFirstChild("手持展牌")

				if tool and tool:IsA("Tool") then
					humanoid:EquipTool(tool)
				end
			else
				humanoid:UnequipTools()
			end
		end

		local function toggleEquip()
			if not v4 or v5 then
				return
			end

			setEquipped(v6 == nil or v6:FindFirstChild("手持展牌") == nil)
		end

		ButtonActions.Bind(v, toggleEquip)
		UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.One and v4 then
				if v5 then
					return
				end

				setEquipped(v6 == nil or v6:FindFirstChild("手持展牌") == nil)
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onInDuelTableChanged()
			v5 = localPlayer:GetAttribute("InDuelTable") == true
			local humanoid = v5 and v6 and v6:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:UnequipTools()
			end

			sync() -- equivalent call inferred; original call site unknown
		end

		localPlayer:GetAttributeChangedSignal("InDuelTable"):Connect(onInDuelTableChanged)
		onInDuelTableChanged() -- equivalent call inferred; original call site unknown
	end
}