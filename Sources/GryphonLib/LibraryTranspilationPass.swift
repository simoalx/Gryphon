//
// Copyright 2018 Vinícius Jorge Vendramini
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public struct TranspilationTemplate {
	let expression: Expression
	let string: String

	static var templates: ArrayClass<TranspilationTemplate> = []
}

public class RecordTemplatesTranspilationPass: TranspilationPass {
	// declaration: constructor(ast: GryphonAST): super(ast) { }

	override func replaceFunctionDeclaration( // annotation: override
		_ functionDeclaration: FunctionDeclaration)
		-> ArrayClass<Statement>
	{
		if functionDeclaration.prefix == "gryphonTemplates",
			functionDeclaration.parameters.isEmpty,
			let statements = functionDeclaration.statements
		{
			let topLevelExpressions: ArrayClass<Expression> = []
			for statement in statements {
				if let expressionStatement = statement as? ExpressionStatement {
					topLevelExpressions.append(expressionStatement.expression)
				}
			}

			var previousExpression: Expression?
			for expression in topLevelExpressions {
				if let templateExpression = previousExpression {
					guard let literalString = getStringLiteralOrSum(expression) else {
						continue
					}
					let cleanString = literalString.removingBackslashEscapes
					TranspilationTemplate.templates.insert(
						TranspilationTemplate(
							expression: templateExpression, string: cleanString),
						at: 0)
					previousExpression = nil
				}
				else {
					previousExpression = expression
				}
			}

			return []
		}

		return super.replaceFunctionDeclaration(functionDeclaration)
	}

	/// Some String literals are written as sums of string literals (i.e. "a" + "b") or they'd be
	/// too large to fit in one line. This method should detect Strings both with and without sums.
	private func getStringLiteralOrSum(_ expression: Expression) -> String? {

		if let stringExpression = expression as? LiteralStringExpression {
			return stringExpression.value
		}

		if let binaryExpression = expression as? BinaryOperatorExpression,
			binaryExpression.operatorSymbol == "+",
			binaryExpression.typeName == "String"
		{
			if let leftString = getStringLiteralOrSum(binaryExpression.leftExpression),
				let rightString = getStringLiteralOrSum(binaryExpression.rightExpression)
			{
				return leftString + rightString
			}
		}

		return nil
	}
}

public class ReplaceTemplatesTranspilationPass: TranspilationPass {
	// declaration: constructor(ast: GryphonAST): super(ast) { }

	override func replaceExpression( // annotation: override
		_ expression: Expression)
		-> Expression
	{
		for template in TranspilationTemplate.templates {
			if let matches = expression.matches(template.expression) {

				let replacedMatches = matches.mapValues { // kotlin: ignore
					self.replaceExpression($0)
				}
				// insert: val replacedMatches = matches.mapValues {
				// insert: 	replaceExpression(it.value)
				// insert: }.toMutableMap()

				return TemplateExpression(
					range: expression.range,
					pattern: template.string,
					matches: replacedMatches)
			}
		}
		return super.replaceExpression(expression)
	}
}

extension Expression {
	func matches(_ template: Expression) -> DictionaryClass<String, Expression>? {
		let result: DictionaryClass<String, Expression> = [:]
		let success = matches(template, result)
		if success {
			return result
		}
		else {
			return nil
		}
	}

