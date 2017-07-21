//
//  InputCell.swift
//  WSToDoDemo
//
//  Created by WS on 2017/7/21.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

protocol InputCellDelegate: class {
    func inputChange(cell: InputCell, text: String)
}

class InputCell: UITableViewCell {
    
    public let inputTextField: UITextField = UITextField()
    weak var delegate: InputCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK:- layout
    private func configSubviews() {
        inputTextField.addTarget(self, action: #selector(textfieldValueDidChange), for: .editingChanged)
        self.addSubview(inputTextField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputTextField.frame = self.bounds
    }
//MARK:- tapped response
    @objc private func textfieldValueDidChange(textField: UITextField) {
        delegate?.inputChange(cell: self, text: textField.text ?? "")
    }

}

