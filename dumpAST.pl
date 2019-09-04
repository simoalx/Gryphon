#
# Copyright 2018 Vinícius Jorge Vendramini
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use File::Basename;
use File::stat;
use Time::localtime;

$swift5Toolchain = "org.swift.4220190203a";

foreach (@ARGV) {
	$swiftFilePath = $_;
	
	$astFilePath = $swiftFilePath;
	$astFilePath =~ s/(.*).swift/$1.swiftASTDump/;
	
	# If the AST file already exists, check if it's up to date
	if (-e $astFilePath) {
		# If it's up to date, skip it
		if (-C $swiftFilePath > -C $astFilePath) {
			print "Skipping $swiftFilePath...\n";
			next;
		}
	}
	
	print "Processing $swiftFilePath...\n";

	# Get the AST dump from the swift compiler
	$swiftASTDump = `xcrun -toolchain $swift5Toolchain swiftc -dump-ast -module-name=ModuleName -output-file-map=output-file-map.json \"$swiftFilePath\" 2>&1`;

	# Remove possible warnings printed before the AST dump
	$swiftASTDump =~ s/^((.*)\n)*\(source\_file/\(source\_file/;
	
	# Get the name of the output file
	if ($swiftFilePath =~ /(.*).swift/) {
		# Write to the output file
		open(my $fh, '>', $astFilePath) or die "Could not open file '$$astFileName' $!";
		print $fh $swiftASTDump;
		close $fh;
	}
}

print "Done!\n";
