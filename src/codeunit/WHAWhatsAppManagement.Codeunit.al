codeunit 83255 "WHA WhatsApp Management"
{
    internal procedure SendMessage(PhoneNo: Text[30]; CountryCode: Code[10]; Message: BigText)
    var
        //https://wa.me/whatsappphonenumber/?text=urlencodedtext
        WhatsappTxt: Label 'https://wa.me/%1/?text=%2', comment = '%1 = Phone no., %2 = Message text';
    begin
        FormatPhoneNo(PhoneNo, CountryCode);
        Hyperlink(StrSubstNo(WhatsappTxt, PhoneNo, Message));
    end;

    internal procedure FormatPhoneNo(var PhoneNo: Text[30]; CountryCode: Code[10])
    var
        IsHandled: Boolean;
    begin
        //https://faq.whatsapp.com/general/contacts/how-to-add-an-international-phone-number
        //https://datahub.io/JohnSnowLabs/iso-3166-country-codes-itu-dialing-codes-iso-4217-currency-codes
        //https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers
        IsHandled := false;
        OnBeforeFormatPhoneNo(PhoneNo, CountryCode, IsHandled);
        if IsHandled then
            exit;

        PhoneNo := DelChr(PhoneNo, '=', ' -()');

        if CountryCode = '' then
            exit;

        FormatPhonePrefix(PhoneNo, CountryCode);
        if CopyStr(PhoneNo, 1, 1) <> '+' then
            PhoneNo := Format('+' + PhoneNo);
    end;

    local procedure FormatPhonePrefix(var PhoneNo: Text[30]; CountryCode: Code[10])
    var
        Country: Record "Country/Region";
    //DialErr: Label 'Country dial %1 not found on %2', Comment = '%1 = Country Dial, %2 = Phone No.';
    begin
        if Country.Get(CountryCode) then begin
            if Country."WHA Dial" = '' then
                exit;

            if CopyStr(PhoneNo, 2, StrLen(Country."WHA Dial")) = Country."WHA Dial" then
                PhoneNo := DelStr(PhoneNo, 1, StrLen(Country."WHA Dial") + 1);
            PhoneNo := Format('+' + Country."WHA Dial" + PhoneNo);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFormatPhoneNo(var PhoneNo: Text[30]; CountryCode: Code[10]; var IsHandled: Boolean)
    begin
    end;
}