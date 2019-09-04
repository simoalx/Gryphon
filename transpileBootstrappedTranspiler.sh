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

./.build/debug/Gryphon \
	-emit-kotlin \
	-output-file-map=output-file-map.json \
	-indentation=4 \
	-q \
	\
	Sources/GryphonLib/SwiftStandardLibrary.swift \
	\
	Sources/GryphonLib/ASTDumpDecoder.swift \
	Sources/GryphonLib/Compiler.swift \
	Sources/GryphonLib/Driver.swift \
	Sources/GryphonLib/Extensions.swift \
	Sources/GryphonLib/GryphonAST.swift \
	Sources/GryphonLib/KotlinTranslator.swift \
	Sources/GryphonLib/LibraryTranspilationPass.swift \
	Sources/GryphonLib/OutputFileMap.swift \
	Sources/GryphonLib/PrintableAsTree.swift \
	Sources/GryphonLib/SharedUtilities.swift \
	Sources/GryphonLib/SourceFile.swift \
	Sources/GryphonLib/SwiftAST.swift \
	Sources/GryphonLib/SwiftTranslator.swift \
	Sources/GryphonLib/TranspilationPass.swift
