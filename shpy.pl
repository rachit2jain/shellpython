#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------
#				 written by Rachit Jain (z5088424@cse.unsw.edu.au)					#
#							Shell to Python Translator 								#
#							written in September,2015								#
#																					#
#																					#
#																					#
#-------------------------------------------------------------------------------------
$os_count=0;
$rflag=0;
$dflag=0;
$subprocess_count=0;
$ospath_count=0;
$sys=0;
while ($line = <>) 
{
	chomp $line;

	if($line =~ /^(\s+)/)    #indentation
	{
		 print "$1";
	}

    if ($line =~ /^#!/ && $. == 1) 
	{
		print "#!/usr/bin/python2.7\n";
    }

###################################################################################

#--------------------variables----------------------------------------------------
	elsif($line =~ /([^\'\"\s]+)=([^\'\"\s\\]+)/)		#variable declaration taken care of 
	{
		$line=~ /([a-zA-Z_0-9]+)\s*=([a-zA-Z 0-9]+)/; #variable name might contain
		print "$1 = '$2'\n";
	}


####################################################################################
	
#-------------------echo------------------------------------------------------------	
	elsif ($line =~ /echo/) 
	{		$line=~ /([echo]+)\s*([0-9a-zA-Z \$!_ \#",'\-.=\/]+)/ ;		#dividing echo into 2 parts
			$matter = $2;
			if($matter =~ /\'/)					#if matter has single quotes
			{
				print "print $matter\n";				#matter 
				
			}
			elsif($matter =~ /\"/)				#if matter has double quotes
			{
				if($matter !~ /\$/)
				{
					print "print $matter\n";
				}
				else
				{
					@words = split / /, $matter;
				    print "print";
				    foreach $word (@words)
				    {
				       $word =~ s/^\$//g;
			           print " $word";
			        }
			        print "\n";

				}
			}
			elsif($matter=~ /\$[^\d]+/)			#if matter has no digits
			{
				@words = split / /, $matter;
				print "print ";
				foreach $word (@words)
				{
					$word =~ s/^\$//g;
				}
				print join (", ", @words);
				print "\n";
			}
			elsif($matter =~ /[\$]+/ && $matter =~ /[0-9]/)		#if matter has $ and digits
			{
				@words = split / /, $matter;
				if($sys==0)
				{
					print "import sys\n";
					$sys=1;
				}
				print "print";
				foreach $word( @words)
				{	
				
					if($word =~ /([\$\d]+)/)
					{
							$word =~ s/\$//g;
							print " sys.argv[$word]"; 
					}
					elsif($word !~ /(\$[\d]+)/)
					{
						print " '$word',";
					}
				}
				print "\n";
			}
			else
			{
				@words = split / /, $matter;
				print "print \'";
				print join ("\', \'", @words);
				print "\'\n";
			}
	}
#####################################################################################

#---------------------------------------if/else statements---------------------------#
	elsif($line =~ /if/)
	{
		@words = split / /, $line;
		foreach $word (@words)
		{	if($word eq '-r')							#rflag
			{	
				$rflag=1;
				if($os_count==0)
				{
					print "import os\n";
					$os_count=1;
				}
			}	
			elsif($word eq '-d')						#dflag
			{	
				if($ospath_count==0)
				{
					print "import os.path\n";
					$ospath_count=1;
				}
				$dflag=1;
			}

		}
		if ($rflag == 1)
		{
			$line =~ /([elif]+)\s*([test\[]+)\s*([-r]+)\s*([a-zA-Z0-9\]\/]+)/;
			print "if os.access('$4', os.R_OK):\n";
		}
		elsif ($dflag ==1)
		{
			$line =~ /([elif]+)\s*([test\[]+)\s*([-d]+)\s*([a-zA-Z0-9\]\/]+)/;
			print "if os.path.isdir('$4'):\n";
		}

		else
		{
			$line =~ /([elif]+)\s*([test\[]+)\s*([a-zA-Z0-9\._]+)\s*([=]*)\s*([a-zA-Z0-9]*)/;
			if($1 eq "if")
			{
				print "if \'$3\' == \'$5\':\n";
			}
			elsif($1 eq "elif")
			{
				print "elif \'$3\' == \'$5\':\n";
			}

		}	
	}
	elsif($line =~ /then/)			#do nothing
	{
	}
	elsif($line =~ /else/)
	{
		print "else:\n"
	}
	elsif($line =~ /fi/)				#do nothing
	{
	}
####################################################################################
#----------------------------------cd/ls/id/date/pwd---------------------------------#
	elsif($line=~ /cd/)
	{
		$line=~ /([cd]+)\s*([\/a-zA-Z]+)/;
		$matter=$2;
		if($os_count==0)
		{
			print "import os\n";
			$os_count=1;
		}
		print "os.chdir(\'$matter\')\n";
	}
	elsif ($line =~ /ls/ || $line=~ /pwd/ ||$line=~ /id/ || $line=~ /date/)
	{
		if($subprocess_count==0)
		{
			print "import subprocess\n";
			$subprocess_count=1;
		}
		if($line =~ /ls/)
		{
			$line=~ /([ls]+)\s*([\- l]+)\s*([a-zA-Z \/ \-"']+)/;
			$matter= $3;
			if($matter ne "")
			{
				if($2 eq "-l ")
				{
					print "subprocess.call(['ls', '-l', '$matter'])\n";
				}
				else
				{
					print "subprocess.call(['ls', '$matter'])\n";
				}
			}
			else
			{	
				if($2 eq "-l ")
				{
				 	print "subprocess.call(['ls', '-l')\n";
				}
				else
				{
					print "subprocess.call(['ls'])\n";
				}
			}
		}
		elsif($line eq "pwd")
		{
			$line=~ /([pwd]+)\s*([a-zA-Z "']+)/;
			print "subprocess.call(['pwd'])\n";
		}
		elsif($line eq "id")
		{
			$line=~ /([id]+)\s*([a-zA-Z "']+)/;
			print "subprocess.call(['id'])\n";
		}
		elsif($line eq "date")
		{
			
			print "subprocess.call(['date'])\n";
		}
		elsif($line eq "ls")
		{
			$line=~ /([ls]+)\s*([a-zA-Z \/"']+)/;
			$matter = $2;
			print "subprocess.call(['ls' '$matter'])\n";
		}
		
	}
	elsif($line eq '')
	{
		print "\n";
	}
####################################################################################
#------------------------------------for statements---------------------------------#
	elsif($line =~ /for/)
	{
		print "import sys\n";
		$line=~ /([for]+)\s*([a-zA-Z]+)\s*([in]+)\s*([a-zA-Z 0-9]+)/;
		$matter = $4;
		@words= split / / , $matter;
		print "for $2 in \'";
		print join("\',\'" , @words);
		print "\':\n";

	}
	
	
	elsif($line=~ /do/)     #to remove do and done because of for loop
	{
		if($line eq "do")			#do nothing
		{
		}
	}

	elsif($line =~ /read/)
	{
		$line =~ /([read]+)\s*([a-zA-Z]+)/;
		$matter = $2;
		print "$matter = sys.stdin.readline().rstrip()\n";
	}

	elsif($line =~ /exit (\d+)/)
	{
		print "sys.exit($1)\n";	
	}
#############################################################################
	else 
	{
        # Lines we can't translate are turned into comments
        print "#$line\n";
    }
}
