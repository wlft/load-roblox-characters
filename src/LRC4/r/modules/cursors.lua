local plugin_mouse = script.Parent.Parent.connect.plugin_gateway:Invoke("get", "mouse")

local rbxasset_cursors = {
	arrow = "rbxasset://SystemCursors/Arrow";
	pointer = "rbxasset://SystemCursors/PointingHand";
	open_hand = "rbxasset://SystemCursors/OpenHand";
	closed_hand = "rbxasset://SystemCursors/ClosedHand";
	i_beam = "rbxasset://SystemCursors/IBeam";
	forbidden = "rbxasset://SystemCursors/Forbidden";
	_wait = "rbxasset://SystemCursors/Wait";
	busy = "rbxasset://SystemCursors/Busy";
}

local cursors = {
	default = rbxasset_cursors.arrow;
	hover = rbxasset_cursors.pointer;
	forbidden = rbxasset_cursors.forbidden;
	_wait = rbxasset_cursors._wait;
	busy = rbxasset_cursors.busy;
}

local function c(cursor:string)
	plugin_mouse.Icon = cursor
end

return function(gui_object:GuiObject)
	if not gui_object or not gui_object:IsA("GuiObject") then return end
	
	for _, v in pairs(gui_object:GetDescendants()) do
		if not v:IsA("GuiObject") then continue end
		if v:GetAttribute("cursor") then
			local is_static = v:GetAttribute("cursor__is_static") ~= false
			
			if is_static then
				local s = v:GetAttribute("cursor")
				v.MouseEnter:Connect(function()
					if cursors[s] then
						c(cursors[s])
					end
				end)
			else
				v.MouseEnter:Connect(function()
					local d = v:GetAttribute("cursor")
					if cursors[d] then
						c(cursors[d])
					end
				end)
			end
			
			v.MouseLeave:Connect(function()
				c(cursors.default)
			end)
		else
			continue
		end
	end
end