	private func matches(
		_ template: Expression, _ matches: DictionaryClass<String, Expression>) -> Bool
	{
		let lhs = self
		let rhs = template

		if let declarationExpression = rhs as? DeclarationReferenceExpression {
			if declarationExpression.identifier.hasPrefix("_"),
				lhs.isOfType(declarationExpression.typeName)
			{
				matches[declarationExpression.identifier] = lhs
				return true
			}
		}

		if let lhs = lhs as? LiteralCodeExpression, let rhs = rhs as? LiteralCodeExpression {
			return lhs.string == rhs.string
		}
		if let lhs = lhs as? ParenthesesExpression,
			let rhs = rhs as? ParenthesesExpression
		{
			return lhs.expression.matches(rhs.expression, matches)
		}
		if let lhs = lhs as? ForceValueExpression,
			let rhs = rhs as? ForceValueExpression
		{
			return lhs.expression.matches(rhs.expression, matches)
		}
		if let lhs = lhs as? DeclarationReferenceExpression,
			let rhs = rhs as? DeclarationReferenceExpression
		{
			return lhs.identifier == rhs.identifier &&
				GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName)) &&
				lhs.isImplicit == rhs.isImplicit
		}
		if let lhs = lhs as? OptionalExpression,
			let rhs = rhs as? OptionalExpression
		{
			return lhs.expression.matches(rhs.expression, matches)
		}
		if let lhs = lhs as? TypeExpression,
			let rhs = rhs as? TypeExpression
		{
			return GryphonType.create(fromString: lhs.typeName)
				.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? TypeExpression,
			let rhs = rhs as? DeclarationReferenceExpression
		{
			guard declarationExpressionMatchesImplicitTypeExpression(rhs) else {
				return false
			}
			let expressionType = String(rhs.typeName.dropLast(".Type".count))
			return GryphonType.create(fromString: lhs.typeName)
				.isSubtype(of: GryphonType.create(fromString: expressionType))
		}
		if let lhs = lhs as? DeclarationReferenceExpression,
			let rhs = rhs as? TypeExpression
		{
			guard declarationExpressionMatchesImplicitTypeExpression(lhs) else {
				return false
			}
			let expressionType = String(lhs.typeName.dropLast(".Type".count))
			return GryphonType.create(fromString: expressionType)
				.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? SubscriptExpression,
			let rhs = rhs as? SubscriptExpression
		{
			return lhs.subscriptedExpression.matches(rhs.subscriptedExpression, matches)
				&& lhs.indexExpression.matches(rhs.indexExpression, matches)
				&& GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? ArrayExpression,
			let rhs = rhs as? ArrayExpression
		{
			var result = true
			for (leftElement, rightElement) in zipToClass(lhs.elements, rhs.elements) {
				result = result && leftElement.matches(rightElement, matches)
			}
			return result &&
				(GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName)))
		}
		if let lhs = lhs as? DotExpression,
			let rhs = rhs as? DotExpression
		{
			return lhs.leftExpression.matches(rhs.leftExpression, matches) &&
				lhs.rightExpression.matches(rhs.rightExpression, matches)
		}
		if let lhs = lhs as? BinaryOperatorExpression,
			let rhs = rhs as? BinaryOperatorExpression
		{
			return lhs.leftExpression.matches(rhs.leftExpression, matches) &&
				lhs.rightExpression.matches(rhs.rightExpression, matches) &&
				lhs.operatorSymbol == rhs.operatorSymbol &&
				GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? PrefixUnaryExpression,
			let rhs = rhs as? PrefixUnaryExpression
		{
			return lhs.subExpression.matches(rhs.subExpression, matches) &&
				lhs.operatorSymbol == rhs.operatorSymbol &&
				GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? PostfixUnaryExpression,
			let rhs = rhs as? PostfixUnaryExpression
		{
			return lhs.subExpression.matches(rhs.subExpression, matches) &&
				lhs.operatorSymbol == rhs.operatorSymbol &&
				GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? CallExpression,
			let rhs = rhs as? CallExpression
		{
			return lhs.function.matches(
				rhs.function, matches) &&
				lhs.parameters.matches(rhs.parameters, matches) &&
				GryphonType.create(fromString: lhs.typeName)
					.isSubtype(of: GryphonType.create(fromString: rhs.typeName))
		}
		if let lhs = lhs as? LiteralIntExpression,
			let rhs = rhs as? LiteralIntExpression
		{
			return lhs.value == rhs.value
		}
		if let lhs = lhs as? LiteralDoubleExpression,
			let rhs = rhs as? LiteralDoubleExpression
		{
			return lhs.value == rhs.value
		}
		if let lhs = lhs as? LiteralFloatExpression,
			let rhs = rhs as? LiteralFloatExpression
		{
			return lhs.value == rhs.value
		}
		if let lhs = lhs as? LiteralBoolExpression,
			let rhs = rhs as? LiteralBoolExpression
		{
			return lhs.value == rhs.value
		}
		if let lhs = lhs as? LiteralStringExpression,
			let rhs = rhs as? LiteralStringExpression
		{
			return lhs.value == rhs.value
		}
		if let lhs = lhs as? LiteralStringExpression,
			rhs is DeclarationReferenceExpression
		{
			let characterExpression = LiteralCharacterExpression(range: lhs.range, value: lhs.value)
			return characterExpression.matches(rhs, matches)
		}
		if lhs is NilLiteralExpression,
			rhs is NilLiteralExpression
		{
			return true
		}
		if let lhs = lhs as? InterpolatedStringLiteralExpression,
			let rhs = rhs as? InterpolatedStringLiteralExpression
		{
			var result = true
			for (leftExpression, rightExpression) in zipToClass(lhs.expressions, rhs.expressions) {
				result = result && leftExpression.matches(rightExpression, matches)
			}
			return result
		}
		if let lhs = lhs as? TupleExpression,
			let rhs = rhs as? TupleExpression
		{
			// Check manually for matches in trailing closures (that don't have labels in code
			// but do in templates)
			if lhs.pairs.count == 1,
				let onlyLeftPair = lhs.pairs.first,
				rhs.pairs.count == 1,
				let onlyRightPair = rhs.pairs.first
			{
				if let closureInParentheses = onlyLeftPair.expression as? ParenthesesExpression {
					if closureInParentheses.expression is ClosureExpression {
						// Unwrap a redundand parentheses expression if needed
						if let templateInParentheses =
							onlyRightPair.expression as? ParenthesesExpression
						{
							return closureInParentheses.expression.matches(
								templateInParentheses.expression, matches)
						}
						else {
							return closureInParentheses.expression.matches(
								onlyRightPair.expression, matches)
						}
					}
				}
			}

			var result = true
			for (leftPair, rightPair) in zip(lhs.pairs, rhs.pairs) {
				result = result &&
					leftPair.expression.matches(rightPair.expression, matches) &&
					leftPair.label == rightPair.label
			}
			return result
		}
		if let lhs = lhs as? TupleShuffleExpression,
			let rhs = rhs as? TupleShuffleExpression
		{
			var result = (lhs.labels == rhs.labels)

			for (leftIndex, rightIndex) in zip(lhs.indices, rhs.indices) {
				result = result && leftIndex == rightIndex
			}

			for (leftExpression, rightExpression) in zip(lhs.expressions, rhs.expressions) {
				result = result && leftExpression.matches(rightExpression, matches)
			}

			return result
		}

		// If no matches were found
		return false
	}

	///
	/// In a static context, some type expressions can be omitted. When that happens, they get
	/// translated as declaration references instead of type expressions. However, thwy should still
	/// match type expressions, as they're basically the same. This method should detect those
	/// cases.
	///
	/// Example:
	///
	/// ```
	/// class A {
	/// 	static func a() { }
	/// 	static func b() {
	/// 		a() // implicitly this is A.a(), and the implicit `A` gets dumped as a declaration
	/// 		// reference expression instead of a type expression.
	/// 	}
	/// ```
	///
	private func declarationExpressionMatchesImplicitTypeExpression(
		_ expression: DeclarationReferenceExpression) -> Bool
	{
		if expression.identifier == "self",
			expression.typeName.hasSuffix(".Type"),
			expression.isImplicit
		{
			return true
		}
		else {
			return false
		}
	}

	func isOfType(_ superTypeString: String) -> Bool {
		guard let typeName = self.swiftType else {
			return false
		}

		let selfType = GryphonType.create(fromString: typeName)
		let superType = GryphonType.create(fromString: superTypeString)

		return selfType.isSubtype(of: superType)
	}
}
