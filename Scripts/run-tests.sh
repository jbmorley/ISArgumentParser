#!/bin/bash

set -e
set -u

script_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
root_directory="$script_directory/.."
tests=ISArgumentParserTests

pushd "$root_directory/Tests"
pod update
xcodebuild -workspace "$tests.xcworkspace" -scheme "$tests" clean build | xcpretty -c
xcodebuild -workspace "$tests.xcworkspace" -scheme "$tests" test
popd
