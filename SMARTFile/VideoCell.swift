//
//  ProjectCellTableViewCell.swift
//  
//
//  Created by Tom Rogers on 02/11/2017.
//
//

import UIKit

class VideoCell: UITableViewCell {
    
    

    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var uploaded: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var deleteVideo: DeleteButton!
    
    
    @IBAction func deleteVideoPressed(_ sender: Any) {
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
