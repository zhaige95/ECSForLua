require("Core.functions")

require("ECS.Context")


require("Generated.GeneratedContext")

-- print(Context.mEntityUID)

local e = Context:CreateEntity()
e:AddTest("new  test", {43,5,62,523})
