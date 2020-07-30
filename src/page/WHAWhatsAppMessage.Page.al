page 50100 "WHA WhatsApp Message"
{
    PageType = Card;
    Caption = 'Whatsapp Messages';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(Receiver)
            {
                Caption = 'Receiver';
                field(PhoneType; PhoneType)
                {
                    Caption = 'Type';
                    OptionCaption = ' ,Customer,Contact,Vendor,Employee';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        InitData();
                    end;
                }
                field(SourceNo; SourceNo)
                {
                    Caption = 'Source No.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        GetData();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RecRef: RecordRef;
                        FldRef: FieldRef;
                        VarRecRef: Variant;
                    begin
                        case PhoneType of
                            PhoneType::Customer:
                                RecRef.Open(Database::Customer);
                            PhoneType::Vendor:
                                RecRef.Open(Database::Vendor);
                            PhoneType::Contact:
                                RecRef.Open(Database::Contact);
                            PhoneType::Employee:
                                RecRef.Open(Database::Employee);
                        end;

                        VarRecRef := RecRef;
                        if Page.RunModal(0, VarRecRef) = Action::LookupOK then begin
                            RecRef := VarRecRef;
                            FldRef := RecRef.Field(1);
                            SourceNo := FldRef.Value;
                            GetData();
                        end;
                    end;
                }
                field(ReceiverName; ReceiverName)
                {
                    Caption = 'Receiver Name';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CountryCode; CountryCode)
                {
                    Caption = 'Country Code';
                    ApplicationArea = All;
                    TableRelation = "Country/Region";
                }
                field(PhoneNo; PhoneNo)
                {
                    Caption = 'Phone No.';
                    ApplicationArea = All;
                }
            }
            group(SendMessage)
            {
                Caption = 'Message';
                field("Message"; Message)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Send)
            {
                Image = Calls;
                Caption = 'Send Message';
                ApplicationArea = All;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Send Whatsapp message';

                trigger OnAction()
                var
                    Whatsapp: Codeunit "WHA WhatsApp Management";
                begin
                    Whatsapp.SendMessage(PhoneNo, '', Message);
                    InitData();
                end;
            }
        }
    }
    var
        Message: BigText;
        PhoneType: Option " ",Customer,Contact,Vendor,Employee;
        PhoneNo: Text[30];
        SourceNo: Code[20];
        CountryCode: Code[10];
        ReceiverName: Text;

    trigger OnOpenPage()
    begin
        InitData();
    end;

    local procedure GetData()
    var
        WhatsAppMgt: Codeunit "WHA WhatsApp Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        case PhoneType of
            PhoneType::Customer:
                RecRef.Open(Database::Customer);
            PhoneType::Vendor:
                RecRef.Open(Database::Vendor);
            PhoneType::Contact:
                RecRef.Open(Database::Contact);
            PhoneType::Employee:
                RecRef.Open(Database::Employee);
        end;

        FldRef := RecRef.Field(1);
        FldRef.SetRange(SourceNo);
        if RecRef.FindSet() then begin
            if PhoneType in [PhoneType::Customer, PhoneType::Vendor, PhoneType::Contact] then begin
                FldRef := RecRef.Field(2);
                ReceiverName := FldRef.Value;
                FldRef := RecRef.Field(35);
                CountryCode := FldRef.Value;
                FldRef := RecRef.Field(9);
                PhoneNo := FldRef.Value;
            end else
                if PhoneType = PhoneType::Employee then begin
                    FldRef := RecRef.Field(2);
                    ReceiverName := FldRef.Value;
                    FldRef := RecRef.Field(4);
                    if Format(FldRef.Value) <> '' then
                        ReceiverName += ' ' + Format(FldRef.Value);
                    FldRef := RecRef.Field(3);
                    if Format(FldRef.Value) <> '' then
                        ReceiverName += ' ' + Format(FldRef.Value);
                    FldRef := RecRef.Field(25);
                    CountryCode := FldRef.Value;
                    FldRef := RecRef.Field(13);
                    PhoneNo := FldRef.Value;
                end else
                    InitData();
        end else
            InitData();

        WhatsAppMgt.FormatPhoneNo(PhoneNo, CountryCode);
    end;

    local procedure InitData()
    var
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
    begin
        PhoneType := PhoneType::" ";
        SourceNo := '';
        CountryCode := '';
        PhoneNo := '';
        ReceiverName := '';
        Clear(Message);
        CompanyInfo.Get();
        CountryCode := CompanyInfo."Country/Region Code";
        if Country.Get(CountryCode) then
            PhoneNo := '+' + Country."WHA Dial";
    end;
}