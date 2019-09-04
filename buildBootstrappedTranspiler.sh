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
