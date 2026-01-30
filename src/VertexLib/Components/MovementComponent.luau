local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "MovementComponent",
        updateFrequency = nil,
        accumulator = 0,
        bindableEvents = {
            ["Jump"] = {functionName = "requestJump", keybinds = {Enum.KeyCode.Space}, mobileButton = true},
            ["Crouch"] = {functionName = "requestCrouch", keybinds = {Enum.KeyCode.LeftControl, Enum.KeyCode.C}, mobileButton = true}
        },
        jumpImpulse = Vector3.new(0,250,0)
    }
    return self
end

function Component:onUpdate()
    if self.Manager.ActiveState.Name ~= "Dead" then
        local moveDir = self.Manager.Shared.humanoid.MoveDirection
        self.Manager.Shared.inputDirection = moveDir
        if self.Manager.Shared.char.Hitbox.LocalTransparencyModifier == 1 then
            self.Manager.Shared.lookDirection = self.Manager.Shared.cam.CFrame.LookVector
        else
            self.Manager.Shared.lookDirection = moveDir
        end
        if not self.Manager.Shared.crouchInput and self.Manager.Shared.isCrouched then
            self:attemptUncrouch()
        end
        if self.Manager.Shared.groundSensor.SensedPart then
            if self.Manager.ActiveState.Name ~= "Grounded" then
                self.Manager:changeState("Grounded", false)
                self.Manager.Shared.numJumps = 0
            end
        elseif self.Manager.ActiveState.Name ~= "Airborne" then
            self.Manager:changeState("Airborne", false)
        end
    end
end

function Component:requestJump(inputType, inputObj)
    if inputType == Enum.UserInputState.Begin and self.Manager.ActiveState.canJump and self.Manager.Shared.numJumps < 2 then
        local vel = self.Manager.Shared.humanoidRoot.AssemblyLinearVelocity
        self.Manager.Shared.humanoidRoot.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        self.Manager.Shared.humanoidRoot:ApplyImpulse(self.jumpImpulse)
        self.Manager.Shared.numJumps += 1
    end
end

function Component:attemptUncrouch()
    local rayOrigin = self.Manager.Shared.humanoidRoot.CFrame
    local raySize = Vector3.new(self.Manager.Shared.humanoidRoot.Size.X, 0.1, self.Manager.Shared.humanoidRoot.Size.Z)
    local dir = Vector3.new(0,3,0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {self.Manager.Shared.humanoidRoot, self.Manager.Shared.char.HeadCollider, self.Manager.Shared.hitbox}
    local ray = workspace:Blockcast(rayOrigin, raySize, dir, params)
    if not ray then
        self.Manager.Shared.hitbox.Size = self.Manager.Shared.hitboxSize
        self.Manager.Shared.controllerManager.BaseMoveSpeed = self.Manager.Shared.walkSpeed
        self.Manager.Shared.groundController.GroundOffset = self.Manager.Shared.groundOffset
        self.Manager.Shared.groundSensor.SearchDistance = self.Manager.Shared.groundOffset + self.Manager.Shared.safeCheckOffset
        self.Manager.Shared.isCrouched = false
        self:setOffset()
    end
end

function Component:setOffset()
    local offset = self.Manager.Shared.isCrouched and self.Manager.Shared.hitboxOffsetCrouched or self.Manager.Shared.hitboxOffset
    self.Manager.Shared.humanoidRoot.HitboxWeld.C0 = offset.C0
    self.Manager.Shared.humanoidRoot.HitboxWeld.C1 = offset.C1
end

function Component:requestCrouch(inputType, inputObj)
    if inputType == Enum.UserInputState.Begin and self.Manager.ActiveState.canCrouch and not self.Manager.Shared.isCrouched then
        self.Manager.Shared.hitbox.Size = self.Manager.Shared.hitboxSizeCrouched
        self.Manager.Shared.isCrouched = true
        self.Manager.Shared.crouchInput = true
        self.Manager.Shared.controllerManager.BaseMoveSpeed = self.Manager.Shared.crouchSpeed
        self.Manager.Shared.groundController.GroundOffset = self.Manager.Shared.groundOffsetCrouched
        self:setOffset()
        self.Manager.Shared.groundSensor.SearchDistance = self.Manager.Shared.groundOffsetCrouched + self.Manager.Shared.safeCheckOffset
    elseif inputType == Enum.UserInputState.End and self.Manager.Shared.isCrouched then
        self.Manager.Shared.crouchInput = false
    end
end

return Component