import XCTest
@testable import SwiftStructureInterface

class TypeIdentifierParserTests: XCTestCase {

    // MARK: - parse

    func test_parse_shouldParseSimpleType() {
        assertTypeName("Type", "Type")
    }

    func test_parse_shouldParseEmptyTypeAsError() {
        let element = createParser("", TypeIdentifierParser.self).parse()
        XCTAssert(element === SwiftInheritedType.error)
    }

    // MARK: - Nested

    func test_parse_shouldParseNestedType() {
        assertTypeName("Swift.Type", "Swift.Type")
    }

    func test_parse_shouldParseDeeplyNestedType() {
        assertTypeName("Swift.Deep.Nested.Type", "Swift.Deep.Nested.Type")
    }

    // MARK: - Generic

    func test_parse_shouldParseGenericType() {
        assertTypeName("Generic<Type>", "Generic<Type>")
    }

    func test_parse_shouldNotParseNonGenericOperator() {
        assertTypeName("Generic|Type>", "Generic")
    }

    func test_parse_shouldParseNestedGenericType() {
        assertTypeName("Nested.Generic<Type>", "Nested.Generic<Type>")
        assertTypeName("Deep.Nested.Generic<Type>", "Deep.Nested.Generic<Type>")
    }

    func test_parse_shouldParseGenericTypeWithNestedInnerType() {
        assertTypeName("Generic<Nested.Type>", "Generic<Nested.Type>")
    }

    func test_parse_shouldParseIncompleteGenericType() {
        assertTypeName("Generic<", "Generic<")
    }

    func test_parse_shouldParseEmptyGenericType() {
        assertTypeName("Generic< >", "Generic<>")
    }

    func test_parse_shouldParseGenericWithMultipleArguments() {
        assertTypeName("Generic<A, B>", "Generic<A, B>")
    }

    func test_parse_shouldParseComplicatedType() {
        assertTypeName("Nested.Generic<With.Nested.Generic<Inside.Another>, Side.By<Side, Again>>", "Nested.Generic<With.Nested.Generic<Inside.Another>, Side.By<Side, Again>>")
    }

    func test_parse_shouldCalculateLengthWhenDifferentFormatting() {
        assertOffsetLength("A < B,C > next element", 0, 9)
    }

    func test_parse_shouldParseGenericWithArrayType() {
        assertTypeName("Generic<[Int]>", "Generic<[Int]>")
    }

    func test_parse_shouldParseGenericWithDictionaryType() {
        assertTypeName("Generic<[Int:String]>", "Generic<[Int:String]>")
    }

    // MARK: - Array

    func test_parse_shouldParseArray() {
        assertTypeName("[Int]", "[Int]")
    }

    func test_parse_shouldParseArrayWithNestedType() {
        assertTypeName("[Nested.Type]", "[Nested.Type]")
    }

    func test_parse_shouldParseArrayWithGenericType() {
        assertTypeName("[Generic<Type>]", "[Generic<Type>]")
        assertTypeName("[Nested.Generic<Nested.Type>]", "[Nested.Generic<Nested.Type>]")
    }

    func test_parse_shouldParseArrayWithEmptyType() {
        assertTypeName("[]", "[]")
    }

    func test_parse_shouldNotParseArrayWithBadClosingType() {
        assertTypeName("[Type)", "")
    }

    func test_parse_shouldParse3DArray() {
        assertTypeName("[[[Int]]]", "[[[Int]]]")
    }

    // MARK: - Dictionary

    func test_parse_shouldParseDictionary() {
        assertTypeName("[A:B]", "[A:B]")
    }

    func test_parse_shouldParseDictionaryWithNestedTypes() {
        assertTypeName("[A.B.C:D.E.F]", "[A.B.C:D.E.F]")
    }

    func test_parse_shouldParseDictionaryWithGenericTypes() {
        assertTypeName("[Generic<Type>:Generic<Type>]", "[Generic<Type>:Generic<Type>]")
    }

    func test_parse_shouldParseDictionaryWithArray() {
        assertTypeName("[[Int]:[String]]", "[[Int]:[String]]")
    }

    // MARK: - Optional

    func test_parse_shouldParseOptional() {
        assertTypeName("Int?", "Int?")
    }

    func test_parse_shouldParseNestedTypeOptional() {
        assertTypeName("A.B.C?", "A.B.C?")
    }

    func test_parse_shouldParseGenericOptional() {
        assertTypeName("Generic<Type>?", "Generic<Type>?")
    }

    func test_parse_shouldParseOptionalArray() {
        assertTypeName("[Int?]?", "[Int?]?")
    }

    func test_parse_shouldParseOptionalDictionary() {
        assertTypeName("[[String?:Int?]?:Int?]?", "[[String?:Int?]?:Int?]?")
    }

    func test_parse_shouldDoubleOptional() {
        assertTypeName("Int??", "Int??")
    }

    // MARK: - IUO

    func test_parse_shouldParseIUO() {
        assertTypeName("Int!", "Int!")
    }

    func test_parse_shouldParseNestedTypeIUO() {
        assertTypeName("A.B.C!", "A.B.C!")
    }

    func test_parse_shouldParseGenericIUO() {
        assertTypeName("Generic<Type>!", "Generic<Type>!")
    }

    func test_parse_shouldParseIUOArray() {
        assertTypeName("[Int!]!", "[Int!]!")
    }

    func test_parse_shouldParseIUODictionary() {
        assertTypeName("[[String!:Int!]!:Int!]!", "[[String!:Int!]!:Int!]!")
    }

    func test_parse_shouldDoubleIUO() {
        assertTypeName("Int!!", "Int!!")
    }

    // MARK: - Protocol composition

    func test_parse_shouldParseComposition() {
        assertTypeName("A & B", "A & B")
    }

    func test_parse_shouldNotParseIncomplete() {
        assertTypeName("A &", "A")
    }

    func test_parse_shouldNotParseIncorrectComposition() {
        assertTypeName("A & 0", "A")
    }

    func test_parse_shouldNotParseIncorrectBinaryOperator() {
        assertTypeName("A | B", "A")
    }

    func test_parse_shouldParseMultipleComposition() {
        assertTypeName("A & B & C & D", "A & B & C & D")
    }

    func test_parse_shouldParseWhenFirstIsCorrectButNextIsWrong() {
        assertTypeName("A & B | C", "A & B")
        assertTypeName("A & B & 0", "A & B & ")
    }

    // MARK: Keywords

    func test_parse_shouldParseAny() {
        assertTypeName("Any", "Any")
    }

    func test_parse_shouldParseSelf() {
        assertTypeName("Self", "Self")
    }

    // MARK: - Helpers

    func assertTypeName(_ input: String, _ expected: String, line: UInt = #line) {
        let element = createParser(input, TypeIdentifierParser.self).parse()
        XCTAssertEqual(element.name, expected, line: line)
    }

    func assertOffsetLength(_ input: String, _ expectedOffset: Int64, _ expectedLength: Int64, line: UInt = #line) {
        let element = createParser(input, TypeIdentifierParser.self).parse()
        XCTAssertEqual(element.offset, expectedOffset, line: line)
        XCTAssertEqual(element.length, expectedLength, line: line)
    }
}