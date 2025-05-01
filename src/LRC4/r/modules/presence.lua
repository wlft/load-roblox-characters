local presence = {}
local tasks = {}

function presence:set_task(task_name:string)
	if not table.find(tasks, task_name) then
		table.insert(tasks, 1, task_name)
	else
		table.remove(tasks, table.find(tasks, task_name))
		table.insert(tasks, 1, task_name)
	end
end

return presence