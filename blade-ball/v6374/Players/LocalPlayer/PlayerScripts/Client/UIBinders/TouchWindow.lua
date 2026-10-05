local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
return {
	Binder = function(instance)
		local maid = Utils.Maid.new()
		local flag = false
		local signal = Utils.Signal.new()
		local signal2 = Utils.Signal.new()

		local function AddStreamingObject(attributeName, value)
			local maid2 = Utils.Maid.new()

			local function UpdatePath(list)
				if list then
					local streamingObject = Utils.Streamer:Sync(localPlayer.PlayerGui, unpack(list))
					maid2.StreamingObject = streamingObject
					maid2.OnLoad = streamingObject.Loaded:Connect(function(instance2)
						if instance2:IsA("ScreenGui") then
							if flag then
								GuiHandler:Open(instance2.Name)
							else
								GuiHandler:Close(instance2.Name)
							end
						elseif instance2:IsA("GuiObject") then
							instance2.Visible = flag
						end

						maid2.OnEntered = signal:Connect(function()
							if instance2:IsA("ScreenGui") then
								GuiHandler:Open(instance2.Name)
							elseif instance2:IsA("GuiObject") then
								instance2.Visible = true
							end
						end)
						maid2.OnLeave = signal2:Connect(function()
							if instance2:IsA("ScreenGui") then
								GuiHandler:Close(instance2.Name)
							elseif instance2:IsA("GuiObject") then
								instance2.Visible = false
							end
						end)

						function maid2.OnDisconnect()
							if instance2:IsA("ScreenGui") then
								GuiHandler:Close(instance2.Name)
							elseif instance2:IsA("GuiObject") then
								instance2.Visible = false
							end
						end
					end)
				else
					maid2.StreamingObject = nil
					maid2.OnLoad = nil
				end
			end

			maid2.OnChanged = instance:GetAttributeChangedSignal(attributeName):Connect(function()
				local attribute = instance:GetAttribute(attributeName)
				UpdatePath(attribute and string.split(attribute, "."))
			end)
			UpdatePath(string.split(value, "."))
			maid[value .. "Maid"] = maid2
		end

		for k, v in pairs(instance:GetAttributes()) do
			if k:sub(1, 13) == "PlayerGuiPath" then
				AddStreamingObject(k, v)
			end
		end

		maid.CheckIsInside = Utils.Thread.Every(0.5, function()
			if not instance:IsDescendantOf(workspace) then
				return
			end

			local character = localPlayer.Character
			local position = character and character:GetPivot().Position

			if position and Utils.CFrame.InsidePart(instance, position) then
				if flag then
					return
				end

				flag = true
				signal:Fire()
			elseif flag then
				flag = false
				signal2:Fire()
			end
		end)
		return maid
	end
}