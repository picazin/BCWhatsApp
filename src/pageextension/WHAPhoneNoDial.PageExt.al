pageextension 83255 "WHA Phone No. Dial" extends "Countries/Regions"
{
    layout
    {
        addlast(Control1)
        {
            field("WHA Dial"; Rec."WHA Dial")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the country Dial acording to ISO';
            }
        }
    }
}