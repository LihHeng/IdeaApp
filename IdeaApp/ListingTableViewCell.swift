//
//  ListingTableViewCell.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {

    @IBOutlet weak var IdeaLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
