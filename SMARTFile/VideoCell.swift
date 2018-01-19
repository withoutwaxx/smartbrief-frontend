//
//  ProjectCellTableViewCell.swift
//  
//
//  Created by Tom Rogers on 02/11/2017.
//
//

import UIKit

protocol videoCellDelegate: class {
    func deleteVideoPressed(index: IndexPath)
}

class VideoCell: UITableViewCell {
    
    var delegateCell:videoCellDelegate?
    var indexPath:IndexPath?

    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var uploaded: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var deleteVideo: DeleteButton!
    
    
    @IBAction func deleteVideoPressed(_ sender: Any) {
        delegateCell?.deleteVideoPressed(index: indexPath!)
        
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
