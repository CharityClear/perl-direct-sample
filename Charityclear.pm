require 5.000;

$VERSION = 2013.4;

package Charityclear;

use strict;
use Carp;
use LWP::UserAgent;
use LWP::Protocol::https;
use Digest::SHA qw(sha512_hex);
use URL::Encode qw(url_encode);

my $GATEWAY_URL = "https://gateway.charityclear.com/direct/";

sub new {
    my ($class, $fields) = @_;

    my $self = bless {}, $class;

    # Initialise parameters
    return $self->_init($fields);
}

sub _init {
	my ($self, $fields) = @_;
	my @keys = keys $fields;
	my @values = values $fields;
	while ( @keys ) {
		$self->{request}->{pop @keys} = pop @values;
	}

	# Validation
	if ( ! $self->{request}->{merchantID} ) {
		carp("Missing Merchant ID");
	} 
	if ( ! $self->{request}->{amount} ) {
		carp("Missing amount");
	}
	if ( ! $self->{request}->{type} ) {
		$self->{request}->{type} = 1;
	}
	if ( ! $self->{request}->{action} ) {
		$self->{request}->{action} = "SALE";
	}
	if ( ! $self->{request}->{countryCode} ) {
		carp("No Country Code found");
	}
	if ( ! $self->{request}->{currencyCode} ) {
		carp("No Currency Code Found");
	}
	if ( ! $self->{request}->{sigKey} ) {
		carp("No Signature Key Found");
	}
	$self->{sigkey} = $self->{request}->{sigKey};
	delete($self->{request}->{sigKey});
	return $self;
}

sub process {
	my ($self) = @_;
	
	# Build the form
	$self->_build_form();

	my $browser = LWP::UserAgent->new;

	my $req = HTTP::Request->new(POST => $GATEWAY_URL);
	$req->content_type('application/x-www-form-urlencoded');
	$req->content($self->{form});

	# Send the request

	my $res = $browser->request($req);

	# Check for success
	if ($res->is_success()) {
		$self->{success} = 1;
		$self->{status} = $res->status_line;

		# Parse the response
		$self->_parse_response($res->content());
	} else {
		$self->{success} = 0;
		$self->{status} = $res->status_line;
	}

	return;
}

sub _build_form {
	my ($self) = @_;

	for my $field (sort keys %{$self->{request}}) {
		$self->{form} .= "$field=" . url_encode($self->{request}->{$field}) . '&';
	}

	# Remove the trailing &
	chop $self->{form};
	
	# Manually replace ~ for hex as url_encode has some bugs
	$self->{form} =~ s/~/%7E/g;

	# Create the signature and append it to the end of the string
	my $signature = sha512_hex($self->{form} . $self->{sigkey});
	$self->{form} .= "&signature=$signature";
	return;
}

sub _parse_response {
    my ($self, $content) = @_;

    # Loop through the response parameters
    for my $kv (split /\&/, $content) {
        my $k;
        my $v;
        my $e;

        for my $c (split //, $kv) {
            if ($c eq '=' && !$v) {
                $e++;
                next;
            }
            elsif ($e) {
                $v .= $c;
            }
            else {
                $k .= $c;
            }
        }
		
        $self->{response}->{$k} = $v;
    }

    return;
}

sub status {
    return shift->{status};
}

sub success {
    return shift->{success};
}

sub responseMessage {
	my $msg = shift->{response}->{responseMessage};
	$msg =~ s/\+/\ /g;
    return $msg;
}

sub responseCode {
    return shift->{response}->{responseCode};
}

sub xref {
    return shift->{response}->{xref};
}

sub threeDSACSURL {
	return shift->{response}->{threeDSACSURL};
}

1;

__END__

=head1 NAME

Charityclear.pm -- Direct integration for charityclear

=head1 SYNOPSIS

Example:

use strict;
use Charityclear;

my $cs = Charityclear->new({

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

$cs->process();

if ( $cs->responseCode == 0 ) {
	print "Payment Sucessful. Xref: " . $cs->xref() . "\n";
} else {
	print "Payment Failed: " . $cs->responseMessage() . " (" . $cs->responseCode() . ")\n";
}

=head1 DESCRIPTION

This modules provides integration for Charityclear. For more info, see www.charityclear.com.

The sigKey is the preshared signature key. This should be create in the MMS

=head1 GENESIS

Written by Adam Deacon <adam.deacon@charityclear.com>.

=head1 LICENSE

Copyright (C) 2013 Charityclear Ltd
License hereby
granted for anyone to use, modify or redistribute this module at
their own risk.  Please feed useful changes back to solutions@charityclear.com
