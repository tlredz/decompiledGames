return {
	apply = function(state, p: string, p2, location)
		if not state or state.closed or not state.transfer or state.transfer.token ~= p then
			return "stale"
		end

		local flag = true

		for _, member in state.members do
			if not (not p2[member.userId] or state.transfer.arrived[tostring(member.userId)]) then
				continue
			end

			flag = false
			break
		end

		if flag then
			state.location = location
			state.transfer = nil
			return "restored"
		else
			for i = #state.members, 1, -1 do
				local member = state.members[i]

				if not p2[member.userId] then
					continue
				end

				table.remove(state.members, i)

				for k, invite in state.invites do
					if invite.inviter == member.userId then
						state.invites[k] = nil
					end
				end
			end

			if #state.members == 0 then
				state.closed = true
				state.invites = {}
			end

			return "split"
		end
	end
}