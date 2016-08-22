#!/usr/bin/perl -w

use strict;
use warnings;
use File::Copy;
use Cwd qw(abs_path);
use Data::Dumper;

###############################
# GLOBALS
###############################
# path to directory containing script files
my $rootdir = substr(abs_path($0), 0, rindex(abs_path($0), "/") + 1);

executeAllTests();

###############################

sub executeAllTests {
    # parse CTestTestfile.cmake in autotest subfolder for all provided unit tests
    my $filename = "autotests/CTestTestfile.cmake";
    open(my $fh, '<:encoding(UTF-8)', $filename)
        or die "Could not open file '$filename' $!";

    my @matches;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /add_test\((.*) \"(.*)\"\)/s) {
            push @matches, $2;
        }
    }
    print "Found Tests:\n";
    print "$_\n" for @matches;
    print "\n";

    # now execute for every match
    # FIXME use only the first one
    print "Generating APK for unit test $matches[0]\n";
    # directory with tailing '/'
    my $dir = substr($matches[0], 0, rindex($matches[0], "/") + 1);
    my $test = substr($matches[0], rindex($matches[0], "/") + 1);

    executeTest($dir, $test);
}

# execute the given test case
# @param $dir test directory
# @param $test the test name
sub executeTest {
    my $dir = shift;
    my $test = shift;

    # directory for perform the packaging
    my $apkdir = "$dir/apk_$test/";
    # TODO remove previous directory
    mkdir "$apkdir";

    copy("$rootdir/manifest/AndroidManifest.xml", "$apkdir/AndroidManifest.xml") or die "Copy failed: $!";

    generateDeploymentFile($dir, $test, $apkdir);

    # COMMAND $<TARGET_FILE_DIR:Qt5::qmake>/androiddeployqt --input "${QTANDROID_EXPORTED_TARGET}-deployment.json" --output "${EXPORT_DIR}" --deployment bundled "\\$(ARGS)"

    # TODO run test now!
}

# generate $test-deployment.json file
# @param $dir test directory
# @param $test the test name
# @param $apkdir the temporary directory for executing the test
sub generateDeploymentFile {
    my $dir = shift;
    my $test = shift;
    my $apkdir = shift;

    # parse CMake generated dependencies
    # NOTE: same code is in the android toolchain and we should merge it
    open(my $fh, '<:encoding(UTF-8)', "$dir/CMakeFiles/$test.dir/link.txt")
        or die "Could not open file '$dir/CMakeFiles/$test.dir/link.txt' $!";
    my $row = <$fh>;
    chomp $row;
    my @libCandidates = ($row =~ /[^ ]+\.so/g);

    #now we filter Qt5 libraries, because Qt wants to take care about these itself
    for (my $index = $#libCandidates; $index >= 0; --$index) {
        splice @libCandidates, $index, 1
            if $libCandidates[$index] =~ /.*\/libQt5.*/;
    }
    # resolve relative paths
    for (my $index = $#libCandidates; $index >= 0; --$index) {
        if ($libCandidates[$index] =~ /^\..*/) { # any path starting with "."
            $libCandidates[$index] = "$dir/$libCandidates[$index]";
        }
    }
#     print "Adding the following libraries to APK:\n";
#     print Dumper(@libCandidates);
    my $extralibs = join(',', @libCandidates);

    # set further variables
    my $Qt5_PATH = $ENV{'Qt5_android'};
    my $ANDROID_NDK = $ENV{'ANDROID_NDK'};
    my $ANDROID_SDK_ROOT = $ENV{'ANDROID_SDK_ROOT'};
    # TODO hardcoded for now:
    my $ANDROID_TOOLCHAIN = "arm-linux-androideabi";
    my $ANDROID_ABI = "armeabi-v7a";
    my $ANDROID_GCC_VERSION = "4.9";
    my $NDK_HOST  = "linux-x86_64";
    # set(ANDROID_API_LEVEL "14" CACHE string "Android API Level")
    my $ANDROID_SDK_BUILD_TOOLS_REVISION = "21.1.1";

    # do same computation as cmake toolchain
    my $executable_dest_path = "$apkdir/libs/$ANDROID_ABI/lib$test.so";

    # write file
    my $deploymentFile = "{
    \"qt\": \"$Qt5_PATH\",
    \"sdk\": \"$ANDROID_SDK_ROOT\",
    \"ndk\": \"$ANDROID_NDK\",
    \"toolchain-prefix\": \"$ANDROID_TOOLCHAIN\",
    \"tool-prefix\": \"$ANDROID_TOOLCHAIN\",
    \"toolchain-version\": \"$ANDROID_GCC_VERSION\",
    \"ndk-host\": \"$NDK_HOST\",
    \"target-architecture\": \"$ANDROID_ABI\",
    \"application-binary\": \"$executable_dest_path\",
    \"android-extra-libs\": \"$extralibs\",
    \"android-package-source-directory\": \"$apkdir\",
    \"sdkBuildToolsRevision\": \"$ANDROID_SDK_BUILD_TOOLS_REVISION\"
    }\n";
    open($fh, '>', "$dir/$test-deployment.json");
    print $fh $deploymentFile;
    close $fh;
    print "Created deployment file: $dir/$test-deployment.json\n";
}
