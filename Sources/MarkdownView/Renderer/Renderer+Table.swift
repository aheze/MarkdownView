import Markdown
import SwiftUI

extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> Result {
        Result {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow { visitTableHead(table.head).content }
                visitTableBody(table.body).content
            }
            .overlay {
                Rectangle()
                    .stroke(configuration.tableOptions.strokeColor, lineWidth: configuration.tableOptions.strokeWidth)
            }
        }
    }

    mutating func visitTableHead(_ head: Markdown.Table.Head) -> Result {
        Result {
            let contents = contents(of: head)
            let font = configuration.fontGroup.tableHeader
            let foregroundStyle = configuration.foregroundStyleGroup.tableHeader
            let cellPadding = configuration.tableOptions.cellPadding

            ForEach(contents.indices, id: \.self) {
                contents[$0].content
                    .font(font)
                    .foregroundStyle(foregroundStyle)
                    .padding(cellPadding)
            }
        }
    }

    mutating func visitTableBody(_ body: Markdown.Table.Body) -> Result {
        Result {
            let contents = contents(of: body)
            let font = configuration.fontGroup.tableBody
            let foregroundStyle = configuration.foregroundStyleGroup.tableBody
            let cellPadding = configuration.tableOptions.cellPadding

            ForEach(contents.indices, id: \.self) {
                Divider()

                contents[$0].content
                    .font(font)
                    .foregroundStyle(foregroundStyle)
                    .padding(cellPadding)
            }
        }
    }

    mutating func visitTableRow(_ row: Markdown.Table.Row) -> Result {
        Result {
            let cells = row.children.map { $0 as! Markdown.Table.Cell }
            let contents = cells.map { visitTableCell($0) }
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                GridRow {
                    ForEach(contents.indices, id: \.self) { index in
                        let tableCell = cells[index]
                        contents[index].content
                            .gridColumnAlignment(tableCell.alignment)
                            .gridCellColumns(Int(tableCell.colspan))
                    }
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
