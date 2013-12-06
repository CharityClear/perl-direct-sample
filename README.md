Charityclear.pm
==================================================

Direct integration for charityclear

Example

    use strict; 
    use Charityclear;
    my $cs = Charityclear->new({

            "merchantID"            =>      "100003",
            "amount"                =>      1337,
            "type"                  =>      1,
            "action"                =>      "SALE",
            "countryCode"           =>      826,
            "currencyCode"          =>      826,
            "transactionUnique"     =>      time(),
            "orderRef"              =>      "1 Yellow Camel",
            "cardNumber"            =>      "4543059999999982",
            "customerAddress"       =>      "76 Roseby Avenue Manchester",
            "customerPostCode"      =>      "M63X 7TH",
            "cardCVV"               =>      "110",
            "cardExpiryMonth"       =>      "12",
            "cardExpiryYear"        =>      "13",
            "threeDSRequired"       =>      "N",
            "sigKey"                =>      "Circle4Take40Idea",
    });

    $cs->process();

    if ( $cs->responseCode == 0 ) { print "Payment Sucessful. Xref: " .
    $cs->xref() . "\n"; } else { print "Payment Failed: " .
    $cs->responseMessage() . " (" . $cs->responseCode() . ")\n"; }

DESCRIPTION
This modules provides integration for Charityclear. For more info, see www.charityclear.com.
The sigKey is the preshared signature key. This should be create in the MMS
