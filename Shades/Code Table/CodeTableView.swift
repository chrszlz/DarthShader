//
//  CodeTableView.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public protocol CodeTableDelegate {
    func codeTable(_ table: CodeTableView, didSelect geometry: Geometry)
    func codeTable(_ table: CodeTableView, didUpdate shader: Shader)
}

open class CodeTableView: UITableViewController {
    
    /// String snippets of code that will be concatened, in-order
    /// to produce the final output shader.
    public var sections = [Section]()
    
    public var currentTextView: UITextView?
    
    /// Complete shader of snippet set.
    public var shader: Shader {
        return sections
            .items
            .compactMap { item in // [Shader]
                if case .code(let snippet) = item {
                    return snippet.code
                } else {
                    return nil
                }
            }
            .reduce("") { $0 + $1 } // Shader
    }
    
    private lazy var toolbar: InputToolbar = {
        let toolbar = InputToolbar()
        toolbar.delegate = self
        return toolbar
    }()
    
    public var delegate: CodeTableDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
        sharedInit()
    }
    
    private func sharedInit() {
        view.backgroundColor = .clear
        
        tableView.dataSource = self
        tableView.register(reusableCell: CodeCell.self)
        tableView.register(reusableCell: GeometryCell.self)
        tableView.register(reusableHeaderFooter: SectionHeaderView.self)
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }
    
}

// MARK: - UITableViewDataSource

extension CodeTableView {
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isCollapsed ? 0 : sections[section].items.count
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item {
        case .code(let snippet):
            let cell = tableView.dequeue(reusableCell: CodeCell.self, indexPath: indexPath)
            cell.code = snippet.code
            cell.delegate = self
            return cell
            
        case .geometry(let geometry):
            let cell = tableView.dequeue(reusableCell: GeometryCell.self, indexPath: indexPath)
            cell.model = geometry
            cell.delegate = self
            return cell
        }
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeue(reusableHeaderFooterCell: SectionHeaderView.self)
        header.titleLabel.text = sections[section].name
        header.section = section
        header.isCollapsed = sections[section].isCollapsed
        header.delegate = self
        return header
    }
    
}

extension CodeTableView: CodeCellDelegate {
    
    public func codeCellDidUpdateText(cell: CodeCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        // This is less-than ideal
        sections.write(cell.textView.text, to: indexPath)
        delegate?.codeTable(self, didUpdate: shader)
        
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    public func codeCell(cell: CodeCell, willBeginEditing textView: UITextView) {
        currentTextView = textView
        textView.inputAccessoryView = toolbar
    }
    
}

extension CodeTableView: GeometryCellDelegate {
    
    func geometryControlDidSelect(geometry: Geometry) {
        delegate?.codeTable(self, didSelect: geometry)
    }
    
}

extension CodeTableView: ToolbarDelegate {
    
    public func toolbarKeyPressed(_ toolbar: InputToolbar, key: InputToolbarKey, value: String) {
        currentTextView?.insertText(value)
    }
    
}

extension CodeTableView: SectionHeaderViewDelegate {
    
    public func toggleSection(_ header: SectionHeaderView, section: Int) {
        TapticEngine.selection.feedback()
        
        let isCollapsed = !sections[section].isCollapsed
        
        // Toggle collapse
        header.isCollapsed = isCollapsed
        sections[section].isCollapsed = isCollapsed
//        header.setCollapsed(isCollapsed)
        
        // Reload the whole section
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        tableView.endUpdates()
    }
    
}
