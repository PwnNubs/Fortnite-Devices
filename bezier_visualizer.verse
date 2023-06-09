
using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

using { /Verse.org/Colors/NamedColors }

bezier_visualizer := class(creative_device):

    @editable
    SpawnButton:button_device = button_device{}

    @editable
    StartPosition:creative_prop = creative_prop{}
    @editable
    EndPosition:creative_prop = creative_prop{}
    @editable
    Handle1:creative_prop = creative_prop{}
    @editable
    Handle2:creative_prop = creative_prop{}

    MyDD:debug_draw = debug_draw{}

    OnBegin<override>()<suspends>:void=
        SpawnButton.InteractedWithEvent.Subscribe(OnButtonInteractedWith)
        MyDD.ShowChannel()

    OnButtonInteractedWith(InPlayer:agent):void=
        MyDD.Clear()    # in case of spamming button

        SPvec := StartPosition.GetTransform().Translation
        EPvec := EndPosition.GetTransform().Translation
        H1vec := Handle1.GetTransform().Translation
        H2vec := Handle2.GetTransform().Translation

        X := array{SPvec.X, H1vec.X, H2vec.X, EPvec.X}
        Y := array{SPvec.Y, H1vec.Y, H2vec.Y, EPvec.Y}
        Z := array{SPvec.Z, H1vec.Z, H2vec.Z, EPvec.Z}

        # Debug Printing Handles
        <#
        if (Handles := array{vector3{X:=X[1], Y:=Y[1], Z:=Z[1]}, vector3{X:=X[2], Y:=Y[2], Z:=Z[2]}}):
            size := vector3{X:=10.0, Y:=10.0, Z:=10.0}
            if (R := Handles[0] + Origin.Translation):
                MyDD.DrawBox(R, IdentityRotation(), ?Extent:=size, ?Color:=Red, ?Duration:=10.0)

            if (R := Handles[1] + Origin.Translation):
                MyDD.DrawBox(R, IdentityRotation(), ?Extent:=size, ?Color:=Red, ?Duration:=10.0)
        #>

        var dX:float = 0.0
        var dY:float = 0.0
        var dZ:float = 0.0

        for (i := 1..100):
            t := i * 0.01

            if (set dX = ((1.0 - t) * (1.0 - t) * (1.0 - t) * X[0] + 3 * (1.0 - t) * (1.0 - t) * t * X[1] + 3 * (1.0 - t) * (t * t) * X[2] + (t * t * t) * X[3])) {}
            if (set dY = ((1.0 - t) * (1.0 - t) * (1.0 - t) * Y[0] + 3 * (1.0 - t) * (1.0 - t) * t * Y[1] + 3 * (1.0 - t) * (t * t) * Y[2] + (t * t * t) * Y[3])) {}
            if (set dZ = ((1.0 - t) * (1.0 - t) * (1.0 - t) * Z[0] + 3 * (1.0 - t) * (1.0 - t) * t * Z[1] + 3 * (1.0 - t) * (t * t) * Z[2] + (t * t * t) * Z[3])) {}

            Pos := vector3{X:=dX, Y:=dY, Z:=dZ}
            Result := MyDD.DrawSphere(Pos, ?Radius:=2.0, ?Duration:=10.0)