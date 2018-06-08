import Source

class GetterSetterKeywordBlockParser: Parser<GetterSetterKeywordBlock> {

    override func parse(start: LineColumn) -> GetterSetterKeywordBlock {
        var isWritable = false
        advance(if: .leftBrace)
        parseGetSet(isWritable: &isWritable)
        parseGetSet(isWritable: &isWritable)
        advance(if: .rightBrace)
        return createElement(start: start) { offset, length, text in
            return GetterSetterKeywordBlockImpl(
                text: text,
                children: [],
                offset: offset,
                length: length,
                isWritable: isWritable)
        } ?? GetterSetterKeywordBlockImpl.errorGetterSetterKeywordBlock
    }

    private func parseGetSet(isWritable: inout Bool) {
        _ = parseAttributes()
        _ = parseMutationModifiers()
        if isNext(.set) {
            isWritable = true
        }
        advance(if: [.get, .set])
    }
}