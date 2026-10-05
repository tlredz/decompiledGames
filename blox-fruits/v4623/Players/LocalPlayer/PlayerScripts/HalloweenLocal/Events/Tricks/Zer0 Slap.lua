local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Effect)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)

local function fn(eventId)
	local child = workspace._WorldOrigin:WaitForChild(eventId, 60)
	local _storagePtr = child:WaitForChild("_storagePtr", 60)

	if not _storagePtr then
		return
	end

	if not _storagePtr.Value then
		_storagePtr.Changed:Wait()
	end

	local remoteFunction = _storagePtr.Value:WaitForChild("RemoteFunction")
	return child, _storagePtr.Value, remoteFunction
end

return {
	RunEarly = true,
	func = function(instance, p, _, _)
		local v, _, v2 = fn(instance:GetAttribute("EventId"))
		local v3 = p.WorldModel:GetChildren()[1]
		local zeroZero_Two = v3.NPCs.ZeroZero_Two
		zeroZero_Two:PivotTo(instance.Part.CFrame * CFrame.Angles(0, -0.17453292519943295, 0) * CFrame.new(0, -2.5, 5))
		local animation = Instance.new("Animation", zeroZero_Two)
		animation.AnimationId = "rbxassetid://507766388"
		zeroZero_Two.Humanoid:LoadAnimation(animation):Play()
		local animation2 = Instance.new("Animation", zeroZero_Two)
		animation2.AnimationId = "rbxassetid://110180049276123"
		zeroZero_Two.Humanoid:LoadAnimation(animation2):Play()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn2(attribute: boolean)
			if attribute then
				zeroZero_Two.Parent = nil
			else
				zeroZero_Two.Parent = v3.NPCs
			end
		end

		local v4 = "zer0hidden"
		v:GetAttributeChangedSignal("zer0hidden"):Connect(function()
			fn2(v:GetAttribute(v4))
		end)

		if v:GetAttribute("zer0hidden") then
			fn2(true) -- equivalent call inferred; original call site unknown
		else
			fn2(false) -- equivalent call inferred; original call site unknown
		end

		local function fn3(flag: boolean)
			if flag then
				zeroZero_Two.Head.CFrame = instance.Part.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, -5, 5)
				zeroZero_Two:ScaleTo(7)
			end
		end

		local v5 = "zer0jumpscar"
		v:GetAttributeChangedSignal("zer0jumpscar"):Connect(function()
			fn3(v:GetAttribute(v5))
		end)
		fn3(v:GetAttribute("zer0jumpscar"))
		zeroZero_Two.AncestryChanged:Connect(function(_, parent)
			if not parent then
				task.wait(1)
				DialogueController:Close()
			end
		end)
		local v6 = nil
		DialogueController:Start({
			Title = "rip_return",
			Get = function(_)
				task.spawn(function()
					local total = 0

					while DialogueController.Active do
						total += task.wait()

						if not (total > 12) then
							continue
						end

						DialogueController:Close()
						break
					end
				end)
				return {
					Text = { "..bro? im busy trying to fish rn, is there something u need? say fast and say well" },
					Option1 = {
						Label = "TRICK OR TREAT!",
						JumpTo = function()
							v6 = "spawnfish"
							local success, result = pcall(function()
								return runAsync(v2.InvokeServer, v2, "activate", "candy"):awaitResultTimeout(5)
							end)
							return success and result or {
								Text = { "..." }
							}
						end
					},
					Option2 = {
						Label = "[Ignore rip_return]",
						JumpTo = function()
							v6 = "ignore"
							local success, result = pcall(function()
								return runAsync(v2.InvokeServer, v2, "activate", "ignore"):awaitResultTimeout(5)
							end)
							return success and result or {
								Text = { "..." }
							}
						end
					}
				}
			end
		})

		if not v6 then
			v2:InvokeServer("activate", "ignore")
		end
	end
}