tableextension 83255 "WHA Phone No. Dial" extends "Country/Region"
{
    fields
    {
        field(83255; "WHA Dial"; Code[10])
        {
            Caption = 'Dial';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                C: Text[1];
                i: Integer;
                DialErr: Label 'Only allowed numbers and -';
            begin
                for i := 1 to StrLen("WHA Dial") do begin
                    C := CopyStr("WHA Dial", i, 1);
                    if not (C in ['-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
                        Error(DialErr);
                end;
            end;
        }
    }
}