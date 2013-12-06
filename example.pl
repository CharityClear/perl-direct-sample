#!/usr/bin/perl -w

use strict;
use Charityclear;

my $cc = Charityclear->new({

	"merchantID"		=>	"100003",
	"amount"		=>	1337,
	"type"			=>	1,
	"action"		=>	"SALE",
	"countryCode"		=>	826,
	"currencyCode"		=>	826,
	"transactionUnique"	=>	time(),
	"orderRef"		=>	"1 Yellow Camel",
	"cardNumber"		=>	"4543059999999982",
	"customerAddress"	=>	"76 Roseby Avenue Manchester",
	"customerPostCode"	=>	"M63X 7TH",
	"cardCVV"		=>	"110",
	"cardExpiryMonth"	=>	"12",
	"cardExpiryYear"	=>	"13",
	"threeDSRequired"	=>	"N",
	"sigKey"		=>	"Circle4Take40Idea",
});

$cc->process();

if ( $cc->responseCode == 0 ) {
	print "Payment Sucessful. Xref: " . $cc->xref() . "\n";
} else {
	print "Payment Failed: " . $cc->responseMessage() . " (" . $cc->responseCode() . ")\n";
}
