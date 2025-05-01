--!nocheck

--/lrc4.1.1|ah/
-- @Wolf1te 2024-10-19 // Injected per user request via LRC4 (https://create.roblox.com/store/asset/8867876284/Load-Roblox-Characters-4)
-- Do not remove the comments above

local scan = {workspace}
local streaming = workspace.StreamingEnabled

local function scan_and_apply(m:Model)
	if m and m:GetAttribute('lrc4_animation__enabled') and m:FindFirstChildOfClass('Humanoid') then
		local h = m:FindFirstChildOfClass('Humanoid')
		local animator = h:FindFirstChildOfClass('Animator') or Instance.new('Animator', h)
		local animtrack = Instance.new('Animation')
		animtrack.AnimationId = 'rbxassetid://'..m:GetAttribute('lrc4_animation__id')
		local anim = animator:LoadAnimation(animtrack)
		if m:GetAttribute('lrc4_animation__use_action4') then
			anim.Priority = Enum.AnimationPriority.Action4
		else
			anim.Priority = Enum.AnimationPriority.Idle
		end
		anim.Looped = true
		anim:Play()
	end
end

for _, v in pairs(scan) do
	if streaming then
		v.DescendantAdded:Connect(function(d)
			if d:IsA('Model') then scan_and_apply(d) end
		end)
	end
	
	for _, vv in pairs(v:GetDescendants()) do
		if typeof(vv) == 'Instance' and vv:IsA('Model') then
			scan_and_apply(vv)
		end
	end
end