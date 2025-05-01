-- // Inserted by LRC4
-- // Written by @Wolf1te 23/06/23 | 2.2 - 20/08/24
-- // Auto Apply / Auto Update
-- // https://create.roblox.com/store/asset/8867876284/Load-Roblox-Characters-4

local players = game:GetService("Players")

local sp = script.Parent

local s, err = pcall(function()
	task.wait(2)
	local desc = players:GetHumanoidDescriptionFromUserId(script:GetAttribute("target") or script:GetAttribute("uid") or 1)
	
	if not desc then return end
	
	desc.Parent = script

	sp.Humanoid:ApplyDescriptionReset(desc)
end)

if not s then
	warn("LRC4.AutoApply: Error when updating character: ", err, tostring(sp.Name).. " failed to update", debug.traceback())
	sp:Destroy()
end