//
//  NASAFavouriteCell.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import UIKit

final class NASAFavouriteCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func configureWithData(data: NASADataModel) {
        titleLabel.text = data.title
        dateLabel.text = data.date
    }
}
