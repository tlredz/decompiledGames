local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
require3(script.Parent.Utils.Types)
local v5 = require3(script.Parent.Utils.Visual)
return function(p, parent, p2)
	if not (p2 and parent:FindFirstChild("EmoteVFX_Storage")) then
		return nil
	end

	if parent:GetAttribute("PassiveRNGEmote") == p.Emote.Name then
		parent:SetAttribute("PassiveRNGEmote", nil)
		parent:SetAttribute("CurrentEmotePassiveSerial", nil)
		parent:SetAttribute("EmoteAnimationProfile", nil)
		return nil
	else
		local maid = v3.new()
		maid:AttachToInstance(parent)
		local maid2 = v3.new()
		maid2:AttachToInstance(parent)
		local v6 = maid2:Add(Instance.new("Folder"))
		v6.Parent = parent
		local v7 = maid:Add(Instance.new("Folder"))
		v7.Parent = parent
		parent:SetAttribute("PassiveRNGEmote", p.Emote.Name)
		parent:SetAttribute("CurrentEmotePassiveSerial", parent:GetAttribute("CurrentEmoteSerial"))
		local instance = p.VFX and v:GetInstance(p.VFX)

		if instance then
			local default = instance:FindFirstChild("Default")

			if default then
				v5.play(parent, maid, v7, default)

				if not v2.isAFKServer() then
					local v8 = {}
					local descendants = {}
					local descendants2 = {}

					for _, folder in v7:GetChildren() do
						if not string.find(folder.Name, "Enable") then
							continue
						end

						for _, v9 in v5.getVFX(folder) do
							table.insert(v8, v9)
						end

						for _, descendant in folder:GetDescendants() do
							if descendant:IsA("Sound") then
								table.insert(descendants, descendant)
							elseif descendant:IsA("BasePart") and descendant.Transparency ~= 1 then
								table.insert(descendants2, descendant)
							end
						end
					end

					local humanoid = parent:FindFirstChildWhichIsA("Humanoid")

					if humanoid then
						local now = 0
						local thread = nil

						local function updateEnabled()
							if os.clock() - now >= 4.9 and humanoid.MoveDirection == createVector(0, 0, 0) then
								parent:SetAttribute("EmoteAnimationProfile", p.Emote.Name)

								for _, v9 in descendants do
									v9:Resume()
								end

								for _, v9 in descendants2 do
									if v9:GetAttribute("TargetTransparency") == 0 then
										continue
									end

									v9:SetAttribute("Time", 0.25)
									v9:SetAttribute("TargetTransparency", 0)
									v9:AddTag("EmoteVFXTransparency")
								end

								for _, sound in v8 do
									if not sound:IsA("Sound") then
										sound.Enabled = true
									end
								end
							else
								parent:SetAttribute("EmoteAnimationProfile", nil)

								for _, v9 in descendants do
									v9:Pause()
								end

								for _, v9 in descendants2 do
									if v9:GetAttribute("TargetTransparency") == 1 then
										continue
									end

									v9:SetAttribute("Time", 0.25)
									v9:SetAttribute("TargetTransparency", 1)
									v9:AddTag("EmoteVFXTransparency")
								end

								for _, sound in v8 do
									if not sound:IsA("Sound") then
										sound.Enabled = false
									end
								end
							end
						end

						local function updateLastMoved()
							if thread then
								v4.Thread.SafeCancel(thread)
								thread = nil
							end

							if humanoid.MoveDirection == createVector(0, 0, 0) then
								thread = task.delay(5, function()
									updateEnabled()
								end)
							else
								now = os.clock()
							end

							updateEnabled()
						end

						maid:Add(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(updateLastMoved))
						task.spawn(updateLastMoved)
						maid:Add(function()
							parent:SetAttribute("EmoteAnimationProfile", nil)

							if thread then
								v4.Thread.SafeCancel(thread)
								thread = nil
							end
						end)
					end
				end
			end

			local passive = instance:FindFirstChild("Passive")

			if passive then
				v5.play(parent, maid2, v6, passive)

				if not v2.isAFKServer() then
					local v8 = {}

					for _, child in v6:GetChildren() do
						if not string.find(child.Name, "Enable") then
							continue
						end

						for _, v9 in v5.getVFX(child) do
							table.insert(v8, v9)
						end
					end

					local function checkShouldEnable()
						for k in parent:GetAttributes() do
							if string.find(k, "PassiveLock_") then
								return false
							end
						end

						return true
					end

					local function updateEnabled()
						local enabled = checkShouldEnable()

						if enabled then
							task.wait(2)

							if not checkShouldEnable() then
								return
							end
						end

						for _, v10 in v8 do
							v10.Enabled = enabled
						end
					end

					maid2:Add(parent.AttributeChanged:Connect(updateEnabled))
					task.spawn(updateEnabled)
				end
			end
		end

		local flag = false
		return function()
			if flag then
				return
			end

			flag = true
			local passiveRNGEmoteChangedConnection = nil

			local function destroy()
				passiveRNGEmoteChangedConnection:Disconnect()
				maid:Destroy()
				maid2:Destroy()
			end

			passiveRNGEmoteChangedConnection = parent:GetAttributeChangedSignal("PassiveRNGEmote"):Connect(function()
				if parent:GetAttribute("PassiveRNGEmote") ~= p.Emote.Name then
					task.defer(destroy)
				end
			end)
		end
	end
end