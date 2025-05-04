--!nocheck

local rs = game:GetService("RunService")

local distance = 10
local fov = 50
local pitch_angle = 0
--local speed = 50
local speed = 1
local should = true

local frame_start = os.clock()
local frame = 0
local framediv = 1/60

local base_offset = Vector3.new(0,0,distance)

local mouse:PluginMouse = script.Parent.Parent.connect.plugin_gateway:Invoke('get', 'mouse')

local pvfr = {}

function pvfr:enable(vpf:ViewportFrame, target:Model, widget:DockWidgetPluginGui?)
	-- rotation snippet adapted from create.roblox.com/docs/ui/frames#viewportframe

	local vpc = vpf:FindFirstChildOfClass('Camera') or Instance.new("Camera")
	vpc.FieldOfView = fov
	vpc.Parent = vpf
	vpc.Name = 'camera'
	vpf.CurrentCamera = vpc

	local object = target:FindFirstChildOfClass("Humanoid") and target:FindFirstChildOfClass("Humanoid").RootPart
	
	if object then
		object.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(pitch_angle), 0, 0)
		
		local wheel_forward
		wheel_forward = vpf.MouseWheelForward:Connect(function()
			vpc.FieldOfView = math.clamp(vpc.FieldOfView-2, 1, 120)
		end)
		
		local wheel_backward
		wheel_backward = vpf.MouseWheelBackward:Connect(function()
			vpc.FieldOfView = math.clamp(vpc.FieldOfView+2, 1, 120)
		end)
		
		--local dragmap = vpf.Parent:FindFirstChild('dragmap')
		
		local bdown, bup, bmove, bleave
		local is_down = false
		local t = 0
		--if dragmap and dragmap:IsA('GuiButton') then
		--	local px, py
		--	bdown = dragmap.MouseButton1Down:Connect(function()
		--		is_down = true
				
		--		--while is_down and task.wait() do
		--		--	if not is_down then break end
		--		--	if not px and not py then px,py = mouse.X,mouse.Y continue end
		--		--	--print(px, mouse.X)
		--		--	--if px == mouse.X then continue end
					
		--		--	px,py=mouse.X,mouse.Y
		--		--	print(mouse.X, mouse.Y)
		--		--end
		--	end)
			
		--	bup = dragmap.MouseButton1Up:Connect(function()
		--		is_down = false
		--	end)
			
		--	bleave = dragmap.MouseLeave:Connect(function()
		--		is_down = false
		--	end)
			
		--	--local px,py
		--	----bmove = dragmap.MouseMoved:Connect(function(x,y)
		--	----	--if not is_down then return end
		--	----	--if not px and not py then px,py = x,y return end
				
		--	----	print(x,y)
				
		--	----end)
			
		--	--bmove = mouse.Move:Connect(function(x,y)
		--	--	--if not is_down then return end
		--	--	--if not px and not py then px,py = x,y return end
		--	--	--print(px,x)
		--	--	print(mouse.Hit.Position)
		--	--end)
			
		--	----mouse.
		--end
		
		--local conn
		--conn = rs.PostSimulation:Connect(function(delta)
		--	if os.clock() - frame_start < 1 / 60 then return end
		--	frame_start = os.clock()
			
		--	if not target or not target.Parent then conn:Disconnect(); wheel_forward:Disconnect(); wheel_backward:Disconnect(); --[[if bdown then is_down = false bdown:Disconnect() end; if bup then bup:Disconnect() end; if bmove then bmove:Disconnect() end if bleave then bleave:Disconnect() end]] end
		--	if widget then if not widget.app.loader.Visible or not widget.Enabled or not should or not vpf.Visible or is_down then return end end
		--	t += delta
			
		--	vpc.CFrame = CFrame.Angles(0, math.rad(t * speed), 0) * CFrame.new(0, 0, distance)
		--end)
		
		rs:BindToRenderStep('lrc4__viewport_auto_rotate', Enum.RenderPriority.Camera.Value, function(dt)
			if not target or not target.Parent then rs:UnbindFromRenderStep('lrc4__viewport_auto_rotate'); wheel_forward:Disconnect(); wheel_backward:Disconnect(); return end
			if not should or not vpf.Visible or is_down then return end
			t = (t + dt) % (2 * math.pi)
			
			--vpc.CFrame = CFrame.Angles(0, math.rad(t * speed), 0) * CFrame.new(0, 0, distance)
			local rot = CFrame.Angles(0, t * speed, 0)
			vpc.CFrame = rot + rot:VectorToWorldSpace(base_offset)
		end)
	else
		warn("LRC4 | Rig not found in viewport frame")
	end
end

function pvfr:pref__auto_rotate(val:boolean)
	should = val
end

return pvfr