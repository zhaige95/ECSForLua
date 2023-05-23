local GameEntity = class("GameEntity")

function GameEntity:AddTest(id, list)
    self.Test = Context:_GetComponent(GameComponentLookUp.TestComponent)
    self.Test:Init(id, list)
end

return GameEntity