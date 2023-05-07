--[[

	Lua 2D RPG
	How to Make an RPG

	main.lua

	Dustin Heyden
	Feb 9, 2023


]]

LoadLibrary('Asset')
Asset.Run('Dependencies.lua')

Renderer = Renderer.Create()


local mapDef = CreateMap()
mapDef.on_wake = {}

-- separate trigger definitions from placement
-- this way wide doors can utilize same trigger
-- and not create new trigger for each tile
mapDef.actions = {}
mapDef.trigger_types = {}
mapDef.triggers = {}

local stack = StateStack:Create()

-- 11, 3, 1 == x, y, layer
local explore = ExploreState:Create(stack, mapDef, Vector.Create(11, 3, 1))

local menu = InGameMenuState:Create(stack)

stack:Push(explore)
stack:Push(menu)


function update()

	local dt = GetDeltaTime()

	stack:Update(dt)
	--state:HandleInput()
	stack:Render(Renderer)

end
