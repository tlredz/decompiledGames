local uDim = UDim2.fromScale(0, 0)
local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v = {
	[Enum.PlaybackState.Completed] = true,
	[Enum.PlaybackState.Cancelled] = true
}

local function collectChrome(object)
	local result = {}
	local gui = object.gui
	local exitButton = gui:FindFirstChild("ExitButton")

	if exitButton and exitButton:IsA("GuiObject") then
		table.insert(result, exitButton)
	else
		warn("[Profiles] journal ExitButton not found; it will stay visible")
	end

	local margin = gui:FindFirstChild("Margin")
	local count = 0

	local function sweepArtwork(instance)
		if not instance then
			return
		end

		for _, image in ipairs(instance:GetChildren()) do
			if not image:IsA("ImageLabel") then
				continue
			end

			table.insert(result, image)
			count += 1
		end
	end

	sweepArtwork(margin)
	sweepArtwork(margin and margin:FindFirstChild("Display"))

	if count == 0 then
		warn("[Profiles] no journal artwork found under Margin; it will stay visible")
	end

	local bookmarks = object.map and object.map.Bookmarks

	if bookmarks then
		table.insert(result, bookmarks)

		for _, button in ipairs(bookmarks.Parent:GetChildren()) do
			if button:IsA("TextButton") and object:FindPage(button.Name) then
				table.insert(result, button)
			end
		end
	else
		warn("[Profiles] journal Bookmarks not found; tabs will stay visible")
	end

	return result
end

return {
	Bind = function(object, instance, p)
		local isViewingOther = p and p.isViewingOther
		local guardLeave = p and p.guardLeave
		local margin = instance:FindFirstChild("Margin")

		if not (margin and margin:IsA("GuiObject")) then
			warn("[Profiles] no Margin frame; takeover not bound")
			return
		end

		local exitButton = instance:FindFirstChild("ExitButton", true)

		if not (exitButton and exitButton:IsA("GuiButton")) then
			warn("[Profiles] no ExitButton found on the page; there will be no way back")
			exitButton = nil
		end

		local position = margin.Position
		local visibility = {}
		local v2 = nil
		local v3 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopSlide()
			local v4 = v2
			v2 = nil

			if v4 and not v[v4.PlaybackState] then
				v4:Cancel()
				v4:Destroy()
			end
		end

		local function apply()
			for _, v4 in ipairs((collectChrome(object))) do
				visibility[v4] = v4.Visible
				v4.Visible = false
			end

			stopSlide() -- equivalent call inferred; original call site unknown
			margin.Position = position + uDim
			v2 = object.tweens.playTween(margin, tweenInfo, {
				Position = position
			})
		end

		local function release()
			stopSlide() -- equivalent call inferred; original call site unknown
			margin.Position = position

			for k, visible in pairs(visibility) do
				local hidden = k:GetAttribute("Hidden")

				if hidden == nil then
					k.Visible = visible
				else
					k.Visible = hidden ~= true
				end
			end

			table.clear(visibility)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setActive(visible: boolean)
			if visible == v3 then
				return
			end

			v3 = visible

			if v3 then
				apply()
			else
				release()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			local visible = instance.Visible and object.gui.Visible
			setActive(visible) -- equivalent call inferred; original call site unknown
		end

		instance:GetPropertyChangedSignal("Visible"):Connect(refresh)
		object.gui:GetPropertyChangedSignal("Visible"):Connect(refresh)
		refresh() -- equivalent call inferred; original call site unknown

		-- equivalent calls inferred from this helper; original call sites unknown
		local function goToPage(p2: string)
			if v3 ~= false then
				v3 = false
				release()
			end

			object:ShowPage(p2)
		end

		if exitButton then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function leave()
				if isViewingOther and isViewingOther() then
					if v3 ~= false then
						v3 = false
						release()
					end

					object:Close()
				else
					goToPage("Overview") -- equivalent call inferred; original call site unknown
				end
			end

			object:BindButton(exitButton, function()
				if guardLeave and guardLeave(leave) then
					return
				end

				leave() -- equivalent call inferred; original call site unknown
			end)
		end

		return {
			GoToPage = goToPage
		}
	end
}