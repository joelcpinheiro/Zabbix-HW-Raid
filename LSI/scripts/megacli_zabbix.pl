#!/usr/bin/env perl
use Data::Dumper qw(Dumper);

($device, $metric, $raw) = @ARGV;
$device = lc $device;
$metric = lc $metric;
$metric =~ s/_/ /g;

sub collect {
	for $i ('AdpAllInfo','PDList'){
		$status = system("sudo megacli -$i -Aall > /tmp/megacli_$i");
		if ($status != 0){
			print "1\n";
			exit;
		}
	$status = system("sudo megacli -LDInfo -Lall -Aall > /tmp/megacli_LDInfo");
	}
	print "0\n";
}

sub pd {
	$device = @_[0];
	$device =~ s/_/ /g;
	open(FILE,"/tmp/megacli_PDList" ) || die 'Cant open';
	while (<FILE>) {
		$count++;
		$_ =~ s/^\s+|\s+$//g;
		$_ =~ s/\h+/ /g;
		@file = (@file,$_);
		if ( (lc $_)  =~ /^$device/){
			$device_name = @_[0];
            $start = $count; $stop = $start + 48;
            $dev{$device_name}{'self'} = $device_name
		}
	}
		for $i ($start .. $stop){
			#print $i . " => ". @file[$i]."\n";
			@f = split (':',lc @file[$i]);
			@f[0] =~ s/^\s+|\s+$//g;
			@f[1] =~ s/^\s+|\s+$//g;
			$dev{$device_name}{@f[0]} = @f[1];
	}
	#print Dumper \%dev;
	return %dev;
}

sub ld {
	$device = @_[0];
	$device =~ s/_/ /g;
	open(FILE,"/tmp/megacli_LDInfo" ) || die 'Cant open';
	while (<FILE>) {
		$count++;
		$_ =~ s/^\s+|\s+$//g;
		$_ =~ s/\h+/ /g;
		@file = (@file,$_);
		if ( (lc $_)  =~ /^$device/){
			$device_name = @_[0];
            $start = $count; $stop = $start + 18;
            $dev{$device_name}{'self'} = $device_name
		}
	}
		for $i ($start .. $stop){
			#print $i . " => ". @file[$i]."\n";
			@f = split (':',lc @file[$i]);
			@f[0] =~ s/^\s+|\s+$//g;
			@f[1] =~ s/^\s+|\s+$//g;
			$dev{$device_name}{@f[0]} = @f[1];
	}
	#print Dumper \%dev;
	return %dev;
}

sub ld_all {
	open(FILE,"/tmp/megacli_LDInfo" ) || die "Can't open file";
	@file = 'start';
	while (<FILE>) {
		$count++;
		$_ =~ s/^\s+|\s+$//g;
		$_ =~ s/\h+/ /g;
		@file = (@file,$_);
		#print $count ." -> " . lc @file[$count]."\n";
		if ( (lc $_)  =~ /^virtual drive:/){
			#  позиция в файле откуда начинается следующий диск
              		@chank = (@chank,$count);
		}
		for $index (0..$#chank){
			@drive_index = split(':', @file[$chank[$index]]);
        	@drive_index[1] =~ s/^\s+|\s+$//g;
        	@file[$chank[$index]] = lc @file[$chank[$index]];
			$dev_ld{@file[$chank[$index]]}{'self'} = 	@file[$chank[$index]];
			$start =  $chank[$index]; $stop = ($chank[$index]+18);
			for $i ($start..$stop){
				#print $i . " => ". @file[$i]."\n";
				@f = split (':',lc @file[$i]);
				@f[1] =~ s/^\s+|\s+$//g;
				$dev_ld{lc @file[$chank[$index]]}{@f[0]} = @f[1];
			}
		}
	}
	#print Dumper \%dev_ld;
	return %dev_ld;
}


sub pd_all {
	open(FILE,"/tmp/megacli_PDList" ) || die "Can't open file";
	@file = 'start';
	while (<FILE>) {
		$count++;
		$_ =~ s/^\s+|\s+$//g;
		$_ =~ s/\h+/ /g;
		@file = (@file,$_);
		#print $count ." -> " . @file[$count]."\n";
		if ( $_  =~ /^Slot Number/){
			#  позиция в файле откуда начинается следующий диск
              		@chank = (@chank,$count);
		}
		for $index (0..$#chank){
			@drive_index = split(':', @file[$chank[$index]]);
        	@drive_index[1] =~ s/^\s+|\s+$//g;
        	@file[$chank[$index]] = lc @file[$chank[$index]];
			$dev_pd{@file[$chank[$index]]}{'self'} = 	@file[$chank[$index]];
			$start =  $chank[$index]; $stop = ($chank[$index]+49);
			for $i ($start..$stop){
				@f = split (':',lc @file[$i]);
				@f[1] =~ s/^\s+|\s+$//g;
				$dev_pd{lc @file[$chank[$index]]}{@f[0]} = @f[1];
			}
		}
	}
	#print Dumper \%dev_pd;
	return %dev_pd;
}


sub status {
	$arg = lc @_[0];
    	%status = (
  		 'online' 	=> 0
		,'optimal'	=> 0
  		,'zmm optimal' 	=> 0
  		,'on' 		=> 0
  		,'normal' 	=> 0
  		,'enabled' 	=> 0
		,'ready'        => 0
  		,'enabled (write-back)' => 0
  		,'rebuilding' => 3
  		,'global hot-spare' => 2
		,'dedicated hot-spare' => 2
		,'active' => 0
    	);

    if (length($status{$arg}) < 1 ) {
    	return 1;
    }
    else {
    	return $status{$arg};
    }
}

sub discovery_pd {
	undef $count; undef @chank;
	%pd = pd_all();
	print "{\n\"data\": [";
	$count = 0;
	while ( my ($key, $value) = each(%pd) ) {
	 	        $key =~ s/ /_/g;
	 	        if ($count != 0){
		    		print 	",\n{\"{#HARDDISK}\":\"" .  $key . "\"}";
		    	} else {
		    		print 	"\n{\"{#HARDDISK}\":\"" .  $key . "\"}";
		    	}
		    	$count++;
    }
}

sub discovery_ld {
	undef $count; undef @chank;
    %ld = ld_all();
	$count = 0;
    while ( my ($k, $v) = each(%ld) ) {
    	@key  = split(' ',$k);
    	$k = "@key[0]_@key[1]_@key[2]";
	 	#$k =~ s/ /_/g;
	 	if ($count != 0){
		    print 	",\n{\"{#HARDDISK}\":\"" .  $k . "\"}";
		} else {
		    print 	",\n{\"{#HARDDISK}\":\"" .  $k . "\"}";
		}
		$count++;
    }
    print "\n]\n}\n";
}


if ($metric =~ /^collect/) {
	collect();
}

if ($metric =~ /^discovery/) {
	discovery_pd();
	discovery_ld();
}

if ($device =~ /^slot_number/) {
	%pd = pd($device);
	if ($raw){
		print $pd{$device}{$metric}."\n";
	}
	else {
		print status($pd{$device}{$metric})."\n";
	}
}

if ($device =~ /^virtual_drive/) {
	%data = ld($device);
	if ($raw){
	 	print $data{$device}{$metric}."\n";
	}
	else {
	 	print status($data{$device}{$metric})."\n";
	}
}
