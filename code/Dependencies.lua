--[[LoadLibrary("Asset")
LoadLibrary("Keyboard")
LoadLibrary("Renderer")
LoadLibrary("Sprite")
LoadLibrary("System")
LoadLibrary("Texture")
LoadLibrary("Vector")

Asset.Run("Actions.lua")
Asset.Run("Animation.lua")
Asset.Run("Character.lua")
Asset.Run("Entity.lua")
Asset.Run("small_room.lua")
Asset.Run("Map.lua")
Asset.Run("MoveState.lua")
Asset.Run("NPCStandState.lua")
Asset.Run("PlanStrollState.lua")
Asset.Run("StateMachine.lua")
Asset.Run("Tween.lua")
Asset.Run("Trigger.lua")
Asset.Run("Util.lua")
Asset.Run("WaitState.lua")

Asset.Run("EntityDefs.lua")
]]--

function Apply(list, f, iter)
	iter = iter or ipairs
	for k, v in iter(list) do
		f(v, k)
	end
end


Apply(
    {
    	"Keyboard",
    	"Renderer",
    	"Sprite",
    	"System",
    	"Texture",
    	"Vector"
    },
    function(v) LoadLibrary(v) end)

Apply(
    {
        "Animation.lua",
        "Map.lua",
        "Util.lua",
        "Entity.lua",
        "StateMachine.lua",
        "MoveState.lua",
        "WaitState.lua",
        "NPCStandState.lua",
        "PlanStrollState.lua",
        "Tween.lua",
        "Actions.lua",
        "Trigger.lua",
        "EntityDefs.lua",
        "Character.lua",
        "small_room.lua",
        "Panel.lua",
        "ProgressBar.lua",
        "Selection.lua",
        "StateStack.lua",
        "Textbox.lua",
        "ExploreState.lua",
        "FadeState.lua",
        "MenuLayout.lua",
        "InGameMenuState.lua",
        "FrontMenuState.lua",
        "ItemDB.lua",
        "ItemMenuState.lua",
        "Icons.lua",
        "World.lua"
    },
    function(v) Asset.Run(v) end)