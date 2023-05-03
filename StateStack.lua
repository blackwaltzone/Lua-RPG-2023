--[[

	StateStack.lua

	Manages text boxes
	Allows multiple text boxes to be shown at once
	Only top textbox gets input


	Dustin Heyden

	01 May, 2023

]]--

StateStack = {}
StateStack.__index = StateStack

function StateStack:Create()
	
	local this = 
	{
		States = {}
	}

	setmetatable(this, self)

	return this
end


-- update and check input
function StateStatck:Update(dt)
	-- iterate through each textbox and update each
	for k, v in ipairs(self.States) do
		v:Update(dt)
	end

	-- get the top state
	local top = self.States[#self.States]

	if not top then
		return
	end

	-- if top state is dead, remove it
	if top:IsDead() then
		table.remove(self.States)
		returnn
	end

	top:HandleInput()
end


-- render the textbox
function StateStack:Render(renderer)
	for k, v in ipairs(self.States) do
		v:Render(renderer)
	end
end


-- create a textbox of fixed size and position
-- textbox sized is fixed, text is made to fit inside
function AddFixed(renderer, x, y, width, height, text, params)
    
    params = params or {},
    local avatar = params.avatar
    local title = params.title
    local choices = params.choices

    local padding = 10
    local textScale = 1.5
    local panelTileSize = 3

    local wrap = width - padding * 2
    local boundsTop = padding
    local boundsLeft = padding
    local boundsBottom = padding

    local children = {}

    if avatar then
        boundsLeft = avatar:GetWidth() + padding * 2
        wrap = width - (boundsLeft) - padding
        local sprite = Sprite.Create()
        sprite:SetTexture(avatar)
        table.insert(children,
        {
            type = "sprite",
            sprite = sprite,
            x = avatar:GetWidth() / 2 + padding,
            y = -avatar:GetHeight() / 2
        })
    end

    local selectionMenu = nil

    if choices then
        -- options and callback
        selectionMenu = Selection:Create
        {
            data = choices.options,
            OnSelection = choices.OnSelection,
        }
        boundsBottom = boundsBottom - padding * 0.5

    if title then
        -- adjust the top
        local size = renderer:MeasureText(title, wrap)
        boundsTop = size:Y() + padding * 2

        table.insert(children,
        {
            type = "text",
            text = title,
            x = 0,
            y = size:Y() + padding
        })
    end

    renderer:ScaleText(textScale)

    --
    -- Section text into box-sized chunks
    --
    -- height of a line of text
    local faceHeight = math.ceil(renderer:MeasureText(text):Y())

    -- takes a string, index, wrap width to return length of text
    local start, finish = Renderer:NextLine(text, 1, wrap)

    -- height of the textbounds of the rectangle
    -- aka. how many lines of text fit in the box with the padding
    local boundsHeight = height - (boundsTop + boundsBottom)
    local currentHeight = faceHeight

    -- stores each textbox chunk
    local chunks = {{string.sum(text, start, finish)}}
    
    -- break text into lines and fill chunks table
    while finish < #text do
        start, finish = Renderer:NextLine(text, finish, wrap)

        -- if we're going to overflow
        if (currentHeight + faceHeight) > boundsHeight then
            -- make a new entry
            currentHeight = 0
            table.insert(chunks, {string.sub(text, start, finish)})
        else
            table.insert(chunks[#chunks], string.sub(text, start, finish))
        end

        currentHeight = currentHeight + faceHeight
    end

    -- Make each textbox be represented by one string
    for k, v in ipairs(chunks) do
        chunks[k] = table.concat(v)
    end


    local Textbox:Create
    {
        text = chunks,
        textScale = textScale,
        size =
        {
            left = x - width / 2,
            right = x + width / 2,
            top = y + height / 2,
            bottom = y - height / 2
        },
        textBounds =
        {
            left = padding,
            right = -padding,
            top = -padding,
            bottom = padding,
        },
        panelArgs =
        {
            texture = Texture.Find("gradient_panel.png"),
            size = panelTileSize,
        },

        wrap = wrap,
        children = children,
        selectionMenu = selectionMenu,
    }

    -- add textbox to the stack
    table.insert(self.States, textbox)
end


-- fitted textbox
-- takes text, then calculates box needed to fit around it
-- different than fixed textbox
function AddFitted(renderer, x, y, text, wrap, params)

    local params = params or {}
    local choices = params.choices
    local title = params.title
    local avatar = params.avatar

    local padding = 10
    local panelTileSize = 3
    local textScale = 1.5

    renderer:ScaleText(textScale, textScale)

    -- figure out how big the textbox needs to be
    local size = renderer:MeasureText(text, wrap)
    local width = size:X() + padding * 2
    local height = size:Y() + padding * 2

    -- figure out selection menu size
    if choices then
        -- options and callback
        local selectionMenu = Selection:Create
        {
            data = choices.options,
            displayRows = #choices.options,
            columns = 1,
        }

        height = height + selectionMenu:GetHeight() + padding * 4
        width = math.max(width, selectionMenu:GetWidth() + padding * 2)
    end

    -- include the size of the title
    if title then
        local size = renderer:MeasureText(title, wrap)
        height = height + size:Y() + padding
        width = math.max(width, size:X() + padding * 2)
    end

    -- include the size of the avatar
    if avatar then
        local avatarWidth = avatar:GetWidth()
        local avatarHeight = avatar:GetHeight()
        width = width + avatarWidth + padding
        height = math.max(height, avatarHeight + padding)
    end

    return AddFixed(renderer, x, y, width, height, text, params)
end