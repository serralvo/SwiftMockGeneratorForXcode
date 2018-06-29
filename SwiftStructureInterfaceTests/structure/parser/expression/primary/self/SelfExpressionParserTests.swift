import XCTest
@testable import SwiftStructureInterface

class SelfExpressionParserTests: XCTestCase {

    func test_shouldParseSelfOnItsOwn() throws {
        let text = "self"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
    }

    func test_shouldParseSelfMethodExpression() throws {
        let text = "self.identifier"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
        XCTAssert(expression is SelfMethodExpression)
    }

    func test_shouldParseSelfInitializerExpression() throws {
        let text = "self.init"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
        XCTAssert(expression is SelfInitializerExpression)
    }

    func test_shouldParseSelfSubscriptExpression() throws {
        let text = "self[a: expr, ++]"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
        XCTAssert(expression is SelfSubscriptExpression)
    }

    func test_shouldNotParseSubscriptWhenMissingLeadingSquare() {
        XCTAssertFalse(try parse("self expr]") is SelfSubscriptExpression)
    }

    func test_shouldParseSelfSubscriptExpressionMissingClosingSquare() throws {
        let text = "self[a: expr"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
        XCTAssert(expression is SelfSubscriptExpression)
    }

    func test_shouldParseSelfSubscriptExpressionMissingFunctionCallList() throws {
        let text = "self[]"
        let expression = try parse(text)
        XCTAssertEqual(expression.text, text)
        XCTAssert(expression is SelfSubscriptExpression)
    }

    private func parse(_ input: String) throws -> SelfExpression {
        return try createParser(input, SelfExpressionParser.self).parse()
    }
}
