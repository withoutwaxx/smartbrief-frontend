//
//  ProjectCellTableViewCell.swift
//  
//
//  Created by Tom Rogers on 02/11/2017.
//
//

import UIKit

class UploadCell: UITableViewCell {
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var deleteButton: DeleteButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

}
