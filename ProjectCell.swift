//
//  ProjectCellTableViewCell.swift
//  
//
//  Created by Tom Rogers on 02/11/2017.
//
//

import UIKit

class ProjectCell: UITableViewCell {
    
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var videoCount: UILabel!
    @IBOutlet weak var created: UILabel!
    
    @IBOutlet weak var readyValue: Circle!
    @IBOutlet weak var receivedValue: Circle!

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
