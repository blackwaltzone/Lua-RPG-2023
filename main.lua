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

--local Map = Map:Create(mapDef)'

-- 11, 3, 1 == x, y, layer
local state = ExploreState:Create(nil, mapDef, Vector.Create(11, 3, 1))



function update()

	local dt = GetDeltaTime()

	state:Update(dt)
	state:HandleInput()
	state:Render(Renderer)

end
