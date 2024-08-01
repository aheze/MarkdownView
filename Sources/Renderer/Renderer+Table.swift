import Markdown
import SwiftUI

extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> Result {
        Result {
            let strokeColor = configuration.tableOptions.strokeColor
            let strokeWidth = configuration.tableOptions.strokeWidth

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                visitTableHead(table.head).content
                visitTableBody(table.body).content
            }
            .backgroundPreferenceValue(VerticalBordersPreferenceKey.self) { preferences in
                GeometryReader { geometry in
                    ForEach(0 ..< preferences.count, id: \.self) { index in
                        let bounds = geometry[preferences[index]]

                        strokeColor
                            .frame(width: strokeWidth)
                            .frame(height: bounds.height)
                            .offset(x: bounds.minX - (strokeWidth * 0.5))
                            .offset(y: bounds.minY)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(strokeColor, lineWidth: strokeWidth)
            }
        }
    }

    mutating func visitTableHead(_ head: Markdown.Table.Head) -> Result {
        Result {
            let contents = contents(of: head)
            let font = configuration.fontGroup.tableHeader
            let foregroundStyle = configuration.foregroundStyleGroup.tableHeader
            let cellPadding = configuration.tableOptions.cellPadding

            GridRow {
                ForEach(contents.indices, id: \.self) { index in
                    contents[index].content
                        .font(font)
                        .foregroundStyle(foregroundStyle)
                        .padding(cellPadding)
                        .anchorPreference(key: VerticalBordersPreferenceKey.self, value: .bounds) { index == 0 ? [] : [$0] }
                }
            }
        }
    }

    mutating func visitTableBody(_ body: Markdown.Table.Body) -> Result {
        Result {
            let contents = contents(of: body)
            let font = configuration.fontGroup.tableBody
            let foregroundStyle = configuration.foregroundStyleGroup.tableBody
            let strokeColor = configuration.tableOptions.strokeColor
            let strokeWidth = configuration.tableOptions.strokeWidth

            ForEach(contents.indices, id: \.self) { index in
                Divider()

                contents[index].content
                    .font(font)
                    .foregroundStyle(foregroundStyle)
                    .background {
                        if index % 2 == 0 {
                            Color.primary
                                .opacity(0.02)
                        }
                    }
            }
        }
    }

    mutating func visitTableRow(_ row: Markdown.Table.Row) -> Result {
        Result {
            let cells = row.children.map { $0 as! Markdown.Table.Cell }
            let contents = cells.map { visitTableCell($0) }
            let cellPadding = configuration.tableOptions.cellPadding

            GridRow {
                ForEach(contents.indices, id: \.self) { index in
                    let tableCell = cells[index]
                    contents[index].content
                        .padding(cellPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .gridColumnAlignment(tableCell.alignment)
                        .gridCellColumns(Int(tableCell.colspan))
                        .anchorPreference(key: VerticalBordersPreferenceKey.self, value: .bounds) { index == 0 ? [] : [$0] }
                }
            }
        }
    }

    mutating func visitTableCell(_ cell: Markdown.Table.Cell) -> Result {
        Result(contents(of: cell), alignment: cell.alignment)
    }
}

// MARK: - Table Style

private struct _TableViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scenePadding()
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.quaternary, lineWidth: 2)
            }
    }
}

struct VerticalBordersPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGRect>]

    static var defaultValue: Value = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
