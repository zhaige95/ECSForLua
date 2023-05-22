local Matcher = class("Matcher")

function Matcher:ctor()
    self:Reset()
end

function Matcher:Reset()
    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mOnAdded = false
    self.mOnRemoved = false
    return self
end

function Matcher:AllOf(...)
    self.mAllOfIndexer = {...}
    return self
end

function Matcher:NoneOf(...)
    self.mNoneOfIndexer = {...}
    return self
end

function Matcher:Added()
    self.mOnAdded = true
    return self
end

function Matcher:Removed()
    self.mOnRemoved = true
    return self
end

function Matcher:AddedOrRemoved()
    
    self.mOnAdded = true
    self.mOnRemoved = true
    return self
end




return Matcher