# Blitter - A Social Networking App Demo

An demonstration that uses the [Kitura web framework](https://github.com/IBM-Swift/Kitura) to produce a feed of posts that people can follow.

[![Build Status](https://travis-ci.org/IBM-Swift/Blitter.svg?branch=master)](https://travis-ci.org/IBM-Swift/Blitter)
![](https://img.shields.io/badge/Swift-3.0%20RELEASE-orange.svg?style=flat)
![](https://img.shields.io/badge/platform-Linux,%20macOS-blue.svg?style=flat)

## Requires:

 - [XCode 8](https://developer.apple.com/xcode/)
 - [Cassandra 3.4+](http://cassandra.apache.org/) or [ScyllaDB](http://www.scylladb.com/)

## Quick start:

 You can build and run this demo on multiple platforms, such as XCode, macOS Terminal, Linux terminal, or a docker container. The quick start steps vary by how you intend to build the target.

1. Install Cassandra or ScyllaDB:

 On Linux, you can download the latest package from the website. If on macOS, you can install it with Homebrew:

 `brew install cassandra`

2. Set up the schemas with the blitter.sql file:

 CQLsh is in the /bin directory of your Cassandra/ScyllaDB installation.

 `cqlsh -f blitter.sql`

3. Install OpenSSL with:

 `brew install openssl`
  
### Generate an XCode project:

You can use XCode to edit, build, test, and debug your code. To generate an XCode project, you can use the Swift Package Manager to generate one for you. Since we must use the OpenSSL header and library files, we must specify the search paths for these files to the generator script.

 `swift package generate-xcodeproj -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib`


### Building and testing in Linux

1. Build the project

 `swift build`
  
2. Test the project

 `swift test`

## License

Copyright 2016 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
