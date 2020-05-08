#!/usr/bin/perl

use strict;

###########################################################################
# This is an implementation of the webhook message format used by Gitlab
# to notify a remote service of changes to files. This does not include
# all of the data that Gitlab would include; the data is limited to a set
# of paths that were added/removed/modified between the pushed commits.
# All paths are stored in the "modified" array for simplicity since the 
# TxInfinity config server does not treat the categories differently.
###########################################################################

# 'git diff-tree' will escape certain characters such as " and \, and it will
# additionally wrap the entire string with quotes (") if any escapes are present.
sub stripSurroundingQuotes($) {
        my $inputStr = shift;
	# Remove surrounding quotes if they were added by 'git diff-tree'
	if($inputStr =~ /^\"(.*)\"$/) {
		return $1;
	} else {
		return $inputStr;
	
	}
}

# No JSON library is used here since the structure is simple and does not vary,
# allowing us to avoid including additional libraries with this container.
sub buildJSONText($) {
	my $paths = shift;

	my $jsonText = '{"paths": [';
	my $jsonText = '{"commits": [{ "added":[], "removed":[], "modified":[';

	my $index = 0;

	for my $path (@$paths) {
		$jsonText .= '"' . stripSurroundingQuotes($path) . '"';
		$index++;
		if($index < @$paths) {
			$jsonText .= ",";
		}
	}

	return $jsonText . "]}]}";
}

my $webhook_url = `cat /tmp/tx_webhook_url`;

if((defined $webhook_url) && length($webhook_url) > 0) {

	my $gitRef = <STDIN>;

	my @gitRefParts = split(" ", $gitRef);

	my $beginCommit = $gitRefParts[0];
	my $endCommit = $gitRefParts[1];

	my $pathData;

	if($beginCommit =~ /^0+$/)  {
		# Handle an initial commit
		$pathData = `git diff-tree --no-commit-id --name-only -r $endCommit`;
	} else {
		$pathData = `git diff-tree --no-commit-id --name-only -r $beginCommit $endCommit`;
	}

	my @pathList = split("\n", $pathData);

	if(@pathList > 0) {
		my $pathJson = buildJSONText(\@pathList);
		open(my $pipe, "| curl --silent --connect-timeout 5 -H \"X-Gitlab-Event: Push Hook\" -H \"Content-Type: application/json\" --data-binary \@- -X POST $webhook_url");
		print $pipe $pathJson;
		close($pipe);
	}

}
