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

# Update AST dumps
echo " ➡️  Updating AST dumps for tests and library templates..."
perl dumpAST.pl Example\ ASTs/*.swift
perl dumpAST.pl Test\ Files/*.swift
perl dumpAST.pl Library\ Templates/*.swift

# Lint swift files
echo " ➡️  Linting swift files..."

if which swiftlint >/dev/null; then
  swiftlint lint
else
  echo "warning: SwiftLint not installed."
fi
