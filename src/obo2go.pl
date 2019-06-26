# ### term    namespace    level   name    path
#
my $file = shift;
open IN, $file or die $!;
$/="[Term]";
<IN>;
while(<IN>){
	my $line = $_;
	$line=~s/\[Typedef\].*$//g;
	my @arr = split(/\n/, $line);
	my ($id, $name, $space, @father);
	foreach my $i (@arr){
		next if $i=~/^\s*$/;
		$id = $1 if $i=~/^id:\s(GO:\d+)/;
		$name = $1 if $i=~/^name:\s(.*)/;
		$space = $1 if $i=~/^namespace:\s(.*)/;
		push @father, $1 if $i=~/is_a:\s(GO:\d+)/;
	}
	print join("\t", $id, "$space:$name", join(";",@father)) . "\n";
}
close IN;
