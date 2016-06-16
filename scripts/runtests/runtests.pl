#!/usr/bin/perl -w
#
# Copyright 2016  Andreas Cord-Landwehr <cordlandwehr@kde.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



use Cwd;
use Cwd 'abs_path';
use File::Basename;
use File::Temp 'tempdir';
use File::Path 'remove_tree';
use Getopt::Long;
use Pod::Usage;
use XML::Simple;
use Term::ANSIColor;

my $host_arch = "linux-x86";
my $android_sdk_dir = "$ENV{'ANDROID_SDK_ROOT'}";

# absolute path for ADB 
my $adb_tool="$android_sdk_dir/platform-tools/adb";

# make sure we have at least on device attached
system("$adb_tool devices") == 0 or die "No device found, please plug in/start at least one device/emulator\n";

# unit test names
my $packageName = "org.kde.frameworkstest";
my $intentName = "$packageName/org.qtproject.qt5.android.bindings.QtActivity";

#TODO find & build tests here

#FIXME change hardcoded test
print "=== INSTALL TEST... ===\n";
system("$adb_tool install /opt/android/kde/build/frameworks/attica/persontest_build_apk/bin/QtApp-debug.apk");
print "=== TEST INSTALLED ===\n";

# run test and start logging thread
print "=== STARTING TEST... ===\n";

my $testLib="-o /data/data/foo/output.txt,txt";
system("$adb_tool shell am start -e \QapplicationArguments \Q$testLib\E\E -n ${intentName}");

# uncomment to get full debug output
# system("$adb_tool -e logcat");

print "=== TEST STARTED ===\n";
# download
system("$adb_tool pull /data/data/$packageName/output.txt /tmp/baa.txt");

# uninstall
print "=== UNINSTALL TEST... ===\n";
system("$adb_tool uninstall ${packageName}");
print "=== TEST UNINSTALLED ===\n";

