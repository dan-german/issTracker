import UIKit

class SwitchCell: UITableViewCell {
    
    
    //MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }
    
    //MARK: - UI
    
    let label = UILabel()
    
    let enableSwitch = UISwitch()
    
    func setupViews(){
        
        
        addSubview(label)
        addSubview(enableSwitch)
        
        addConstraintsWithVFL(views: label, VFL: "V:|[v0]|")
        addConstraintsWithVFL(views: label, VFL: "H:|-16-[v0]")
        
        addConstraintsWithVFL(views: enableSwitch, VFL: "V:|-7-[v0]|")
        addConstraintsWithVFL(views: enableSwitch, VFL: "H:[v0]-16-|")
    }
}
