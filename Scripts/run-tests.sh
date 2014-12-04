#!/bin/bash

set -e
set -u

script_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
root_directory="$script_directory/.."

pushd "$root_directory/Tests"
pod update
xcodebuild -workspace ISArgumentParserTests.xcworkspace -scheme ISArgumentParserTests clean test
popd
