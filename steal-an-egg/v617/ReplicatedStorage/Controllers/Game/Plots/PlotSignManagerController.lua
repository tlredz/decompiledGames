local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = require(ReplicatedStorage.Shared.Player)
local PlotState = require(ReplicatedStorage.Client.PlotState)
require(ReplicatedStorage.Shared.Types.Plots)
local Streamable = require(ReplicatedStorage.Packages.Streamable)
local streamable = Streamable.Streamable
local PlotSignHomeButtonFade = require(script.Parent.Parent.Parent.GUI.PlotSignHomeButtonFade)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
local v = {}
local v2 = {}
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearRemotePlotSignBinding(p: number)
			local v3 = v2[p]

			if v3 == nil then
				return
			end

			v3:Destroy()
		end

		local function bindRemotePlotSign(k: number, p: number?)
			clearRemotePlotSignBinding(k) -- equivalent call inferred; original call site unknown

			if p == nil or p == localPlayer.UserId then
				return
			end

			local playerByUserId = Players:GetPlayerByUserId(p)

			if playerByUserId == nil then
				return
			end

			local plot = PlotState.ResolvePlot(playerByUserId)

			if plot == nil then
				return
			end

			local maid2 = Trove.new()
			v2[k] = maid2
			maid2:Add(function()
				if v2[k] == maid2 then
					v2[k] = nil
				end
			end)
			local v3 = streamable.new(plot.PlotFolder, "PlotSign")
			maid2:Add(function()
				v3:Destroy()
			end)
			maid2:Add(v3:Observe(function(p2, maid3)
				local v4 = streamable.new(p2, "PlayerPlotSign")
				maid3:Add(function()
					v4:Destroy()
				end)
				maid3:Add(v4:Observe(function(billboardGui)
					assert(billboardGui:IsA("BillboardGui"), "PlayerPlotSign must be a BillboardGui")
					local v5 = {
						PetArea = plot.PetArea,
						PlayerPlotSign = billboardGui
					}
					v[k] = v5
					return function()
						if v[k] == v5 then
							v[k] = nil
						end

						if billboardGui.Parent ~= nil then
							billboardGui.AlwaysOnTop = false
						end
					end
				end))
			end))
		end

		local function rebindAllRemotePlotSigns()
			local v3 = {}

			for k in pairs(v2) do
				v3[#v3 + 1] = k
			end

			for _, v4 in ipairs(v3) do
				clearRemotePlotSignBinding(v4) -- equivalent call inferred; original call site unknown
			end

			for k, v4 in pairs(PlotState.ReadOwners()) do
				bindRemotePlotSign(k, v4)
			end
		end

		local function updateRemotePlotSigns()
			local rootPart = Player.FindRootPart(localPlayer)
			local position

			if rootPart ~= nil then
				position = rootPart.Position
			end

			for _, v3 in pairs(v) do
				local playerPlotSign = v3.PlayerPlotSign

				if playerPlotSign.Parent == nil then
					continue
				end

				local petArea = v3.PetArea
				local alwaysOnTop

				if position == nil or petArea.Parent == nil then
					alwaysOnTop = false
				else
					local pointToObjectSpace = petArea.CFrame:PointToObjectSpace(position)
					local v5 = petArea.Size * 0.5

					if math.abs(pointToObjectSpace.X) <= v5.X then
						alwaysOnTop = math.abs(pointToObjectSpace.Z) <= v5.Z
					else
						alwaysOnTop = false
					end
				end

				if playerPlotSign.AlwaysOnTop ~= alwaysOnTop then
					playerPlotSign.AlwaysOnTop = alwaysOnTop
				end
			end
		end

		local function updateYourBaseTracker(p)
			maid:Clean()

			if not p then
				return
			end

			local centerPoint = p.CenterPoint
			local v3 = streamable.new(p.PlotFolder, "PlotSign")
			maid:Add(function()
				v3:Destroy()
			end)
			maid:Add(v3:Observe(function(p2, maid2)
				local v4 = streamable.new(p2, "SignUI")
				maid2:Add(function()
					v4:Destroy()
				end)
				maid2:Add(v4:Observe(function(billboardGui)
					assert(billboardGui:IsA("BillboardGui"), "SignUI must be a BillboardGui")
					local enabled = billboardGui.Enabled
					billboardGui.Enabled = false
					return function()
						if billboardGui.Parent ~= nil then
							billboardGui.Enabled = enabled
						end
					end
				end))
				local v5 = streamable.new(p2, "Attachment")
				maid2:Add(function()
					v5:Destroy()
				end)
				maid2:Add(v5:Observe(function(p3, maid3)
					local v6 = streamable.new(p3, "YourBase")
					maid3:Add(function()
						v6:Destroy()
					end)
					maid3:Add(v6:Observe(function(billboardGui)
						assert(billboardGui:IsA("BillboardGui"), "YourBase must be a BillboardGui")
						local v7 = PlotSignHomeButtonFade.new(billboardGui)
						maid3:Add(function()
							v7:Destroy()
						end)

						local function updateDistance()
							local character = localPlayer.Character
							local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

							if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
								v7:SetVisible(false)
								return
							end

							billboardGui.MaxDistance = 300
							v7:SetVisible((humanoidRootPart.Position - centerPoint.Position).Magnitude > 50)
						end

						updateDistance()
						return RunService.Heartbeat:Connect(updateDistance)
					end))
				end))
			end))
		end

		updateYourBaseTracker(PlotState.ResolvePlot())
		PlotState.LocalPlotChanged:Connect(function()
			updateYourBaseTracker(PlotState.ResolvePlot())
		end)
		rebindAllRemotePlotSigns()
		PlotState.PlotChanged:Connect(bindRemotePlotSign)
		PlotState.FolderChanged:Connect(rebindAllRemotePlotSigns)
		Players.PlayerAdded:Connect(rebindAllRemotePlotSigns)
		Players.PlayerRemoving:Connect(function(player)
			for k, v3 in pairs(PlotState.ReadOwners()) do
				if v3 ~= player.UserId then
					continue
				end

				clearRemotePlotSignBinding(k) -- equivalent call inferred; original call site unknown
			end
		end)
		RunService.Heartbeat:Connect(updateRemotePlotSigns)
	end
}