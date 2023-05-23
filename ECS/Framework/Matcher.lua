-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 匹配器
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Matcher = class("Matcher")

function Matcher:ctor()
    self:Reset()
end

function Matcher:OnDispose()

end

function Matcher:Reset()
    self.mAllOfContent = {}
    self.mNoneOfContent = {}

    self.mAdded = false
    self.mRemoved = false
    self.mAnyMode = false
    return self
end

function Matcher:AllOf(...)
    self.mAllOfContent = { ... }
    return self
end

function Matcher:NoneOf(...)
    self.mNoneOfContent = { ... }
    return self
end

function Matcher:AnyOf(...)
    self.mAllOfContent = { ... }
    self.mAnyMode = true
    return self
end

function Matcher:Added()
    self.mAdded = true
    return self
end

function Matcher:Removed()
    self.mRemoved = true
    return self
end

function Matcher:AddedOrRemoved()
    self.mAdded = true
    self.mRemoved = true
    return self
end

return Matcher
