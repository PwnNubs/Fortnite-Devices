
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

nimbus := class(creative_device):

    #configured to use Adventure Beanbag
    @editable
    PropAsset:creative_prop_asset = DefaultCreativePropAsset

    var IsMoving:logic = false

    OnBegin<override>()<suspends>:void=
        if (Player := GetPlayspace().GetPlayers()[0], FortChar := Player.GetFortCharacter[]):
            FortChar.SprintedEvent().Subscribe(MovingCallback)

            var Prop:creative_prop = creative_prop{}

            loop:
                var PrvProp:creative_prop = Prop

                var PlayerFeetPos:vector3 = FortChar.GetTransform().Translation
                # Player.Z Offset from feet pos: Standing ~ +77.156, Crouch ~ +52.156
                if (FortChar.IsCrouching[]):
                    set PlayerFeetPos.Z -= 52.156
                else:
                    set PlayerFeetPos.Z -= 77.156

                # dependent on the prop
                var PropAdjust:vector3 = vector3{X:=0.0, Y:=0.0, Z:=-44.8}

                SpawnLocation := PlayerFeetPos + PropAdjust
                Result := SpawnProp(PropAsset, transform{Translation:=SpawnLocation})
                if (SpawnedProp := Result(0)?):
                    set Prop = SpawnedProp

                if. PrvProp.IsValid[]
                    if. PrvProp.TeleportTo[transform{Translation:=vector3{Z:=-10000.0}}]
                    PrvProp.Dispose()
                
                # Up and Down movement handled by animation otherwise weird behaviour
                if (IsMoving?, AnimeControl := Prop.GetAnimationController[]):
                    var VerticalAdjust:vector3 = vector3{}
                    if. set VerticalAdjust.Z = FortChar.GetViewRotation().GetYawPitchRollDegrees()[1] * 0.5
                    set VerticalAdjust.Z = Clamp(VerticalAdjust.Z, -24.0, 24.0)

                    var AnimDuration:float = 0.035
                    if (VerticalAdjust.Z < 0.0):
                        set AnimDuration = 0.045
                    
                    var KeyframeArray:[]keyframe_delta = array{}
                    set KeyframeArray = array{keyframe_delta{
                        DeltaLocation := VerticalAdjust,
                        DeltaRotation := IdentityRotation(),
                        DeltaScale := vector3{X:=1.0, Y:=1.0, Z:=1.0},
                        Time := 0.045, 
                        Interpolation := Linear}}

                    AnimeControl.SetAnimation(KeyframeArray, ?Mode:=animation_mode.OneShot)
                    AnimeControl.Play()

                Sleep(0.0)
    
    MovingCallback(FortChar:fort_character, Moving:logic):void=
        set IsMoving = Moving