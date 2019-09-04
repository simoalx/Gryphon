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

kotlinc -include-runtime \
	-d Bootstrap/kotlin.jar \
	\
	Bootstrap/KotlinStandardLibrary.kt \
	\
	Bootstrap/ASTDumpDecoder.kt \
	Bootstrap/Compiler.kt \
	Bootstrap/Driver.kt \
	Bootstrap/Extensions.kt \
	Bootstrap/GryphonAST.kt \
	Bootstrap/KotlinTranslator.kt \
	Bootstrap/LibraryTranspilationPass.kt \
	Bootstrap/OutputFileMap.kt \
	Bootstrap/PrintableAsTree.kt \
	Bootstrap/SharedUtilities.kt \
	Bootstrap/SourceFile.kt \
	Bootstrap/SwiftAST.kt \
	Bootstrap/SwiftTranslator.kt \
	Bootstrap/TranspilationPass.kt \
	\
	Bootstrap/Shell.kt \
	Bootstrap/Utilities.kt \
	\
	Bootstrap/main.kt \
	Bootstrap/KotlinTests.kt \
	Bootstrap/ASTDumpDecoderTest.kt \
	Bootstrap/ExtensionsTest.kt \
	Bootstrap/PrintableAsTreeTest.kt \
	Bootstrap/ShellTest.kt \
	Bootstrap/UtilitiesTest.kt;
