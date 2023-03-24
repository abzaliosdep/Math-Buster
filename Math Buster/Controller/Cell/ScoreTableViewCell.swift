//
//  ScoreTableViewCell.swift
//  Math Buster
//
//  Created by АБЗАЛ АБЗАЛ on 26.02.2023.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var scoreTextLabel: UILabel!
    
    static let identifier: String = "ScoreTableViewCellIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scoreTextLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scoreTextLabel.text = nil
    }
}
